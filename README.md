# StageEEGpre

dependencies:
- eeglab : https://sccn.ucsd.edu/eeglab/download.php  eeglab current v2021.1 version avec matlab
- article : 
on trouve les 4 dependances sur https://github.com/Neuro-Tools/
il faut telecharger : https://github.com/Neuro-Tools/MATLAB-EEG-preProcessing
  https://github.com/Neuro-Tools/MATLAB-EEG-fileIO
  https://github.com/Neuro-Tools/MATLAB-EEG-timeFrequencyAnalysis
  https://github.com/Neuro-Tools/MATLAB-EEG-icaTools

data:
https://osf.io/qrs4h/
telecharger Raw data Part 1.zip et l'extraire dans le dossier ./data
telecharger https://osf.io/ztw8u/ ChanlocsMaster.mat et l'ajouter dans le dossier Raw data part 1 ci dessus

## Reproducing Fig 2A of (Williams et al, 2021)

### Using the code provided with the paper and the preprocessed datasets

1. Run the analysis and create the intermediatary file that processes the subject results to estimate the means etc [RewardProcessing_Plots.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/eeglabcode/plot/RewardProcessing_Plots.m). 
2. Create the figures using the R script [RewardProcessing_Plots_and_Statistics.R](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/graphiques/RewardProcessing_Plots_and_Statistics.R). 

We obtain [this figure](https://github.com/Inria-Empenn/StageEEGpre/blob/main/figures/articke%20fig2/preprocessed100.png)

### Using the code provided with the paper and the raw datasets (without ICA manual)

1. Add path to dependencies with [demarragemaison.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/header%20script/demarragemaison.m). Note: this file has to be edited to include your own pathes.
2. Create the figures using the R script [RewardProcessing_Plots_and_Statistics.R](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/graphiques/RewardProcessing_Plots_and_Statistics.R). Note: the number of participants has to be updated to the number of participants included.

We obtain [this figure](https://github.com/Inria-Empenn/StageEEGpre/blob/main/figures/articke%20fig2/noica73.png)

### Using EEGlab and the raw datasets

1. Run the analysis [eeglab_preprocessing.m](https://github.com/AyaKabbara/StageEEGpre/blob/main/src/eeglab/eeglab_preprocessing.m).
2. Create the figures using the R script [fig2Av2.R](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/codeR/fig2Av2.R). Note: the number of participants has to be updated to the number of participants included, the name of csv files should be changed accordingly.

We obtain [this figure](https://github.com/Inria-Empenn/StageEEGpre/blob/main/figures/articke%20fig2/100sujetseeglabfinal.png)

### Using Brainstorm and the raw datasets

1. Convert the dataset into EEGLAB set using the following functions: [toset.m](https://github.com/AyaKabbara/StageEEGpre/blob/main/src/BST/toset.m)  so that it can be recognized by BS
2. Run the analysis with [bsPreprocessing.m](https://github.com/AyaKabbara/StageEEGpre/blob/main/src/BST/bsPreprocessing.m). Note: the paths should be changed 
