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

##  Include library for handling arguments and documentation
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
my $mtspath_fn_arg = "";

##  Data structures


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
$config -> define ("protein", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Protein of interest
$config -> define ("mtspath", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Unprocessed path to the MTS HMoment files

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
  printf STDERR "EE\tProtein of interest required with the --protein option!\n";
  exit (1);
}
$protein_arg = $config -> get ("protein");

if (!defined ($config -> get ("mtspath"))) {
  printf STDERR "EE\tPath to the completion file in the HMoment summary directory required with the --mtspath option!\n";
  exit (1);
}
$mtspath_fn_arg = $config -> get ("mtspath");


########################################
##  Correct the MTS path
########################################

my $mtspath = "";
if ($mtspath_fn_arg =~ /^(.+)\/mts-hmoment.done$/) {
  $mtspath = $1."/";
}
else {
  printf STDERR "EE\tCould not match the MTS path [%s]!\n", $mtspath_fn_arg;
  exit (1);
}

########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Protein of interest:  %s\n", $protein_arg;
printf STDERR "==\t  Files:\n";
printf STDERR "==\t    MTS path (unprocessed):  %s\n", $mtspath_fn_arg;
printf STDERR "==\t    MTS path (final):        %s\n", $mtspath;
printf STDERR "\n";


########################################
##  Read in the input file and process a line at a time
########################################

my $header = <STDIN>;
chomp ($header);

$header = $header."\tMaxHMoment\tTopHMoment_avg\tAllHMoment_avg";
printf STDOUT "%s\n", $header;

my $HMOMENT_MAX_POS = 1;
my $HMOMENT_TOP_AVG_POS = 4;
my $HMOMENT_TOP_MEDIAN_POS = 5;
my $HMOMENT_ALL_AVG_POS = 7;
my $HMOMENT_ALL_MEDIAN_POS = 8;

while (<STDIN>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  my $curr_synmts = $tmp[0];

  my $curr_fn = $mtspath.$curr_synmts.".tsv";

  open (my $curr_fp, "<", $curr_fn) or die "EE\tCould not open $curr_fn for input!\n";

  my $curr_fp_header = <$curr_fp>;
  chomp ($curr_fp_header);
  my $curr_fp_data = <$curr_fp>;
  chomp ($curr_fp_data);

  my @curr_fp_tmp = split /\t/, $curr_fp_data;

  printf STDOUT "%s", $line;
  printf STDOUT "\t%.3f", $curr_fp_tmp[$HMOMENT_MAX_POS];
  printf STDOUT "\t%.3f", $curr_fp_tmp[$HMOMENT_TOP_AVG_POS];
  printf STDOUT "\t%.3f", $curr_fp_tmp[$HMOMENT_ALL_AVG_POS];
  printf STDOUT "\n";

  close ($curr_fp);
}



