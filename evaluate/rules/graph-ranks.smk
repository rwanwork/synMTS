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


rule Plot_DeepMito_MitoFates_Ranks:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_both/ranks.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_both_graph/ranks.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_both_graph/ranks.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_both_graph/ranks.log"
  shell:
    """
    R/ranks.R --type png --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/ranks.R --type eps --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


rule Plot_DeepMito_Ranks:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_deepmito/pairwise.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_deepmito_graph/pairwise_DM.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_deepmito_graph/pairwise_DM.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_deepmito_graph/pairwise_DM.log"
  shell:
    """
    R/ranks-deepmito.R --type png --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/ranks-deepmito.R --type eps --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


rule Plot_MitoFates_Ranks:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_mitofates/pairwise.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_mitofates_graph/pairwise_MF.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_mitofates_graph/pairwise_MF.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_mitofates_graph/pairwise_MF.log"
  shell:
    """
    R/ranks-mitofates.R --type png --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/ranks-mitofates.R --type eps --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


