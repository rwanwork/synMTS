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

def Lookup_DeepMito_ID (wc):
  results = []

  for deepmito_row in deepmito_panda.itertuples (index = False):
    curr_replicate = str (deepmito_row.Replicate)  ##  Convert integer to string in order to compare correctly
    curr_method = str (deepmito_row.Method)  ##  Convert integer to string in order to compare correctly
    curr_protein = deepmito_row.Protein
    curr_deepmito_id = deepmito_row.DeepMito

    if wc.replicate == str (curr_replicate) and wc.method == str (curr_method) and wc.protein == str (curr_protein):
      d = [INPUT_DIR + "/deepmito/{i}.json".format (i=curr_deepmito_id)]
      results.extend (d)
      continue  ##  There should be only one entry

  print ("Lookup_DeepMito_ID:\t", results, file=sys.stderr)

  return results


def Lookup_DeepMito_Halved_ID (wc):
  results = []

  for deepmito_halved_row in deepmito_halved_panda.itertuples (index = False):
    curr_replicate = str (deepmito_halved_row.Replicate)  ##  Convert integer to string in order to compare correctly
    curr_method = str (deepmito_halved_row.Method)  ##  Convert integer to string in order to compare correctly
    curr_protein = deepmito_halved_row.Protein
    curr_deepmito_id = deepmito_halved_row.DeepMito
    curr_side = deepmito_halved_row.Side

    if wc.replicate == str (curr_replicate) and wc.method == str (curr_method) and wc.protein == str (curr_protein) and wc.side == str (curr_side):
      d = [INPUT_DIR + "/deepmito/{i}.json".format (i=curr_deepmito_id)]
      results.extend (d)
      continue  ##  There should be only one entry

  print ("Lookup_DeepMito_Halved_ID:\t", results, file=sys.stderr)

  return results


def Lookup_MitoFates_ID (wc):
  results = []

  for mitofates_row in mitofates_panda.itertuples (index = False):
    curr_replicate = str (mitofates_row.Replicate)  ##  Convert integer to string in order to compare correctly
    curr_protein = mitofates_row.Protein
    curr_mitofates_id = mitofates_row.MitoFates

    if wc.replicate == str (curr_replicate) and wc.protein == str (curr_protein):
      d = [INPUT_DIR + "/mitofates/{i}.tsv".format (i=curr_mitofates_id)]
      results.extend (d)
      continue  ##  There should be only one entry

  print ("Lookup_MitoFates_ID:\t", results, file=sys.stderr)

  return results


def Lookup_MitoFates_SubRK_ID (wc):
  results = []

  for mitofates_subrk_row in mitofates_subrk_panda.itertuples (index = False):
    curr_replicate = str (mitofates_subrk_row.Replicate)  ##  Convert integer to string in order to compare correctly
    curr_protein = mitofates_subrk_row.Protein
    curr_mitofates_id = mitofates_subrk_row.MitoFates

    if wc.replicate == str (curr_replicate) and wc.protein == str (curr_protein):
      d = [INPUT_DIR + "/mitofates/{i}.tsv".format (i=curr_mitofates_id)]
      results.extend (d)
      continue  ##  There should be only one entry

  print ("Lookup_MitoFates_SubRK_ID:\t", results, file=sys.stderr)

  return results


##################################
##  Define rules
##################################

rule Copy_DeepMito:
  input:
    Lookup_DeepMito_ID
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/01_deepmito_copy/{method}_{protein}_{replicate}.json"
  shell:
    """
    cp {input[0]} {output.output_fn1}
    """


rule Copy_DeepMito_Halved:
  input:
    Lookup_DeepMito_Halved_ID
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/01_deepmito_copy_halved/{method}_{protein}_{replicate}_{side}.json"
  shell:
    """
    cp {input[0]} {output.output_fn1}
    """


rule Copy_MitoFates:
  input:
    Lookup_MitoFates_ID
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/01_mitofates_copy/{protein}_{replicate}.html"
  shell:
    """
    cp {input[0]} {output.output_fn1}
    """


rule Copy_MitoFates_SubRK:
  input:
    Lookup_MitoFates_SubRK_ID
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/01_mitofates_copy_subrk/{protein}_{replicate}.html"
  shell:
    """
    cp {input[0]} {output.output_fn1}
    """
