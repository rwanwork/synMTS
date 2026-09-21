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
my $sample_arg = "";
my $fasta_fn_arg = "";


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
$config -> define ("sample", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Sample to extract
$config -> define ("fasta", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of FASTA sequences

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("sample"))) {
  printf STDERR "EE\tSample ID to extract required with the --sample option!\n";
  exit (1);
}
$sample_arg = $config -> get ("sample");

if (!defined ($config -> get ("fasta"))) {
  printf STDERR "EE\tFASTA sequences required with the --fasta option!\n";
  exit (1);
}
$fasta_fn_arg = $config -> get ("fasta");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Sample:  %s\n", $sample_arg;
printf STDERR "==\t  FASTA file:  %s\n", $fasta_fn_arg;


########################################
##  Scan through the FASTA file
########################################

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

  if ($header eq $sample_arg) {
    printf STDOUT ">%s\n", $header;
    printf STDOUT "%s\n", $seq;
    last;
  }
}
close ($fasta_fp);


