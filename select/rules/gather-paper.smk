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


rule Copy_Supp_NoProtein_Files:
  input:
    input_fn1 = SELECTORDER_FILE,
    input_fn2 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/oxa1.png",
    input_fn3 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/oxa1.eps",
    input_fn4 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/su9.png",
    input_fn5 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/su9.eps"
  output:
    output_fn1 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/text/select-order.tsv",
    output_fn2 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/png/oxa1.png",
    output_fn3 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/eps/oxa1.eps",
    output_fn4 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/png/su9.png",
    output_fn5 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/eps/su9.eps",
    output_fn0 = MANUSCRIPT_OUTPUT_DIR + "/select.{greps}"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    cp {input.input_fn2} {output.output_fn2}
    cp {input.input_fn3} {output.output_fn3}
    cp {input.input_fn4} {output.output_fn4}
    cp {input.input_fn5} {output.output_fn5}

    touch {output.output_fn0}
    """


rule Copy_Supp_Protein_Files:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/11_aggregate_properties_cleaned/out.tex",
    input_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/07_streme_normal/streme.html",
    input_fn3 = OUTPUT_DIR + "/select/{greps}/{protein}/08_streme_altalphabet/streme.html"
  output:
    output_fn1 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/text/{protein}.tex",
    output_fn2 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/text/{protein}-normal.html",
    output_fn3 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/text/{protein}-altalphabet.html",
    output_fn0 = MANUSCRIPT_OUTPUT_DIR + "/select.{greps}_{protein}"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    cp {input.input_fn2} {output.output_fn2}
    cp {input.input_fn3} {output.output_fn3}

    touch {output.output_fn0}
    """


