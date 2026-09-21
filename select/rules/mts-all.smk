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

##  Take all of the selected MTS files
def ExpandSelectedMTSFiles (wc):
  results = []

  curr_group = wc.greps
  curr_protein = wc.protein

  for select_row in select_order_panda.itertuples (index = False):
    curr_sample = select_row.Name

    r = [OUTPUT_DIR + "/select/{g}/{p}/05_hydrophilicity_graphs/{s}.png".format (g=curr_group, p=curr_protein, s=curr_sample)]
    results.extend (r)

    r = [OUTPUT_DIR + "/select/{g}/{p}/05_hydrophilicity_graphs/{s}.eps".format (g=curr_group, p=curr_protein, s=curr_sample)]
    results.extend (r)

  print ("ExpandSelectedMTSFiles:\t", results, file=sys.stderr)
  print ("ExpandSelectedMTSFiles:\t", len (results), file=sys.stderr)

  return results


rule MTS_All:
  input:
    ExpandSelectedMTSFiles
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/mts-graphs.done"
  shell:
    """
    touch {output.output_fn1}
    """

