#!/usr/bin/env perl
#####################################################################
##  Access_DeepMito.pm
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
package Access_DeepMito;

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
our @EXPORT = qw (GetDeepMitoID GetDeepMitoMethod GetDeepMitoProtein GetDeepMitoPredicted GetDeepMitoScore);

##  Directories where Perl modules are stored
use lib qw (. ../../Common/Perl/);

##  0-based positions in the DeepMito file format
my $DEEPMITO_ID_POS = 0;
my $DEEPMITO_METHOD_POS = 1;
my $DEEPMITO_PROTEIN_POS = 2;
my $DEEPMITO_PREDICTED_POS = 3;
my $DEEPMITO_SCORE_POS = 4;


sub GetDeepMitoID {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$DEEPMITO_ID_POS]);
}


sub GetDeepMitoMethod {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$DEEPMITO_METHOD_POS]);
}


sub GetDeepMitoProtein {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$DEEPMITO_PROTEIN_POS]);
}


sub GetDeepMitoPredicted {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$DEEPMITO_PREDICTED_POS]);
}


sub GetDeepMitoScore {
  my ($record) = @_;

  my @tmp = split /\t/, $record;

  return ($tmp[$DEEPMITO_SCORE_POS]);
}

