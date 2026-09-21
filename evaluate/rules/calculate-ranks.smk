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

##  Return the set of proteins in this group, but separated by a comma
def GetProteins (wc):
  results = []

  for gproteins_row in gproteins_panda.itertuples (index = False):
    if wc.gproteins == gproteins_row.Group:
      results.append (gproteins_row.Protein)

  delimiter = ","
  joined_str = delimiter.join (results)

  return dict (proteins = joined_str)


rule Calculate_DeepMito_MitoFates_Ranks:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_deepmito_combine/deepmito.tsv",
    input_fn2 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine/mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_both/ranks.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_both/ranks.log"
  shell:
    """
    ranks_list="10,50,100,200,300,400,500,600,700,800,900,1000,2000,4000,6000,8000,10000,11000,12000,13000,14000,15000,16000,17000,20000"
    methods_list="1,2,3,4,5,6,7,8,9"

    Perl/rank-deepmito-mitofates.pl --deepmito {input.input_fn1} --mitofates {input.input_fn2} --ranks ${{ranks_list}} --methods ${{methods_list}}  >{output.output_fn1} 2>{log.log_fn1}
    """


rule Calculate_DeepMito_Ranks:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_deepmito_combine/deepmito.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_deepmito/pairwise.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_deepmito/pairwise.log"
  params:
    x=GetProteins
  shell:
    """
    ranks_list="10,50,100,125,250,375,500,625,750,875,1000,1125,1200"
    methods_list="4,7"
    proteins={params.x[proteins]}

    ##  Create the output files with 0 bytes
    touch {output.output_fn1}
    touch {log.log_fn1}

    for first in ${{proteins//,/ }}; do
      for second in ${{proteins//,/ }}; do
        if [[ ${{first}} < ${{second}} ]]; then
          Perl/rank-deepmito.pl --deepmito {input.input_fn1} --protein1 ${{first}} --protein2 ${{second}} --ranks ${{ranks_list}} --methods ${{methods_list}} >>{output.output_fn1} 2>>{log.log_fn1}
        fi
      done
    done
    """


rule Calculate_MitoFates_Ranks:
  input:
    input_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/04_mitofates_combine/mitofates.tsv"
  output:
    output_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_mitofates/pairwise.tsv"
  log:
    log_fn1 = OUTPUT_DIR + "/evaluate/{greps}/{gproteins}/06_ranks_mitofates/pairwise.log"
  params:
    x=GetProteins
  shell:
    """
    ranks_list="10,50,100,125,250,375,500,625,750,875,1000,1125,1200"
    methods_list="4,7"
    proteins={params.x[proteins]}

    ##  Create the output files with 0 bytes
    touch {output.output_fn1}
    touch {log.log_fn1}

    for first in ${{proteins//,/ }}; do
      for second in ${{proteins//,/ }}; do
        if [[ ${{first}} < ${{second}} ]]; then
          Perl/rank-mitofates.pl --mitofates {input.input_fn1} --protein1 ${{first}} --protein2 ${{second}} --ranks ${{ranks_list}} --methods ${{methods_list}} >>{output.output_fn1} 2>>{log.log_fn1}
        fi
      done
    done
    """


