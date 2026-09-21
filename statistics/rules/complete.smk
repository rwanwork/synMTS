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
def ExpandAllFiles (wc):
  results = []

  curr_window = wc.window
  curr_greps = wc.greps
  curr_gproteins = wc.gproteins

  for greps_row in greps_panda.itertuples (index = False):
    if wc.greps == greps_row.Group:
      curr_replicate = greps_row.Replicate

      ##  A window size of NA means the window size is not applicable
      d = [OUTPUT_DIR + "/statistics/{r}/NA/any/all/04_properties_graphs/mts_properties.eps".format (r=curr_greps)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{r}/NA/any/all/04_properties_graphs/mts_length.eps".format (r=curr_greps)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{r}/NA/any/all/04_properties_graphs/mts_charge.eps".format (r=curr_greps)]
      results.extend (d)

      ##  Obtain all of the methods
      for method in config["generate"]["methods"]:
        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-maximum.png".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-maximum.eps".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-topavg.png".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-topavg.eps".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-topmedian.png".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-topmedian.eps".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-allavg.png".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-allavg.eps".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-allmedian.png".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/NA/{w}/06_hmoment_graph/hmoment-allmedian.eps".format (r=curr_greps, w=curr_window)]
        results.extend (d)

        d = [OUTPUT_DIR + "/statistics/{r}/{g}/{w}/09_hmoment_mitofates_graphs/all.proteins".format (r=curr_greps, g=curr_gproteins, w=curr_window)]
        results.extend (d)

        d = [MANUSCRIPT_OUTPUT_DIR + "/statistics.{r}".format (r=curr_greps)]
        results.extend (d)

        d = [MANUSCRIPT_OUTPUT_DIR + "/statistics.{r}_{g}_{w}".format (r=curr_greps, g=curr_gproteins, w=curr_window)]
        results.extend (d)

#  d = [OUTPUT_DIR + "/statistics/{r}/{p}/NA/07_mitofates_combine/mitofates.tsv".format (r=curr_greps, p=curr_gproteins)]
#  results.extend (d)

  print ("ExpandAllFiles:\t", results, file=sys.stderr)
  print ("ExpandAllFiles:\t", len (results), file=sys.stderr)

  return results




##################################
##  Define rules
##################################

rule Complete_MTS:
  input:
    ExpandAllFiles
  output:
    output_fn1 = PROGRESS_OUTPUT_DIR + "/statistics/{greps}_{gproteins}_{window}.done"
  shell:
    """
    touch {output.output_fn1}
    """


