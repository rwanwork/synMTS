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

def Expand_HMoment_MitoFates (wc):
  results = []

  for gproteins_row in gproteins_panda.itertuples (index = False):
    if wc.gproteins == gproteins_row.Group:
      curr_protein = gproteins_row.Protein

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-{p}.png".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-{p}.eps".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-{p}.png".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-{p}.eps".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-topmedian-{p}.png".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-topmedian-{p}.eps".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-{p}.png".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-{p}.eps".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-allmedian-{p}.png".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

      d = [OUTPUT_DIR + "/statistics/{gr}/{gp}/{w}/09_hmoment_mitofates_graphs/mitofates-hmoment-allmedian-{p}.eps".format (gr=wc.greps, gp=wc.gproteins, w=wc.window, p=curr_protein)]
      results.extend (d)

  print ("Expand_HMoment_MitoFates:\t", results, file=sys.stderr)
  return results


##################################
##  Define rules
##################################

rule Scatterplot_MitoFates_HMoment_Maximum:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/08_hmoment_mitofates/hmoment_mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-{protein}.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-{protein}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-maximum-{protein}.log"
  params:
    protein = "{protein}"
  shell:
    """
    R/scatterplot-mitofates-hmoment.R --column Maximum --type png --protein {params.protein} --input {input.input_fn1} --output {output.output_fn1} 2>{log.log_fn1}
    R/scatterplot-mitofates-hmoment.R --column Maximum --type eps --protein {params.protein} --input {input.input_fn1} --output {output.output_fn2} 2>>{log.log_fn1}
    """


rule Scatterplot_MitoFates_HMoment_TopAvg:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/08_hmoment_mitofates/hmoment_mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-{protein}.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-{protein}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topavg-{protein}.log"
  params:
    protein = "{protein}"
  shell:
    """
    R/scatterplot-mitofates-hmoment.R --column TopAvg --type png --protein {params.protein} --input {input.input_fn1} --output {output.output_fn1} 2>{log.log_fn1}
    R/scatterplot-mitofates-hmoment.R --column TopAvg --type eps --protein {params.protein} --input {input.input_fn1} --output {output.output_fn2} 2>>{log.log_fn1}
    """


rule Scatterplot_MitoFates_HMoment_TopMedian:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/08_hmoment_mitofates/hmoment_mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topmedian-{protein}.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topmedian-{protein}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-topmedian-{protein}.log"
  params:
    protein = "{protein}"
  shell:
    """
    R/scatterplot-mitofates-hmoment.R --column TopMedian --type png --protein {params.protein} --input {input.input_fn1} --output {output.output_fn1} 2>{log.log_fn1}
    R/scatterplot-mitofates-hmoment.R --column TopMedian --type eps --protein {params.protein} --input {input.input_fn1} --output {output.output_fn2} 2>>{log.log_fn1}
    """


rule Scatterplot_MitoFates_HMoment_AllAvg:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/08_hmoment_mitofates/hmoment_mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-{protein}.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-{protein}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allavg-{protein}.log"
  params:
    protein = "{protein}"
  shell:
    """
    R/scatterplot-mitofates-hmoment.R --column AllAvg --type png --protein {params.protein} --input {input.input_fn1} --output {output.output_fn1} 2>{log.log_fn1}
    R/scatterplot-mitofates-hmoment.R --column AllAvg --type eps --protein {params.protein} --input {input.input_fn1} --output {output.output_fn2} 2>>{log.log_fn1}
    """


rule Scatterplot_MitoFates_HMoment_AllMedian:
  input:
    input_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/08_hmoment_mitofates/hmoment_mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allmedian-{protein}.png",
    output_fn2 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allmedian-{protein}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/mitofates-hmoment-allmedian-{protein}.log"
  params:
    protein = "{protein}"
  shell:
    """
    R/scatterplot-mitofates-hmoment.R --column AllMedian --type png --protein {params.protein} --input {input.input_fn1} --output {output.output_fn1} 2>{log.log_fn1}
    R/scatterplot-mitofates-hmoment.R --column AllMedian --type eps --protein {params.protein} --input {input.input_fn1} --output {output.output_fn2} 2>>{log.log_fn1}
    """


rule Scatterplot_HMoment_MitoFates_All:
  input:
    Expand_HMoment_MitoFates
  output:
    output_fn1 = OUTPUT_DIR + "/statistics/{greps}/{gproteins}/{window}/09_hmoment_mitofates_graphs/all.proteins"
  shell:
    """
    touch {output.output_fn1}
    """

