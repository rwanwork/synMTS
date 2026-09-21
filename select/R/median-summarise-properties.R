#!/usr/bin/env Rscript
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


##############################
##  Read in libraries and modules

#  Load in libraries
library (ggplot2)
library (ggsignif)
library (Cairo)  #  For transparency
library (docopt)  #  See:  https://github.com/docopt/docopt.R

library (dplyr)
library (rstatix)  #  wilcox_test
library (tibble)
library (janitor)


#####################################################################
##  Setup constants
#####################################################################

FIGURE_WIDTH <- 18
FIGURE_HEIGHT <- 12
FIGURE_DPI <- 600


#####################################################################
##  Functions
#####################################################################


#####################################################################
##  Process arguments using docopt
#####################################################################

"Usage:
  median-summarise-properties.R --input INPUT --output OUTPUT

Options:
  --input INPUT  Input file
  --output OUTPUT  Output file

.
" -> options

# Retrieve the command-line arguments
arguments <- docopt (options)

INPUT_ARG <- arguments$input
OUTPUT_ARG <- arguments$output


######################################################################
##  Read in the data table
######################################################################

in_fn <- INPUT_ARG

x <- read.table (in_fn, sep="\t", header=TRUE)


######################################################################
##  Group by and then summarise
######################################################################

y_median <- x |>
  group_by (Class) |>
    summarise (number = n(),
      length = median (Length),
      net_charge = median (charge_median),
      flexibility = median (flexibility_median),
      transmembrane = median (transmembrane_median),
      hydropathicity = median (hydropathicity_median),
      polarity = median (polarity_median),
      bulkiness = median (bulkiness_median),
      KR_count = median (krcount_median),
      hydrophobic = median (hydrophobic_median),
      maxhmoment = median (MaxHMoment),
      tophmoment = median (TopHMoment_median),
      allhmoment = median (AllHMoment_median)
      )
y_median_df <- data.frame (y_median)

##  Add an empty row
y_median_df[ nrow (y_median_df) + 1 , ] <- NA

z <- x %>% wilcox_test (Length ~ Class, paired = FALSE)
y_median_df[3,3] <- z$p

## z <- x %>% wilcox_test (charge_median ~ Class, paired = FALSE)
## y_median_df[3,4] <- z$p

z <- x %>% wilcox_test (flexibility_median ~ Class, paired = FALSE)
y_median_df[3,5] <- z$p

z <- x %>% wilcox_test (transmembrane_median ~ Class, paired = FALSE)
y_median_df[3,6] <- z$p

## z <- x %>% wilcox_test (hydropathicity_median ~ Class, paired = FALSE)
## y_median_df[3,7] <- z$p

z <- x %>% wilcox_test (polarity_median ~ Class, paired = FALSE)
y_median_df[3,8] <- z$p

z <- x %>% wilcox_test (bulkiness_median ~ Class, paired = FALSE)
y_median_df[3,9] <- z$p

## z <- x %>% wilcox_test (krcount_median ~ Class, paired = FALSE)
## y_median_df[3,10] <- z$p

z <- x %>% wilcox_test (hydrophobic_median ~ Class, paired = FALSE)
y_median_df[3,11] <- z$p

z <- x %>% wilcox_test (MaxHMoment ~ Class, paired = FALSE)
y_median_df[3,12] <- z$p

z <- x %>% wilcox_test (TopHMoment_median ~ Class, paired = FALSE)
y_median_df[3,13] <- z$p

z <- x %>% wilcox_test (AllHMoment_median ~ Class, paired = FALSE)
y_median_df[3,14] <- z$p

y <- y_median_df


######################################################################
##  Write out the table
######################################################################

##  Transpose the data frame with column and row names intact
##    (note that a warning will be produced since no row names were present initially)
out_y <- data.frame(t(y)) %>% tibble::rownames_to_column() %>% janitor::row_to_names(row_number = 1)

##  Write out the table with 3 decimal places
write.table (format (out_y, digits=3), file = OUTPUT_ARG, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

