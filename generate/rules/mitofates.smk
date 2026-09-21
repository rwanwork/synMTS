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

def Expand_Methods_MitoFates (wc):
  all_results = []

  for curr_method in config["generate"]["methods"]:
    curr_result = [OUTPUT_DIR + "/generate/{r}/04_protein/{curr}/{p}.fasta".format (r=wc.replicate, curr=curr_method, p=wc.protein)]
    all_results.extend (curr_result)

  print ("Expand_Methods_MitoFates:\t", all_results, file=sys.stderr)

  return all_results


def Expand_Sub_R_K_Methods_MitoFates (wc):
  all_results = []

  for curr_method in config["generate"]["methods"]:
    #print ("XXX\t" + str (curr_method) + "\n", file=sys.stderr)
    curr_result = [OUTPUT_DIR + "/generate/{r}/04_sub_r_k_protein/{curr}/{p}.fasta".format (r=wc.replicate, curr=curr_method, p=wc.protein)]
    all_results.extend (curr_result)

  print ("Expand_Sub_R_K_Methods_MitoFates:\t", all_results, file=sys.stderr)

  return all_results


########################################
##  Merge across all methods for MitoFates
########################################

rule Merge_MitoFates:
  input:
    Expand_Methods_MitoFates
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/05_mitofates/all/{protein}.fasta"
  shell:
    """
    cat {input} >{output.output_fn1}
    """


rule Substitute_R_K_Merge_MitoFates:
  input:
    Expand_Sub_R_K_Methods_MitoFates
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/05_sub_r_k_mitofates/all/{protein}.fasta"
  shell:
    """
    cat {input} >{output.output_fn1}
    """


