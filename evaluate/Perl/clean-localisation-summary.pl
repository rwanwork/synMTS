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
##  Subroutines
########################################

sub AddLaTeXSpacing {
  my ($value, $width) = @_;
  my $new_value = "";

  my $tmp_value = $value;
  my $count = 0;

  if ($tmp_value == 0) {
    $count = 1;
  }
  else {
    while ($tmp_value > 1) {
      $tmp_value = $tmp_value / 10;
      $count++;
    }
  }

  while ($count < $width) {
    $new_value = $new_value."\\D";
    $count++;
  }
  if (length ($new_value) > 0) {
    $new_value = "{".$new_value."}";
  }

  $new_value = $new_value.$value;

  return ($new_value);
}


########################################
##  Important variables
########################################

##  Data structures
my %prediction_hash;
my %goterm_hash;

##  This is the order that the sections are printed
my @prediction_sections = ("Yes", "No");
my @mitochondrial_sections = ("OM", "Space", "IM", "Matrix");


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
##  Read in and store the input file
########################################

##  Input file has two sections
my $section = 0;

while (<STDIN>) {
  my $line = $_;
  chomp ($line);

  ##  Since these terms have spaces in them, we need to replace them first...
  $line =~ s/C:mitochondrial outer membrane/OM/gs;
  $line =~ s/C:mitochondrial intermembrane space/Space/gs;
  $line =~ s/C:mitochondrial inner membrane/IM/gs;
  $line =~ s/C:mitochondrial matrix/Matrix/gs;

  ##  ...before we replace all spaces with tab characters.
  $line =~ s/(\s+)/\t/gs;

  if ($line =~ /Predicted/) {
    $section = 1;
    next;
  }
  elsif ($line =~ /GO_Term/) {
    $section = 2;
    next;
  }

  my @tmp = split /\t/, $line;
  my $protein = $tmp[1];
  my $value = $tmp[3];

  if ($section == 1) {
    my $yes_no = $tmp[2];

    $prediction_hash{$protein}{$yes_no} = $value;
  }
  elsif ($section == 2) {
    my $go_term = $tmp[2];

    $goterm_hash{$protein}{$go_term} = $value;
  }
}


########################################
##  Initialise values to 0 which have not yet been set (because they are not
##    in the input file)
########################################

foreach my $key (sort (keys %prediction_hash)) {
  for (my $k = 0; $k < scalar (@prediction_sections); $k++) {
    if (!defined ($prediction_hash{$key}{$prediction_sections[$k]})) {
      $prediction_hash{$key}{$prediction_sections[$k]} = 0;
    }
  }
  for (my $k = 0; $k < scalar (@mitochondrial_sections); $k++) {
    if (!defined ($goterm_hash{$key}{$mitochondrial_sections[$k]})) {
      $goterm_hash{$key}{$mitochondrial_sections[$k]} = 0;
    }
  }
}


########################################
##  Output the table
########################################

printf STDOUT "\\begin{tabular}{ccccccc}\n";
printf STDOUT "\\hline\n";
printf STDOUT "& \\multicolumn{2}{c}{\\tppred / \\bacello} & \\multicolumn{4}{c}{Mitochondria compartment} \\\\ \\cmidrule(lr){2-3}\\cmidrule(lr){4-7}\n";

for (my $k = 0; $k < scalar (@prediction_sections); $k++) {
  printf STDOUT "& %s ", $prediction_sections[$k];
}

for (my $k = 0; $k < scalar (@mitochondrial_sections); $k++) {
  my $long_term = "";

  if ($mitochondrial_sections[$k] eq "OM") {
    $long_term = "Outer membrane";
  }
  elsif ($mitochondrial_sections[$k] eq "Space") {
    $long_term = "Inter membrane space";
  }
  elsif ($mitochondrial_sections[$k] eq "IM") {
    $long_term = "Inner membrane";
  }
  elsif ($mitochondrial_sections[$k] eq "Matrix") {
    $long_term = "Matrix";
  }
  else {
    printf STDERR "EE\tThe term [%s] was not recognised!\n", $mitochondrial_sections[$k];
    exit (1);
  }

  printf STDOUT "& %s ", $long_term;
}

printf STDOUT " \\\\ \n";
printf STDOUT "\\hline\n";

foreach my $key (sort (keys %prediction_hash)) {
  printf STDOUT "%s ", $key;
  for (my $k = 0; $k < scalar (@prediction_sections); $k++) {
    printf STDOUT "& %s ", AddLaTeXSpacing ($prediction_hash{$key}{$prediction_sections[$k]}, 4);
  }

  for (my $k = 0; $k < scalar (@mitochondrial_sections); $k++) {
    printf STDOUT "& %s ", AddLaTeXSpacing ($goterm_hash{$key}{$mitochondrial_sections[$k]}, 4);
  }
  printf STDOUT "\\\\";

  printf STDOUT "\n";
}

printf STDOUT "\\hline\n";
printf STDOUT "\\end{tabular}\n";


