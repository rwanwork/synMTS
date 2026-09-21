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
my $mitofates_fn_arg = 0;
my $hmoment_fn_arg = 0;

##  Data structures
my %hmoment_records;

##  Positions in the tab-separated input files
my $HMOMENT_NAME_POS = 0;
my $HMOMENT_METHOD_POS = 1;
my $HMOMENT_NUMPOS_POS = 3;

my $MITOFATES_NAME_POS = 0;
my $MITOFATES_METHOD_POS = 1;
my $MITOFATES_PROTEIN_POS = 2;
my $MITOFATES_PROBABILITY_POS = 3;


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
$config -> define ("mitofates", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  MitoFates filename
$config -> define ("hmoment", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  HMoment filename

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("mitofates"))) {
  printf STDERR "EE\tMitoFates filename required with the --mitofates option!\n";
  exit (1);
}
$mitofates_fn_arg = $config -> get ("mitofates");

if (!defined ($config -> get ("hmoment"))) {
  printf STDERR "EE\tHMoment filename required with the --hmoment option!\n";
  exit (1);
}
$hmoment_fn_arg = $config -> get ("hmoment");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  MitoFates file:  %s\n", $mitofates_fn_arg;
printf STDERR "==\t  HMoment file:  %s\n", $hmoment_fn_arg;


########################################
##  Process the hmoment file first
########################################

my $hmoment_count = 0;

open (my $hmoment_fp, "<", $hmoment_fn_arg) or die "EE\tThe file $hmoment_fn_arg could not be opened for input!\n";

my $header = <$hmoment_fp>;
chomp ($header);

my @tmp_hmoment_header = split /\t/, $header;
while (<$hmoment_fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  my $hmoment_name = $tmp[$HMOMENT_NAME_POS];

  if (defined ($hmoment_records{$hmoment_name})) {
    printf STDERR "EE\tDuplicate hmoment record found for [%s]!\n", $hmoment_name;
    exit (1);
  }

  $hmoment_records{$hmoment_name} = $line;
  $hmoment_count++;
}

close ($hmoment_fp);


########################################
##  Output header
########################################

printf STDOUT "Name";
printf STDOUT "\tMethod";
printf STDOUT "\tProtein";
printf STDOUT "\tMitoFates";
for (my $k = $HMOMENT_NUMPOS_POS; $k < scalar (@tmp_hmoment_header); $k++) {
  printf STDOUT "\t%s", $tmp_hmoment_header[$k];
}
printf STDOUT "\n";


########################################
##  Process the other next, and output it immediately
########################################

my $mitofates_count = 0;

open (my $mitofates_fp, "<", $mitofates_fn_arg) or die "EE\tThe file $mitofates_fn_arg could not be opened for input!\n";

$header = <$mitofates_fp>;
chomp ($header);

while (<$mitofates_fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  my $mitofates_name = $tmp[$MITOFATES_NAME_POS];
  my $mitofates_method = $tmp[$MITOFATES_METHOD_POS];
  my $mitofates_protein = $tmp[$MITOFATES_PROTEIN_POS];
  my $mitofates_probability = $tmp[$MITOFATES_PROBABILITY_POS];

  my $mitofates_name_prefix = "";

  if ($mitofates_name =~ /^(.+)_([^_]+)$/) {
    $mitofates_name_prefix = $1;
    if ($2 ne $mitofates_protein) {
      printf STDERR "EE\tCould not match the MitoFates protein [%s]!\n", $mitofates_name;
      exit (1);
    }
  }
  else {
    printf STDERR "EE\tCould not match the MitoFates name [%s]!\n", $mitofates_name;
    exit (1);
  }

  if (!defined ($hmoment_records{$mitofates_name_prefix})) {
    printf STDERR "EE\tThe record %s could not be found in the hmoment records!\n", $mitofates_name_prefix;
    exit (1);
  }

  my @tmp_hmoment = split /\t/, $hmoment_records{$mitofates_name_prefix};

  printf STDOUT "%s", $mitofates_name;
  printf STDOUT "\t%s", $mitofates_method;
  printf STDOUT "\t%s", $mitofates_protein;
  printf STDOUT "\t%s", $mitofates_probability;
  for (my $k = $HMOMENT_NUMPOS_POS; $k < scalar (@tmp_hmoment); $k++) {
    printf STDOUT "\t%s", $tmp_hmoment[$k];
  }
  printf STDOUT "\n";

  $mitofates_count++;
}

close ($mitofates_fp);


########################################
##  Print out summary
########################################

printf STDERR "==\tNumber of HMoment records:  %u\n", $hmoment_count;
printf STDERR "==\tNumber of MitoFates records:  %u\n", $mitofates_count;

