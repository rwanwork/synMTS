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


##################################
##  Define rules
##################################

rule Select_FASTA_MTS:
  input:
    input_fn1 = SELECTORDER_FILE,
    input_fn2 = OUTPUT_DIR + "/select/{greps}/copy/01_concatenate_fasta_mts/mts.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/mts.fasta",
    output_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/positive.fasta",
    output_fn3 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/negative.fasta"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/mts.log"
  params:
    protein="{protein}"
  shell:
    """
    Perl/select-fasta-mts.pl --protein {params.protein} --select {input.input_fn1} --fasta {input.input_fn2} --all {output.output_fn1} --positive {output.output_fn2} --negative {output.output_fn3} 2>{log.log_fn1}
    """


rule Separate_FASTA_MTS:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/mts.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/03_separate_fasta/{sample}.fasta"
  params:
    sample = "{sample}"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/03_separate_fasta/{sample}.log"
  shell:
    """
    Perl/separate-fasta.pl --sample {params.sample} --fasta {input.input_fn1} >{output.output_fn1} 2>{log.log_fn1}
    touch {output.output_fn1}
    """


