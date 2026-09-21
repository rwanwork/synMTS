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


rule Protein_Append:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts/{method}/mts.fasta",
    input_fn2 = DATA_DIR + "/protein/{protein}.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/04_protein/{method}/{protein}.fasta"
  log:
    log_fn1 = OUTPUT_DIR + "/generate/{replicate}/04_protein/{method}/{protein}.log"
  shell:
    """
    cat {input.input_fn1} | Perl/append-protein.pl --append {input.input_fn2} >{output.output_fn1} 2>{log.log_fn1}
    """


rule Substitute_R_K_Protein_Append:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/03_sub_r_k_mts/{method}/mts.fasta",
    input_fn2 = DATA_DIR + "/protein/{protein}.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/04_sub_r_k_protein/{method}/{protein}.fasta"
  log:
    log_fn1 = OUTPUT_DIR + "/generate/{replicate}/04_sub_r_k_protein/{method}/{protein}.log"
  shell:
    """
    cat {input.input_fn1} | Perl/append-protein.pl --append {input.input_fn2} >{output.output_fn1} 2>{log.log_fn1}
    """

