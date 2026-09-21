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

##  Take all of the MTS files which are from the replicates
##    assigned to the group of interest
def ExpandAllMTSFiles (wc):
  results = []

  for greps_row in greps_panda.itertuples (index = False):
    if wc.greps == greps_row.Group:
      curr_replicate = greps_row.Replicate

      ##  Obtain all of the methods
      for method in config["generate"]["methods"]:
        d = [OUTPUT_DIR + "/generate/{r}/02_rename_mts/{m}/mts.fasta".format (r=curr_replicate, m=method)]
        results.extend (d)

  print ("ExpandAllMTSFiles:\t", results, file=sys.stderr)
  print ("ExpandAllMTSFiles:\t", len (results), file=sys.stderr)

  return results


def DetermineDeepMitoPath (wc):
  greps = wc.greps
  gproteins = config["select"]["gproteins"]

  result = OUTPUT_DIR + "/evaluate/{r}/{p}/04_deepmito_combine/deepmito.tsv".format (r=greps, p=gproteins)

  print ("DetermineDeepMitoPath:\t", result, file=sys.stderr)

  return result


def DetermineMitoFatesPath (wc):
  greps = wc.greps
  gproteins = config["select"]["gproteins"]

  result = OUTPUT_DIR + "/evaluate/{r}/{p}/04_mitofates_combine/mitofates.tsv".format (r=greps, p=gproteins)

  print ("DetermineMitoFatesPath:\t", result, file=sys.stderr)

  return result


def DetermineHMomentPath (wc):
  greps = wc.greps
  window = config["select"]["hmoment_window"]

  result = OUTPUT_DIR + "/statistics/{r}/NA/{w}/05_hmoment_merge/mts.tsv".format (r=greps, w=window)

  print ("DetermineHMomentPath:\t", result, file=sys.stderr)

  return result


##################################
##  Define rules
##################################

rule Concatenate_FASTA_MTS:
  input:
    ExpandAllMTSFiles
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/copy/01_concatenate_fasta_mts/mts.fasta"
  shell:
    """
    cat {input} >{output.output_fn1}
    """


rule Copy_Properties:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/03_properties_all/all.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/copy/02_copy_properties/all.tsv"
  shell:
    """
    cp {input.input_fn1} {output.output_fn1}
    """


rule Copy_DeepMito:
  input:
    DetermineDeepMitoPath
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/copy/03_deepmito/deepmito.tsv"
  shell:
    """
    cp {input[0]} {output.output_fn1}
    """


rule Copy_MitoFates:
  input:
    DetermineMitoFatesPath
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/copy/04_mitofates/mitofates.tsv"
  shell:
    """
    cp {input[0]} {output.output_fn1}
    """


rule Copy_HMoment:
  input:
    DetermineHMomentPath
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/copy/05_hmoment/hmoment.tsv"
  shell:
    """
    cp {input[0]} {output.output_fn1}
    """
