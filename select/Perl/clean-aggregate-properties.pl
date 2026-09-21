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

##  Number of samples not yet set
my $UNSET = -1;

##  Positions in the input file
my $NAME_POS = 1;
my $MEAN_POSITIVE_POS = 2;
my $SD_POSITIVE_POS = 3;
my $NUM_POSITIVE_POS = 4;
my $MEAN_NEGATIVE_POS = 5;
my $SD_NEGATIVE_POS = 6;
my $NUM_NEGATIVE_POS = 7;
my $PVALUE_POS = 8;


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
});                        ##  Name of protein

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


########################################
##  Read in and process the file
########################################

my $num_positive = $UNSET;
my $num_negative = $UNSET;

printf STDOUT "\\begin{table}\n";
printf STDOUT "\\centering\n";
printf STDOUT "\\begin{tabular}{lccc}\n";
printf STDOUT "\\hline\n";
printf STDOUT "& Positive (mean \$\\pm\$ SD) & Negative (mean \$\\pm\$ SD) & p value \\\\ \n";
printf STDOUT "\\hline\n";

while (<STDIN>) {
  my $line = $_;
  chomp ($line);

  $line =~ s/\"//gs;  ##  Remove quotes

  ##  Can skip the first row
  if ($line =~ /^variable/) {
    if ($. != 1) {
      printf STDERR "EE\tUnexpected header row is not the first row, but is row #%u!\n", $.;
      exit (1);
    }
    next;
  }

  my @tmp = split /\t/, $line;

  if ($num_positive == $UNSET) {
    $num_positive = $tmp[$NUM_POSITIVE_POS];
    $num_negative = $tmp[$NUM_NEGATIVE_POS];
    printf "n & %u & %u & \\\\\n", $num_positive, $num_negative;
  }
  else {
    if (($num_positive != $tmp[$NUM_POSITIVE_POS]) || ($num_negative != $tmp[$NUM_NEGATIVE_POS])) {
      printf STDERR "EE\tUnexpected mismatch in the number of samples:  ++ (%u); - (%u); [%s]!\n", $num_positive, $num_negative, $line;
      exit (1);
    }
  }

  if (($tmp[1] eq "Length") ||
      ($tmp[1] eq "charge_sum") ||
      ($tmp[1] eq "krcount_avg") ||
      ($tmp[1] eq "krcount_sum") ||
      ($tmp[1] eq "MitoFates") ||
      ($tmp[1] eq "DeepMito") ||
      ($tmp[1] eq "hmoment.maximum") ||
      ($tmp[1] eq "hmoment.topavg") ||
      ($tmp[1] eq "hmoment.allavg")
      ) {

    if ($tmp[1] eq "hmoment.maximum") {
      $tmp[1] = "{\\textmu}Hmax";
    }
    elsif ($tmp[1] eq "hmoment.topavg") {
      $tmp[1] = "Average of top 10\\% of {\\textmu}H";
    }
    elsif ($tmp[1] eq "hmoment.allavg") {
      $tmp[1] = "{\\textmu}Hmean";
    }

    $tmp[1] =~ s/_/\\_/gs;  ##  Add \\ to underscores

    printf "%s & ", $tmp[$NAME_POS];

    printf " \$ %.3f \\pm", $tmp[$MEAN_POSITIVE_POS];
    printf " %.3f \$ & ", $tmp[$SD_POSITIVE_POS];
    printf " \$ %.3f \\pm", $tmp[$MEAN_NEGATIVE_POS];
    printf " %.3f \$ & ", $tmp[$SD_NEGATIVE_POS];
    printf " \$ %.3f \$ ", $tmp[$PVALUE_POS];
    printf "\\\\";

    printf "\n";
  }
}

printf STDOUT "\\hline\n";
printf STDOUT "\\end{tabular}\n";
printf STDOUT "\\caption[\\propshort{%s}]{\\label{tab:properties-%s}\\proplong{%s}.}\n", $protein_arg, $protein_arg, $protein_arg;
printf STDOUT "\\end{table}\n";

