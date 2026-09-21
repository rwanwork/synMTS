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


rule Change_Alphabet:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/positive.fasta",
    input_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/negative.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/06_change_alphabet_mts/positive.fasta",
    output_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/06_change_alphabet_mts/negative.fasta"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/06_change_alphabet_mts/mts.log",
    log_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/06_change_alphabet_mts/mts.log"
  params:
    category="{protein}"
  shell:
    """
    cat {input.input_fn1} | Perl/change-alphabet.pl >{output.output_fn1} 2>{log.log_fn1}
    cat {input.input_fn2} | Perl/change-alphabet.pl >{output.output_fn2} 2>{log.log_fn2}
    """


rule Run_Streme_Normal:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/positive.fasta",
    input_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/02_select_fasta_mts/negative.fasta"
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/07_streme_normal/streme.html"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/07_streme_normal/streme.log",
  shell:
    """
    outpath="`dirname {output.output_fn1}`"

    touch {output.output_fn1}
    {STREME_SOFTWARE} --verbosity 1 --oc ${{outpath}} --protein --totallength 4000000 --time 14400 --minw 5 --maxw 15 --thresh 0.05 --align left --p {input.input_fn1} --n {input.input_fn2} 2>{log.log_fn1}
    """


rule Run_Streme_AltAlphabet:
  input:
    input_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/06_change_alphabet_mts/positive.fasta",
    input_fn2 = OUTPUT_DIR + "/select/{greps}/{protein}/06_change_alphabet_mts/negative.fasta",
    input_fn3 = STREME_ALPHA_FILE
  output:
    output_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/08_streme_altalphabet/streme.html"
  log:
    log_fn1 = OUTPUT_DIR + "/select/{greps}/{protein}/08_streme_altalphabet/streme.log",
  shell:
    """
    outpath="`dirname {output.output_fn1}`"

    {STREME_SOFTWARE} --verbosity 1 --oc ${{outpath}} --alph {input.input_fn3} --totallength 4000000 --time 14400 --minw 5 --maxw 15 --thresh 0.05 --align left --p {input.input_fn1} --n {input.input_fn2} 2>{log.log_fn1}
    """


