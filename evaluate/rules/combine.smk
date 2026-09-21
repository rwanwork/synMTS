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
##  Define local functions for selecting DeepMito and MitoFates input files
##################################

##  Only take the DeepMito output which are from the replicates
##    assigned to the group of interest
def ExpandDeepMito (wc):
  results = []

  for greps_row in greps_panda.itertuples (index = False):

    if wc.greps == greps_row.Group:
      this_replicate = str (greps_row.Replicate)  ##  Convert integer to string in order to compare correctly
      for gproteins_row in gproteins_panda.itertuples (index = False):

        if wc.gproteins == gproteins_row.Group:
          this_protein = gproteins_row.Protein

          ##  Search in deepmito.tsv for the record
          for deepmito_row in deepmito_panda.itertuples (index = False):
            curr_replicate = str (deepmito_row.Replicate)  ##  Convert integer to string in order to compare correctly
            curr_method = str (deepmito_row.Method)  ##  Convert integer to string in order to compare correctly
            curr_protein = deepmito_row.Protein

            if curr_replicate == this_replicate and curr_protein == this_protein:
              d = [OUTPUT_DIR + "/evaluate/main/04_deepmito_rename/{m}_{p}_{r}.tsv".format (m=curr_method, p=curr_protein, r=curr_replicate)]
              results.extend (d)

          ##  Search in deepmito-halved.tsv for the record; only take it once so match on "A" as well
          for deepmito_halved_row in deepmito_halved_panda.itertuples (index = False):
            curr_replicate = str (deepmito_halved_row.Replicate)  ##  Convert integer to string in order to compare correctly
            curr_method = str (deepmito_halved_row.Method)  ##  Convert integer to string in order to compare correctly
            curr_protein = deepmito_halved_row.Protein
            curr_side = deepmito_halved_row.Side

            if curr_replicate == this_replicate and curr_protein == this_protein and curr_side == "A":
              d = [OUTPUT_DIR + "/evaluate/main/04_deepmito_rename/{m}_{p}_{r}.tsv".format (m=curr_method, p=curr_protein, r=curr_replicate)]
              results.extend (d)

  print ("ExpandDeepMito:\t", results, file=sys.stderr)
  print ("ExpandDeepMito:\t", len (results), file=sys.stderr)

  if len (results) == 0:
    print ("EE\tNumber of samples for DeepMito should not be 0.\n", file=sys.stderr)
    sys.exit ()

  return results


##  Only take the MitoFates output which are from the replicates
##    assigned to the group of interest
def ExpandMitoFates (wc):
  results = []

  for greps_row in greps_panda.itertuples (index = False):

    if wc.greps == greps_row.Group:
      this_replicate = str (greps_row.Replicate)  ##  Convert integer to string in order to compare correctly
      for gproteins_row in gproteins_panda.itertuples (index = False):

        if wc.gproteins == gproteins_row.Group:
          this_protein = gproteins_row.Protein

          for mitofates_row in mitofates_panda.itertuples (index = False):
            curr_replicate = str (mitofates_row.Replicate)  ##  Convert integer to string in order to compare correctly
            curr_protein = mitofates_row.Protein

            if curr_replicate == this_replicate and curr_protein == this_protein:
              d = [OUTPUT_DIR + "/evaluate/main/04_mitofates_rename/{p}_{r}.tsv".format (p=curr_protein, r=curr_replicate)]
              results.extend (d)

  print ("ExpandMitoFates:\t", results, file=sys.stderr)
  print ("ExpandMitoFates:\t", len (results), file=sys.stderr)

  if len (results) == 0:
    print ("EE\tNumber of samples for MitoFates should not be 0.\n", file=sys.stderr)
    sys.exit ()

  return results


##  Only take the MitoFates output which are from the replicates
##    assigned to the group of interest
def ExpandMitoFates_SubRK (wc):
  results = []

  for greps_row in greps_panda.itertuples (index = False):

    if wc.greps == greps_row.Group:
      this_replicate = str (greps_row.Replicate)  ##  Convert integer to string in order to compare correctly
      for gproteins_row in gproteins_panda.itertuples (index = False):

        if wc.gproteins == gproteins_row.Group:
          this_protein = gproteins_row.Protein

          for mitofates_subrk_row in mitofates_subrk_panda.itertuples (index = False):
            curr_replicate = str (mitofates_subrk_row.Replicate)  ##  Convert integer to string in order to compare correctly
            curr_protein = mitofates_subrk_row.Protein

            if curr_replicate == this_replicate and curr_protein == this_protein:
              d = [OUTPUT_DIR + "/evaluate/main/04_mitofates_rename_subrk/{p}_{r}.tsv".format (p=curr_protein, r=curr_replicate)]
              results.extend (d)

  print ("ExpandMitoFates_SubRK:\t", results, file=sys.stderr)
  print ("ExpandMitoFates_SubRK:\t", len (results), file=sys.stderr)

  if len (results) == 0:
    print ("EE\tNumber of samples for MitoFates should not be 0.\n", file=sys.stderr)
    sys.exit ()

  return results


##################################
##  Define rules
##################################

rule Combine_DeepMito:
  input:
    ExpandDeepMito
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_deepmito_combine/deepmito.tsv"
  shell:
    """
    Perl/generate-deepmito-header.pl >{output.output_fn1}
    cat {input} >>{output.output_fn1}
    """


rule Combine_MitoFates:
  input:
    ExpandMitoFates
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine/mitofates.tsv"
  shell:
    """
    Perl/generate-mitofates-header.pl >{output.output_fn1}
    cat {input} >>{output.output_fn1}
    """


rule Combine_MitoFates_SubRK:
  input:
    ExpandMitoFates_SubRK
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine_subrk/mitofates.tsv"
  shell:
    """
    Perl/generate-mitofates-header.pl >{output.output_fn1}
    cat {input} >>{output.output_fn1}
    """
