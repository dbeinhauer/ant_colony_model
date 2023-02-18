#!/bin/bash
#PBS -N ants_output
#PBS -l select=1:ncpus=8:mem=16gb:scratch_local=10gb
#PBS -l walltime=12:00:00 
#PBS -m ae
# The 4 lines above are options for scheduling system: job will run 1 hour at maximum, 1 machine with 4 processors + 4gb RAM memory + 10gb scratch memory are requested, email notification will be sent when the job aborts (a) or ends (e)

# define a DATADIR variable: directory where the input files are taken from and where output will be copied to
DATADIR=/storage/praha1/home/dbeinhauer # substitute username and path to to your real username and path

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of node it is run on and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt


module load julia

# test if scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

cp -r "$DATADIR/Ants" $SCRATCHDIR

cd "$SCRATCHDIR/Ants"

# cd $DATADIR/ants_output

julia experiments.jl >output.txt

mv output.txt $DATADIR/Ants_output

clean_scratch