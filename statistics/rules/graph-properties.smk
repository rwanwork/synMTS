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


rule Graph_Properties_Dist:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/03_properties_all/all.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_properties.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_properties.eps"
  shell:
    """
    R/properties-dist.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/properties-dist.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """


rule Graph_Properties_Length:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/03_properties_all/all.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_length.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_length.eps"
  shell:
    """
    R/properties-length.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/properties-length.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """


rule Graph_Properties_Charge:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/03_properties_all/all.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_charge.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_charge.eps"
  shell:
    """
    R/properties-charge.R --type png --input {input.input_fn1} --output {output.output_fn1}
    R/properties-charge.R --type eps --input {input.input_fn1} --output {output.output_fn2}
    """


