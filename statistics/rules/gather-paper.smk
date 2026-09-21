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


rule Copy_Supp_NoWindow_Files:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_length.png",
    input_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_length.eps",
    input_fn3 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_charge.png",
    input_fn4 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/04_properties_graphs/mts_charge.eps",
  output:
    output_fn1 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/png/Figure-S2.png",
    output_fn2 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/eps/Figure-S2.eps",
    output_fn3 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/png/Figure-S3.png",
    output_fn4 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/eps/Figure-S3.eps",
    output_fn0 = MANUSCRIPT_OUTPUT_DIR + "/statistics.{greps}"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    cp {input.input_fn2} {output.output_fn2}
    cp {input.input_fn3} {output.output_fn3}
    cp {input.input_fn4} {output.output_fn4}

    touch {output.output_fn0}
    """


rule Copy_Supp_Window_Files:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-maximum.png",
    input_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-maximum.eps",
    input_fn3 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-topavg.png",
    input_fn4 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-topavg.eps",
    input_fn5 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-allavg.png",
    input_fn6 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/06_hmoment_graph/hmoment-allavg.eps",
    input_fn7 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-cox2.png",
    input_fn8 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-cox2.eps",
    input_fn9 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-atp9.png",
    input_fn10 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-atp9.eps",
    input_fn11 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-atp8.png",
    input_fn12 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-atp8.eps",
    input_fn13 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-hac1.png",
    input_fn14 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-hac1.eps",
    input_fn15 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-mmf1.png",
    input_fn16 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-mmf1.eps",
    input_fn17 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-cox2.png",
    input_fn18 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-cox2.eps",
    input_fn19 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-atp9.png",
    input_fn20 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-atp9.eps",
    input_fn21 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-atp8.png",
    input_fn22 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-atp8.eps",
    input_fn23 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-hac1.png",
    input_fn24 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-hac1.eps",
    input_fn25 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-mmf1.png",
    input_fn26 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-mmf1.eps",
    input_fn27 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-cox2.png",
    input_fn28 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-cox2.eps",
    input_fn29 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-atp9.png",
    input_fn30 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-atp9.eps",
    input_fn31 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-atp8.png",
    input_fn32 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-atp8.eps",
    input_fn33 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-hac1.png",
    input_fn34 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-hac1.eps",
    input_fn35 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-mmf1.png",
    input_fn36 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-mmf1.eps"
  output:
    output_fn1 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S9.png",
    output_fn2 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S9.eps",
    output_fn3 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S10.png",
    output_fn4 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S10.eps",
    output_fn5 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S11.png",
    output_fn6 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S11.eps",
    output_fn7 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S12.png",
    output_fn8 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S12.eps",
    output_fn9 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S13.png",
    output_fn10 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S13.eps",
    output_fn11 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S14.png",
    output_fn12 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S14.eps",
    output_fn13 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S15.png",
    output_fn14 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S15.eps",
    output_fn15 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S16.png",
    output_fn16 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S16.eps",
    output_fn17 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S17.png",
    output_fn18 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S17.eps",
    output_fn19 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S18.png",
    output_fn20 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S18.eps",
    output_fn21 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S19.png",
    output_fn22 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S19.eps",
    output_fn23 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S20.png",
    output_fn24 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S20.eps",
    output_fn25 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S21.png",
    output_fn26 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S21.eps",
    output_fn27 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S22.png",
    output_fn28 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S22.eps",
    output_fn29 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S23.png",
    output_fn30 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S23.eps",
    output_fn31 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S24.png",
    output_fn32 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S24.eps",
    output_fn33 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S25.png",
    output_fn34 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S25.eps",
    output_fn35 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/png/Figure-S26.png",
    output_fn36 = PAPER_SUPP_OUTPUT_DIR + "/{greps}/{gproteins}/{window}/eps/Figure-S26.eps",
    output_fn0 = MANUSCRIPT_OUTPUT_DIR + "/statistics.{greps}_{gproteins}_{window}"
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
    cp {input.input_fn18} {output.output_fn18}
    cp {input.input_fn19} {output.output_fn19}
    cp {input.input_fn20} {output.output_fn20}
    cp {input.input_fn21} {output.output_fn21}
    cp {input.input_fn22} {output.output_fn22}
    cp {input.input_fn23} {output.output_fn23}
    cp {input.input_fn24} {output.output_fn24}
    cp {input.input_fn25} {output.output_fn25}
    cp {input.input_fn26} {output.output_fn26}
    cp {input.input_fn27} {output.output_fn27}
    cp {input.input_fn28} {output.output_fn28}
    cp {input.input_fn29} {output.output_fn29}
    cp {input.input_fn30} {output.output_fn30}
    cp {input.input_fn31} {output.output_fn31}
    cp {input.input_fn32} {output.output_fn32}
    cp {input.input_fn33} {output.output_fn33}
    cp {input.input_fn34} {output.output_fn34}
    cp {input.input_fn35} {output.output_fn35}
    cp {input.input_fn36} {output.output_fn36}

    touch {output.output_fn0}
    """


