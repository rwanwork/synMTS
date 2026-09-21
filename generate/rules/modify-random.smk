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


rule Substitute_R_K_MTS:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts/{method}/mts.fasta",
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/03_sub_r_k_mts/{method}/mts.fasta"
  log:
    log_fn1 = OUTPUT_DIR + "/generate/{replicate}/03_sub_r_k_mts/{method}/mts.log"
  shell:
    """
    cat {input.input_fn1} | Perl/substitute-mts.pl --from R --to K >{output.output_fn1} 2>{log.log_fn1}
    """


