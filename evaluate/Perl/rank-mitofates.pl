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

use Access_MitoFates;


########################################
##  Important variables
########################################

##  Input arguments
my $mitofates_fn_arg = "";
my $protein1_arg = "";
my $protein2_arg = "";
my $ranks_str_arg = "";
my $methods_str_arg = "";
my $shownames_arg = 0;
my $debug_arg = 0;

##  Data structures
my @mitofates1;
my @mitofates2;


########################################
##  Subroutines
########################################

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
$config -> define ("mitofates", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of MitoFates' output
$config -> define ("protein1", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  First protein
$config -> define ("protein2", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Second protein
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

if (!defined ($config -> get ("mitofates"))) {
  printf STDERR "EE\tMitoFates output required with the --mitofates option!\n";
  exit (1);
}
$mitofates_fn_arg = $config -> get ("mitofates");

if (!defined ($config -> get ("protein1"))) {
  printf STDERR "EE\tName of first protein required with the --protein1 option!\n";
  exit (1);
}
$protein1_arg = $config -> get ("protein1");

if (!defined ($config -> get ("protein2"))) {
  printf STDERR "EE\tName of second protein required with the --protein2 option!\n";
  exit (1);
}
$protein2_arg = $config -> get ("protein2");

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
printf STDERR "==\t  MitoFates filename:  %s\n", $mitofates_fn_arg;
printf STDERR "==\t  Protein 1:  %s\n", $protein1_arg;
printf STDERR "==\t  Protein 2:  %s\n", $protein2_arg;
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
##  Store the methods of interest
########################################

my @methods = split /,/, $methods_str_arg;
my %methods_hash;
for (my $k = 0; $k < scalar (@methods); $k++) {
  $methods_hash{$methods[$k]} = 1;
}


########################################
##  Read in the DeepMito file
########################################

my $mitofates_count = 0;
my $mitofates_count1 = 0;
my $mitofates_count2 = 0;

open (my $mitofates_fp, "<", $mitofates_fn_arg) or die "EE\tCould not open $mitofates_fn_arg for input!\n";
my $header = <$mitofates_fp>;  ##  Discard the header
while (<$mitofates_fp>) {
  my $line = $_;
  chomp ($line);

  my $curr_method = GetMitoFatesMethod ($line);
  if (!defined ($methods_hash{$curr_method})) {
    next;
  }

  my $curr_protein = GetMitoFatesProtein ($line);

  if ($curr_protein eq $protein1_arg) {
    push (@mitofates1, $line);
    $mitofates_count1++;
  }
  if ($curr_protein eq $protein2_arg) {
    push (@mitofates2, $line);
    $mitofates_count2++;
  }
  $mitofates_count++;
}
close ($mitofates_fp);


printf STDERR "==\t%u %u %u\n", $mitofates_count, $mitofates_count1, $mitofates_count2;


########################################
##  Sort the two arrays
########################################

my @sorted_mitofates1 = sort mitofates_cmpfn @mitofates1;
my @sorted_mitofates2 = sort mitofates_cmpfn @mitofates2;


printf STDERR "==\t%u %u\n", scalar (@sorted_mitofates1), scalar (@sorted_mitofates2);


########################################
##  Debug mode; print the arrays out (long output!)
########################################

if ($debug_arg == 1) {
  for (my $k = 0; $k < scalar (@sorted_mitofates1); $k++) {
    printf STDERR "[1 %u] %s", $k, GetMitoFatesID ($sorted_mitofates1[$k]);
    printf STDERR "\t%f", GetMitoFatesProbability ($sorted_mitofates1[$k]);
    printf STDERR "\n";
  }

  for (my $k = 0; $k < scalar (@sorted_mitofates2); $k++) {
    printf STDERR "[2 %u] %s", $k, GetMitoFatesID ($sorted_mitofates2[$k]);
    printf STDERR "\t%f", GetMitoFatesProbability ($sorted_mitofates2[$k]);
    printf STDERR "\n";
  }
}

##  Sanity check that both lists are of equal length
if (scalar (@sorted_mitofates1) != scalar (@sorted_mitofates2)) {
  printf STDERR "EE\tSize of the two lists are different!  %u vs %u\n", scalar (@sorted_mitofates1), scalar (@sorted_mitofates2);
  exit (1);
}


########################################
##  Process each rank
########################################

my @ranks = split /,/, $ranks_str_arg;

for (my $k = 0; $k < scalar (@ranks); $k++) {
  my %names_list = ();
  my $overlap_count = 0;

  ##  Force the rank to be no larger than the number of records
  if ($ranks[$k] > scalar (@sorted_mitofates1)) {
    $ranks[$k] = scalar (@sorted_mitofates1);
  }

  for (my $i = 0; $i < $ranks[$k]; $i++) {
    ##  Remove the protein from the ID in order to compare later
    my $curr_name = TrimOffProtein (GetMitoFatesID ($sorted_mitofates1[$i]));
    my $curr_predicted = GetMitoFatesProbability ($sorted_mitofates1[$i]);

    $names_list{$curr_name} = 1;
  }

  for (my $j = 0; $j < $ranks[$k]; $j++) {
    ##  Remove the protein from the ID in order to compare
    my $curr_name = TrimOffProtein (GetMitoFatesID ($sorted_mitofates2[$j]));

    if (defined ($names_list{$curr_name})) {
      $overlap_count++;
      if ($shownames_arg == 1) {
        printf STDERR "==\t%u\t%s\n", $ranks[$k], $curr_name;
      }
    }
  }

  my $protein1_out = ucfirst ($protein1_arg);
  my $protein2_out = ucfirst ($protein2_arg);

  if ($protein1_out !~ /p$/) {
    $protein1_out = $protein1_out."p";
  }

  if ($protein2_out !~ /p$/) {
    $protein2_out = $protein2_out."p";
  }

  printf STDOUT "%s-%s\t%u\t%u\t%f\n", $protein1_out, $protein2_out, $ranks[$k], $overlap_count, $overlap_count / $ranks[$k];
}



