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
my $fasta_fn_arg = "";
my $all_fn_arg = "";
my $positive_fn_arg = "";
my $negative_fn_arg = "";

##  Data structures
my %ids_to_seq;

my @output_all;
my @output_positive;
my @output_negative;

my $SELECT_NAME_POS = 0;


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
});                        ##  Protein name
$config -> define ("select", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of identifiers to select
$config -> define ("fasta", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of FASTA sequences
$config -> define ("all", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  All sequences
$config -> define ("positive", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Positive sequences
$config -> define ("negative", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Negative sequences

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

if (!defined ($config -> get ("fasta"))) {
  printf STDERR "EE\tFASTA sequences required with the --fasta option!\n";
  exit (1);
}
$fasta_fn_arg = $config -> get ("fasta");

if (!defined ($config -> get ("all"))) {
  printf STDERR "EE\tFile of all output sequences required with the --all option!\n";
  exit (1);
}
$all_fn_arg = $config -> get ("all");

if (!defined ($config -> get ("positive"))) {
  printf STDERR "EE\tFile of positive output sequences required with the --positive option!\n";
  exit (1);
}
$positive_fn_arg = $config -> get ("positive");

if (!defined ($config -> get ("negative"))) {
  printf STDERR "EE\tFile of negative output sequences required with the --negative option!\n";
  exit (1);
}
$negative_fn_arg = $config -> get ("negative");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Protein:  %s\n", $protein_arg;
printf STDERR "==\t  Input selection file:  %s\n", $select_fn_arg;
printf STDERR "==\t  Input FASTA file:  %s\n", $fasta_fn_arg;
printf STDERR "==\t  Output all file:  %s\n", $all_fn_arg;
printf STDERR "==\t  Output positive file:  %s\n", $positive_fn_arg;
printf STDERR "==\t  Output negative file:  %s\n", $negative_fn_arg;


########################################
##  Read in the selection file
########################################

my $pos = 0;
my $duplicates = 0;
my $neutral_count = 0;

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

  ##  Check if any of the synMTS names have whitespace after
  if ($name =~ /^(\S+)\s+$/) {
    printf STDERR "EE\tThe synMTS [%s] has a whitespace at the end; please correct this and re-run!\n", $name;
    exit (1);
  }

  if (defined ($ids_to_seq{$name})) {
    printf STDERR "WW\tDuplicate ID [%s] found in selection file!\n", $name;
    $duplicates++;
    next;
  }

  if ($tmp[$column_of_interest] eq "++") {
    push (@output_positive, $name);
  }
  elsif ($tmp[$column_of_interest] eq "+") {
    $neutral_count++;
  }
  elsif ($tmp[$column_of_interest] eq "N/A") {
    $neutral_count++;
  }
  elsif ($tmp[$column_of_interest] eq "-") {
    push (@output_negative, $name);
  }
  else {
    printf STDERR "EE\tInvalid protein value [%s] for record [%s] in column [%s]!\n", $tmp[$column_of_interest], $name, $select_header_array[$column_of_interest];
    exit (1);
  }
  push (@output_all, $name);

  $ids_to_seq{$name} = 1;
  $pos++;
}
close ($select_fp);

printf STDERR "==\tTotal number of FASTA to select:  %u\n", $pos;
printf STDERR "==\t  Number of duplicates (should be 0):  %u\n", $duplicates;
printf STDERR "==\t  Number of positives:  %u\n", scalar (@output_positive);
printf STDERR "==\t  Number of + or N/A:  %u\n", $neutral_count;
printf STDERR "==\t  Number of negatives:  %u\n", scalar (@output_negative);



########################################
##  Scan through the FASTA file
########################################

my $fasta_count = 0;
my $fasta_found = 0;

open (my $fasta_fp, "<", $fasta_fn_arg) or die "EE\tCould not open $fasta_fn_arg for input!\n";
while (<$fasta_fp>) {
  my $header = $_;
  chomp ($header);

  my $seq = <$fasta_fp>;
  chomp ($seq);

  if ($header =~ /^>(.+)$/) {
    $header = $1;
  }
  else {
    printf STDERR "EE\tError matching header [%s]!\n", $header;
    exit (1);
  }

  if (defined ($ids_to_seq{$header})) {
    $ids_to_seq{$header} = $seq;
    $fasta_found++;
  }

  $fasta_count++;
}
close ($fasta_fp);

printf STDERR "==\tNumber of FASTA records processed:  %u\n", $fasta_count;
printf STDERR "==\t  Number found:  %u\n", $fasta_found;

if ($pos != $fasta_found) {
  printf STDERR "EE\tUnexpected error -- not all %u records were found!\n", $pos;
  exit (1);
}


########################################
##  Print the records out in the order defined by the arrays
########################################

##  Only need to check for the existence of a record in @output_all since the other arrays are subsets of this one
open (my $output_all_fp, ">", $all_fn_arg) or die "EE\tCould not open $all_fn_arg for output!\n";
for (my $k = 0; $k < scalar (@output_all); $k++) {
  if (!defined ($ids_to_seq{$output_all[$k]})) {
    printf STDERR "EE\tUnexpected error -- ID [%s] could not be found!\n", $output_all[$k];
    exit (1);
  }

  printf $output_all_fp ">%s\n", $output_all[$k];
  printf $output_all_fp "%s\n", $ids_to_seq{$output_all[$k]};
}
close ($output_all_fp);

open (my $output_positive_fp, ">", $positive_fn_arg) or die "EE\tCould not open $positive_fn_arg for output!\n";
for (my $k = 0; $k < scalar (@output_positive); $k++) {
  printf $output_positive_fp ">%s\n", $output_positive[$k];
  printf $output_positive_fp "%s\n", $ids_to_seq{$output_positive[$k]};
}
close ($output_positive_fp);

open (my $output_negative_fp, ">", $negative_fn_arg) or die "EE\tCould not open $negative_fn_arg for output!\n";
for (my $k = 0; $k < scalar (@output_negative); $k++) {
  printf $output_negative_fp ">%s\n", $output_negative[$k];
  printf $output_negative_fp "%s\n", $ids_to_seq{$output_negative[$k]};
}
close ($output_negative_fp);


