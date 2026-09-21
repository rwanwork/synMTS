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

def Expand_DeepMito_Protein (wc):
  all_results = []

  ##  Gather the outputs from Rename_Protein
  for protein in config["protein"]["sequences"]:
    for method in config["generate"]["methods"]:
      curr_result = [OUTPUT_DIR + "/generate/{r}/05_deepmito_halve/{m}/{p}-A.fasta".format (r=wc.replicate, m=method, p=protein)]
      all_results.extend (curr_result)
      curr_result = [OUTPUT_DIR + "/generate/{r}/05_deepmito_halve/{m}/{p}-B.fasta".format (r=wc.replicate, m=method, p=protein)]
      all_results.extend (curr_result)

  print ("Expand_DeepMito_Protein:\t", all_results, file=sys.stderr)

  return all_results


########################################
##  Rename protein
########################################

rule Copy_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/04_protein/{curr}/{protein}.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/05_deepmito/{curr}/{protein}.fasta"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    """


rule Halve_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/generate/{replicate}/05_deepmito/{curr}/{protein}.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/05_deepmito_halve/{curr}/{protein}-A.fasta",
    output_fn2 = OUTPUT_DIR + "/generate/{replicate}/05_deepmito_halve/{curr}/{protein}-B.fasta"
  params:
    number = lambda wildcards: config["generate"]["number"]
  shell:
    """
    head -n {params.number} {input.input_fn1} >{output.output_fn1}
    tail -n {params.number} {input.input_fn1} >{output.output_fn2}
    """


rule All_DeepMito_Protein:
  input:
    Expand_DeepMito_Protein
  output:
    output_fn1 = OUTPUT_DIR + "/generate/{replicate}/05_deepmito_all/protein.done"
  shell:
    """
    touch {output.output_fn1}
    """


