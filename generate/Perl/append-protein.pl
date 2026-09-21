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


########################################
##  Important variables
########################################

##  Input arguments
my $append_fn_arg = "";


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

$config -> define ("append", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Sequence to append (optional)

##  Process the command-line options
$config -> getopt ();


########################################
##  Validate the settings (mandatory arguments)
########################################

if ($config -> get ("help")) {
  pod2usage (-verbose => 0);
  exit (1);
}

if (!defined ($config -> get ("append"))) {
  printf STDERR "EE\tProtein sequence to append is required with the --append option!\n";
  exit (1);
}
$append_fn_arg = $config -> get ("append");


########################################
##  Validate the settings (optional arguments)
########################################


########################################
##  Print out the options used
########################################

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Append filename (input):  %s\n", $append_fn_arg;

##  Obtain the base of the filename
my $base_fn;
if ($append_fn_arg =~ /^(.*)\/([^\/]+)\.fasta$/) {
  $base_fn = $2;
  printf STDERR "==\t    Base filename (input):  %s\n", $base_fn;
}
else {
  printf STDERR "EE\tCould not properly parse the append filename!\n";
  exit (1);
}


########################################
##  Preparation for appending
########################################

my $append_str = "";
if (length ($append_fn_arg) != 0) {
  open (my $in_append_fp, "<", $append_fn_arg) or die "EE\tCould not open $append_fn_arg for reading!\n";
  my $header = <$in_append_fp>;

  if ($header !~ /^>(.+)$/) {
    printf STDERR "EE\tThe protein sequence being appended is not a properly formatted FASTA file!  Header line was expected!\n";
    exit (1);
  }

  ##  Take the remainder of the file as the sequence
  while (<$in_append_fp>) {
    my $line = $_;
    chomp ($line);

    $append_str = $append_str.$line;
  }
  close ($in_append_fp);
}


########################################
##  Process FASTA file
########################################

my $num_seqs = 0;
while (<STDIN>) {
  my $seq_name = $_;
  chomp ($seq_name);

  my $seq = <STDIN>;
  chomp ($seq);

  $seq = $seq.$append_str;

  printf STDOUT "%s_%s\n", $seq_name, $base_fn;
  printf STDOUT "%s\n", $seq;
  $num_seqs++;
}


########################################
##  Print out a summary
########################################

printf STDERR "==\tNumber of sequences processed:  %u\n", $num_seqs;

