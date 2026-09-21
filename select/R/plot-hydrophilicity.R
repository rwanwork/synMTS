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

library(dplyr)


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
  plot-hydrophilicity.R --input INPUT --output OUTPUT --type IMGTYPE [--rescale] [--showaa] [--showpos] [--emptyx]

Options:
  --input INPUT  Input file
  --output OUTPUT  Output file
  --type IMGTYPE  Type of graph to output
  --rescale   Rescale the horizontal dimensions based on the sequence length
  --showaa    Show amino acids along the x-axis
  --showpos   Show positions along the x-axis
  --emptyx    Show nothing along the x-axis (the default)

.
" -> options

# Retrieve the command-line arguments
arguments <- docopt (options)

INPUT_ARG <- arguments$input
OUTPUT_ARG <- arguments$output
IMGTYPE_ARG <- arguments$type
SHOWAA_ARG <- arguments$showaa
SHOWPOS_ARG <- arguments$showpos
EMPTYX_ARG <- arguments$emptyx
RESCALE_ARG <- arguments$rescale

##  Check certain combinations of arguments are disallowed
if (SHOWAA_ARG & SHOWPOS_ARG) {
  stop ("EE\tCannot execute with both the --showaa and --showpos options together!")
}


######################################################################
##  Read in the data table
######################################################################

in_fn <- INPUT_ARG

x <- read.table (in_fn, sep="\t", header=TRUE)

##  Need to convert column to a factor if amino acids are shown
if (SHOWAA_ARG) {
  x$Position <- as.factor (x$Position)
}


######################################################################
##  Adjust the figure width
######################################################################

if (RESCALE_ARG) {
  ##  Originally, the figure width is 18.  This looks reasonable for
  ##    a sequence of 44 amino acids.  Hence this conversion factor.
  FIGURE_WIDTH <- ((length (x$Base)) * FIGURE_WIDTH) / 44
}


######################################################################
##  Plot the graph
######################################################################

ggplot_obj <- ggplot (x, aes (x=Position, y=Hydrophilicity, fill=Colour))
ggplot_obj <- ggplot_obj + geom_bar (stat="identity")
ggplot_obj <- ggplot_obj + theme (legend.position="none")
ggplot_obj <- ggplot_obj + scale_fill_identity (guide = "none") + xlab ("Amino acids")
ggplot_obj <- ggplot_obj + theme_classic () + scale_y_continuous(limits = c(-3.5, 3.5))
ggplot_obj <- ggplot_obj + geom_hline (yintercept = 0)


######################################################################
##  Adjust the x-axis; note the order of the if statements
######################################################################

##  Show amino acids along the top
if (SHOWAA_ARG) {
  ggplot_obj <- ggplot_obj + scale_x_discrete (breaks=seq(1, length (x$Base), 1), labels = x$Base, position = "top")
}

##  Show positions along the bottom
if (SHOWPOS_ARG) {
  ggplot_obj <- ggplot_obj + scale_x_continuous (breaks = seq (0, length (x$Base), by = 10))
}

##  If we do not want x-axis labels
if (EMPTYX_ARG) {
  ggplot_obj <- ggplot_obj + theme (axis.ticks.x = element_blank(), axis.text.x=element_blank ())
}


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


