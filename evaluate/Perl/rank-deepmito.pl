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


########################################
##  Important variables
########################################

##  Input arguments
my $deepmito_fn_arg = "";
my $protein1_arg = "";
my $protein2_arg = "";
my $ranks_str_arg = "";
my $methods_str_arg = "";
my $shownames_arg = 0;
my $debug_arg = 0;

##  Data structures
my @deepmito1;
my @deepmito2;
my %methods_hash;


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
});                        ##  List of ranks as a comma-separated list
$config -> define ("methods", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  List of methods as a comma-separated list
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
printf STDERR "==\t  DeepMito filename:  %s\n", $deepmito_fn_arg;
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
for (my $k = 0; $k < scalar (@methods); $k++) {
  $methods_hash{$methods[$k]} = 1;
}


########################################
##  Read in the DeepMito file
########################################

my $deepmito_count = 0;
my $deepmito_count1 = 0;
my $deepmito_count2 = 0;

open (my $deepmito_fp, "<", $deepmito_fn_arg) or die "EE\tCould not open $deepmito_fn_arg for input!\n";
my $header = <$deepmito_fp>;  ##  Discard the header
while (<$deepmito_fp>) {
  my $line = $_;
  chomp ($line);

  my $curr_method = GetDeepMitoMethod ($line);
  if (!defined ($methods_hash{$curr_method})) {
    next;
  }

  my $curr_protein = GetDeepMitoProtein ($line);

  if ($curr_protein eq $protein1_arg) {
    push (@deepmito1, $line);
    $deepmito_count1++;
  }
  if ($curr_protein eq $protein2_arg) {
    push (@deepmito2, $line);
    $deepmito_count2++;
  }
  $deepmito_count++;

}
close ($deepmito_fp);


printf STDERR "==\tTotal number of records:  %u\n", $deepmito_count;
printf STDERR "==\t  Number for %s:  %u\n", $protein1_arg, $deepmito_count1;
printf STDERR "==\t  Number for %s:  %u\n", $protein2_arg, $deepmito_count2;


########################################
##  Sort the two arrays
########################################

my @sorted_deepmito1 = sort deepmito_cmpfn @deepmito1;
my @sorted_deepmito2 = sort deepmito_cmpfn @deepmito2;


printf STDERR "==\tArray sizes:  %u %u\n", scalar (@sorted_deepmito1), scalar (@sorted_deepmito2);


########################################
##  Debug mode; print the arrays out (long output!)
########################################

if ($debug_arg == 1) {
  for (my $k = 0; $k < scalar (@sorted_deepmito1); $k++) {
    printf STDERR "[1 %u] %s", $k, GetDeepMitoID ($sorted_deepmito1[$k]);
    printf STDERR "\t%s", GetDeepMitoPredicted ($sorted_deepmito1[$k]);
    printf STDERR "\t%f", GetDeepMitoScore ($sorted_deepmito1[$k]);
    printf STDERR "\n";
  }

  for (my $k = 0; $k < scalar (@sorted_deepmito2); $k++) {
    printf STDERR "[2 %u] %s", $k, GetDeepMitoID ($sorted_deepmito2[$k]);
    printf STDERR "\t%s", GetDeepMitoPredicted ($sorted_deepmito2[$k]);
    printf STDERR "\t%f", GetDeepMitoScore ($sorted_deepmito2[$k]);
    printf STDERR "\n";
  }
}

##  Sanity check that both lists are of equal length
if (scalar (@sorted_deepmito1) != scalar (@sorted_deepmito2)) {
  printf STDERR "EE\tSize of the two lists are different!  %u vs %u\n", scalar (@sorted_deepmito1), scalar (@sorted_deepmito2);
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
  if ($ranks[$k] > scalar (@sorted_deepmito1)) {
    $ranks[$k] = scalar (@sorted_deepmito1);
  }

  for (my $i = 0; $i < $ranks[$k]; $i++) {
    ##  Remove the protein from the ID in order to compare later
    my $curr_name = TrimOffProtein (GetDeepMitoID ($sorted_deepmito1[$i]));
    my $curr_predicted = GetDeepMitoPredicted ($sorted_deepmito1[$i]);

    $names_list{$curr_name} = 1;
  }

  for (my $j = 0; $j < $ranks[$k]; $j++) {
    ##  Remove the protein from the ID in order to compare
    my $curr_name = TrimOffProtein (GetDeepMitoID ($sorted_deepmito2[$j]));

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



