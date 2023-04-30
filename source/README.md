# About

This directory contains the source code of the simulator, experiment analysis and 
the output data of the experiments.

# Structure
This directory contains the source code of the simulator, experiment analysis and 
the output data of the experiments:

* `ant_colony.jl` - source code of the implementation of the ant colony model 
in Pluto notebook
* `experiment.jl` - source code for experiments execution and creation of some plots 
from the experiment analysis in Pluto notebook
* `plot_creator.ipynb` - Jupyter Lab project for plot creation of experiment analysis
* `experiment_parser.sh` - program for parsing output data files of the experiments
(run in format: `./experiment_parser.sh INPUT_DIR OUTPUT_DIR`)
* `Outputs/` - subdirectory contating outputs from experiment analysis
* `Prepared_Output/` - subdirectory containing preprocessed experiment outputs for 
future analysis
* `Metacentrum/` - subdirectory containing the source code necessary 
for experiment execution on Metacentrum