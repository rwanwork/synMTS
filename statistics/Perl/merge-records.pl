#!/usr/bin/env perl
#####################################################################
##  merge-properties.pl
##
##  Raymond Wan
##    raymond.wan@manchester.ac.uk
##    rwan.work@gmail.com
##
##  Manchester Institute of Biotechnology
##  University of Manchester
##  Manchester, UK
##
##  Copyright (C) 2024-2025, Raymond Wan, All rights reserved.
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
my $start_column_arg = 0;


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
$config -> define ("start", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Starting column to take

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("start"))) {
  printf STDERR "EE\tStarting column required with the --start option!\n";
  exit (1);
}
$start_column_arg = $config -> get ("start");


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
for (my $k = $start_column_arg; $k < scalar (@header_array); $k++) {
  printf STDOUT "\t%s", $header_array[$k];
}
printf STDOUT "\n";

while (<STDIN>) {
  my $line = $_;
  chomp ($line);

  ##  Discard all other headers if they are equal to the first one
  if ($line eq $header) {
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

    for (my $j = $start_column_arg; $j < scalar (@array); $j++) {
      printf STDOUT "\t%s", $array[$j];
    }
    printf STDOUT "\n";

    $num_records++;
  }
}

printf STDERR "==\tNumber of records:  %u\n", $num_records;
printf STDERR "==\tHeaders discarded:  %u\n", $num_headers_discarded;


