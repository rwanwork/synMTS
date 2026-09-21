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
##  Print the header to standard out
########################################

printf STDOUT "Name";
printf STDOUT "\tMethod";
printf STDOUT "\tProtein";
printf STDOUT "\tProbability";
printf STDOUT "\tPrediction";
printf STDOUT "\tCleavage_site";
printf STDOUT "\tNet charge";
printf STDOUT "\tTOM20";
printf STDOUT "\tAmphypathic_alpha-helix_position";
printf STDOUT "\tBHHPPP";
printf STDOUT "\tBPHBHH";
printf STDOUT "\tHBHHBb";
printf STDOUT "\tHBHHbB";
printf STDOUT "\tHHBHHB";
printf STDOUT "\tHHBPHB";
printf STDOUT "\tHHBPHH";
printf STDOUT "\tHHBPHP";
printf STDOUT "\tHHHBBH";
printf STDOUT "\tHHHBPH";
printf STDOUT "\tHHHHBB";
printf STDOUT "\tHHPBHH";
printf STDOUT "\tHPBHHP";
printf STDOUT "\tPHHBPH";
printf STDOUT "\n";


