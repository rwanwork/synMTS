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

##  Determine whether the source of this file is in deepmito.tsv or deepmito-halved.tsv
def Determine_DeepMito_Source (wc):
  results = []

  ##  Search in deepmito.tsv for the record
  for deepmito_row in deepmito_panda.itertuples (index = False):
    curr_replicate = str (deepmito_row.Replicate)  ##  Convert integer to string in order to compare correctly
    curr_method = str (deepmito_row.Method)  ##  Convert integer to string in order to compare correctly
    curr_protein = deepmito_row.Protein
    curr_deepmito_id = deepmito_row.DeepMito

    if wc.replicate == str (curr_replicate) and wc.method == str (curr_method) and wc.protein == str (curr_protein):
      d = [OUTPUT_DIR + "/evaluate/main/02_deepmito_parse/{m}_{p}_{r}.tsv".format (m=curr_method, p=curr_protein, r=curr_replicate)]
      results.extend (d)

  ##  Search in deepmito-halved.tsv for the record
  for deepmito_halved_row in deepmito_halved_panda.itertuples (index = False):
    curr_replicate = str (deepmito_halved_row.Replicate)  ##  Convert integer to string in order to compare correctly
    curr_method = str (deepmito_halved_row.Method)  ##  Convert integer to string in order to compare correctly
    curr_protein = deepmito_halved_row.Protein
    curr_deepmito_id = deepmito_halved_row.DeepMito

    if wc.replicate == str (curr_replicate) and wc.method == str (curr_method) and wc.protein == str (curr_protein):
      d = [OUTPUT_DIR + "/evaluate/main/02_deepmito_parse_halved_merged/{m}_{p}_{r}.tsv".format (m=curr_method, p=curr_protein, r=curr_replicate)]
      results.extend (d)
      break  ##  We only need the first one of the pair

  print ("Determine_DeepMito_Source:\t", results, file=sys.stderr)

  ##  There should be only one entry
  if len (results) != 1:
    print ("EE\tNumber of samples for DeepMito should be exactly 1.", file=sys.stderr)
    print ("EE\t  method:", wc.method, file=sys.stderr)
    print ("EE\t  replicate:", wc.replicate, file=sys.stderr)
    print ("EE\t  protein:", wc.protein, file=sys.stderr)
    print ("EE\tNumber of records found:  %u.\n" % len (results), file=sys.stderr)
    sys.exit ()

  return results


##################################
##  Define rules
##################################

rule Clean_DeepMito:
  input:
    Determine_DeepMito_Source
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/03_deepmito_clean/{method}_{protein}_{replicate}.tsv"
  shell:
    """
    ##  No cleaning needed; so just copy
    cp {input} {output.output_fn1}
    """


rule Clean_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/main/01_mitofates_copy/{protein}_{replicate}.html"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/03_mitofates_clean/{protein}_{replicate}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/main/03_mitofates_clean/{protein}_{replicate}.log"
  shell:
    """
    Perl/clean-mitofates.pl --input {input.input_fn1} >{output.output_fn1} 2>{log.log_fn1}
    """


rule Clean_MitoFates_SubRK:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/main/01_mitofates_copy_subrk/{protein}_{replicate}.html"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/main/03_mitofates_clean_subrk/{protein}_{replicate}.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/main/03_mitofates_clean_subrk/{protein}_{replicate}.log"
  shell:
    """
    Perl/clean-mitofates.pl --input {input.input_fn1} >{output.output_fn1} 2>{log.log_fn1}
    """

