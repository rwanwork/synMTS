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


##  "NA" means that the output is not relevant to {gproteins}
rule Copy_MTS:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts/{method}/mts.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/01_mts/mts.tsv"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    """


##  "NA" means that the output is not relevant to {gproteins}
rule Copy_Names:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts/{method}/mapping.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/01_mts_names/mapping.tsv"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    """


##  "any" means any window size
rule Copy_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine/mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/any/01_mitofates_combine/mitofates.tsv"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    """

