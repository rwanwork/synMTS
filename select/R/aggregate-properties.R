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
library (docopt)
library (tidyverse)
library (rstatix)


#####################################################################
##  Setup constants
#####################################################################


#####################################################################
##  Functions
#####################################################################


#####################################################################
##  Process arguments using docopt
#####################################################################

"Usage:
  aggegate-properties.R --input INPUT --output OUTPUT

Options:
  --input INPUT  Input file
  --output OUTPUT  Output file

.
" -> options

# Retrieve the command-line arguments
arguments <- docopt (options)

INPUT_ARG <- arguments$input
OUTPUT_ARG <- arguments$out


######################################################################
##  Read in the data table
######################################################################

in_fn <- INPUT_ARG

x <- read.table (in_fn, sep="\t", header=TRUE)

##  Delete unnecessary columns
x$Method <- NULL
x$Protein <- NULL
x$Name <- NULL

x$Category <- gsub ("0", "No", x$Category)
x$Category <- gsub ("1", "Yes", x$Category)


######################################################################
##  Perform the aggregation
######################################################################

stats <- x %>%
  group_by (Category) %>%
  get_summary_stats (type = "mean_sd") %>%
  pivot_wider (names_from = Category, values_from = c(n, mean, sd), names_glue = "{.value} (Category={Category})")

pvals <- x %>%
  pivot_longer(-Category) %>%
  group_by(name) %>%
  t_test(data = ., formula = value ~ Category)

combined <- stats %>%
  left_join (pvals, by = c("variable" = "name")) %>%
  select (-c(.y., group1, group2, n1, n2))

y <- data.frame (combined)

z <- y[c("variable", "mean..Category.Yes.", "sd..Category.Yes.", "n..Category.Yes.", "mean..Category.No.", "sd..Category.No.", "n..Category.No.", "p")]


######################################################################
##  Write out the data table
######################################################################

out_fn <- OUTPUT_ARG

write.table (z, file = out_fn, sep="\t", col.names = TRUE)

