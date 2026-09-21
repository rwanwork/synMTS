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
##  Define local functions
##################################

def Expand_DeepMito_Halved (wc):
  results = []

  for deepmito_halved_row in deepmito_halved_panda.itertuples (index = False):
    curr_replicate = str (deepmito_halved_row.Replicate)  ##  Convert integer to string in order to compare correctly
    curr_method = str (deepmito_halved_row.Method)  ##  Convert integer to string in order to compare correctly
    curr_protein = deepmito_halved_row.Protein
    curr_deepmito_id = deepmito_halved_row.DeepMito
    curr_side = deepmito_halved_row.Side

    if wc.replicate == str (curr_replicate) and wc.method == str (curr_method) and wc.protein == str (curr_protein):
      d = [OUTPUT_DIR + "/evaluate/main/02_deepmito_parse_halved/{m}_{p}_{r}_{s}.tsv".format (m=curr_method, p=curr_protein, r=curr_replicate, s=curr_side)]
      results.extend (d)

  print ("Expand_DeepMito_Halved:\t", results, file=sys.stderr)

  return results


##################################
##  Define rules
##################################

rule JSON_to_TSV:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/main/01_deepmito_copy/{method}_{protein}_{replicate}.json"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/02_deepmito_parse/{method}_{protein}_{replicate}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/main/02_deepmito_parse/{method}_{protein}_{replicate}.log"
  shell:
    """
    Perl/parse-deepmito.pl --input {input.input_fn1} >{output.output_fn1} 2>{log.log_fn1}
    """


rule JSON_to_TSV_Halved:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/main/01_deepmito_copy_halved/{method}_{protein}_{replicate}_{side}.json"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/02_deepmito_parse_halved/{method}_{protein}_{replicate}_{side}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/main/02_deepmito_parse_halved/{method}_{protein}_{replicate}_{side}.log"
  shell:
    """
    Perl/parse-deepmito.pl --input {input.input_fn1} >{output.output_fn1} 2>{log.log_fn1}
    """


rule DeepMito_Halved_Merge:
  input:
    Expand_DeepMito_Halved
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/02_deepmito_parse_halved_merged/{method}_{protein}_{replicate}.tsv"
  shell:
    """
    cat {input} >{output.output_fn1}
    """



