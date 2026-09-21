#!/usr/bin/env perl
#####################################################################
##  Access_MitoFates.pm
##
##  Raymond Wan
##    raymond.wan@manchester.ac.uk
##    rwan.work@gmail.com
##
##  Manchester Institute of Biotechnology
##  University of Manchester
##  Manchester, UK
##
##  Copyright (C) 2024-2026, Raymond Wan, All rights reserved.
#####################################################################


##  Define the namespace
package Access_MitoFates;

use FindBin qw ($Bin);
use lib $FindBin::Bin;  ##  Search the directory where the script is located

##  Employ strict, warnings, and diagnostics
use strict;
use warnings;
use diagnostics;

##  Define this module's version
our $VERSION = '1.00';

##  Inherit from the Exporter module
use base 'Exporter';

##  Set of subroutines to be exported
our @EXPORT = qw (GetMitoFatesID GetMitoFatesMethod GetMitoFatesProtein GetMitoFatesProbability GetMitoFatesPrediction);

##  Directories where Perl modules are stored
use lib qw (. ../../Common/Perl/);


##  0-based positions in the MitoFates file format
my $MITOFATES_ID_POS = 0;
my $MITOFATES_METHOD_POS = 1;
my $MITOFATES_PROTEIN_POS = 2;
my $MITOFATES_PROBABILITY_POS = 3;
my $MITOFATES_PREDICTION_POS = 4;


sub GetMitoFatesID {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$MITOFATES_ID_POS]);
}


sub GetMitoFatesMethod {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$MITOFATES_METHOD_POS]);
}


sub GetMitoFatesProtein {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$MITOFATES_PROTEIN_POS]);
}


sub GetMitoFatesProbability {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$MITOFATES_PROBABILITY_POS]);
}


sub GetMitoFatesPrediction {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$MITOFATES_PREDICTION_POS]);
}

