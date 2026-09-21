synMTS
======


Introduction
------------

This repository, **synMTS**, consists of four [Snakemake-based](https://snakemake.readthedocs.io/en/stable/) workflows whose purposes are to:

1.  Generate synthetic mitochondria targeting sequences (synMTS) (generate).
2.  Evaluate these sequences (evaluate).
3.  Calculate some statistics over the properties of the synMTS (statistics).
4.  Take a subset of the results to focus on (select).

The software in this repository supports the following manuscript:

    K. Gombeau, R. Wan, J. S. James, D. Tribouillard-Tanvier, and Y. Cai. "TargetMITO: A rule-based model for generating functional synthetic mitochondrial targeting sequences in yeast", 2026 (To appear).

which was published in preliminary form as:

    K. Gombeau, R. Wan, J. S. James, D. Tribouillard-Tanvier, and Y. Cai. "TargetMITO: A rule-based model for generating functional synthetic mitochondrial targeting sequences in yeast".  [bioRxiv](https://www.biorxiv.org/content/10.64898/2026.02.22.707306v1), 2026.

We refer to the first of these two throughout this document as "the manuscript".

In between workflows (1) and (2), you will need to submit the synMTS sequences with passenger proteins to:

1.  [MitoFates](https://mitf.cbrc.pj.aist.go.jp/MitoFates/cgi-bin/top.cgi),
2.  [DeepMito](https://busca.biocomp.unibo.it/deepmito/),

If you do not plan to use both systems, then you will need to edit the workflows yoruself.  Prior to workflow 4, a file of synMTS identifiers is required (`Common/config/select-order.tsv`).  This file is used to select a subset of the entire data set to produce a set of tables that are used in the manuscript.

This repository contains the following:

  * Four Snakemake workflows in four separate directories,
  * source code in Perl and R,
  * Varopis `environment.yml` file for creating a [conda](https://docs.conda.io/en/latest/) environment,
  * licensing information, and
  * data from a sample execution of the workflow (including output from the MitoFates and DeepMito servers).  More specifically, there are: 
       * Three replicates of 200 sequences each across the 9 methods (i.e., 3 * 200 * 9 = 5,400 synMTS).
       * Results from the MitoFates server for these 5,400 synMTS.
       * Results from the DeepMito server for these 5,400 synMTS.


Installation
------------

Software that needs to be installed is given in this table:

| Software                | Version              | Required? | Ubuntu package? | Web site                                                              |
|:-----------------------:|:--------------------:|:---------:|:---------------:|:---------------------------------------------------------------------:|
| conda                   | 26.5.3               | Yes       | No              | [Miniforge](https://github.com/conda-forge/miniforge)                 |
| emboss                  | 6.6.0+dfsg-18        | Yes       | Yes             | [Ubuntu package](https://packages.ubuntu.com/eu/resolute/emboss)      |
| ncbi-blast+             | 2.16.0+ds-7          | No        | Yes             | [Ubuntu package](https://packages.ubuntu.com/eu/resolute/ncbi-blast+) |
| streme                  | 5.5.9                | Yes       | No              | [Meme Suite](https://meme-suite.org/meme/doc/download.html)           |

Experiments with this software have been successfully run on a Linux system running Ubuntu 25.10 and Ubuntu 26.04.  The software versions in the table above represent the tools used during software development.  They do not represent the minimum requirements; it is possible that lower versions can be used.

More importantly, the workflows in this repository use Snakemake to call Perl and R scripts.  All of these programs were installed via [Miniforge](https://github.com/conda-forge/miniforge) into a "conda" environment, except for the software listed in the above table.

Go to the `Common/conda/` directory and create the environment using `conda env create -f original-pinned.yml` to create the environment used for the manuscript.  This is explained in the online conda [instructions](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-from-an-environment-yml-file).  Alternatively, use `original.yml` if some pinned software are no longer available.  Other environments that might be of interest to you are `updated.yml` and `macos.yml`.  The former employs updated software from the original manuscript submission while the latter is for the MacOS operating system (only limited testing performed).


Directory Organisation
----------------------

After cloning this repository from GitHub using the `git clone` command, **and** running the four workflows (explained further below), the following file/directory structure is obtained:

    .
    ├── Common                              Directories and files shared across workflows
    │   ├── conda                             Directory of conda environments
    │   │   ├── *-pinned.yml                    Conda environments pinned to specific software versions
    │   │   └── *.yml                           Conda environments without any pinning
    │   ├── config                            Configuration files
    │   ├── md5sum-mts_only.txt               MD5 checksums for the synMTS stored in the repository
    │   ├── md5sum-post-generate.txt          MD5 checksums for the FASTA files after running the "generate" "workflow"
    │   ├── Data                            Data directory
    │   │   ├── fused                         Real MTS fused with passenger proteins
    │   │   ├── mts                           Real MTS
    │   │   └── protein                       Sample passenger proteins for appending
    │   ├── Input                           Input directory
    │   │   ├── deepmito                      Diretory of sample DeepMito results
    │   │   ├── deepmito.tsv                  List of DeepMito results
    │   │   ├── mitofates                     Directory of sample MitoFates results
    │   │   └── mitofates.tsv                 List of MitoFates results
    │   ├── Output                          Output directory
    │   │   ├── graphs                        Output of the "evaluate" workflow
    │   │   ├── Progress                      Location of files that are created when a workflow has completed successfully
    │   │   └── generate                      Output of the "generate" workflow
    │   │       ├── 1                           Sample replicate #1 of data with only the "01_random" directory
    │   │       ├── 2                           Sample replicate #2 of data with only the "01_random" directory
    │   │       └── 3                           Sample replicate #3 of data with only the "01_random" directory
    │   └── Perl                            Perl modules that could be potentially used by multiple workflows
    ├── evaluate                            "evaluate" workflow
    │   ├── config -> ../Common/config
    │   ├── Data -> ../Common/Data
    │   ├── Input -> ../Common/Input
    │   ├── Output -> ../Common/Output
    │   ├── Perl                              Perl scripts
    │   ├── R                                 R scripts
    │   └── rules                             Snakemake rules
    ├── generate                            "generate" workflow
    │   ├── config -> ../Common/config
    │   ├── Data -> ../Common/Data
    │   ├── Input -> ../Common/Input
    │   ├── Output -> ../Common/Output
    │   ├── Perl                              Perl scripts
    │   └── rules                             Snakemake rules
    ├── select                              "select" workflow
    │   ├── config -> ../Common/config
    │   ├── Data -> ../Common/Data
    │   ├── Input -> ../Common/Input
    │   ├── Output -> ../Common/Output
    │   ├── Perl                              Perl scripts
    │   └── rules                             Snakemake rules
    ├── statistics                          "statistics" workflow
    │   ├── config -> ../Common/config
    │   ├── Data -> ../Common/Data
    │   ├── Input -> ../Common/Input
    │   ├── Output -> ../Common/Output
    │   ├── Perl                              Perl scripts
    │   ├── R                                 R scripts
    │   └── rules                             Snakemake rules
    ├── LICENSE                             Software license (GNU GPL v3)
    └── README.md                           This README file


### Directories of interest

Here is a list of some directories of interest:

* `Common/Output/generate/?/01_random` -- The 3 replicates of the synMTS data sets that are stored in the GitHub repository (i.e., they are not generated by the workflow) with their "original" names.  Originally, the names of the synMTS sequences contained the random seed used to generate them.  They are renamed early within the `generate` workflow. The sequences are lexically sorted and assigned increasing integers starting from 1, 201, and 401 (since each replicate has 200 sequences) for each of the 3 replicates.
* `Common/Output/Manuscript/` -- Tables and graphs used for the manuscript, with filenames that reflect where they are in the main or supplementary manuscript.

When examining directory names, `A` is a grouping of replicates while `X` is a grouping of passenger proteins.  If the synMTS has not been fused with a passenger protein yet, then no grouping by passenger proteins exists (yet).  See `Common/config/group-reps.tsv` and `Common/config/group-proteins.tsv` for more information.


Running the example
-------------------

### Locations of the input data

The example data of 3 replicates and all 9 methods is spread out in two main locations:

* `Common/Output/generate/1/`, `Common/Output/generate/2/`, and `Common/Output/generate/3/`
* `Common/Input/deepmito/` and `Common/Input/mitofates/`


### Re-running the workflow locally

In order to run each of the 4 Snakemake workflows, we suggest you:

1.  Enter the directory in question.
2.  Enter `snakemake --snakefile Snakefile.smk --cores 1 -p --dryrun`.
3.  If there are no errors, then repeat the command without `--dryrun`:  `snakemake --snakefile Snakefile.smk --cores 1 -p`.  If the computer you are using has more cores, you can change the `1` to a higher value.

Thus, to run all 4 workflows, do the following:

1.  Install the `conda` environment, as described above.
2.  Run the `generate` workflow.  If you wish to use the same random MTS' that are currently in the repository, then make sure that the rule `Random_MTS` does **not** appear in the rule summary (i.e., "Job stats" section).  If it does appear, it means that it will be executed and the files in the `01_random/` directories will be overwritten.  One way to avoid regenerating these files is to enter the output directory (`Common/Output/generate/`) before running the workflow and execute this:  `find ./ -type f -exec touch {} \;`.  This will "touch" the files so that they will have the current date and time.
3.  Submit the generated `.fasta` files in the `Common/Output/generate/{replicate}/05_mitofates/` directory to the MitoFates server.
4.  Submit the generated `.fasta` files in the `Common/Output/generate/{replicate}/05_deepmito/` directory to the DeepMito server.  If the files in this directory are too large for the DeepMito server, then submit the files in the `Common/Output/generate/{replicate}/05_deepmito_halve/` directory instead.  These are the same files, but have been split in two with an `A` and a `B` suffix.
5.  Download the results and record them into two tab-separated files:  `Common/config/deepmito.tsv` and `Common/config/mitofates.tsv`.  See below for the format of these files.  Note that our results from submitting our data to these web services have already been included in this repository.
6.  Run the `evaluate` workflow.  Output can be found in `Common/Output/evaluate/`.
7.  Run the `statistics` workflow.  Output can be found in `Common/Output/statistics/`.
8.  Run the `select` workflow.  Output can be found in `Common/Output/select/`.

If you make a mistake while processing the sample data and want to delete everything except for the sample data cloned from the repository, then go to the `Common/` and execute the script `clear-data.sh`.  Alternatively, delete everything in the `Common/Output/` directory and use `git restore` to restore all of the files stored in the `01_random/` directory from the GitHub repository.


### Verifying the FASTA sequences

You can verify that the FASTA sequences that you have obtained matched what we have generated by using `md5sum` to check the MD5 message digest.  Within the `Common/Output/` directory, run these two commands:

1. `md5sum -c ../md5sum-mts_only.txt --quiet` after cloning our repository
2. `md5sum -c ../md5sum-post-generate.txt --quiet` after running the "generate" workflow

If no output is produced, then the MD5 message digest matched for all of the files.


### Downloading the web server results

Both the MitoFates and DeepMito web servers assign a unique identifier for the data that you submit.  This "job ID" can be used to download the data file for use by this workflow.


#### MitoFates

For a job ID "XXX", the data file can be downloaded with this `wget` command and saved into `XXX.tsv`:

`wget https://mitf.cbrc.pj.aist.go.jp/MitoFates/cgi-bin/download.cgi?jobId=XXX\&file=result -O XXX.tsv`


#### DeepMito

For a job ID "XXX", the data file can be downloaded with this `wget` command and saved into `XXX.json`:

`wget https://busca.biocomp.unibo.it/deepmito/XXX/getjson/ -O XXX.json`


Format of the data tables
-------------------------

### MitoFates

The tab-separated file `Common/config/mitofates.tsv` should have a column header as the first row, with the following 4 fields:

* ID -- Unique identifier for each row
* Replicate -- Replicate number
* Protein -- Name of the passenger protein appended on
* MitoFates -- Unique identifier for the run


### DeepMito

The tab-separated file `Common/config/deepmito.tsv` should have a column header as the first row, with the following 5 fields:

* ID -- Unique identifier for each row
* Replicate -- Replicate number
* Method -- Method used (1 -- 9)
* Protein -- Name of the passenger protein appended on
* DeepMito -- Unique identifier for the run


Starting a new data set
-----------------------

In order to start a new data set, after cloning the repository, delete these directories:

* `Common/Output/*`
* `Common/Input/*`

If you want to add a new passenger protein to the workflow, you will need to do at least the following:

1.  Add the protein sequence as a FASTA file in `Common/Data/protein/`, ensuring it has a `.fasta` file extension.  The part of the file that comes before file extension is the sequence's name.
2.  Consider how you would like the passenger protein to be grouped by updating `Common/config/group-reps.tsv` and `Common/config/group-proteins.tsv`, updating `evaluate/Snakefile.smk`, `select/Snakefile.smk`, and `statistics/Snakefile.smk` as needed.
3.  Add the sequence name to the `protein` | `sequences` variable in `Common/config/config.yml`.
4.  Add the sequence name to the `wildcard_constraints` | `protein` variable in `generate/Snakefile.smk`, `evaluate/Snakefile.smk`, and `select/Snakefile.smk`.


About synMTS
------------

This software was implemented while I was at the University of Manchester.  My contact details:

     E-mail:  rwan.work@gmail.com

My homepage is [here](http://www.rwanwork.info/).

The latest version can be downloaded from [GitHub (forked)](https://github.com/the-cai-lab/synMTS), which is forked from [GitHub](https://github.com/rwanwork/synMTS).

If you have any information about bugs, suggestions for the documentation or just have some general comments, feel free to contact me via e-mail or as a [GitHub issue](https://github.com/rwanwork/synMTS/issues).  (Of the two, I prefer latter.)


Copyright and License
---------------------

     synMTS (synthetic MTS)
     Copyright (C) 2024-2026 by Raymond Wan

synMTS is distributed under the terms of the GNU General Public License (GPL, version 3 or later) -- see the file LICENSE for details.

Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts and no Back-Cover Texts. A copy of the license is included with the archive as LICENSE.


