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


rule Rename_DeepMito_Samples:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/main/03_deepmito_clean/{method}_{protein}_{replicate}.tsv",
    input_fn2 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts_all/all.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/04_deepmito_rename/{method}_{protein}_{replicate}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/main/04_deepmito_rename/{method}_{protein}_{replicate}.log"
  shell:
    """
    cat {input.input_fn1} | Perl/rename-deepmito-mitofates.pl --mapping {input.input_fn2} >{output.output_fn1} 2>{log.log_fn1}
    """


rule Rename_MitoFates_Samples:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/main/03_mitofates_clean/{protein}_{replicate}.tsv",
    input_fn2 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts_all/all.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/04_mitofates_rename/{protein}_{replicate}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/main/04_mitofates_rename/{protein}_{replicate}.log"
  shell:
    """
    cat {input.input_fn1} | Perl/rename-deepmito-mitofates.pl --mapping {input.input_fn2} >{output.output_fn1} 2>{log.log_fn1}
    """


rule Rename_MitoFates_Samples_SubRK:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/main/03_mitofates_clean_subrk/{protein}_{replicate}.tsv",
    input_fn2 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts_all/all.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/04_mitofates_rename_subrk/{protein}_{replicate}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/main/04_mitofates_rename_subrk/{protein}_{replicate}.log"
  shell:
    """
    cat {input.input_fn1} | Perl/rename-deepmito-mitofates.pl --mapping {input.input_fn2} >{output.output_fn1} 2>{log.log_fn1}
    """


