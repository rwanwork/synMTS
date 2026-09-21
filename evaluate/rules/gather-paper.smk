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


rule Copy_Main_Files:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-cox2.png",
    input_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-cox2.eps",
    input_fn3 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-atp9.png",
    input_fn4 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-atp9.eps",
    input_fn5 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-atp8.png",
    input_fn6 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-atp8.eps",
    input_fn7 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-hac1.png",
    input_fn8 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-hac1.eps",
    input_fn9 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-mmf1.png",
    input_fn10 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-mmf1.eps",
    input_fn11 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_mitofates_graph/pairwise_MF.png",
    input_fn12 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_mitofates_graph/pairwise_MF.eps",
    input_fn13 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_localisation/deepmito.tex",
    input_fn14 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/deepmito.png",
    input_fn15 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/deepmito.eps",
    input_fn16 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_deepmito_graph/pairwise_DM.png",
    input_fn17 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/07_ranks_deepmito_graph/pairwise_DM.eps"
  output:
    output_fn1 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-2A.png",
    output_fn2 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-2A.eps",
    output_fn3 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-2B.png",
    output_fn4 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-2B.eps",
    output_fn5 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-2C.png",
    output_fn6 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-2C.eps",
    output_fn7 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-2D.png",
    output_fn8 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-2D.eps",
    output_fn9 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-2E.png",
    output_fn10 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-2E.eps",
    output_fn11 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-2F.png",
    output_fn12 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-2F.eps",
    output_fn13 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/text/Figure-3A.tex",
    output_fn14 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-3B.png",
    output_fn15 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-3B.eps",
    output_fn16 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-3C.png",
    output_fn17 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-3C.eps"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    cp {input.input_fn2} {output.output_fn2}
    cp {input.input_fn3} {output.output_fn3}
    cp {input.input_fn4} {output.output_fn4}
    cp {input.input_fn5} {output.output_fn5}
    cp {input.input_fn6} {output.output_fn6}
    cp {input.input_fn7} {output.output_fn7}
    cp {input.input_fn8} {output.output_fn8}
    cp {input.input_fn9} {output.output_fn9}
    cp {input.input_fn10} {output.output_fn10}
    cp {input.input_fn11} {output.output_fn11}
    cp {input.input_fn12} {output.output_fn12}
    cp {input.input_fn13} {output.output_fn13}
    cp {input.input_fn14} {output.output_fn14}
    cp {input.input_fn15} {output.output_fn15}
    cp {input.input_fn16} {output.output_fn16}
    cp {input.input_fn17} {output.output_fn17}
    """


rule Copy_Supp_Files:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_cox2.png",
    input_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_cox2.eps",
    input_fn3 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_atp9.png",
    input_fn4 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_atp9.eps",
    input_fn5 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_atp8.png",
    input_fn6 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_atp8.eps",
    input_fn7 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_hac1.png",
    input_fn8 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_hac1.eps",
    input_fn9 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_mmf1.png",
    input_fn10 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_mmf1.eps"
  output:
    output_fn1 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-S4.png",
    output_fn2 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-S4.eps",
    output_fn3 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-S5.png",
    output_fn4 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-S5.eps",
    output_fn5 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-S6.png",
    output_fn6 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-S6.eps",
    output_fn7 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-S7.png",
    output_fn8 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-S7.eps",
    output_fn9 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/png/Figure-S8.png",
    output_fn10 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-S8.eps"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    cp {input.input_fn2} {output.output_fn2}
    cp {input.input_fn3} {output.output_fn3}
    cp {input.input_fn4} {output.output_fn4}
    cp {input.input_fn5} {output.output_fn5}
    cp {input.input_fn6} {output.output_fn6}
    cp {input.input_fn7} {output.output_fn7}
    cp {input.input_fn8} {output.output_fn8}
    cp {input.input_fn9} {output.output_fn9}
    cp {input.input_fn10} {output.output_fn10}
    """


rule Gather_Paper_Files:
  input:
    input_fn1 = PAPER_MAIN_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-3C.eps",
    input_fn2 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/eps/Figure-S8.eps"
  output:
    output_fn1 = MANUSCRIPT_OUTPUT_DIR + "/evaluate.{greps}_{gproteins}"
  shell:
    """
    touch {output.output_fn1}
    """


