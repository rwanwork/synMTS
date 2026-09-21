#!/usr/bin/env perl
#####################################################################
##  summarise-hmoment.pl
##
##  Raymond Wan
##    raymond.wan@manchester.ac.uk
##    rwan.work@gmail.com
##
##  Manchester Institute of Biotechnology
##  University of Manchester
##  Manchester, UK
##
##  Copyright (C) 2025, Raymond Wan, All rights reserved.
#####################################################################


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
my $top_arg = 0;
my $input_fn_arg = "";
my $output_fn_arg = "";

##  Data structures
my @hmoment_values;


########################################
##  Subroutines
########################################

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
$config -> define ("top", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Top percent to take
$config -> define ("input", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Input file
$config -> define ("output", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Output file

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("top"))) {
  printf STDERR "EE\tPercentage of values required with the --top option!\n";
  exit (1);
}
$top_arg = $config -> get ("top");

if (($top_arg <= 0) || ($top_arg > 100)) {
  printf STDERR "EE\tValid values for --top is greater than 0 and less than or equal to 100!\n";
  exit (1);
}

if (!defined ($config -> get ("input"))) {
  printf STDERR "EE\tInput filename required with the --input option!\n";
  exit (1);
}
$input_fn_arg = $config -> get ("input");

if (!defined ($config -> get ("output"))) {
  printf STDERR "EE\tOutput filename required with the --output option!\n";
  exit (1);
}
$output_fn_arg = $config -> get ("output");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Top percentage:  %u\n", $top_arg;
printf STDERR "==\t  Input filename:  %s\n", $input_fn_arg;
printf STDERR "==\t  Output filename:  %s\n", $output_fn_arg;


########################################
##  Read in the input file and find the maximum
########################################

my $max_value_pos = 0;
my $max_value = 0;

open (my $input_fp, "<", $input_fn_arg) or die "EE\tCould not open $input_fn_arg for input!\n";

while (<$input_fp>) {
  my $line = $_;
  chomp ($line);

  ##  Skip the first few lines
  if ($line =~ /^HMOMENT/) {
    next;
  }
  elsif ($line =~ /^(\s*)$/) {
    next;
  }
  elsif ($line =~ /^Window:/) {
    next;
  }
  elsif ($line =~ /^Position/) {
    next;
  }

  my $pos = 0;
  my $value = 0;
  if ($line =~ /^(\S+)\s+(\S+)$/) {
    $pos = $1;
    $value = $2;
  }
  else {
    printf STDERR "EE\tIncorrectly formatted hmoment file (two tab characters expected between the two fields)!  Check line %u [%s]!\n", $., $line;
    exit (1);
  }

  if ($value > $max_value) {
    $max_value_pos = $pos;
    $max_value = $value;
  }

  push (@hmoment_values, $value);
}

close ($input_fp);


########################################
##  Sort the hmoments
########################################

##  Sort values in decreasing order
my @sorted_hmoment_values = sort {$b <=> $a} @hmoment_values;


########################################
##  Determine summary statistics over the average and median of the top X%
########################################

my $total_values = scalar (@sorted_hmoment_values);
my $top_positions = 0;

##  Special case of $top_arg == 100; make it exactly the total, to avoid rounding issues
if ($top_arg == 100) {
  $top_positions = $total_values;
}
else {
  my $check_rounding = ($top_arg / 100 * $total_values) - (int ($top_arg / 100 * $total_values));

  $top_positions = int ($top_arg / 100 * $total_values);
  if ($check_rounding > 0.5) {
    $top_positions = $top_positions + 1;
  }
}

##  Calculate the sum and average of the top X% values
my $top_sum = 0;
for (my $k = 0; $k < $top_positions; $k++) {
  $top_sum += $sorted_hmoment_values[$k];
}

##  Calculate the median
my $top_median_pos = 0;
my $top_median_value = 0;
if ($top_positions % 2 == 0) {
  ##  Even -- take the average of the two values around the centre
  $top_median_pos = $top_positions / 2;
  $top_median_value = ($sorted_hmoment_values[$top_median_pos - 1] + $sorted_hmoment_values[$top_median_pos]) / 2;
}
else {
  ##  Odd -- take the centre value
  $top_median_pos = int ($top_positions / 2);
  $top_median_value = $sorted_hmoment_values[$top_median_pos];
}


printf STDERR "==\t  Number of values:  %u\n", $total_values;
printf STDERR "==\t  Number of positions (%u%% of total):  %u\n", $top_positions, $top_arg;
printf STDERR "==\t  Top %u%% Sum:  %.3f\n", $top_arg, $top_sum;
printf STDERR "==\t  Top %u%% Average:  %.3f\n", $top_arg, $top_sum / $top_positions;
printf STDERR "==\t  Top %u%% Median:  %.3f\n", $top_arg, $top_median_value;


########################################
##  Determine summary statistics over all of the values (average and median)
########################################

my $all_positions = $total_values;

my $all_sum = 0;
for (my $k = 0; $k < $all_positions; $k++) {
  $all_sum += $sorted_hmoment_values[$k];
}

##  Calculate the median
my $all_median_pos = 0;
my $all_median_value = 0;
if ($all_positions % 2 == 0) {
  ##  Even -- take the average of the two values around the centre
  $all_median_pos = $all_positions / 2;
  $all_median_value = ($sorted_hmoment_values[$all_median_pos - 1] + $sorted_hmoment_values[$all_median_pos]) / 2;
}
else {
  ##  Odd -- take the centre value
  $all_median_pos = int ($all_positions / 2);
  $all_median_value = $sorted_hmoment_values[$all_median_pos];
}

printf STDERR "==\t  All Sum:  %.3f\n", $all_sum;
printf STDERR "==\t  All Average:  %.3f\n", $all_sum / $all_positions;
printf STDERR "==\t  All Median:  %.3f\n", $all_median_value;


########################################
##  Print the output in tab separated format
########################################

open (my $output_fp, ">", $output_fn_arg) or die "EE\tCould not open $output_fn_arg for input!\n";

# printf $output_fp "NumPos\tMaximum\tPosition\tTopSum\tTopAvg\tTopMedian\tAllSum\tAllAvg\tAllMedian\n";
printf $output_fp "%u", $total_values;
printf $output_fp "\t%.3f", $max_value;
printf $output_fp "\t%u", $max_value_pos;
printf $output_fp "\t%.3f", $top_sum;
printf $output_fp "\t%.3f", $top_sum / $top_positions;
printf $output_fp "\t%.3f", $top_median_value;
printf $output_fp "\t%.3f", $all_sum;
printf $output_fp "\t%.3f", $all_sum / $all_positions;
printf $output_fp "\t%.3f", $all_median_value;
printf $output_fp "\n";

close ($output_fp);


