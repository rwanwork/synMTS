#!/usr/bin/env perl
#####################################################################
##  run-summarise-hmoment.pl
##
##  Raymond Wan
##    raymond.wan@manchester.ac.uk
##    rwan.work@gmail.com
##
##  Manchester Institute of Biotechnology
##  University of Manchester
##  Manchester, UK
##
##  Copyright (C) 2025, Raymond Wan, All rights reserved.
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

use File::Temp qw/ tempfile /;  ##  Handle temporary files

##  Directories where Perl modules are stored
use lib qw (. ../Common/Perl/ ../../Common/Perl/);


########################################
##  Important variables
########################################

##  Input arguments
my $mapping_fn_arg = "";
my $infile_fn_arg = "";
my $outfile_fn_arg = "";

##  Data structures
my @ids;


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
});                        ##  Mapping file
$config -> define ("infile", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Input file
$config -> define ("outfile", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Output file

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
  printf STDERR "EE\tMapping file required with the --mapping option!\n";
  exit (1);
}
$mapping_fn_arg = $config -> get ("mapping");

if (!defined ($config -> get ("infile"))) {
  printf STDERR "EE\tInput file required with the --infile option!\n";
  exit (1);
}
$infile_fn_arg = $config -> get ("infile");

if (!defined ($config -> get ("outfile"))) {
  printf STDERR "EE\tOutput file required with the --outfile option!\n";
  exit (1);
}
$outfile_fn_arg = $config -> get ("outfile");


########################################
##  Print out the options used
########################################

my $inpath = "";
if ($infile_fn_arg =~ /^(.+)\/mts\.done$/) {
  $inpath = $1."/";
}
else {
  printf STDERR "EE\tCould not match the infile [%s]!\n", $infile_fn_arg;
  exit (1);
}

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Mapping file:  %s\n", $mapping_fn_arg;
printf STDERR "==\t  Input file:  %s\n", $infile_fn_arg;
printf STDERR "==\t    Input path:  %s\n", $inpath;
printf STDERR "==\t  Output file:  %s\n", $outfile_fn_arg;


########################################
##  Read in the mapping file
########################################

my $mapping_count = 0;

open (my $mapping_fp, "<", $mapping_fn_arg) or die "EE\tCould not open $mapping_fn_arg for input!\n";

while (<$mapping_fp>) {
  my $line = $_;
  chomp ($line);

  my @tmp = split /\t/, $line;

  my $curr_id = $tmp[1];

  push (@ids, $curr_id);

  $mapping_count++;
}

printf STDERR "==\tIDs read:  %u\n", $mapping_count;


########################################
##  Open output file
########################################

open (my $out_fp, ">", $outfile_fn_arg) or die "EE\tCould not open $outfile_fn_arg for output!\n";
printf $out_fp "ID\tMethod\tNumPos\tMaximum\tPosition\tTopSum\tTopAvg\tTopMedian\tAllSum\tAllAvg\tAllMedian\n";


########################################
##  Process each sequences
########################################

my $curr_fp = "";
my $curr_filename = "";
($curr_fp, $curr_filename) = tempfile ();
close ($curr_fp);

##  Take the top 10%
my $top_arg = 10;

printf STDERR "==\tTemporary file:  %s\n", $curr_filename;

for (my $k = 0; $k < $mapping_count; $k++) {
  my $curr_infile = $inpath.$ids[$k].".txt";
  #my $curr_logfile = $inpath.$ids[$k].".log";

  my $curr_method = "";
  if ($ids[$k] =~ /^synMTS_(\d+)_(\d+)$/) {
    $curr_method = $1;
  }
  else {
    printf STDERR "EE\tCould not match the ID [%s]!\n", $ids[$k];
    exit (1);
  }

  my @args = ("Perl/summarise-hmoment.pl", "--top", $top_arg, "--input", $curr_infile, "--output", $curr_filename);
  system (@args) == 0 or die "system @args failed: $?";

  open (my $tmp_fp, "<", $curr_filename) or die "EE\tCould not open $curr_filename for input!\n";
  my $tmp_record = <$tmp_fp>;
  chomp ($tmp_record);
  printf $out_fp "%s\t%u\t%s\n", $ids[$k], $curr_method, $tmp_record;
  close ($tmp_fp);
}


########################################
##  Close output file
########################################

close ($out_fp);

