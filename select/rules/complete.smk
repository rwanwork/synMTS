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


rule Complete_Real:
  input:
    input_fn1 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/oxa1.eps",
    input_fn2 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/su9.eps"
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/select/real_mts.done"
  shell:
    """
    touch {output.output_fn1}
    """


rule Complete_MTS:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/mts-graphs.done",
    input_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/07_streme_normal/streme.html",
    input_fn3 = OUTPUT_DIR + "/select/{greps}/{protein}/08_streme_altalphabet/streme.html",
    input_fn4 = OUTPUT_DIR + "/select/{greps}/{protein}/11_aggregate_properties_cleaned/out.tex"
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/select/{greps}_{protein}_mts.done"
  shell:
    """
    touch {output.output_fn1}
    """


rule Complete_All:
  input:
    input_fn1 = PROGRESS_OUTPUT_DIR + "/select/real_mts.done",
    input_fn2 = PROGRESS_OUTPUT_DIR + "/select/{greps}_{protein}_mts.done",
    input_fn3 = MANUSCRIPT_OUTPUT_DIR + "/select.{greps}",
    input_fn4 = MANUSCRIPT_OUTPUT_DIR + "/select.{greps}_{protein}"
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/select/{greps}_{protein}.done"
  shell:
    """
    touch {output.output_fn1}
    """


