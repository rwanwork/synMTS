#!/usr/bin/env perl
# Copyright 2026 Raymond Wan (rwan.work@gmail.com)
#   https://github.com/rwanwork/synMTS
#
# This file is part of synMTS.
#
# synMTS is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# synMTS is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.



use FindBin;
use lib $FindBin::Bin;  ##  Search the directory where the script is located

use diagnostics;
use strict;
use warnings;

##  Include libraries for handling arguments and documentation
use AppConfig;
use AppConfig::Getopt;
use Pod::Usage;

##  Directories where Perl modules are stored
use lib qw (. ../Common/Perl/ ../../Common/Perl/);


########################################
##  Important variables
########################################

##  Input arguments
my $protein_arg = "";
my $select_fn_arg = "";
my $properties_fn_arg = "";
my $deepmito_fn_arg = "";
my $mitofates_fn_arg = "";
my $hmoment_fn_arg = "";

##  Data structures
my %ids_to_properties;
my %ids_to_deepmito;
my %ids_to_mitofates;
my %ids_to_hmoment_maximum;
my %ids_to_hmoment_topavg;
my %ids_to_hmoment_allavg;
my %ids_to_categories;

my @output_all;

my $SELECT_NAME_POS = 0;
my $PROPERTIES_NAME_POS = 0;

my $DEEPMITO_NAME_POS = 0;
my $DEEPMITO_PROTEIN_POS = 2;
my $DEEPMITO_SCORE_POS = 4;

my $MITOFATES_NAME_POS = 0;
my $MITOFATES_PROTEIN_POS = 2;
my $MITOFATES_SCORE_POS = 3;

my $HMOMENT_NAME_POS = 0;
my $HMOMENT_MAXIMUM_POS = 4;
my $HMOMENT_TOPAVG_POS = 7;
my $HMOMENT_ALLAVG_POS = 10;


########################################
##  Process arguments
########################################

##  Create AppConfig and AppConfig::Getopt objects
my $config = AppConfig -> new ({
  GLOBAL => {
    DEFAULT => undef,      ##  Default value for new variables
  }
});

my $getopt = AppConfig::Getopt -> new ($config);

##  General program options
$config -> define ("help!", {
  ARGCOUNT => AppConfig::ARGCOUNT_NONE
});                        ##  Help screen

##  Program parameters
$config -> define ("protein", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Name of protein
$config -> define ("select", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of identifiers to select
$config -> define ("properties", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of input properties
$config -> define ("deepmito", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of DeepMito data
$config -> define ("mitofates", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of MitoFates data
$config -> define ("hmoment", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of HMoment data


##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("protein"))) {
  printf STDERR "EE\tProtein required with the --protein option!\n";
  exit (1);
}
$protein_arg = $config -> get ("protein");

if (!defined ($config -> get ("select"))) {
  printf STDERR "EE\tIdentifiers to select required with the --select option!\n";
  exit (1);
}
$select_fn_arg = $config -> get ("select");

if (!defined ($config -> get ("properties"))) {
  printf STDERR "EE\tProperties required with the --properties option!\n";
  exit (1);
}
$properties_fn_arg = $config -> get ("properties");

if (!defined ($config -> get ("deepmito"))) {
  printf STDERR "EE\tDeepMito file required with the --deepmito option!\n";
  exit (1);
}
$deepmito_fn_arg = $config -> get ("deepmito");

if (!defined ($config -> get ("mitofates"))) {
  printf STDERR "EE\tMitoFates file required with the --mitofates option!\n";
  exit (1);
}
$mitofates_fn_arg = $config -> get ("mitofates");

if (!defined ($config -> get ("hmoment"))) {
  printf STDERR "EE\tHMoment file required with the --hmoment option!\n";
  exit (1);
}
$hmoment_fn_arg = $config -> get ("hmoment");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Protein:  %s\n", $protein_arg;
printf STDERR "==\t  Input selection file:  %s\n", $select_fn_arg;
printf STDERR "==\t  Input properties file:  %s\n", $properties_fn_arg;
printf STDERR "==\t  Input MitoFates file:  %s\n", $mitofates_fn_arg;
printf STDERR "==\t  Input DeepMito file:  %s\n", $deepmito_fn_arg;
printf STDERR "==\t  Input HMoment file:  %s\n", $hmoment_fn_arg;


########################################
##  Read in the selection file
########################################

my $pos = 0;
my $duplicates = 0;

my $num_positive = 0;
my $num_negative = 0;
my $num_na = 0;

open (my $select_fp, "<", $select_fn_arg) or die "EE\tCould not open $select_fn_arg for input!\n";

##  Remove the header
my $select_header = <$select_fp>;
chomp ($select_header);
my @select_header_array = split /\t/, $select_header;

my $column_of_interest = 0;

##  Determine which column we want
for (my $k = 1; $k < scalar (@select_header_array); $k++) {
  if ($select_header_array[$k] eq $protein_arg) {
    $column_of_interest = $k;
  }
}

if ($column_of_interest == 0) {
  printf STDERR "EE\tColumn of interest in %s could not be found!\n", $select_fn_arg;
  exit (1);
}
printf STDERR "==\tColumn of interest:  %u\n", $column_of_interest;

while (<$select_fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  my $name = $tmp[$SELECT_NAME_POS];

  if (defined ($ids_to_properties{$name})) {
    printf STDERR "WW\tDuplicate ID [%s] found in selection file!\n", $name;
    $duplicates++;
    next;
  }

  if ($tmp[$column_of_interest] eq "++") {
    $ids_to_categories{$name} = 1;
    push (@output_all, $name);
    $num_positive++;
  }
  elsif ($tmp[$column_of_interest] eq "+") {
    ##  Not retained
    $num_na++;
  }
  elsif ($tmp[$column_of_interest] eq "N/A") {
    ##  Not retained
    $num_na++;
  }
  elsif ($tmp[$column_of_interest] eq "-") {
    $ids_to_categories{$name} = 0;
    push (@output_all, $name);
    $num_negative++;
  }
  else {
    printf STDERR "EE\tInvalid category value [%s] for record [%s] in column [%s]!\n", $tmp[$column_of_interest], $name, $select_header_array[$column_of_interest];
    exit (1);
  }

  $ids_to_properties{$name} = 1;
  $ids_to_deepmito{$name} = 1;
  $ids_to_mitofates{$name} = 1;

  $ids_to_hmoment_maximum{$name} = 1;
  $ids_to_hmoment_topavg{$name} = 1;
  $ids_to_hmoment_allavg{$name} = 1;

  $pos++;
}
close ($select_fp);

printf STDERR "==\tTotal number of records to select:  %u\n", $pos;
printf STDERR "==\t  Number of duplicates:  %u\n", $duplicates;
printf STDERR "==\t  Categories:\n";
printf STDERR "==\t    1 (Yes):  %u\n", $num_positive;
printf STDERR "==\t    0 (No):  %u\n", $num_negative;
printf STDERR "==\t    N/A:  %u\n", $num_na;



########################################
##  Scan through the properties file
########################################

my $properties_count = 0;
my $properties_found = 0;

open (my $properties_fp, "<", $properties_fn_arg) or die "EE\tCould not open $properties_fn_arg for input!\n";

my $properties_header = <$properties_fp>;
chomp ($properties_header);

while (<$properties_fp>) {
  my $record = $_;
  chomp ($record);

  my @tmp = split /\t/, $record;
  my $curr_name = $tmp[$PROPERTIES_NAME_POS];

  if (defined ($ids_to_properties{$curr_name})) {
    $ids_to_properties{$curr_name} = $record;
    $properties_found++;
  }

  $properties_count++;
}

close ($properties_fp);

printf STDERR "==\tNumber of properties records processed:  %u\n", $properties_count;
printf STDERR "==\t  Number found:  %u\n", $properties_found;

if ($pos != $properties_found) {
  printf STDERR "EE\tUnexpected error -- not all %u records were found (properties)!\n", $pos;
  exit (1);
}


########################################
##  Read in the mitofates file
########################################

my $mitofates_count = 0;
my $mitofates_found = 0;

open (my $mitofates_fp, "<", $mitofates_fn_arg) or die "EE\tCould not open $mitofates_fn_arg for input!\n";

my $mitofates_header = <$mitofates_fp>;
chomp ($mitofates_header);

while (<$mitofates_fp>) {
  my $record = $_;
  chomp ($record);

  my @tmp = split /\t/, $record;
  my $record_name = $tmp[$MITOFATES_NAME_POS];
  my $record_protein = $tmp[$MITOFATES_PROTEIN_POS];
  my $record_score = $tmp[$MITOFATES_SCORE_POS];

  if ($record_protein ne $protein_arg) {
    next;
  }

  if ($record_name =~ /^(.+)_([^_]*)$/) {
    my $prefix = $1;
    my $suffix = $2;

    if ($suffix ne $record_protein) {
      printf STDERR "EE\tExpected protein suffix [%s] for the protein [%s]!\n", $record_protein, $record_name;
      exit (1);
    }

    $record_name = $prefix;


    if (defined ($ids_to_mitofates{$record_name})) {
      $ids_to_mitofates{$record_name} = $record_score;
      $mitofates_found++;
    }
  }

  $mitofates_count++;
}

close ($mitofates_fp);

printf STDERR "==\tNumber of MitoFates records for %s processed:  %u\n", $protein_arg, $mitofates_count;
printf STDERR "==\t  Number found:  %u\n", $mitofates_found;

if ($pos != $mitofates_found) {
  printf STDERR "EE\tUnexpected error -- not all %u records were found (MitoFates)!\n", $pos;
  exit (1);
}


########################################
##  Read in the deepmito file
########################################

my $deepmito_count = 0;
my $deepmito_found = 0;

open (my $deepmito_fp, "<", $deepmito_fn_arg) or die "EE\tCould not open $deepmito_fn_arg for input!\n";

my $deepmito_header = <$deepmito_fp>;
chomp ($deepmito_header);

while (<$deepmito_fp>) {
  my $record = $_;
  chomp ($record);

  my @tmp = split /\t/, $record;
  my $record_name = $tmp[$DEEPMITO_NAME_POS];
  my $record_protein = $tmp[$DEEPMITO_PROTEIN_POS];
  my $record_score = $tmp[$DEEPMITO_SCORE_POS];

  if ($record_protein ne $protein_arg) {
    next;
  }

  if ($record_name =~ /^(.+)_([^_]*)$/) {
    my $prefix = $1;
    my $suffix = $2;

    if ($suffix ne $record_protein) {
      printf STDERR "EE\tExpected protein suffix [%s] for the protein [%s]!\n", $record_protein, $record_name;
      exit (1);
    }

    $record_name = $prefix;

    if (defined ($ids_to_deepmito{$record_name})) {
      $ids_to_deepmito{$record_name} = $record_score;
      $deepmito_found++;
    }
  }

  $deepmito_count++;
}

close ($deepmito_fp);

printf STDERR "==\tNumber of DeepMito records for %s processed:  %u\n", $protein_arg, $deepmito_count;
printf STDERR "==\t  Number found:  %u\n", $deepmito_found;

if ($pos != $deepmito_found) {
  printf STDERR "EE\tUnexpected error -- not all %u records were found (DeepMito)!\n", $pos;
  exit (1);
}


########################################
##  Read in the hmoment file
########################################

my $hmoment_count = 0;
my $hmoment_found = 0;

open (my $hmoment_fp, "<", $hmoment_fn_arg) or die "EE\tCould not open $hmoment_fn_arg for input!\n";

my $hmoment_header = <$hmoment_fp>;
chomp ($hmoment_header);

##  Check the header to make sure we are taking the right columns
my @hmoment_header_tmp = split /\t/, $hmoment_header;
if ($hmoment_header_tmp[$HMOMENT_NAME_POS] ne "Name") {
  printf STDERR "EE\tUnexpected column name [%s] in HMoment header [%s]!\n", $hmoment_header_tmp[$HMOMENT_NAME_POS], $hmoment_header;
  exit (1);
}

if ($hmoment_header_tmp[$HMOMENT_MAXIMUM_POS] ne "Maximum") {
  printf STDERR "EE\tUnexpected column name [%s] in HMoment header [%s]!\n", $hmoment_header_tmp[$HMOMENT_MAXIMUM_POS], $hmoment_header;
  exit (1);
}

if ($hmoment_header_tmp[$HMOMENT_TOPAVG_POS] ne "TopAvg") {
  printf STDERR "EE\tUnexpected column name [%s] in HMoment header [%s]!\n", $hmoment_header_tmp[$HMOMENT_TOPAVG_POS], $hmoment_header;
  exit (1);
}

if ($hmoment_header_tmp[$HMOMENT_ALLAVG_POS] ne "AllAvg") {
  printf STDERR "EE\tUnexpected column name [%s] in HMoment header [%s]!\n", $hmoment_header_tmp[$HMOMENT_ALLAVG_POS], $hmoment_header;
  exit (1);
}

while (<$hmoment_fp>) {
  my $record = $_;
  chomp ($record);

  my @tmp = split /\t/, $record;

  my $record_name = $tmp[$HMOMENT_NAME_POS];
  my $record_maximum = $tmp[$HMOMENT_MAXIMUM_POS];
  my $record_topavg = $tmp[$HMOMENT_TOPAVG_POS];
  my $record_allavg = $tmp[$HMOMENT_ALLAVG_POS];

  if (defined ($ids_to_hmoment_maximum{$record_name})) {
    $ids_to_hmoment_maximum{$record_name} = $record_maximum;
    $ids_to_hmoment_topavg{$record_name} = $record_topavg;
    $ids_to_hmoment_allavg{$record_name} = $record_allavg;
    $hmoment_found++;
  }

  $hmoment_count++;
}

close ($deepmito_fp);

printf STDERR "==\tNumber of HMoment records processed:  %u\n", $hmoment_count;
printf STDERR "==\t  Number found:  %u\n", $hmoment_found;

if ($pos != $hmoment_found) {
  printf STDERR "EE\tUnexpected error -- not all %u records were found (HMoment)!\n", $pos;
  exit (1);
}


########################################
##  Print the records out in the order defined by the array
########################################

##  Only check for the existence of a record in @output_all since the other arrays are subsets of this one

printf STDOUT "%s", $properties_header;
printf STDOUT "\tMitoFates";
printf STDOUT "\tDeepMito";
printf STDOUT "\thmoment-maximum";
printf STDOUT "\thmoment-topavg";
printf STDOUT "\thmoment-allavg";
printf STDOUT "\tCategory";
printf STDOUT "\n";

for (my $k = 0; $k < scalar (@output_all); $k++) {
  if (!defined ($ids_to_properties{$output_all[$k]})) {
    printf STDERR "EE\tUnexpected error -- ID [%s] could not be found!\n", $output_all[$k];
    exit (1);
  }

  printf STDOUT "%s", $ids_to_properties{$output_all[$k]};
  printf STDOUT "\t%s", $ids_to_mitofates{$output_all[$k]};
  printf STDOUT "\t%s", $ids_to_deepmito{$output_all[$k]};
  printf STDOUT "\t%s", $ids_to_hmoment_maximum{$output_all[$k]};
  printf STDOUT "\t%s", $ids_to_hmoment_topavg{$output_all[$k]};
  printf STDOUT "\t%s", $ids_to_hmoment_allavg{$output_all[$k]};
  printf STDOUT "\t%s", $ids_to_categories{$output_all[$k]};
  printf STDOUT "\n";
}
