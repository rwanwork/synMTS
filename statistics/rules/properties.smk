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


rule MTS_Properties:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/01_mts/mts.tsv",
    input_fn2 = AAPROP_FILE
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/02_properties/mts.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/02_properties/mts.log"
  shell:
    """
    cat {input.input_fn1} | Perl/aa-properties.pl --aaprop {input.input_fn2} --stats {output.output_fn1} >{log.log_fn1} 2>&1
    """


