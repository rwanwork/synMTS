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

def Expand_Methods_MTS_Properties (wc):
  all_results = []

  curr_greps = wc.greps

  for greps_row in greps_panda.itertuples (index = False):
    if curr_greps == greps_row.Group:
      curr_replicate = greps_row.Replicate

      for curr_method in config["generate"]["methods"]:
        #print ("XXX\t" + curr_seq + "\n", file=sys.stderr)
        curr_result = [OUTPUT_DIR + "/statistics/{g}/NA/any/{r}/{m}/02_properties/mts.tsv".format (g=curr_greps, r=curr_replicate, m=curr_method)]
        all_results.extend (curr_result)

  print ("Expand_Methods_MTS_Properties:\t", all_results, file=sys.stderr)

  return all_results


##################################
##  Define rules
##################################

##  "all" means across all replicates
rule All_MTS_Properties:
  input:
    Expand_Methods_MTS_Properties
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/03_properties_all/all.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/NA/any/all/03_properties_all/all.log"
  shell:
    """
    cat {input} | Perl/merge-records.pl --start 1 >{output.output_fn1} 2>{log.log_fn1}
    """


