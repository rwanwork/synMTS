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

use Statistics_Utils;
use Random_Utils;
use Random_Methods;
use Random_Postprocess;


########################################
##  Important variables
########################################

##  Input arguments
my $method_arg = 0;
my $num_seqs_arg = 0;
my $min_len_arg = 0;
my $max_len_arg = 0;
my $seed_arg = 0;
my $aaprop_fn_arg = "";
my $min_charge_arg = 0;

##  Default constants
my $NUM_AMINO_ACIDS = 20;
my $DEFAULT_MIN_CHARGE = 8;

##  Data structures
my %aa;


########################################
##  High hydrophilicity
my @groupA1;
my @groupA2;
my @groupA;

push (@groupA1, "K");
push (@groupA1, "R");

push (@groupA2, "D");
push (@groupA2, "E");

@groupA = (@groupA1, @groupA2);

my %groupA1_hash;
my %groupA2_hash;
my %groupA_hash;

for (my $k = 0; $k < scalar (@groupA1); $k++) {
  $groupA1_hash{$groupA1[$k]} = 1;
  $groupA_hash{$groupA1[$k]} = 1;
}

for (my $k = 0; $k < scalar (@groupA2); $k++) {
  $groupA2_hash{$groupA2[$k]} = 1;
  $groupA_hash{$groupA2[$k]} = 1;
}


########################################
##  Remaining amino acids
my @groupB;
push (@groupB, "A");
push (@groupB, "C");
push (@groupB, "F");
push (@groupB, "G");
push (@groupB, "H");
push (@groupB, "I");
push (@groupB, "L");
push (@groupB, "M");
push (@groupB, "N");
push (@groupB, "P");
push (@groupB, "Q");
push (@groupB, "S");
push (@groupB, "T");
push (@groupB, "V");
push (@groupB, "Y");
push (@groupB, "W");


########################################
##  All amino acids
my @groupAll = (@groupA, @groupB);
if (scalar (@groupAll) != $NUM_AMINO_ACIDS) {
  printf STDERR "EE\tThe total number of amino acids must be %u; but %u were included.\n", $NUM_AMINO_ACIDS, scalar (@groupAll);
  exit (1);
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
$config -> define ("method", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Method to use
$config -> define ("num", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Number of sequences
$config -> define ("min", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Minimum length
$config -> define ("max", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Maximum length
$config -> define ("seed", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Random seed to use (optional)
$config -> define ("aaprop", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of amino acid properties
$config -> define ("mincharge", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Minimum charge for method 2

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("method"))) {
  printf STDERR "EE\tMethod required with the --method option!\n";
  exit (1);
}
$method_arg = $config -> get ("method");

if (!defined ($config -> get ("num"))) {
  printf STDERR "EE\tNumber of sequences required with the --num option!\n";
  exit (1);
}
$num_seqs_arg = $config -> get ("num");

if ($num_seqs_arg > 999) {
  printf STDERR "EE\tThe maximum number of sequences permitted is 999.\n";
  exit (1);
}

if (!defined ($config -> get ("min"))) {
  printf STDERR "EE\tMinimum length of sequences required with the --min option!\n";
  exit (1);
}
$min_len_arg = $config -> get ("min");

if (!defined ($config -> get ("max"))) {
  printf STDERR "EE\tMaximum length of sequences required with the --max option!\n";
  exit (1);
}
$max_len_arg = $config -> get ("max");

if (!defined ($config -> get ("aaprop"))) {
  printf STDERR "EE\tFile of amino acids properties required with the --aaprop option!\n";
  exit (1);
}
$aaprop_fn_arg = $config -> get ("aaprop");


########################################
##  Validate the settings (optional arguments)
########################################

if (defined ($config -> get ("seed"))) {
  $seed_arg = $config -> get ("seed");
}

$min_charge_arg = $DEFAULT_MIN_CHARGE;
if (defined ($config -> get ("mincharge"))) {
  $min_charge_arg = $config -> get ("mincharge");
}


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Method:  %u\n", $method_arg;
printf STDERR "==\t  Number of sequences:  %u\n", $num_seqs_arg;
printf STDERR "==\t  Minimum length:  %u\n", $min_len_arg;
printf STDERR "==\t  Maximum length:  %u\n", $max_len_arg;
printf STDERR "==\t  Filename of amino acid properties:  %s\n", $aaprop_fn_arg;
printf STDERR "==\t  Minimum charge for method #3:  %s\n", $min_charge_arg;
printf STDERR "==\tOptional arguments:\n";
if ($seed_arg != 0) {
  printf STDERR "==\t  Seed to use:  %u\n", $seed_arg;
}
else {
  printf STDERR "==\t  Seed to use:  (random)\n";
}


########################################
##  Generate and print the random seed
########################################

my $seed = 0;
if ($seed_arg != 0) {
  $seed = $seed_arg;
  srand ($seed);
}
else {
  $seed = srand ();
}

printf STDERR "==\tRandom seed:  %u\n", $seed;


########################################
##  Read in the file of amino acid properties
########################################

open (my $fp, "<", $aaprop_fn_arg) or die "EE\tCould not open $aaprop_fn_arg for input!\n";

##  Read in the header
my $header = <$fp>;
chomp ($header);
my @header_array = split /\t/, $header;

while (<$fp>) {
  my $line = $_;
  chomp ($line);

  ##  Use the header to insert into a two-dimensional hash
  my @tmp = split /\t/, $line;
  for (my $k = 1; $k < scalar (@tmp); $k++) {
    $aa{$tmp[0]}{$header_array[$k]} = $tmp[$k];
  }
}

close ($fp);


########################################
##  Generate sequences
########################################

for (my $k = 0; $k < $num_seqs_arg; $k++) {
  my $curr_begin = "";
  my $curr_end = "";
  my $curr_middle = "";

  ##  Calculate the length of the sequence
  my $range = $max_len_arg - $min_len_arg;
  my $target_len = int (rand ($range)) + $min_len_arg;


  ########################################
  ##  Beginning and end same for all methods
  ########################################

  ##  Create the beginning
  $curr_begin = SelectBegin ();

  ##  Create the end
  $curr_end = $curr_end.SelectEnd (\@groupA1, \@groupA2, \@groupA, \@groupB, \@groupAll);


  ########################################
  ##  Method 1
  ########################################

  if ($method_arg == 1) {
    $curr_end = "";  ##  Only Method #1 does NOT have SelectEnd ()
    $curr_middle = Method1 ($target_len - length ($curr_begin) - length ($curr_end), \@groupA1, \@groupA2, \@groupA, \@groupB, \@groupAll);
  }


  ########################################
  ##  Method 2
  ########################################

  elsif ($method_arg == 2) {
    $curr_middle = Method2 ($target_len - length ($curr_begin) - length ($curr_end), \@groupA1, \@groupA2, \@groupA, \@groupB, \@groupAll);
  }


  ########################################
  ##  Method 3
  ########################################

  elsif ($method_arg == 3) {
    $curr_middle = Method3 ($target_len - length ($curr_begin) - length ($curr_end), $min_charge_arg, \%aa, \@groupA1, \@groupA2, \@groupA, \@groupB, \@groupAll);
  }


  ########################################
  ##  Methods 4 or 7
  ########################################

  elsif (($method_arg == 4) || ($method_arg == 7)) {
    $curr_middle = Method4 ($target_len - length ($curr_begin) - length ($curr_end), \@groupA1, \@groupA2, \@groupA, \@groupB, \@groupAll);
  }


  ########################################
  ##  Methods 5 or 8
  ########################################

  elsif (($method_arg == 5) || ($method_arg == 8)) {
    $curr_middle = Method5 ($target_len - length ($curr_begin) - length ($curr_end), \@groupA1, \@groupA2, \@groupA, \@groupB, \@groupAll);
  }


  ########################################
  ##  Methods 6 or 9
  ########################################

  elsif (($method_arg == 6) || ($method_arg == 9)) {
    $curr_middle = Method6 ($target_len - length ($curr_begin) - length ($curr_end), \@groupA1, \@groupA2, \@groupA, \@groupB, \@groupAll);
  }
  else {
    printf STDERR "EE\tUnexpected method %u provided with the --method option!\n", $method_arg;
    exit (1);
  }


  ########################################
  ##  Postprocessing -- Methods 7, 8, and 9
  ########################################

  if (($method_arg == 7) || ($method_arg == 8) || ($method_arg == 9)) {
    $curr_middle = Postprocess ($curr_middle, \@groupA1, \@groupA2, \@groupA, \%groupA1_hash, \%groupA2_hash, \%groupA_hash);
  }

  my $seq = $curr_begin.$curr_middle.$curr_end;
  my $seq_len = length ($seq);

  my $id_str = "";
  if (($k + 1) < 10) {
    $id_str = "00".($k + 1);
  }
  elsif (($k + 1) < 100) {
    $id_str = "0".($k + 1);
  }
  else {
    $id_str = $k + 1;
  }

  printf STDOUT ">%s_%u_%u\n", $id_str, $method_arg, $seed;
  printf STDOUT "%s\n", $seq;
}


