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

def Expand_MitoFates (wc):
  all_results = []

  for curr_seq in config["protein"]["sequences"]:
    #print ("XXX\t" + curr_seq + "\n", file=sys.stderr)
    curr_result = [OUTPUT_DIR + "/generate/{r}/05_mitofates/all/{curr}.fasta".format (r=wc.replicate, curr=curr_seq)]
    all_results.extend (curr_result)
    curr_result = [OUTPUT_DIR + "/generate/{r}/05_sub_r_k_mitofates/all/{curr}.fasta".format (r=wc.replicate, curr=curr_seq)]
    all_results.extend (curr_result)

  print ("Expand_MitoFates:\t", all_results, file=sys.stderr)

  return all_results


def Expand_MitoFates_DeepMito (wc):
  all_results = []

  for method in config["generate"]["methods"]:
    #print ("XXX\t" + method + "\n", file=sys.stderr)
    curr_result = [OUTPUT_DIR + "/generate/{r}/06_all_proteins/{m}/all_proteins.done".format (m=method, r=wc.replicate)]
    all_results.extend (curr_result)

  curr_result = [OUTPUT_DIR + "/generate/{r}/02_rename_mts_all/all.tsv".format (r=wc.replicate)]
  all_results.extend (curr_result)

  curr_result = [OUTPUT_DIR + "/generate/{r}/05_deepmito_all/protein.done".format (r=wc.replicate)]
  all_results.extend (curr_result)

  print ("Expand_MitoFates_DeepMito:\t", all_results, file=sys.stderr)

  return all_results


########################################
##  Completion rules
########################################

rule Complete_MitoFates:
  input:
    Expand_MitoFates
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/06_all_proteins/{method}/all_proteins.done"
  shell:
    """
    touch {output.output_fn1}
    """


rule Complete_MitoFates_DeepMito:
  input:
    Expand_MitoFates_DeepMito
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/generate/{replicate}.done"
  shell:
    """
    touch {output.output_fn1}
    """

