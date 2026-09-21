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


rule Select_Properties:
  input:
    input_fn1 = SELECTORDER_FILE,
    input_fn2 = OUTPUT_DIR + "/select/{greps}/copy/02_copy_properties/all.tsv",
    input_fn3 = OUTPUT_DIR + "/select/{greps}/copy/03_deepmito/deepmito.tsv",
    input_fn4 = OUTPUT_DIR + "/select/{greps}/copy/04_mitofates/mitofates.tsv",
    input_fn5 = OUTPUT_DIR + "/select/{greps}/copy/05_hmoment/hmoment.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/09_select_properties/properties.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/09_select_properties/properties.log"
  params:
    protein="{protein}"
  shell:
    """
    Perl/select-properties.pl --protein {params.protein} --select {input.input_fn1} --properties {input.input_fn2} --deepmito {input.input_fn3} --mitofates {input.input_fn4} --hmoment {input.input_fn5} >{output.output_fn1} 2>{log.log_fn1}
    """


rule Aggregate_Properties:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/09_select_properties/properties.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/10_aggregate_properties/out.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/10_aggregate_properties/out.log"
  shell:
    """
    R/aggregate-properties.R --input {input.input_fn1} --output {output.output_fn1} 2>{log.log_fn1}
    """


rule Aggregate_Properties_Clean:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/10_aggregate_properties/out.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/11_aggregate_properties_cleaned/out.tex"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/11_aggregate_properties_cleaned/out.log"
  params:
    protein="{protein}"
  shell:
    """
    cat {input.input_fn1} | Perl/clean-aggregate-properties.pl --protein {params.protein} >{output.output_fn1} 2>{log.log_fn1}
    """
