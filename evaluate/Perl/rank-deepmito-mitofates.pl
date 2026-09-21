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

use Access_DeepMito;
use Access_MitoFates;


########################################
##  Important variables
########################################

##  Input arguments
my $deepmito_fn_arg = "";
my $mitofates_fn_arg = "";
my $ranks_str_arg = "";
my $methods_str_arg = "";
my $shownames_arg = 0;
my $debug_arg = 0;

##  Data structures
my @deepmito;
my @mitofates;


########################################
##  Subroutines
########################################

##  Sort using explicit subroutine name on the scores
sub deepmito_cmpfn {
  my $x = GetDeepMitoScore ($a);
  my $y = GetDeepMitoScore ($b);

  ##  Numerical sort in decreasing order
  $y <=> $x;
}


##  Sort using explicit subroutine name on the probability
sub mitofates_cmpfn {
  my $x = GetMitoFatesProbability ($a);
  my $y = GetMitoFatesProbability ($b);

  ##  Numerical sort in decreasing order
  $y <=> $x;
}


##  Remove the protein name at the end in order to do a
##  comparison; the protein name must not have an
##  underscore!
sub TrimOffProtein {
  my ($id) = @_;
  my $trim_id = "";

  if ($id =~ /^(.+)_([^_]+)$/) {
    $trim_id = $1;
  }

  return ($trim_id);
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
$config -> define ("debug!", {
  ARGCOUNT => AppConfig::ARGCOUNT_NONE
});                        ##  Debug mode
$config -> define ("deepmito", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of DeepMito output
$config -> define ("mitofates", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of MitoFates' output
$config -> define ("ranks", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  List of comma separated ranks
$config -> define ("methods", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  List of comma separated methods
$config -> define ("shownames!", {
  ARGCOUNT => AppConfig::ARGCOUNT_NONE
});                        ##  Show names of overlaps

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

$debug_arg = 0;
if ($config -> get ("debug")) {
  $debug_arg = 1;
}

if (!defined ($config -> get ("deepmito"))) {
  printf STDERR "EE\tDeepMito output required with the --deepmito option!\n";
  exit (1);
}
$deepmito_fn_arg = $config -> get ("deepmito");

if (!defined ($config -> get ("mitofates"))) {
  printf STDERR "EE\tMitoFates output required with the --mitofates option!\n";
  exit (1);
}
$mitofates_fn_arg = $config -> get ("mitofates");

if (!defined ($config -> get ("ranks"))) {
  printf STDERR "EE\tComma-separated list of ranks required with the --ranks option!\n";
  exit (1);
}
$ranks_str_arg = $config -> get ("ranks");

if (!defined ($config -> get ("methods"))) {
  printf STDERR "EE\tComma-separated list of methods required with the --methods option!\n";
  exit (1);
}
$methods_str_arg = $config -> get ("methods");


########################################
##  Validate the settings (optional arguments)
########################################

$shownames_arg = 0;
if ($config -> get ("shownames")) {
  $shownames_arg = 1;
}


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  DeepMito filename:  %s\n", $deepmito_fn_arg;
printf STDERR "==\t  MitoFates filename:  %s\n", $mitofates_fn_arg;
printf STDERR "==\t  List of ranks:  %s\n", $ranks_str_arg;
printf STDERR "==\t  List of methods:  %s\n", $methods_str_arg;
printf STDERR "==\tOptional arguments:\n";
if ($shownames_arg == 1) {
  printf STDERR "==\t  Show sequence names:  Yes\n";
}
else {
  printf STDERR "==\t  Show sequence names:  No\n";
}


########################################
##  Read in the DeepMito file
########################################

my $deepmito_count = 0;
open (my $deepmito_fp, "<", $deepmito_fn_arg) or die "EE\tCould not open $deepmito_fn_arg for input!\n";
my $header = <$deepmito_fp>;  ##  Discard the header
while (<$deepmito_fp>) {
  my $line = $_;
  chomp ($line);

  push (@deepmito, $line);
  $deepmito_count++;
}
close ($deepmito_fp);


########################################
##  Read in the MitoFates file
########################################

my $mitofates_count = 0;
open (my $mitofates_fp, "<", $mitofates_fn_arg) or die "EE\tCould not open $mitofates_fn_arg for input!\n";
$header = <$mitofates_fp>;  ##  Discard the header
while (<$mitofates_fp>) {
  my $line = $_;
  chomp ($line);

  push (@mitofates, $line);
  $mitofates_count++;
}
close ($mitofates_fp);


########################################
##  Sort the two arrays
########################################

my @sorted_deepmito = sort deepmito_cmpfn @deepmito;
my @sorted_mitofates = sort mitofates_cmpfn @mitofates;


########################################
##  Debug mode; print the arrays out (long output!)
########################################

if ($debug_arg == 1) {
  for (my $k = 0; $k < scalar (@sorted_deepmito); $k++) {
    printf STDERR "%s", GetDeepMitoID ($sorted_deepmito[$k]);
    printf STDERR "\t%s", GetDeepMitoPredicted ($sorted_deepmito[$k]);
    printf STDERR "\t%f", GetDeepMitoScore ($sorted_deepmito[$k]);
    printf STDERR "\n";
  }

  for (my $k = 0; $k < scalar (@sorted_mitofates); $k++) {
    printf STDERR "%s", GetMitoFatesID ($sorted_mitofates[$k]);
    printf STDERR "\t%f", GetMitoFatesProbability ($sorted_mitofates[$k]);
    printf STDERR "\n";
  }
}

##  Sanity check that both lists are of equal length
if (scalar (@sorted_deepmito) != scalar (@sorted_mitofates)) {
  printf STDERR "EE\tSize of the two lists are different!  %u vs %u\n", scalar (@sorted_deepmito), scalar (@sorted_mitofates);
  exit (1);
}


########################################
##  Process each rank
########################################

my @ranks = split /,/, $ranks_str_arg;
my @methods = split /,/, $methods_str_arg;

for (my $k = 0; $k < scalar (@ranks); $k++) {
  my %names_list = ();
  my $overlap_count = 0;
  my %methods_count = ();

  ##  Force the rank to be no larger than the number of records
  if ($ranks[$k] > scalar (@sorted_deepmito)) {
    $ranks[$k] = scalar (@sorted_deepmito);
  }

  ##  Initialise the methods count
  for (my $m = 0; $m < scalar (@methods); $m++) {
    $methods_count{$methods[$m]} = 0;
  }

  for (my $i = 0; $i < $ranks[$k]; $i++) {
    ##  Remove the protein from the ID in order to compare later
    my $curr_name = TrimOffProtein (GetDeepMitoID ($sorted_deepmito[$i]));
    my $curr_predicted = GetDeepMitoPredicted ($sorted_deepmito[$i]);

    if ($curr_predicted eq "Yes") {
      $names_list{$curr_name} = 1;
    }
  }

  for (my $j = 0; $j < $ranks[$k]; $j++) {
    ##  Remove the protein from the ID in order to compare
    my $curr_name = TrimOffProtein (GetMitoFatesID ($sorted_mitofates[$j]));

    if (defined ($names_list{$curr_name})) {
      $overlap_count++;
      if ($shownames_arg == 1) {
        printf STDERR "==\t%u\t%s\n", $ranks[$k], $curr_name;
      }

      my $curr_method = GetMitoFatesMethod ($sorted_mitofates[$j]);
      if (defined ($methods_count{$curr_method})) {
        $methods_count{$curr_method}++;
      }
      else {
        printf STDERR "EE\tCould not determine method from:  %s\n", $curr_name;
        exit (1);
      }
    }
  }

#   printf STDOUT "%u\tAll\t%u\n", $overlap_count, $overlap_count;
  foreach my $key (sort (keys %methods_count)) {
    printf STDOUT "%u\t%u\t%u\n", $ranks[$k], $key, $methods_count{$key};
  }
}



