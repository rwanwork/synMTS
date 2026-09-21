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


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}



########################################
##  Print out the options used
########################################


########################################
##  Process the file
########################################

while (<STDIN>) {
  my $header = $_;
  chomp ($header);

  my $seq = <STDIN>;
  chomp ($seq);

  ########################################
  ##  Replace with numbers first
  ########################################

  ##  hydrophobic aliphatic
  $seq =~ s/A/1/gs;
  $seq =~ s/V/1/gs;
  $seq =~ s/L/1/gs;
  $seq =~ s/I/1/gs;
  $seq =~ s/M/1/gs;
  $seq =~ s/P/1/gs;

  ##  hydrophobic aromatic
  $seq =~ s/F/2/gs;
  $seq =~ s/W/2/gs;

  ##  glycine
  $seq =~ s/G/3/gs;

  ##  cysteine
  $seq =~ s/C/4/gs;

  ##  hydrophilic polar uncharged
  $seq =~ s/N/5/gs;
  $seq =~ s/Q/5/gs;
  $seq =~ s/S/5/gs;
  $seq =~ s/T/5/gs;
  $seq =~ s/Y/5/gs;

  ##  hydrophilic polar basic
  $seq =~ s/H/6/gs;
  $seq =~ s/K/6/gs;
  $seq =~ s/R/6/gs;

  ##  hydrophilic polar acidic
  $seq =~ s/D/7/gs;
  $seq =~ s/E/7/gs;

  ########################################
  ##  Replace with letters
  ########################################
  $seq =~ s/1/A/gs;
  $seq =~ s/2/F/gs;
  $seq =~ s/3/G/gs;
  $seq =~ s/4/C/gs;
  $seq =~ s/5/N/gs;
  $seq =~ s/6/H/gs;
  $seq =~ s/7/D/gs;

  printf STDOUT "%s\n", $header;
  printf STDOUT "%s\n", $seq;
}


