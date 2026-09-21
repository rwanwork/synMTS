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


##################################
##  Define global constraints on wildcards
wildcard_constraints:
  replicate = "\\d+",
  method = "\\d+"


##################################
##  Include additional functions and rules
include:  "config/global-vars.smk"

include:  "rules/random.smk"

include:  "rules/modify-random.smk"

include:  "rules/append.smk"
include:  "rules/rename.smk"
include:  "rules/mitofates.smk"
include:  "rules/deepmito.smk"

include:  "rules/complete.smk"


##################################
##  Set the shell and the prefix to run before "shell" commands -- activate the conda environment
shell.executable ("/bin/bash")
shell.prefix ("source /opt/miniforge3/etc/profile.d/conda.sh; conda activate synmts; ")


##################################
##  Top-level rule
rule all:
  input:
    PROGRESS_OUTPUT_DIR + "/generate/1.done",
    PROGRESS_OUTPUT_DIR + "/generate/2.done",
    PROGRESS_OUTPUT_DIR + "/generate/3.done"

