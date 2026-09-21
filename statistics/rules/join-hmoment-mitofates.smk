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


rule HMoment_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/any/01_mitofates_combine/mitofates.tsv",
    input_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/08_hmoment_mitofates/hmoment_mitofates.tsv"
  shell:
    """
    Perl/join-hmoment-mitofates.pl --mitofates {input.input_fn1} --hmoment {input.input_fn2} >{output.output_fn1}
    """


