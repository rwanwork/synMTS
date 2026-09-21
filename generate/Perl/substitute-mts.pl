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
my $from_arg = "";
my $to_arg = "";


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
$config -> define ("from", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Amino acid to look for
$config -> define ("to", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Amino acid to change to

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("from"))) {
  printf STDERR "EE\tAmino acid to change from required with the --from option!\n";
  exit (1);
}
$from_arg = $config -> get ("from");

if (!defined ($config -> get ("to"))) {
  printf STDERR "EE\tAmino acid to change to required with the --to option!\n";
  exit (1);
}
$to_arg = $config -> get ("to");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Amino acid to change from:  %s\n", $from_arg;
printf STDERR "==\t  Amino acid to change to:  %s\n", $to_arg;


########################################
##  Process the input file
########################################

my $num_records = 0;
while (<STDIN>) {
  my $header = $_;
  chomp ($header);
  my $seq = <STDIN>;
  chomp ($seq);

  if ($header !~ /^>/) {
    printf STDERR "EE\tImproperly formatted input file; FASTA header started with a > character expected instead of [%s].\n", $header;
    exit (1);
  }

  my $endings_type = 0;

  ##  Two possible endings:
  ##    1.  RRY --> RKY or R*Y --> R*Y
  ##    2.  RR --> RK or R* --> R*
  if ($seq =~ /R.Y$/) {
    $endings_type = 1;
  }
  elsif ($seq =~ /R.$/) {
    $endings_type = 2;
  }

  $seq =~ s/$from_arg/$to_arg/gs;

  if ($endings_type == 1) {
    my @tmp = split //, $seq;
    my $tmp_size = scalar (@tmp);

    if ($tmp[$tmp_size - 3] ne "K") {
      printf STDERR "EE  Unexpected amino acid in [%s] of length %u (1)!\n", $seq, $tmp_size;
      exit (1);
    }

    $tmp[$tmp_size - 3] = "R";

    $seq = join ('', @tmp);
  }
  elsif ($endings_type == 2) {
    my @tmp = split //, $seq;
    my $tmp_size = scalar (@tmp);

    if ($tmp[$tmp_size - 2] ne "K") {
      printf STDERR "EE  Unexpected amino acid in [%s] of length %u (1)!\n", $seq, $tmp_size;
      exit (1);
    }

    $tmp[$tmp_size - 2] = "R";

    $seq = join ('', @tmp);
  }

  printf STDOUT "%s\n", $header;
  printf STDOUT "%s\n", $seq;

  $num_records++;
}


