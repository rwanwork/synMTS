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

deepmito_panda = pd.read_table (config["deepmito"], sep='\t', lineterminator='\n')
deepmito_panda.set_index ("ID", drop=False, inplace=True)
validate (deepmito_panda, schema="config/deepmito.schema.yml")

deepmito_halved_panda = pd.read_table (config["deepmito_halved"], sep='\t', lineterminator='\n')
deepmito_halved_panda.set_index ("ID", drop=False, inplace=True)
validate (deepmito_halved_panda, schema="config/deepmito-halved.schema.yml")

mitofates_panda = pd.read_table (config["mitofates"], sep='\t', lineterminator='\n')
mitofates_panda.set_index ("ID", drop=False, inplace=True)
validate (mitofates_panda, schema="config/mitofates.schema.yml")

mitofates_subrk_panda = pd.read_table (config["mitofates_subrk"], sep='\t', lineterminator='\n')
mitofates_subrk_panda.set_index ("ID", drop=False, inplace=True)
validate (mitofates_subrk_panda, schema="config/mitofates-sub_r_k.schema.yml")

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
  protein = "atp8|atp9|cox2|hac1|mmf1",
  replicate = "\\d+",
  greps = "A|B",
  gproteins = "X|Y"


##################################
##  Include additional functions and rules
include:  "config/global-vars.smk"

include:  "rules/copy.smk"
include:  "rules/json.smk"
include:  "rules/clean.smk"
include:  "rules/rename-samples.smk"
include:  "rules/combine.smk"
include:  "rules/calculate-ranks.smk"

include:  "rules/join-mitofates.smk"
include:  "rules/graph-join-mitofates.smk"

include:  "rules/graph-ranks.smk"
include:  "rules/graph-distribution.smk"
include:  "rules/graph-scatterplot.smk"

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
    PROGRESS_OUTPUT_DIR + "/evaluate/A_X_all.done"

