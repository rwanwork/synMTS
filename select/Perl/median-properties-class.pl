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

use Statistics_Utils;


########################################
##  Important variables
########################################

##  Input arguments
my $protein_arg = "";
my $aaprop_fn_arg = "";
my $class_fn_arg = "";
my $mts_fn_arg = "";
my $output_fn_arg = "";

##  Data structures
my %aa;
my %name_to_class;


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
$config -> define ("aaprop", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of amino acid properties
$config -> define ("class", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of classes
$config -> define ("mts", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of MTS sequences
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

if (!defined ($config -> get ("protein"))) {
  printf STDERR "EE\tProtein of interest required with the --protein option!\n";
  exit (1);
}
$protein_arg = $config -> get ("protein");

if (!defined ($config -> get ("aaprop"))) {
  printf STDERR "EE\tFile of amino acids properties required with the --aaprop option!\n";
  exit (1);
}
$aaprop_fn_arg = $config -> get ("aaprop");

if (!defined ($config -> get ("class"))) {
  printf STDERR "EE\tFile of classes required with the --class option!\n";
  exit (1);
}
$class_fn_arg = $config -> get ("class");

if (defined ($config -> get ("mts"))) {
  $mts_fn_arg = $config -> get ("mts");
}
else {
  $mts_fn_arg = "";
}

if (!defined ($config -> get ("output"))) {
  printf STDERR "EE\tOutput filename required with the --output option!\n";
  exit (1);
}
$output_fn_arg = $config -> get ("output");


########################################
##  Validate the settings (optional arguments)
########################################


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Protein of interest:  %s\n", $protein_arg;
printf STDERR "==\t  Files:\n";
printf STDERR "==\t    amino acid properties:  %s\n", $aaprop_fn_arg;
printf STDERR "==\t    classes:                %s\n", $class_fn_arg;
printf STDERR "==\t    synMTS sequences:       %s\n", $mts_fn_arg;
printf STDERR "==\t    output file:            %s\n", $output_fn_arg;
printf STDERR "\n";


########################################
##  Create statistics file
########################################

open (my $output_fp, ">", $output_fn_arg) or die "EE\tCannot create output file $output_fn_arg!\n";


########################################
##  Read in the file of amino acid properties
########################################

open (my $fp, "<", $aaprop_fn_arg) or die "EE\tCould not open $aaprop_fn_arg for input!\n";

my $header = <$fp>;
chomp ($header);
my @header_array = split /\t/, $header;

printf $output_fp "ID\tClass\tLength";
for (my $k = 1; $k < scalar (@header_array); $k++) {
  ##  Skip the hydrophilicity column
  if ($header_array[$k] !~ /^hydrophilicity/) {
    printf $output_fp "\t%s_median", $header_array[$k];
  }
}
printf $output_fp "\n";

while (<$fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  for (my $k = 1; $k < scalar (@tmp); $k++) {
    $aa{$tmp[0]}{$header_array[$k]} = $tmp[$k];
  }
}

close ($fp);


########################################
##  Read in the file of classes
########################################

my $CLASSES_PROTEIN_POS = 0;
my $CLASSES_NEWNAME_POS = 2;
my $CLASSES_CLASS_POS = 4;

open ($fp, "<", $class_fn_arg) or die "EE\tCould not open $class_fn_arg for input!\n";

##  Discard the header
$header = <$fp>;

while (<$fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;
  if ($tmp[$CLASSES_PROTEIN_POS] ne $protein_arg) {
    next;
  }

  if (defined ($name_to_class{$tmp[$CLASSES_NEWNAME_POS]})) {
    printf STDERR "EE\tDuplicate name %s in %s!\n", $tmp[$CLASSES_NEWNAME_POS], $class_fn_arg;
    exit (1);
  }
  else {
    $name_to_class{$tmp[$CLASSES_NEWNAME_POS]} = $tmp[$CLASSES_CLASS_POS];
  }
}
close ($fp);


########################################
##  Read in the file of MTS
########################################

my %synmtsid_to_seq;

if (length ($mts_fn_arg) != 0) {
  open ($fp, "<", $mts_fn_arg) or die "EE\tCould not open $mts_fn_arg for input!\n";
  while (<$fp>) {
    my $line = $_;
    chomp ($line);

    my $id = "";
    if ($line =~ /^>(.+)$/) {
      $id = $1;
    }
    else {
      printf STDERR "EE\tCould not match the FASTA line %s!\n", $line;
      exit (1);
    }

    my $seq = <$fp>;
    chomp ($seq);

    $synmtsid_to_seq{$id} = $seq;
  }
  close ($fp);
}


########################################
##  Process input FASTA file
########################################

my $num_seqs = 0;
while (<STDIN>) {
  my $seq_name = $_;
  chomp ($seq_name);

  my $seq = <STDIN>;
  chomp ($seq);

  my $id = "";
  if ($seq_name =~ /^>(.+)$/) {
    $id = $1;
  }

  ##  MTS processing mode
  if (length ($mts_fn_arg) != 0) {
    if (!defined ($synmtsid_to_seq{$id})) {
      printf STDERR "EE\tThe identifier %s could not be found in %s!\n", $id, $mts_fn_arg;
      exit (1);
    }
    my $mts_len = length ($synmtsid_to_seq{$id});
    $seq = substr $seq, 0, $mts_len;

    ##  Check that it matches the original MTS
    if ($seq ne $synmtsid_to_seq{$id}) {
      printf STDERR "EE\tsynMTS and front of protein sequence does not match!\n";
      printf STDERR "EE\t%s\n", $seq;
      printf STDERR "EE\t%s\n", $synmtsid_to_seq{$id};
      exit (1);
    }

    ##  Special case with the passenger protein atp9
    if ($protein_arg eq "atp9") {
      $seq = $seq."ADK".$seq;
    }
  }

  my $stats = CalculateStatsMedianNoID (\%aa, $id, $seq);
  printf $output_fp "%s\t%s\t%u\t%s\n", $id, $name_to_class{$id}, length ($seq), $stats;

  $num_seqs++;
}


########################################
##  Print out a summary
########################################

printf STDERR "==\tNumber of sequences processed:  %u\n", $num_seqs;


########################################
##  Close the output file
########################################

close ($output_fp);

