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


##################################
##  Rules for various types of plots
##################################

rule Plot_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_deepmito_graph/pairwise_DM.png",
    input_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_deepmito_graph/pairwise_DM.eps",
    input_fn3 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_violin/deepmito.png",
    input_fn4 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_violin/deepmito.eps",
    input_fn5 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/deepmito.png",
    input_fn6 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/deepmito.eps",
    input_fn7 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_dotplot/deepmito.png",
    input_fn8 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_dotplot/deepmito.eps",
    input_fn9 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_localisation/deepmito.tex"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/11_progress/deepmito.txt"
  shell:
    """
    touch {output.output_fn1}
    """


rule Plot_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_mitofates_graph/pairwise_MF.png",
    input_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_mitofates_graph/pairwise_MF.eps",
    input_fn3 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates.all",
    input_fn5 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/all.proteins"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/11_progress/mitofates.txt"
  shell:
    """
    touch {output.output_fn1}
    """


rule Plot_DeepMito_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_both_graph/ranks.png",
    input_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_both_graph/ranks.eps",
    input_fn3 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.jpg",
    input_fn4 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.eps"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/11_progress/deepmito_mitofates.txt"
  shell:
    """
    touch {output.output_fn1}
    """


##################################
##  Global rules for Snakemake.smk
##################################

rule Complete_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/11_progress/deepmito.txt"
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/evaluate/{greps}_{gproteins}_deepmito.done"
  shell:
    """
    touch {output.output_fn1}
    """


rule Complete_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/11_progress/mitofates.txt"
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/evaluate/{greps}_{gproteins}_mitofates.done"
  shell:
    """
    touch {output.output_fn1}
    """


rule Complete_Both:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/11_progress/deepmito_mitofates.txt"
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/evaluate/{greps}_{gproteins}_both.done"
  shell:
    """
    touch {output.output_fn1}
    """


rule Complete_All:
  input:
    input_fn1 = PROGRESS_OUTPUT_DIR + "/evaluate/{greps}_{gproteins}_deepmito.done",
    input_fn2 = PROGRESS_OUTPUT_DIR + "/evaluate/{greps}_{gproteins}_mitofates.done",
    input_fn3 = PROGRESS_OUTPUT_DIR + "/evaluate/{greps}_{gproteins}_both.done",
    input_fn4 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine_subrk/mitofates.tsv",
    input_fn5 = MANUSCRIPT_OUTPUT_DIR + "/evaluate.{greps}_{gproteins}"
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/evaluate/{greps}_{gproteins}_all.done"
  shell:
    """
    touch {output.output_fn1}
    """



