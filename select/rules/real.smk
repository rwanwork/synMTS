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


rule Preprocess_Real_MTS:
  input:
    input_fn1 = DATA_DIR + "/mts/{real}.fasta",
    input_fn2 = AAPROP_FILE
  output:
    output_fn1 = OUTPUT_DIR + "/select/real/01_preprocess_hydrophilicity/{real}.tsv"
  params:
    real = "{real}"
  shell:
    """
    cat {input.input_fn1} | Perl/prepare-hydrophilicity.pl --aaprop {input.input_fn2} >{output.output_fn1}
    """


rule Hydrophilicity_Real_MTS:
  input:
    input_fn1 = OUTPUT_DIR + "/select/real/01_preprocess_hydrophilicity/{real}.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/{real}.png",
    output_fn2 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/{real}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/select/real/02_hydrophilicity_graphs/{real}.log"
  shell:
    """
    R/plot-hydrophilicity.R --input {input.input_fn1} --output {output.output_fn1} --type png 2>{log.log_fn1}
    R/plot-hydrophilicity.R --input {input.input_fn1} --output {output.output_fn2} --type eps 2>>{log.log_fn1}
    """


