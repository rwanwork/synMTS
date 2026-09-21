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


import pandas as pd

from snakemake.utils import validate, min_version

##  Set the minimum snakemake version
min_version ("8.0")


##################################
##  Configuration files
configfile: "config/config.yml"
validate (config, schema = "config/config.schema.yml")

greps_panda = pd.read_table (config["group_reps"], sep='\t', lineterminator='\n')
greps_panda.set_index ("ID", drop=False, inplace=True)
validate (greps_panda, schema="config/group-reps.schema.yml")

gproteins_panda = pd.read_table (config["group_proteins"], sep='\t', lineterminator='\n')
gproteins_panda.set_index ("ID", drop=False, inplace=True)
validate (gproteins_panda, schema="config/group-proteins.schema.yml")


##################################
##  Define global constraints on wildcards
wildcard_constraints:
  method = "\\d+",
  replicate = "\\d+",
  greps = "A|B",
  gproteins = "X|Y",
  window = "any|10|18|30"


##################################
##  Include additional functions and rules
include:  "config/global-vars.smk"

include:  "rules/copy.smk"

include:  "rules/properties.smk"
include:  "rules/merge-properties.smk"
include:  "rules/graph-properties.smk"

include:  "rules/hmoment.smk"
include:  "rules/graph-hmoment.smk"

include:  "rules/join-hmoment-mitofates.smk"
include:  "rules/graph-hmoment-mitofates.smk"

include:  "rules/gather-paper.smk"

include:  "rules/complete.smk"


##################################
##  Set the shell and the prefix to run before "shell" commands -- activate the conda environment
shell.executable ("/bin/bash")
shell.prefix ("source /opt/miniforge3/etc/profile.d/conda.sh; conda activate synmts; ")


##################################
##  Top-level rule
rule all:
  input:
    PROGRESS_OUTPUT_DIR + "/statistics/A_X_10.done"

