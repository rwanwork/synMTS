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


########################################
##  Functions
########################################

def Expand_Rename_MTS (wc):
  all_results = []

  ##  Gather the outputs from Rename_MTS
  for method in config["generate"]["methods"]:
    curr_result = [OUTPUT_DIR + "/generate/{r}/02_rename_mts/{m}/mapping.tsv".format (m=method, r=wc.replicate)]
    all_results.extend (curr_result)

  print ("Expand_Rename_MTS:\t", all_results, file=sys.stderr)

  return all_results


########################################
##  Rename MTS
########################################

rule Rename_MTS:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/01_random/{method}/mts.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts/{method}/mts.fasta",
    output_fn2 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts/{method}/mapping.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts/{method}/mts.log"
  params:
    replicate = "{replicate}",
    method = "{method}",
    start = lambda wildcards: config["replicates"]["start"]["{}".format (wildcards.replicate)]
  shell:
    """
    cat {input.input_fn1} | Perl/rename-mts.pl --fasta {output.output_fn1} --mapping {output.output_fn2} --replicate {params.replicate} --method {params.method} --start {params.start} >{log.log_fn1} 2>&1
    """


rule All_Rename_MTS:
  input:
    Expand_Rename_MTS
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts_all/all.tsv",
    output_fn2 = OUTPUT_DIR + "/generate/{replicate}/02_rename_mts_all/mts.done"
  shell:
    """
    cat {input} >{output.output_fn1}
    touch {output.output_fn2}
    """


