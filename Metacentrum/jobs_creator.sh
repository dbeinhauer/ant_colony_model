#!/bin/bash

# JOBS_DIR="Jobs/"
# JOBS_POSTFIX=".txt"
for FILE in $(ls Experiments/*.jl)
do
JOBS_DIR="Jobs/"
JOBS_POSTFIX=".txt"
EXP_NAME=$(echo $FILE | cut -d"/" -f2 | cut -d"." -f1)
echo '#!/bin/bash
#PBS -N '$EXP_NAME >>"$JOBS_DIR/$EXP_NAME.sh"
echo '#PBS -l select=1:ncpus=8:mem=16gb:scratch_local=10gb
#PBS -l walltime=12:00:00 
#PBS -m ae
# The 4 lines above are options for scheduling system: job will run 1 hour at maximum, 1 machine with 4 processors + 4gb RAM memory + 10gb scratch memory are requested, email notification will be sent when the job aborts (a) or ends (e)

# define a DATADIR variable: directory where the input files are taken from and where output will be copied to
DATADIR=/storage/praha1/home/dbeinhauer
' >>"$JOBS_DIR/$EXP_NAME.sh"

echo 'EXPERIMENT_NAME='$EXP_NAME >>"$JOBS_DIR/$EXP_NAME.sh"

echo 'echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> jobs_info.txt


module load julia

# test if scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

cp "$DATADIR/Ants/ant_colony.jl" $SCRATCHDIR
cp "$DATADIR/Ants/Experiments/$EXPERIMENT_NAME.jl" $SCRATCHDIR

cd "$SCRATCHDIR/"

julia $EXPERIMENT_NAME.jl >$EXPERIMENT_NAME.txt

mv $EXPERIMENT_NAME.txt $DATADIR/Ants_output

clean_scratch' >>"$JOBS_DIR/$EXP_NAME.sh"

done
