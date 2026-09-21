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


rule Intersect_DeepMito_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_deepmito_combine/deepmito.tsv",
    input_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine/mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.log"
  shell:
    """
    Perl/intersect-deepmito-mitofates.pl --deepmito {input.input_fn1} --mitofates {input.input_fn2} >{output.output_fn1} 2>{log.log_fn1}
    """


rule Scatterplot_DeepMito_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.jpg",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_scatterplot/deepmito_mitofates.log"
  shell:
    """
    R/scatterplot.R --type jpg --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/scatterplot.R --type eps --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


