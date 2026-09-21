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

##  Include library for reading in file
use File::Slurper 'read_text';

##  Directories where Perl modules are stored
use lib qw (. ../Common/Perl/ ../../Common/Perl/);


########################################
##  Important variables
########################################

##  Input arguments
my $input_fn_arg = "";


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
$config -> define ("input", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Input file

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("input"))) {
  printf STDERR "EE\tInput filename required with the --input option!\n";
  exit (1);
}
$input_fn_arg = $config -> get ("input");


########################################
##  Read in entire file
########################################

my $text = read_text ($input_fn_arg);


########################################
##  Remove the surrounding HTML tags
########################################

$text =~ s/<pre>//gs;
$text =~ s/<\/pre>//gs;
chomp ($text);


########################################
##  Remove the header line and split up the name
########################################

##  Split up the file into lines
my @lines = split /\n/, $text;

##  Process from the second line, skipping the header
for (my $k = 1; $k < scalar (@lines); $k++) {
  my @array = split /\t/, $lines[$k];

  ##  Old name:  ID, method, seed, protein
  ##  New name:  "synMTS", method, ID, protein
  ##    (Where ID, seed, and "synMTS" are unnecessary and protein can have a hyphen)
  my $method = 0;
  my $protein = "";

  ##  Old name
  if ($array[0] =~ /^(\d+)_(\d+)_(\d+)_([^_]+)$/) {
    $method = $2;
    $protein = $4;
  }
  ##  New name
  elsif ($array[0] =~ /^synMTS_(\d+)_(\d+)_([^_]+)$/) {
    $method = $1;
    $protein = $3;
  }
  else {
    printf STDERR "EE\tCould not match the identifier %s!\n", $array[0];
    exit (1);
  }

  printf STDOUT "%s", $array[0];
  printf STDOUT "\t%s", $method;
  printf STDOUT "\t%s", $protein;

  for (my $j = 1; $j < scalar (@array); $j++) {
    printf STDOUT "\t%s", $array[$j];
  }
  printf STDOUT "\n";
}
