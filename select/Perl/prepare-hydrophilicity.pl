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
my $aaprop_fn_arg = "";

##  Data structures
my %aa;


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
$config -> define ("aaprop", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of amino acid properties

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("aaprop"))) {
  printf STDERR "EE\tFile of amino acids properties required with the --aaprop option!\n";
  exit (1);
}
$aaprop_fn_arg = $config -> get ("aaprop");


########################################
##  Validate the settings (optional arguments)
########################################


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Filename of amino acid properties:  %s\n", $aaprop_fn_arg;


########################################
##  Read in the file of amino acid properties
########################################

open (my $fp, "<", $aaprop_fn_arg) or die "EE\tCould not open $aaprop_fn_arg for input!\n";

my $header = <$fp>;
chomp ($header);
my @header_array = split /\t/, $header;

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
##  Process FASTA file
########################################

my $seq_name = <STDIN>;
chomp ($seq_name);

my $seq = <STDIN>;
chomp ($seq);

my @tmp = split //, $seq;

printf STDOUT "Position\tBase\tHydrophilicity\tColour\n";
for (my $k = 0; $k < scalar (@tmp); $k++) {
  printf STDOUT "%u\t%s\t%f", $k + 1, $tmp[$k], $aa{$tmp[$k]}{hydrophilicity};
  if ($aa{$tmp[$k]}{hydrophilicity} > 0) {
    printf STDOUT "\tgreen";
  }
  else {
    printf STDOUT "\tred";
  }
  printf STDOUT "\n";
}

