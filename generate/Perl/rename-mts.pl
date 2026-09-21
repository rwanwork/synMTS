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
my $fasta_fn_arg = "";
my $mapping_fn_arg = "";
my $replicate_arg = 0;
my $method_arg = 0;
my $start_arg = 0;

##  Data structures
my @original_fasta;
my @sorted_fasta;
my @new_identifiers;


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
$config -> define ("fasta", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Output FASTA file
$config -> define ("mapping", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Output mapping file
$config -> define ("replicate", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Replicate number
$config -> define ("method", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Method used
$config -> define ("start", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Number to start from

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("fasta"))) {
  printf STDERR "EE\tOutput FASTA filename required with the --fasta option!\n";
  exit (1);
}
$fasta_fn_arg = $config -> get ("fasta");

if (!defined ($config -> get ("mapping"))) {
  printf STDERR "EE\tOutput mapping filename required with the --mapping option!\n";
  exit (1);
}
$mapping_fn_arg = $config -> get ("mapping");

if (!defined ($config -> get ("replicate"))) {
  printf STDERR "EE\tThe replicate number is required with the --replicate option!\n";
  exit (1);
}
$replicate_arg = $config -> get ("replicate");

if (!defined ($config -> get ("method"))) {
  printf STDERR "EE\tMethod required with the --method option!\n";
  exit (1);
}
$method_arg = $config -> get ("method");

if (!defined ($config -> get ("start"))) {
  printf STDERR "EE\tStarting number required with the --start option!\n";
  exit (1);
}
$start_arg = $config -> get ("start");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Output FASTA filename:  %s\n", $fasta_fn_arg;
printf STDERR "==\t  Output mapping filename:  %s\n", $mapping_fn_arg;
printf STDERR "==\t  Replicate number:  %u\n", $replicate_arg;
printf STDERR "==\t  Method:  %u\n", $method_arg;
printf STDERR "==\t  Starting position:  %u\n", $start_arg;


########################################
##  Read in the FASTA file
########################################

while (<STDIN>) {
  my $line = $_;
  chomp ($line);

  my $header = "";
  my $seq = <STDIN>;
  chomp ($seq);

  if ($line =~ /^>(.+)$/) {
    $header = $1;
  }
  else {
    printf STDERR "EE\tCould not match the header [%s]!\n", $line;
    exit (1);
  }

  ##  Sanity check that there are no tab characters in either string
  if (($header =~ /\t/) || ($seq =~ /\t/)) {
    printf STDERR "EE\tTab character found in either the header or the sequence! [%s] [%s]\n", $header, $seq;
    exit (1);
  }

  my $combine = $seq."\t".$header;
  push (@original_fasta, $combine);
}


########################################
##  Lexically sort the identifiers
########################################

sub byseq {
  my ($seq1, $header1) = split (/\t/, $a);
  my ($seq2, $header2) = split (/\t/, $b);

  return ($seq1 cmp $seq2);
}
@sorted_fasta = sort byseq @original_fasta;


########################################
##  Assign the new identifiers
########################################

my $curr_id = $start_arg;
for (my $k = 0; $k < scalar (@sorted_fasta); $k++) {
  my $curr = "";
  my $curr_id_str = "";

  if ($curr_id < 10) {
    $curr_id_str = "00";
  }
  elsif ($curr_id < 100) {
    $curr_id_str = "0";
  }

  $curr_id_str = $curr_id_str.$curr_id;

  $curr = "synMTS_".$method_arg."_".$curr_id_str;
  push (@new_identifiers, $curr);

  $curr_id++;
}

########################################
##  Write out the FASTA file with the new names
########################################

open (my $fasta_fp, ">", $fasta_fn_arg) or die "EE\tCould not open $fasta_fn_arg for output!\n";
for (my $k = 0; $k < scalar (@sorted_fasta); $k++) {
  printf $fasta_fp ">%s\n", $new_identifiers[$k];

  my ($curr_seq, $curr_header) = split (/\t/, $sorted_fasta[$k]);
  printf $fasta_fp "%s\n", $curr_seq;
}
close ($fasta_fp);


########################################
##  Write out the mapping file
########################################

open (my $mapping_fp, ">", $mapping_fn_arg) or die "EE\tCould not open $mapping_fn_arg for output!\n";
for (my $k = 0; $k < scalar (@sorted_fasta); $k++) {
  printf $mapping_fp "%u", $method_arg;
  printf $mapping_fp "\t%s", $new_identifiers[$k];

  my ($curr_seq, $curr_header) = split (/\t/, $sorted_fasta[$k]);
  printf $mapping_fp "\t%s", $curr_header;
  printf $mapping_fp "\n";
}
close ($mapping_fp);


