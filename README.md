# About
This repository contains the source code and LaTeX template of my 
final project of the Mathematical Modeling In Bioinformatics class in 
Charles University. 
The project consists of model of the artificial ant colony and its analysis.

The analysis of the project is available 
[here](https://github.com/dbeinhauer/ant_colony_model/blob/main/template/main.pdf).


# Structure of The Repository
The repository is separated into two main parts:

* `source/` - contains the source code of the simulator, experiment analysis and 
the output data of the experiments
* `template/` - contains LaTeX template of the model analysis, 
figures and all supplementary materials


# Abstract (EN)
The behavior of insect species living in cooperative colonies remains a challenge for
science. Understanding this issue can lead to improving the solutions to a range of 
seemingly unrelated problems. This paper presents a simple multi-agent model of an 
ant colony focusing on the issue of foraging in various complex environments. 
The analysis demonstrated the model's ability to simulate the coordinated 
cooperation of ants in collecting food."


# Abstract (CZ)

Chování hmyzích druhů žijících v kooperujících koloniích je dodnes 
výzvou pro vědu. Pochopení této problematiky může vést k zdokonalení řešení
řady zdánlivě nesouvisejících problémů. V práci je představen jednoduchý
multiagentní model mravenčí kolonie zaměřující se na problematiku shánění
potravy v různě komplexních prostředích. 
Při analýze byla prokázána schopnost modelu simulace koordinované 
spolupráce mravenců při sbírání potravy.

# Setup
To properly run the simulator and experiments analysis it is necessary to have installed:

* [Julia](https://julialang.org/) - with installed packages: 
Pluto, Statistics, Makie, CairoMakie

## Plots Creation
In order to create plots of the experiment analysis it is necessary having 
[poetry](https://python-poetry.org/docs/) installed.

```sh
curl -sSL https://install.python-poetry.org | python3 -
```

Then setup the environment by running.
```sh
poetry install
```

Finally, enter the environment.
```sh
poetry shell
```

You can run ```jupyter lab``` from within the environment with all the required dependencies present.
