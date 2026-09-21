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
##  Define local functions
##################################



##################################
##  Define rules
##################################

rule Graph_HMoment_Maximum:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-maximum.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-maximum.eps"
  shell:
    """
    R/hmoment-maximum.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/hmoment-maximum.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """


rule Graph_HMoment_TopAvg:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-topavg.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-topavg.eps"
  shell:
    """
    R/hmoment-topavg.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/hmoment-topavg.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """


rule Graph_HMoment_TopMedian:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-topmedian.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-topmedian.eps"
  shell:
    """
    R/hmoment-topmedian.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/hmoment-topmedian.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """


rule Graph_HMoment_AllAvg:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-allavg.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-allavg.eps"
  shell:
    """
    R/hmoment-allavg.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/hmoment-allavg.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """


rule Graph_HMoment_AllMedian:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-allmedian.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-allmedian.eps"
  shell:
    """
    R/hmoment-allmedian.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/hmoment-allmedian.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """

