#####################################################################
##  Libraries
#####################################################################

from pathlib import Path
from getpass import getuser
import multiprocessing  ##  for multiprocessing.cpu_count ()
import os  ##  For os.sysconf ()
import math  ##  For math.floor ()


#####################################################################
##  Specifications about the server
#####################################################################

##  Determine the home directory
MY_HOMEDIR = str (Path.home())

##  Get the current user name
MY_USERNAME = getuser ()

##  Get the amount of memory in bytes and then gigabytes; only use 95% of the total memory
##  Source:  https://stackoverflow.com/questions/22102999/get-total-physical-memory-in-python
mem_bytes = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')
mem_gib = mem_bytes / (1024.**3)
mem_gib = math.floor (mem_gib)

##  Set the number of threads and memory usage for the servers
NUM_THREADS = multiprocessing.cpu_count ()
NUM_MEMORY = mem_gib
NUM_MEMORY_PER_THREAD = math.floor (NUM_MEMORY / NUM_THREADS * 0.90)

##  Report the determined values
##  Note:  These are the values for the server where snakemake is executed;
##         it does not reflect the values on other nodes.
print ("II\tNumber of threads:  " + str (NUM_THREADS), file=sys.stderr)
print ("II\tTotal system memory:  " + str (NUM_MEMORY) + " GiB", file=sys.stderr)
print ("II\tAmount of memory per thread:  " + str (NUM_MEMORY_PER_THREAD) + " GiB", file=sys.stderr)


#####################################################################
##  Local directories
#####################################################################

##  Temporary directory for bwa alignment
TMP_DIRECTORY = "/tmp"

##  Directories
CONFIG_DIR = "config"
DATA_DIR = "Data"
INPUT_DIR = "Input"
OUTPUT_DIR = "Output"
PROGRESS_OUTPUT_DIR = OUTPUT_DIR + "/Progress"
MANUSCRIPT_OUTPUT_DIR = OUTPUT_DIR + "/Manuscript"
PAPER_MAIN_OUTPUT_DIR = MANUSCRIPT_OUTPUT_DIR + "/Main"
PAPER_SUPP_OUTPUT_DIR = MANUSCRIPT_OUTPUT_DIR + "/Supplementary"

##  Files
AAPROP_FILE = CONFIG_DIR + "/aminoacids-features.tsv"
SELECTORDER_FILE = CONFIG_DIR + "/select-order.tsv"
STREME_ALPHA_FILE = CONFIG_DIR + "/protein-groups.txt"
DEEPMITO_FILE = DATA_DIR + "deepmito.tsv"
MITOFATES_FILE = DATA_DIR + "mitofates.tsv"

##  Programs
STREME_SOFTWARE = MY_HOMEDIR + "/general/software/meme/bin/streme"


#####################################################################
##  Command options
#####################################################################

##  The formatting string used for /usr/bin/time
##    %U - user time
##    %S - system time
##    %e - elapsed time (in seconds)
##    %K - average total memory used (kb)
##    %M - maximum resident set size
##    %P - percentage of the CPU that the job got
##    %F - major page faults
##    %R - minor page faults
##    %W - number of times process swapped out of memory
##    %C - name and command-line arguments
TIME_CMD = "/usr/bin/time -f \"XXX\t%U\t%S\t%e\t%K\t%M\t%P\t%F\t%R\t%W\t%C\""
