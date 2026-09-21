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
library (Cairo)  #  For transparency
library (docopt)  #  See:  https://github.com/docopt/docopt.R
library (stringr)  # str_to_title ()

library (dplyr)


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

"Usage:  deepmito-dotplot.R --input INPUT --output OUTPUT --type IMGTYPE

Options:
  --input INPUT  Input file
  --output OUTPUT  Output file
  --type IMGTYPE  Type of graph to output

.
" -> options

# Retrieve the command-line arguments
opts <- docopt (options)

INPUT_ARG <- opts$input
OUTPUT_ARG <- opts$output
IMGTYPE_ARG <- opts$type


######################################################################
##  Read in the data table
######################################################################

in_fn <- INPUT_ARG

x <- read.table (in_fn, sep="\t", header=TRUE)

colnames (x) <- c ("Name", "Method", "Protein", "Predicted", "Score", "Length", "GO_ID", "GO_Term", "Comments")

x <- x[x$Method == 4 | x$Method == 7,]

##  Remove suffixes if it exists in the protein name
x$Protein <- gsub ("-yeast", "", x$Protein)

##  Change the gene names to proper protein names
p_suffix <- "p"
x$Protein <- paste0 (unlist(str_to_title (x$Protein)), p_suffix)

##  Change Cox2p to the variant we used in the experiments, specific to our work
x$Protein <- gsub ("Cox2p", "Cox2p-W56R", x$Protein)

x$Predicted <- as.factor (x$Predicted)


######################################################################
##  Plot the graph
######################################################################

x$Method <- as.factor (x$Method)
x$Protein <- as.factor (x$Protein)

x_var <- "Protein"
y_var <- "Score"

ggplot_obj <- ggplot (x, aes (x=Protein, y=Score))
ggplot_obj <- ggplot_obj + geom_dotplot (binaxis = "y", stackdir = "center", binpositions="all", binwidth=0.0005)
ggplot_obj <- ggplot_obj + xlab ("Protein") + ylab ("DeepMito Score")
ggplot_obj <- ggplot_obj + theme (legend.position = "none")


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


