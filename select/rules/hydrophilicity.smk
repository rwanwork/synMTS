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


rule Preprocess_FASTA_MTS:
  input:
    input_fn1 = AAPROP_FILE,
    input_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/03_separate_fasta/{sample}.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/04_preprocess_hydrophilicity/{sample}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/04_preprocess_hydrophilicity/{sample}.log"
  shell:
    """
    cat {input.input_fn2} | Perl/prepare-hydrophilicity.pl --aaprop {input.input_fn1} >{output.output_fn1} 2>{log.log_fn1}
    """


rule Hydrophilicity_FASTA_MTS:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/04_preprocess_hydrophilicity/{sample}.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/05_hydrophilicity_graphs/{sample}.eps",
    output_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/05_hydrophilicity_graphs/{sample}.png"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/05_hydrophilicity_graphs/{sample}.log"
  shell:
    """
    R/plot-hydrophilicity.R --input {input.input_fn1} --output {output.output_fn1} --type eps 2>{log.log_fn1}
    R/plot-hydrophilicity.R --input {input.input_fn1} --output {output.output_fn2} --type png 2>>{log.log_fn1}
    """


