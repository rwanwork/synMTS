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
library (stringr)  # str_to_title ()
library (ggpubr)  # stat_cor ()


#####################################################################
##  Setup constants
#####################################################################

FIGURE_WIDTH <- 18
FIGURE_HEIGHT <- 18
FIGURE_DPI <- 600


#####################################################################
##  Functions
#####################################################################


#####################################################################
##  Process arguments using docopt
#####################################################################

"Usage:  scatterplot-mitofates-hmoment.R --input INPUT --output OUTPUT --protein PROTEIN --column COLUMN --type IMGTYPE

Options:
  --input INPUT  Input file
  --output OUTPUT  Output file
  --protein PROTEIN  Protein to focus on
  --column COLUMN  Column in the HMoment table to select
  --type IMGTYPE  Type of graph to output

.
" -> options

# Retrieve the command-line arguments
opts <- docopt (options)

INPUT_ARG <- opts$input
OUTPUT_ARG <- opts$output
PROTEIN_ARG <- opts$protein
COLUMN_ARG <- opts$column
IMGTYPE_ARG <- opts$type


######################################################################
##  Read in the data table
######################################################################

in_fn <- INPUT_ARG

x <- read.table (in_fn, sep="\t", header=TRUE)

x <- x[x$Protein == PROTEIN_ARG,]

##  Change the gene names to proper protein names
p_suffix <- "p"
x$Protein <- paste0 (unlist(str_to_title (x$Protein)), p_suffix)

##  Change Cox2p to the variant we used in the experiments, specific to our work
x$Protein <- gsub ("Cox2p", "Cox2p-W56R", x$Protein)

##  Add the word "Method" to the x$Method column
x$Method <- gsub ("(\\d)", "Method \\1", x$Method)


######################################################################
##  Decide on the y-axis label
######################################################################

if (str_equal (COLUMN_ARG, "AllAvg")) {
  a = expression (mu)
  b = expression ("Hmean")
  e <- substitute (a * b, lapply (list (a = a, b = b), "[[", 1))
} else if (str_equal (COLUMN_ARG, "AllMedian")) {
  a = expression (mu)
  b = expression ("Hmedian")
  e <- substitute (a * b, lapply (list (a = a, b = b), "[[", 1))
} else if (str_equal (COLUMN_ARG, "Maximum")) {
  a = expression (mu)
  b = expression ("Hmax")
  e <- substitute (a * b, lapply (list (a = a, b = b), "[[", 1))
} else if (str_equal (COLUMN_ARG, "TopAvg")) {
  a = expression ("Average of top 10% of ")
  b = expression (mu)
  c = expression ("H")
  e <- substitute (a * b * c, lapply (list (a = a, b = b, c = c), "[[", 1))
} else if (str_equal (COLUMN_ARG, "TopMedian")) {
  a = expression ("Median of top 10% of ")
  b = expression (mu)
  c = expression ("H")
  e <- substitute (a * b * c, lapply (list (a = a, b = b, c = c), "[[", 1))
}


######################################################################
##  Plot the graph
######################################################################

mitofates_str <- "MitoFates"

ggplot_obj <- ggplot (x, aes (x = eval (str2expression(mitofates_str)), y = eval (str2expression(COLUMN_ARG))))
ggplot_obj <- ggplot_obj + geom_point()
ggplot_obj <- ggplot_obj + facet_wrap (~ Method, ncol=3)
ggplot_obj <- ggplot_obj + stat_cor (method = "spearman")
ggplot_obj <- ggplot_obj + labs (x = mitofates_str, y = e)


######################################################################
##  Write out the graph
######################################################################

out_fn <- OUTPUT_ARG
if (IMGTYPE_ARG == "jpg") {
  ggsave (out_fn, plot=ggplot_obj, device="jpg", width = FIGURE_WIDTH, height = FIGURE_HEIGHT, dpi = FIGURE_DPI, units = "cm")
} else if (IMGTYPE_ARG == "eps") {
  ggsave (out_fn, plot=ggplot_obj, device="eps", width = FIGURE_WIDTH, height = FIGURE_HEIGHT, dpi = FIGURE_DPI, units = "cm")
} else if (IMGTYPE_ARG == "png") {
  ggsave (out_fn, plot=ggplot_obj, device="png", width = FIGURE_WIDTH, height = FIGURE_HEIGHT, dpi = FIGURE_DPI, units = "cm")
}

