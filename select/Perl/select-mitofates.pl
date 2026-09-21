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
my $mitofates_fn_arg = "";

##  Data structures
my %ids_to_record;
my @output_order;

##  Positions in the MitoFates file
my $MITOFATES_NAME = 0;
my $MITOFATES_PROTEIN = 2;
my $MITOFATES_PROBABILITY = 3;
my $MITOFATES_PREDICTION = 4;


########################################
##  Subroutines
########################################

sub RemoveProtein {
  my ($name) = @_;

  if ($name =~ /^(.+)_([^_]+)$/) {
    $name = $1;
  }
  else {
    printf STDERR "EE\tCould not match the record ID [%s]!\n", $name;
    exit (1);
  }

  return ($name);
}


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
});                        ##  Protein to select
$config -> define ("select", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of identifiers to select
$config -> define ("mitofates", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  MitoFates file

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
  printf STDERR "EE\tProtein name required with the --protein option!\n";
  exit (1);
}
$protein_arg = $config -> get ("protein");

if (!defined ($config -> get ("select"))) {
  printf STDERR "EE\tIdentifiers to select required with the --select option!\n";
  exit (1);
}
$select_fn_arg = $config -> get ("select");

if (!defined ($config -> get ("mitofates"))) {
  printf STDERR "EE\tMitoFates file required with the --mitofates option!\n";
  exit (1);
}
$mitofates_fn_arg = $config -> get ("mitofates");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Protein:  %s\n", $protein_arg;
printf STDERR "==\t  Selection file:  %s\n", $select_fn_arg;
printf STDERR "==\t  MitoFates file:  %s\n", $mitofates_fn_arg;


########################################
##  Read in the selection file
########################################

my $pos = 0;
my $duplicates = 0;

open (my $select_fp, "<", $select_fn_arg) or die "EE\tCould not open $select_fn_arg for input!\n";

##  Remove the header
my $select_header = <$select_fp>;

while (<$select_fp>) {
  my $line = $_;
  chomp ($line);

  my ($name, $cherry, $iqc, $cox4, $cox2) = split /\t/, $line;

  ##  Only focus on the protein provided as an argument
  # if ($protein ne $protein_arg) {
  #   next;
  # }

  if (defined ($ids_to_record{$name})) {
    printf STDERR "WW\tDuplicate ID [%s] found in selection file!\n", $name;
    $duplicates++;
    next;
  }

  $ids_to_record{$name} = 1;
  push (@output_order, $name);
  $pos++;
}
close ($select_fp);

printf STDERR "==\tNumber of records to select:  %u\n", $pos;
printf STDERR "==\t  Number of duplicates:  %u\n", $duplicates;


########################################
##  Scan through the records
########################################

my $records_protein = 0;
my $records_total = 0;
my $records_found = 0;

open (my $mitofates_fp, "<", $mitofates_fn_arg) or die "EE\tCould not open $mitofates_fn_arg for input!\n";
while (<$mitofates_fp>) {
  my $line = $_;
  chomp ($line);
  $records_total++;

  my @tmp = split /\t/, $line;
  if ($tmp[$MITOFATES_PROTEIN] ne $protein_arg) {
    next;
  }

  my $id = RemoveProtein ($tmp[$MITOFATES_NAME]);
  if (defined ($ids_to_record{$id})) {
    printf STDERR "II\tFound [%s]!\n", $id;

    $ids_to_record{$id} = $line;
    $records_found++;
  }

  $records_protein++;
}
close ($mitofates_fp);

printf STDERR "==\tTotal number of records processed:  %u\n", $records_total;
printf STDERR "==\t  Records found with %s:  %u\n", $protein_arg, $records_protein;
printf STDERR "==\t  Records found matching selection criteria:  %u\n", $records_found;


########################################
##  Print the records out in the order defined by @output_order
########################################

for (my $k = 0; $k < scalar (@output_order); $k++) {
  if (!defined ($ids_to_record{$output_order[$k]})) {
    printf STDERR "EE\tUnexpected error -- ID [%s] could not be found!\n", $output_order[$k];
    exit (1);
  }

  my @tmp = split /\t/, $ids_to_record{$output_order[$k]};

  printf "%s", RemoveProtein ($tmp[$MITOFATES_NAME]);
  printf "\t%s", $tmp[$MITOFATES_PREDICTION];
  printf "\t%s", $tmp[$MITOFATES_PROBABILITY];
  printf "\n";
}


