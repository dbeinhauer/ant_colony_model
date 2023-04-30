# About
This directory contains the source code necessary for experiment execution on Metacentrum.

# Structure
* `jobs_creator.sh` - a program that is used to create jobs for experiment execution on Metacentrum
* `Experiments/` - a subdirectory containing prepared programs to be executed for experiment analysis
* `Jobs/` - a subdirectory where the prepared scripts for job execution will be stored by the program `jobs_creator.sh`

# Usage
The program will prepare bash jobs that run the experiments prepared in the directory 
`Experiments/` on Metacentrum. To execute the program, run:
```
./jobs_creator.sh
```