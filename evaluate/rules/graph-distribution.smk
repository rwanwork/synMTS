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


########################################
##  Functions
########################################

def Expand_Boxplot_MitoFates_Combinations (wc):
  results = []

  curr_result = [OUTPUT_DIR + "/evaluate/{r}/{p}/09_boxplot/mitofates-all.png".format (r=wc.greps, p=wc.gproteins)]
  results.extend (curr_result)

  curr_result = [OUTPUT_DIR + "/evaluate/{r}/{p}/09_boxplot/mitofates-all.eps".format (r=wc.greps, p=wc.gproteins)]
  results.extend (curr_result)

  for curr_seq in config["protein"]["sequences"]:
    curr_result = [OUTPUT_DIR + "/evaluate/{r}/{p}/09_boxplot/mitofates-{c}.png".format (r=wc.greps, p=wc.gproteins, c=curr_seq)]
    results.extend (curr_result)
    curr_result = [OUTPUT_DIR + "/evaluate/{r}/{p}/09_boxplot/mitofates-{c}.eps".format (r=wc.greps, p=wc.gproteins, c=curr_seq)]
    results.extend (curr_result)

  print ("Expand_Boxplot_MitoFates_Combinations:\t", results, file=sys.stderr)

  return results


########################################
##  DeepMito rules
########################################

rule ViolinPlot_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_deepmito_combine/deepmito.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_violin/deepmito.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_violin/deepmito.eps",
    output_fn3 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_violin/localisation-summary.txt"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_violin/deepmito.log"
  shell:
    """
    ##  Only need STDOUT once
    R/deepmito-violin.R --type png --input {input.input_fn1} --output {output.output_fn1} >{output.output_fn3}
    R/deepmito-violin.R --type eps --input {input.input_fn1} --output {output.output_fn2} >{log.log_fn1} 2>&1
    """


rule LaTeXLocalisation_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_violin/localisation-summary.txt"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_localisation/deepmito.tex"
  shell:
    """
    Perl/clean-localisation-summary.pl <{input.input_fn1} >{output.output_fn1}
    """


rule Boxplot_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_deepmito_combine/deepmito.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/deepmito.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/deepmito.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/deepmito.log"
  shell:
    """
    R/deepmito-boxplot.R --type png --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/deepmito-boxplot.R --type eps --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


rule Dotplot_DeepMito:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_deepmito_combine/deepmito.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_dotplot/deepmito.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_dotplot/deepmito.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_dotplot/deepmito.log"
  shell:
    """
    R/deepmito-dotplot.R --type png --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/deepmito-dotplot.R --type eps --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """



########################################
##  MitoFates rules
########################################

rule Boxplot_MitoFates_All:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine/mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-all.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-all.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-all.log"
  shell:
    """
    R/mitofates-boxplot-all.R --type png --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/mitofates-boxplot-all.R --type eps --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


rule Boxplot_MitoFates_Individual:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine/mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-{protein}.png",
    output_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-{protein}.eps"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates-{protein}.log"
  params:
    protein = "{protein}"
  shell:
    """
    R/mitofates-boxplot-single.R --type png --protein {params.protein} --input {input.input_fn1} --output {output.output_fn1} >{log.log_fn1} 2>&1
    R/mitofates-boxplot-single.R --type eps --protein {params.protein} --input {input.input_fn1} --output {output.output_fn2} >>{log.log_fn1} 2>&1
    """


rule Boxplot_MitoFates_All_Individual:
  input:
    Expand_Boxplot_MitoFates_Combinations
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/09_boxplot/mitofates.all"
  shell:
    """
    touch {output.output_fn1}
    """


