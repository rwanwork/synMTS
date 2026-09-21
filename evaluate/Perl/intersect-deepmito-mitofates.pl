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

use Access_DeepMito;
use Access_MitoFates;


########################################
##  Important variables
########################################

##  Input arguments
my $deepmito_fn_arg = "";
my $mitofates_fn_arg = "";

##  Data structures
my %deepmito;


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
$config -> define ("deepmito", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Input DeepMito file
$config -> define ("mitofates", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Input MitoFates file

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("deepmito"))) {
  printf STDERR "EE\tInput DeepMito filename required with the --deepmito option!\n";
  exit (1);
}
$deepmito_fn_arg = $config -> get ("deepmito");

if (!defined ($config -> get ("mitofates"))) {
  printf STDERR "EE\tInput MitoFates filename required with the --mitofates option!\n";
  exit (1);
}
$mitofates_fn_arg = $config -> get ("mitofates");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Input DeepMito filename:  %s\n", $deepmito_fn_arg;
printf STDERR "==\t  Input MitoFates filename:  %s\n", $mitofates_fn_arg;


########################################
##  Read in the DeepMito file
########################################

open (my $deepmito_fp, "<", $deepmito_fn_arg) or die "EE\tCould not open $deepmito_fn_arg for reading!\n";
my $count = 0;

my $header = <$deepmito_fp>;  ##  Remove header
while (<$deepmito_fp>) {
  my $line = $_;
  chomp ($line);

  my $deepmito_id = GetDeepMitoID ($line);

  if (defined ($deepmito{$deepmito_id})) {
    printf STDERR "EE\tDuplicate record found for %s!\n", $deepmito_id;
    exit (1);
  }

  $deepmito{$deepmito_id} = $line;
  $count++;
}
close ($deepmito_fp);

printf STDERR "II\tNumber of DeepMito records:  %u\n", $count;


########################################
##  Read in the MitoFates file
########################################

open (my $mitofates_fp, "<", $mitofates_fn_arg) or die "EE\tCould not open $mitofates_fn_arg for reading!\n";
$count = 0;
$header = <$mitofates_fp>;  ##  Remove header

printf STDOUT "ID\tMethod\tProtein\tDeepMito\tMitoFates\n";
while (<$mitofates_fp>) {
  my $line = $_;
  chomp ($line);

  my $mitofates_id = GetMitoFatesID ($line);

  if (!defined ($deepmito{$mitofates_id})) {
    printf STDERR "EE\tNo DeepMito record found for the MitoFates record %s!\n", $mitofates_id;
    exit (1);
  }

  printf STDOUT "%s", $mitofates_id;
  printf STDOUT "\t%u", GetDeepMitoMethod ($deepmito{$mitofates_id});
  printf STDOUT "\t%s", GetDeepMitoProtein ($deepmito{$mitofates_id});
  printf STDOUT "\t%s", GetDeepMitoScore ($deepmito{$mitofates_id});
  printf STDOUT "\t%s", GetMitoFatesProbability ($line);
  printf STDOUT "\n";

  $count++;

}
close ($mitofates_fp);

printf STDERR "II\tNumber of MitoFates records:  %u\n", $count;



