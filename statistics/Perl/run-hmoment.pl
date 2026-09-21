#!/usr/bin/env perl
#####################################################################
##  run-hmoment.pl
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
use IPC::Run;  ##  For system calls

##  Directories where Perl modules are stored
use lib qw (. ../Common/Perl/ ../../Common/Perl/);


########################################
##  Important variables
########################################

##  Input arguments
my $mapping_fn_arg = "";
my $sequences_fn_arg = "";
my $outfile_fn_arg = "";
my $window_arg = "";
my $aangle_arg = "";
my $bangle_arg = "";
my $plot_arg = "";

##  Data structures
my %ids_to_seq;
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
$config -> define ("sequences", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Sequences file
$config -> define ("outfile", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Snakemake "done" file
$config -> define ("window", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  Window size
$config -> define ("aangle", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  A angle
$config -> define ("bangle", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=i"
});                        ##  B angle
$config -> define ("plot", {
  ARGCOUNT => AppConfig::ARGCOUNT_ONE,
  ARGS => "=s"
});                        ##  Plot?  yes/no

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

if (!defined ($config -> get ("sequences"))) {
  printf STDERR "EE\tSequences file required with the --sequences option!\n";
  exit (1);
}
$sequences_fn_arg = $config -> get ("sequences");

if (!defined ($config -> get ("outfile"))) {
  printf STDERR "EE\tSnakemake output file required with the --outfile option!\n";
  exit (1);
}
$outfile_fn_arg = $config -> get ("outfile");

if (!defined ($config -> get ("window"))) {
  printf STDERR "EE\tWindow size required with the --window option!\n";
  exit (1);
}
$window_arg = $config -> get ("window");

if (!defined ($config -> get ("aangle"))) {
  printf STDERR "EE\tA-angle required with the --aangle option!\n";
  exit (1);
}
$aangle_arg = $config -> get ("aangle");

if (!defined ($config -> get ("bangle"))) {
  printf STDERR "EE\tB-angle required with the --bangle option!\n";
  exit (1);
}
$bangle_arg = $config -> get ("bangle");

if (!defined ($config -> get ("plot"))) {
  printf STDERR "EE\tA 'yes' or 'no' is required with the --plot option!\n";
  exit (1);
}
$plot_arg = $config -> get ("plot");


########################################
##  Print out the options used
########################################

my $outpath = "";
if ($outfile_fn_arg =~ /^(.+)\/mts\.done$/) {
  $outpath = $1."/";
}
else {
  printf STDERR "EE\tCould not match the outfile [%s]!\n", $outfile_fn_arg;
  exit (1);
}

if ($plot_arg eq "yes") {
  $plot_arg = 1;
}
else {
  $plot_arg = 0;
}

printf STDERR "==\tRequired arguments:\n";
printf STDERR "==\t  Mapping file:  %s\n", $mapping_fn_arg;
printf STDERR "==\t  Sequences file:  %s\n", $sequences_fn_arg;
printf STDERR "==\t  Output file:  %s\n", $outfile_fn_arg;
printf STDERR "==\t    Output path:  %s\n", $outpath;
printf STDERR "==\t  Window size:  %u\n", $window_arg;
printf STDERR "==\t  A-angle size:  %u\n", $aangle_arg;
printf STDERR "==\t  B-angle size:  %u\n", $bangle_arg;
printf STDERR "==\t  Plot?:  %s\n", $plot_arg;


########################################
##  Read in the sequences file and store it in a hash
########################################

my $sequences_count = 0;

open (my $sequences_fp, "<", $sequences_fn_arg) or die "EE\tCould not open $sequences_fn_arg for input!\n";

while (<$sequences_fp>) {
  my $header = $_;
  chomp ($header);

  my $seq = <$sequences_fp>;

  my $id = "";
  if ($header =~ /^>(.+)$/) {
    $id = $1;
  }
  else {
    printf STDERR "EE\tCould not match the header [%s]!\n", $header;
    exit (1);
  }

  $ids_to_seq{$id} = $seq;
  $sequences_count++;
}

printf STDERR "==\tSequences read:  %u\n", $sequences_count;


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
##  Process each sequences
########################################

my $curr_fp = "";
my $curr_filename = "";
($curr_fp, $curr_filename) = tempfile ();
close ($curr_fp);

printf STDERR "==\tTemporary file:  %s\n", $curr_filename;

for (my $k = 0; $k < $mapping_count; $k++) {
  open (my $out_fp, ">", $curr_filename) or die "EE\tCould not open $curr_filename for output!\n";
  printf $out_fp ">%s\n", $ids[$k];
  printf $out_fp "%s\n", $ids_to_seq{$ids[$k]};
  close ($out_fp);

  my $curr_outfile = $outpath.$ids[$k].".txt";
  my $curr_logfile = $outpath.$ids[$k].".log";

  my @args = ("hmoment", $curr_filename, "-window", $window_arg, "-aangle", $aangle_arg, "-bangle", $bangle_arg, "-plot", $plot_arg, "-outfile", $curr_outfile);  ## , "1>&1", "2>", $curr_logfile
  system (@args) == 0 or die "system @args failed: $?";
}

