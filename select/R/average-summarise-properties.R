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
  average-summarise-properties.R --input INPUT --output OUTPUT

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

y_mean <- x |>
  group_by (Class) |>
    summarise (number = n(),
      length = mean (Length),
      net_charge = mean (charge_sum),
      charge_density = mean (charge_avg),
      flexibility = mean (flexibility_avg),
      transmembrane = mean (transmembrane_avg),
      hydropathicity = mean (hydropathicity_avg),
      polarity = mean (polarity_avg),
      bulkiness = mean (bulkiness_avg),
      KR_count = mean (krcount_avg),
      hydrophobic = mean (hydrophobic_avg),
      maxhmoment = mean (MaxHMoment),
      tophmoment = mean (TopHMoment_avg),
      allhmoment = mean (AllHMoment_avg)
      )
y_mean_df <- data.frame (y_mean)

y_sd <- x |>
  group_by (Class) |>
    summarise (number = n(),
      length = sd (Length),
      net_charge = sd (charge_sum),
      charge_density = sd (charge_avg),
      flexibility = sd (flexibility_avg),
      transmembrane = sd (transmembrane_avg),
      hydropathicity = sd (hydropathicity_avg),
      polarity = sd (polarity_avg),
      bulkiness = sd (bulkiness_avg),
      KR_count = sd (krcount_avg),
      hydrophobic = sd (hydrophobic_avg),
      maxhmoment = sd (MaxHMoment),
      tophmoment = sd (TopHMoment_avg),
      allhmoment = sd (AllHMoment_avg)
      )
y_sd_df <- data.frame (y_sd)


##  Add an empty row
y_mean_df[ nrow (y_mean_df) + 1 , ] <- NA

z <- x %>% wilcox_test (Length ~ Class, paired = FALSE)
y_mean_df[3,3] <- z$p

z <- x %>% wilcox_test (charge_sum ~ Class, paired = FALSE)
y_mean_df[3,4] <- z$p

z <- x %>% wilcox_test (charge_avg ~ Class, paired = FALSE)
y_mean_df[3,5] <- z$p

z <- x %>% wilcox_test (flexibility_avg ~ Class, paired = FALSE)
y_mean_df[3,6] <- z$p

z <- x %>% wilcox_test (transmembrane_avg ~ Class, paired = FALSE)
y_mean_df[3,7] <- z$p

z <- x %>% wilcox_test (hydropathicity_avg ~ Class, paired = FALSE)
y_mean_df[3,8] <- z$p

z <- x %>% wilcox_test (polarity_avg ~ Class, paired = FALSE)
y_mean_df[3,9] <- z$p

z <- x %>% wilcox_test (bulkiness_avg ~ Class, paired = FALSE)
y_mean_df[3,10] <- z$p

z <- x %>% wilcox_test (krcount_avg ~ Class, paired = FALSE)
y_mean_df[3,11] <- z$p

z <- x %>% wilcox_test (hydrophobic_avg ~ Class, paired = FALSE)
y_mean_df[3,12] <- z$p

z <- x %>% wilcox_test (MaxHMoment ~ Class, paired = FALSE)
y_mean_df[3,13] <- z$p

z <- x %>% wilcox_test (TopHMoment_avg ~ Class, paired = FALSE)
y_mean_df[3,14] <- z$p

z <- x %>% wilcox_test (AllHMoment_avg ~ Class, paired = FALSE)
y_mean_df[3,15] <- z$p

y <- rbind (y_mean_df, y_sd_df)


######################################################################
##  Write out the table
######################################################################

##  Transpose the data frame with column and row names intact
##    (note that a warning will be produced since no row names were present initially)
out_y <- data.frame(t(y)) %>% tibble::rownames_to_column() %>% janitor::row_to_names(row_number = 1)

##  Write out the table with 3 decimal places
write.table (format (out_y, digits=3), file = OUTPUT_ARG, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

