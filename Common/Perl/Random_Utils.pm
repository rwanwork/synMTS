#!/usr/bin/env perl
#####################################################################
##  Random_Utils.pm
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
package Random_Utils;

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
our @EXPORT = qw (SelectFromGroup SelectBegin SelectEnd Permute);

##  Directories where Perl modules are stored
use lib qw (. ../../Common/Perl/);


########################################
##  Randomly select from %group_ref [$from, $to]
##    (inclusive of end points)
########################################
sub SelectFromGroup {
  my ($group_ref, $from, $to) = @_;

  my @group_array = @{ $group_ref };
  my $str = "";

  my $range = $to - $from + 1;
  my $num = int (rand ($range));
  $num = $num + $from;

  ##  $num is the number of aa to select
  for (my $k = 0; $k < $num; $k++) {
    my $coin_flip = int (rand (scalar (@group_array)));
    $str = $str.$group_array[$coin_flip];
  }

  return ($str);
}


########################################
##  Beginning or end of a sequence
########################################
sub SelectBegin {
  my $str1 = "";
  my $str2 = "";

  my $str = "M";

  return ($str);
}


sub SelectEnd {
  my ($a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my $str = "";

  ##  Two possible ways to end a sequence
  my $other_aa = SelectFromGroup (\@all_array, 1, 1);

  my $coin_flip = rand ();
  if ($coin_flip < 0.5) {
    $str = "R".$other_aa;
  }
  else {
    $str = "R".$other_aa."Y";
  }

  return ($str);
}


########################################
##  Randomly permute within a sequence to A1
########################################
sub Permute {
  my ($str, $a1_ref, $a2_ref, $a_ref, $b_ref, $all_ref) = @_;

  ##  Convert all references back to arrays
  my @a1_array = @{ $a1_ref };
  my @a2_array = @{ $a2_ref };
  my @a_array = @{ $a_ref };
  my @b_array = @{ $b_ref };
  my @all_array = @{ $all_ref };

  my @tmp_array = split //, $str;

  ##  Select where to change
  my $location = int (rand (scalar (@tmp_array)));

  ##  Select what to change it to
  my $coin_flip = int (rand (scalar (@a1_array)));

  ##  Perform the change
  $tmp_array[$location] = $a1_array[$coin_flip];

  ##  Join the sequence back up
  $str = join ('', @tmp_array);

  return ($str);
}


