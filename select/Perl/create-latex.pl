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
my $select_fn_arg = "";

##  Data structures
my %ids_to_seq;
my @output_order;


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
$config -> define ("select", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  File of identifiers to select

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("select"))) {
  printf STDERR "EE\tIdentifiers to select required with the --select option!\n";
  exit (1);
}
$select_fn_arg = $config -> get ("select");


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Selection file:  %s\n", $select_fn_arg;


########################################
##  Read in the selection file
########################################

my $pos = 0;
my $duplicates = 0;

open (my $select_fp, "<", $select_fn_arg) or die "EE\tCould not open $select_fn_arg for input!\n";

##  Remove the header
my $select_header = <$select_fp>;

while (<$select_fp>) {
  my $line = $_;
  chomp ($line);

  my ($name, $cherry, $iqc, $cox4, $cox2) = split /\t/, $line;

  if (defined ($ids_to_seq{$name})) {
    printf STDERR "WW\tDuplicate ID [%s] found in selection file!\n", $name;
    $duplicates++;
    next;
  }

  $ids_to_seq{$name} = 1;
  push (@output_order, $name);
  $pos++;
}
close ($select_fp);

printf STDERR "==\tNumber of FASTA to select:  %u\n", $pos;
printf STDERR "==\t  Number of duplicates:  %u\n", $duplicates;


########################################
##  Print the records out in the order defined by @output_order
########################################

for (my $k = 0; $k < scalar (@output_order); $k++) {
  my $replace_underscore = $output_order[$k];

  $replace_underscore =~ s/_/\\_/gs;

  printf STDOUT "\\begin{figure}[ht]\n";
  printf STDOUT "  \\centering\n";
  printf STDOUT "  \\includegraphics[width=\\linewidth]{./imgs/%s}\n", $output_order[$k];
  printf STDOUT "  \\caption{\\label{fig:%s}Hydrophilicity plot for the synthetic MTS %s}\n", $output_order[$k], $replace_underscore;
  printf STDOUT "\\end{figure}\n";
  printf STDOUT "\n\n";
}

