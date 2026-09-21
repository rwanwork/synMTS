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


#####################################################################
##  Setup constants
#####################################################################

FIGURE_WIDTH <- 20
FIGURE_HEIGHT <- 20
FIGURE_DPI <- 600


#####################################################################
##  Functions
#####################################################################


#####################################################################
##  Process arguments using docopt
#####################################################################

"Usage:  mitofates-boxplot-single.R --protein PROTEIN --input INPUT --output OUTPUT --type IMGTYPE

Options:
  --protein PROTEIN  Name of protein to focus on
  --input INPUT  Input file
  --output OUTPUT  Output file
  --type IMGTYPE  Type of graph to output

.
" -> options

# Retrieve the command-line arguments
opts <- docopt (options)

PROTEIN_ARG <- opts$protein
INPUT_ARG <- opts$input
OUTPUT_ARG <- opts$output
IMGTYPE_ARG <- opts$type


######################################################################
##  Read in the data table
######################################################################

in_fn <- INPUT_ARG

x <- read.table (in_fn, sep="\t", header=TRUE)

x <- x[x$Protein == PROTEIN_ARG,]

##  Remove suffixes if it exists in the protein name
x$Protein <- gsub ("-yeast", "", x$Protein)

##  Change the gene names to proper protein names
p_suffix <- "p"
x$Protein <- paste0 (unlist (str_to_title (x$Protein)), p_suffix)

##  Change the title as well
my_title <- paste0 (unlist (str_to_title (PROTEIN_ARG)), p_suffix)

##  Change Cox2p to the variant we used in the experiments, specific to our work
x$Protein <- gsub ("Cox2p", "Cox2p-W56R", x$Protein)


######################################################################
##  Plot the graph
######################################################################

x$Method <- as.factor (x$Method)

x_var <- "Method"
y_var <- "Probability"

ggplot_obj <- ggplot (x, aes (.data[[x_var]], .data[[y_var]]))
ggplot_obj <- ggplot_obj + geom_boxplot (position="dodge", aes (fill=Method))
ggplot_obj <- ggplot_obj + xlab ("Method") + ylab ("MitoFates Probability")
#ggplot_obj <- ggplot_obj + labs (title = my_title)
ggplot_obj <- ggplot_obj + theme (legend.position = "none", plot.title = element_text (hjust = 0.5), plot.title.position = "plot", text = element_text (size = 22))


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

