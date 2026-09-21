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

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}


########################################
##  Process the file
########################################

my $num_records = 0;
my $num_headers_discarded = 0;

##  Keep only the first header
my $header = <STDIN>;
chomp ($header);
my @header_array = split /\t/, $header;
printf STDOUT "Name\tMethod\tProtein";
for (my $k = 1; $k < scalar (@header_array); $k++) {
  printf STDOUT "\t%s", $header_array[$k];
}
printf STDOUT "\n";

while (<STDIN>) {
  my $line = $_;
  chomp ($line);

  if ($line =~ /^ID/) {
    $num_headers_discarded++;
  }
  else {
    my @array = split /\t/, $line;

    ##  Old name:  ID, method, seed, protein
    ##  New name:  "synMTS", method, ID, protein
    ##    (Where ID, seed, and "synMTS" are unnecessary and protein can have a hyphen)
    my $method = 0;
    my $protein = "";

    ##  Old name -- protein
    if ($array[0] =~ /^(\d+)_(\d+)_(\d+)_(.+)$/) {
      $method = $2;
      $protein = $4;
    }
    ##  Old name -- MTS
    elsif ($array[0] =~ /^(\d+)_(\d+)_(\d+)$/) {
      $method = $2;
      $protein = "N/A";
    }
    ##  New name -- protein
    elsif ($array[0] =~ /^synMTS_(\d+)_(\d+)_([^_]+)$/) {
      $method = $1;
      $protein = $3;
    }
    ##  New name -- MTS
    elsif ($array[0] =~ /^synMTS_(\d+)_(\d+)$/) {
      $method = $1;
      $protein = "N/A";
    }

    printf STDOUT "%s", $array[0];
    printf STDOUT "\t%s", $method;
    printf STDOUT "\t%s", $protein;

    for (my $j = 1; $j < scalar (@array); $j++) {
      printf STDOUT "\t%s", $array[$j];
    }
    printf STDOUT "\n";

    $num_records++;
  }
}

printf STDERR "==\tNumber of records:  %u\n", $num_records;
printf STDERR "==\tHeaders discarded:  %u\n", $num_headers_discarded;

