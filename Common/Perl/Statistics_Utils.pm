#!/usr/bin/env perl
#####################################################################
##  Statistics_Utils.pm
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
package Statistics_Utils;

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
our @EXPORT = qw (SumStats AvgStats CalculateStats CalculateStatsAvgNoID CalculateStatsMedianNoID);

##  Directories where Perl modules are stored
use lib qw (. ../../Common/Perl/);


########################################
##  Various methods
########################################

sub SumStats {
  my ($aa_ref, $seq, $method) = @_;

  my %aa_hash = %{ $aa_ref };
  my $sum = 0;

  my @tmp = split //, $seq;
  my $length = scalar (@tmp);

  for (my $k = 0; $k < $length; $k++) {
    if (!defined ($aa_hash{$tmp[$k]}{$method})) {
      printf STDERR "%s %s\n", $tmp[$k], $method;
    }
    $sum += $aa_hash{$tmp[$k]}{$method};
  }

  return ($sum);
}


sub AvgStats {
  my ($aa_ref, $seq, $method) = @_;

  my %aa_hash = %{ $aa_ref };
  my $sum = 0;

  my @tmp = split //, $seq;
  my $length = scalar (@tmp);

  for (my $k = 0; $k < $length; $k++) {
    if (!defined ($aa_hash{$tmp[$k]}{$method})) {
      printf STDERR "%s %s\n", $tmp[$k], $method;
    }
    $sum += $aa_hash{$tmp[$k]}{$method};
  }

  return ($sum / $length);
}


sub MedianStats {
  my ($aa_ref, $seq, $method) = @_;

  my %aa_hash = %{ $aa_ref };

  my @tmp = split //, $seq;
  my $length = scalar (@tmp);

  my @values;

  for (my $k = 0; $k < $length; $k++) {
    if (!defined ($aa_hash{$tmp[$k]}{$method})) {
      printf STDERR "%s %s\n", $tmp[$k], $method;
    }

    push (@values, $aa_hash{$tmp[$k]}{$method});
  }

  ##  Sort numerically descending
  my @sorted_values = sort {$b <=> $a} @values;

  my $median_pos = 0;
  my $median_value = 0;
  if ($length % 2 == 0) {
    ##  Even -- take the average of the two values around the centre
    $median_pos = $length / 2;
    $median_value = ($sorted_values[$median_pos - 1] + $sorted_values[$median_pos]) / 2;
  }
  else {
    ##  Odd -- take the centre value
    $median_pos = int ($length / 2);
    $median_value = $sorted_values[$median_pos];
  }

  return ($median_value);
}


sub CalculateStats {
  my ($aa_ref, $id, $seq) = @_;
  my $stats_str = "";

  my %aa_hash = %{ $aa_ref };

  my $charge_sum = SumStats (\%aa_hash, $seq, "charge");
  my $flexibility_sum = SumStats (\%aa_hash, $seq, "flexibility");
  my $transmembrane_sum = SumStats (\%aa_hash, $seq, "transmembrane");
  my $hydropathicity_sum = SumStats (\%aa_hash, $seq, "hydropathicity");
  my $polarity_sum = SumStats (\%aa_hash, $seq, "polarity");
  my $bulkiness_sum = SumStats (\%aa_hash, $seq, "bulkiness");
  my $krcount_sum = SumStats (\%aa_hash, $seq, "krcount");
  my $hydrophobic_sum = SumStats (\%aa_hash, $seq, "hydrophobic");

  my $charge_avg = AvgStats (\%aa_hash, $seq, "charge");
  my $flexibility_avg = AvgStats (\%aa_hash, $seq, "flexibility");
  my $transmembrane_avg = AvgStats (\%aa_hash, $seq, "transmembrane");
  my $hydropathicity_avg = AvgStats (\%aa_hash, $seq, "hydropathicity");
  my $polarity_avg = AvgStats (\%aa_hash, $seq, "polarity");
  my $bulkiness_avg = AvgStats (\%aa_hash, $seq, "bulkiness");
  my $krcount_avg = AvgStats (\%aa_hash, $seq, "krcount");
  my $hydrophobic_avg = AvgStats (\%aa_hash, $seq, "hydrophobic");

  $stats_str = $id."\t".length ($seq);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $charge_sum, $charge_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $flexibility_sum, $flexibility_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $transmembrane_sum, $transmembrane_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $hydropathicity_sum, $hydropathicity_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $polarity_sum, $polarity_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $bulkiness_sum, $bulkiness_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $krcount_sum, $krcount_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $hydrophobic_sum, $hydrophobic_avg);

  return ($stats_str);
}


sub CalculateStatsAvgNoID {
  my ($aa_ref, $id, $seq) = @_;
  my $stats_str = "";

  my %aa_hash = %{ $aa_ref };

  my $charge_sum = SumStats (\%aa_hash, $seq, "charge");
  my $flexibility_sum = SumStats (\%aa_hash, $seq, "flexibility");
  my $transmembrane_sum = SumStats (\%aa_hash, $seq, "transmembrane");
  my $hydropathicity_sum = SumStats (\%aa_hash, $seq, "hydropathicity");
  my $polarity_sum = SumStats (\%aa_hash, $seq, "polarity");
  my $bulkiness_sum = SumStats (\%aa_hash, $seq, "bulkiness");
  my $krcount_sum = SumStats (\%aa_hash, $seq, "krcount");
  my $hydrophobic_sum = SumStats (\%aa_hash, $seq, "hydrophobic");

  my $charge_avg = AvgStats (\%aa_hash, $seq, "charge");
  my $flexibility_avg = AvgStats (\%aa_hash, $seq, "flexibility");
  my $transmembrane_avg = AvgStats (\%aa_hash, $seq, "transmembrane");
  my $hydropathicity_avg = AvgStats (\%aa_hash, $seq, "hydropathicity");
  my $polarity_avg = AvgStats (\%aa_hash, $seq, "polarity");
  my $bulkiness_avg = AvgStats (\%aa_hash, $seq, "bulkiness");
  my $krcount_avg = AvgStats (\%aa_hash, $seq, "krcount");
  my $hydrophobic_avg = AvgStats (\%aa_hash, $seq, "hydrophobic");

  $stats_str = sprintf ("%.3f\t%.3f", $charge_sum, $charge_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $flexibility_sum, $flexibility_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $transmembrane_sum, $transmembrane_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $hydropathicity_sum, $hydropathicity_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $polarity_sum, $polarity_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $bulkiness_sum, $bulkiness_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $krcount_sum, $krcount_avg);
  $stats_str = $stats_str."\t".sprintf ("%.3f\t%.3f", $hydrophobic_sum, $hydrophobic_avg);

  return ($stats_str);
}


sub CalculateStatsMedianNoID {
  my ($aa_ref, $id, $seq) = @_;
  my $stats_str = "";

  my %aa_hash = %{ $aa_ref };

  my $charge_median = MedianStats (\%aa_hash, $seq, "charge");
  my $flexibility_median = MedianStats (\%aa_hash, $seq, "flexibility");
  my $transmembrane_median = MedianStats (\%aa_hash, $seq, "transmembrane");
  my $hydropathicity_median = MedianStats (\%aa_hash, $seq, "hydropathicity");
  my $polarity_median = MedianStats (\%aa_hash, $seq, "polarity");
  my $bulkiness_median = MedianStats (\%aa_hash, $seq, "bulkiness");
  my $krcount_median = MedianStats (\%aa_hash, $seq, "krcount");
  my $hydrophobic_median = MedianStats (\%aa_hash, $seq, "hydrophobic");

  $stats_str = sprintf ("%.3f", $charge_median);
  $stats_str = $stats_str."\t".sprintf ("%.3f", $flexibility_median);
  $stats_str = $stats_str."\t".sprintf ("%.3f", $transmembrane_median);
  $stats_str = $stats_str."\t".sprintf ("%.3f", $hydropathicity_median);
  $stats_str = $stats_str."\t".sprintf ("%.3f", $polarity_median);
  $stats_str = $stats_str."\t".sprintf ("%.3f", $bulkiness_median);
  $stats_str = $stats_str."\t".sprintf ("%.3f", $krcount_median);
  $stats_str = $stats_str."\t".sprintf ("%.3f", $hydrophobic_median);

  return ($stats_str);
}


