#!/usr/bin/env perl
#####################################################################
##  Random_Postprocess.pm
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


##  Define the namespace
package Random_Postprocess;

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
our @EXPORT = qw (DoubleGroupA DoubleGroupA1 Postprocess);

##  Directories where Perl modules are stored
use lib qw (. ../../Common/Perl/);


########################################
##  Post-process doubling of hydrophilic amino acids
########################################

sub DoubleGroupA {
  my ($seq, $start, $end, $a1_ref, $a2_ref, $a_ref, $a1_href, $a2_href, $a_href) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };

  ##  Convert all references back to hashes
  my %a1_hash = %{ $a1_href };
  my %a2_hash = %{ $a2_href };
  my %a_hash = %{ $a_href };

  ##  Identify all locations that have a GroupA
  my @tmp = split //, $seq;
  my @random_select;
  for (my $k = $start; $k < $end; $k++) {
    if (defined ($a_hash{$tmp[$k]})) {
      push (@random_select, $k);
    }
  }

  ##  Fatal error if there are no GroupA positions at all
  my $random_select_positions = scalar (@random_select);
  if ($random_select_positions == 0) {
    printf STDERR "EE\tFatal error!  No Group A within the range [%u, %u]!\n", $start, $end;
    exit (1);
  }
  else {
    ##  Select ONE position to insert
    my $curr_select = int (rand ($random_select_positions));

    ##  Insert a groupA1 before it (lengthening the sequence by 1)
    my $coin_flip = int (rand (scalar (@a1_array)));
    substr ($seq, $random_select[$curr_select], 0) = $a1_array[$coin_flip];
  }

  return ($seq);
}


sub DoubleGroupA1 {
  my ($seq, $start, $end, $a1_ref, $a2_ref, $a_ref, $a1_href, $a2_href, $a_href) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };

  ##  Convert all references back to hashes
  my %a1_hash = %{ $a1_href };
  my %a2_hash = %{ $a2_href };
  my %a_hash = %{ $a_href };

  ##  Identify all locations that have a GroupA
  my @tmp = split //, $seq;
  my @random_select;
  for (my $k = $start; $k < $end; $k++) {
    if (defined ($a1_hash{$tmp[$k]})) {
      push (@random_select, $k);
    }
  }

  ##  If there are no GroupA1 positions at all, look for GroupA
  my $random_select_positions = scalar (@random_select);
  if ($random_select_positions == 0) {
    $seq = DoubleGroupA ($seq, $start, $end, \@a1_array, \@a2_array, \@a_array, \%a1_hash, \%a2_hash, \%a_hash);
  }
  else {
    ##  Select ONE position to insert
    my $curr_select = int (rand ($random_select_positions));

    ##  Insert a groupA1 before it
    my $coin_flip = int (rand (scalar (@a1_array)));
    substr ($seq, $random_select[$curr_select], 0) = $a1_array[$coin_flip];
  }

  return ($seq);
}


sub Postprocess {
  my ($str, $a1_ref, $a2_ref, $a_ref, $a1_href, $a2_href, $a_href) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };

  ##  Convert all references back to hashes
  my %a1_hash = %{ $a1_href };
  my %a2_hash = %{ $a2_href };
  my %a_hash = %{ $a_href };

  my $len = length ($str);

  if ($len >= 120) {
    $str = DoubleGroupA1 ($str, 30, 45, \@a1_array, \@a2_array, \@a_array, \%a1_hash, \%a2_hash, \%a_hash);
    $str = DoubleGroupA1 ($str, 60, 75, \@a1_array, \@a2_array, \@a_array, \%a1_hash, \%a2_hash, \%a_hash);
    $str = DoubleGroupA1 ($str, 90, 110, \@a1_array, \@a2_array, \@a_array, \%a1_hash, \%a2_hash, \%a_hash);
  }
  elsif ($len >= 90) {
    $str = DoubleGroupA1 ($str, 30, 45, \@a1_array, \@a2_array, \@a_array, \%a1_hash, \%a2_hash, \%a_hash);
    $str = DoubleGroupA1 ($str, 60, 75, \@a1_array, \@a2_array, \@a_array, \%a1_hash, \%a2_hash, \%a_hash);
  }
  elsif ($len >= 40) {
    $str = DoubleGroupA1 ($str, 30, 40, \@a1_array, \@a2_array, \@a_array, \%a1_hash, \%a2_hash, \%a_hash);
  }

  return ($str);
}

