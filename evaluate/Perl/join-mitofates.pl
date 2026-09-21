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
my $reference_fn_arg = 0;
my $other_fn_arg = 0;

##  Data structures
my %reference_records;

##  Positions in the tab-separated input files
my $NAME_POS = 0;
my $METHOD_POS = 1;
my $PROTEIN_POS = 2;
my $SCORE_POS = 3;


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
$config -> define ("reference", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Reference filename
$config -> define ("other", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Other filename

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("reference"))) {
  printf STDERR "EE\tReference required with the --reference option!\n";
  exit (1);
}
$reference_fn_arg = $config -> get ("reference");

if (!defined ($config -> get ("other"))) {
  printf STDERR "EE\tOther required with the --other option!\n";
  exit (1);
}
$other_fn_arg = $config -> get ("other");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Reference file:  %s\n", $reference_fn_arg;
printf STDERR "==\t  Other file:  %s\n", $other_fn_arg;


########################################
##  Process the reference first
########################################

my $reference_count = 0;

open (my $reference_fp, "<", $reference_fn_arg) or die "EE\tThe file $reference_fn_arg could not be opened for input!\n";

my $header = <$reference_fp>;
while (<$reference_fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  my $reference_name = $tmp[$NAME_POS];

  if (defined ($reference_records{$reference_name})) {
    printf STDERR "EE\tDuplicate reference record found for [%s]!\n", $reference_name;
    exit (1);
  }

  $reference_records{$reference_name} = $line;
  $reference_count++;
}

close ($reference_fp);


########################################
##  Output header
########################################

printf STDOUT "Name";
printf STDOUT "\tMethod";
printf STDOUT "\tProtein";
printf STDOUT "\tReference";
printf STDOUT "\tOther";
printf STDOUT "\n";


########################################
##  Process the other next, and output it immediately
########################################

my $other_count = 0;

open (my $other_fp, "<", $other_fn_arg) or die "EE\tThe file $other_fn_arg could not be opened for input!\n";

$header = <$other_fp>;
while (<$other_fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  my $other_name = $tmp[$NAME_POS];
  my $other_method = $tmp[$METHOD_POS];
  my $other_protein = $tmp[$PROTEIN_POS];
  my $other_score = $tmp[$SCORE_POS];

  if (!defined ($reference_records{$other_name})) {
    printf STDERR "EE\tThe record %s could not be found in the reference!\n", $other_name;
    exit (1);
  }

  my @tmp2 = split /\t/, $reference_records{$other_name};
  my $reference_score = $tmp2[$SCORE_POS];

  printf STDOUT "%s", $other_name;
  printf STDOUT "\t%s", $other_method;
  printf STDOUT "\t%s", $other_protein;
  printf STDOUT "\t%s", $reference_score;
  printf STDOUT "\t%s", $other_score;
  printf STDOUT "\n";

  ##  Delete the hash value to make sure it is not used again
  delete ($reference_records{$other_name});

  $other_count++;
}

close ($other_fp);


########################################
##  Print out summary
########################################

printf STDERR "==\tNumber of reference records:  %u\n", $reference_count;
printf STDERR "==\t\tNumber of reference records remaining:  %u\n", scalar keys %reference_records;
printf STDERR "==\tNumber of other records:  %u\n", $other_count;

