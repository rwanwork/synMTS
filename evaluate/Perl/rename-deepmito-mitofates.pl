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
my $mapping_fn_arg = "";

##  Data structures
my %old_to_new;
my %new_to_old;


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
$config -> define ("mapping", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Output mapping file

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("mapping"))) {
  printf STDERR "EE\tOutput mapping filename required with the --mapping option!\n";
  exit (1);
}
$mapping_fn_arg = $config -> get ("mapping");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Output mapping filename:  %s\n", $mapping_fn_arg;


########################################
##  Read in the mapping file
########################################

open (my $mapping_fp, "<", $mapping_fn_arg) or die "EE\tCould not open $mapping_fn_arg for reading!\n";
my $count = 0;
while (<$mapping_fp>) {
  my $line = $_;
  chomp ($line);

  my ($method, $new_id, $old_id) = split /\t/, $line;

  if (defined ($old_to_new{$old_id})) {
    printf STDERR "EE\tDuplicate old ID found!  [%s] --> [%s]\n", $old_id, $new_id;
    exit (1);
  }
  $old_to_new{$old_id} = $new_id;
  $new_to_old{$new_id} = $old_id;

  $count++;
}
close ($mapping_fp);

printf STDERR "II\tNumber of mappings read in:  %u\n", $count;


########################################
##  Read in the FASTA file
########################################

while (<STDIN>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;

  my $mts_id = "";
  my $protein = "";

  if ($tmp[0] =~ /^(.+)_([^_]+)$/) {
    $mts_id = $1;
    $protein = $2;
  }
  else {
    printf STDERR "EE\tCould not match the header [%s]!\n", $tmp[0];
    exit (1);
  }

  ##  If we can match new name to old name, then that means renaming has already been done; so we don't have to do anything
  if (!defined ($new_to_old{$mts_id})) {
    if (!defined ($old_to_new{$mts_id})) {
      printf STDERR "EE\tThe header [%s] could not be found in the mapping file!\n", $mts_id;
      exit (1);
    }

    $tmp[0] = sprintf ("%s_%s", $old_to_new{$mts_id}, $protein);
  }

  $line = join ("\t", @tmp);
  printf STDOUT "%s\n", $line;
}


