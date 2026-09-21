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

##  Take all of the HMoment files, across replicates and methods
def ExpandAllHMomentFiles (wc):
  results = []

  curr_window = wc.window
  curr_greps = wc.greps

  for greps_row in greps_panda.itertuples (index = False):
    if wc.greps == greps_row.Group:
      curr_replicate = greps_row.Replicate

      ##  Obtain all of the methods
      for method in config["generate"]["methods"]:
        d = [OUTPUT_DIR + "/statistics/{g}/NA/{w}/{r}/{m}/04_hmoment_summary/mts.tsv".format (g=curr_greps, w=curr_window, r=curr_replicate, m=method)]
        results.extend (d)

  print ("ExpandAllMTSFiles:\t", results, file=sys.stderr)
  print ("ExpandAllMTSFiles:\t", len (results), file=sys.stderr)

  return results


##################################
##  Define rules
##################################

rule HMoment_Text:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/01_mts_names/mapping.tsv",
    input_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/01_mts/mts.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/{replicate}/{method}/03_hmoment_txt/mts.done"
  params:
    window = "{window}",
    hmoment_aangle = lambda wildcards: config["statistics"]["hmoment_aangle"],
    hmoment_bangle = lambda wildcards: config["statistics"]["hmoment_bangle"]
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/{replicate}/{method}/03_hmoment_txt/mts.log"
  shell:
    """
    Perl/run-hmoment.pl --mapping {input.input_fn1} --sequences {input.input_fn2} --outfile {output.output_fn1} --window {params.window} -aangle {params.hmoment_aangle} -bangle {params.hmoment_bangle} --plot no 2>{log.log_fn1}
    touch {output.output_fn1}
    """


rule Summarise_HMoment:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/{replicate}/{method}/01_mts_names/mapping.tsv",
    input_fn2 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/{replicate}/{method}/03_hmoment_txt/mts.done"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/{replicate}/{method}/04_hmoment_summary/mts.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/{replicate}/{method}/04_hmoment_summary/mts.log"
  shell:
    """
    Perl/run-summarise-hmoment.pl --mapping {input.input_fn1} --infile {input.input_fn2} --outfile {output.output_fn1} >{log.log_fn1}
    """


rule Merge_HMoment:
  input:
    ExpandAllHMomentFiles
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/{window}/05_hmoment_merge/mts.log"
  shell:
    """
    cat {input} | Perl/merge-records.pl --start 2 >{output.output_fn1} 2>{log.log_fn1}
    """


