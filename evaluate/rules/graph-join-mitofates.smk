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

def Expand_Joined_MitoFates (wc):
  results = []

  for gproteins_row in gproteins_panda.itertuples (index = False):
    if wc.gproteins == gproteins_row.Group:
      curr_protein = gproteins_row.Protein

      d = [OUTPUT_DIR + "/evaluate/{gr}/{gp}/10_mitofates_subrk/scatterplot-subrk_{p}.png".format (gr=wc.greps, gp=wc.gproteins, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/evaluate/{gr}/{gp}/10_mitofates_subrk/scatterplot-subrk_{p}.eps".format (gr=wc.greps, gp=wc.gproteins, p=curr_protein)]
      results.extend (d)

  print ("Expand_Joined_MitoFates:\t", results, file=sys.stderr)
  return results


##################################
##  Define rules
##################################

rule Scatterplot_Join_MitoFates:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/08_joined_mitofates/mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_{protein}.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/scatterplot-subrk_{protein}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/{protein}.log"
  params:
    protein = "{protein}"
  shell:
    """
    R/scatterplot-join-mitofates.R --type png --protein {params.protein} --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/scatterplot-join-mitofates.R --type eps --protein {params.protein} --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


rule Scatterplot_Join_MitoFates_All:
  input:
    Expand_Joined_MitoFates
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/10_mitofates_subrk/all.proteins"
  shell:
    """
    touch {output.output_fn1}
    """

