#!/usr/bin/env perl
#####################################################################
##  Random_Methods.pm
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
package Random_Methods;

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
our @EXPORT = qw (Method1 Method2 Method3 Method4 Method5 Method6);

##  Directories where Perl modules are stored
use lib qw (. ../../Common/Perl/);

use Statistics_Utils;
use Random_Utils;


########################################
##  Various methods
########################################
sub Method1 {
  my ($len, $a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my $str = "";

  $str = SelectFromGroup (\@all_array, $len, $len);

  return ($str);
}


sub Method2 {
  my ($len, $a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my $str = "";

  $str = SelectFromGroup (\@all_array, $len, $len);

  return ($str);
}


sub Method3 {
  my ($len, $min_charge_arg, $aa_ref, $a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert reference back to hash
  my %aa_hash = %{ $aa_ref };

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my $str = "";

  $str = SelectFromGroup (\@all_array, $len, $len);

  my $charge_sum = SumStats (\%aa_hash, $str, "charge");
  while ($charge_sum < $min_charge_arg) {
    $str = Permute ($str, \@a1_array, \@a2_array, \@a_array, \@b_array, \@all_array);
    $charge_sum = SumStats (\%aa_hash, $str, "charge");
  }

  return ($str);
}


sub Method4 {
  my ($len, $a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my $str = "";

  ##  Fill in the middle; note, very likely to be longer than $len in the end
  $str = SelectFromGroup (\@b_array, 2, 4);
  while (length ($str) < $len) {
    my $str1 = SelectFromGroup (\@a1_array, 1, 1);
    my $str2 = SelectFromGroup (\@b_array, 2, 4);
    $str = $str.$str1.$str2;
  }

  return ($str);
}


sub Method5 {
  my ($len, $a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my $str = "";

  ##  Fill in the middle; note, very likely to be longer than $len in the end
  $str = SelectFromGroup (\@b_array, 2, 4);
  while (length ($str) < $len) {
    my $str1 = SelectFromGroup (\@a2_array, 1, 1);
    my $str2 = SelectFromGroup (\@b_array, 2, 4);
    $str = $str.$str1.$str2;
  }

  return ($str);
}


sub Method6 {
  my ($len, $a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my $str = "";

  ##  Fill in the middle; note, very likely to be longer than $len in the end
  $str = SelectFromGroup (\@b_array, 2, 4);
  while (length ($str) < $len) {
    my $str1 = SelectFromGroup (\@a_array, 1, 1);
    my $str2 = SelectFromGroup (\@b_array, 2, 4);
    $str = $str.$str1.$str2;
  }

  return ($str);
}


