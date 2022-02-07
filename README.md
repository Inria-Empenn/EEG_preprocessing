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

### Using the code provided with the paper

1. Add path to dependencies with [demarragemaison.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/header%20script/demarragemaison.m). Note: this file has to be edited to include your own pathes.
2. Create the intermediatary file that processes the subject results to estimate the means etc [sansICA75.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/article/sansICA75.m). Note: this file has to be edited to include your own pathes and [at this line](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/article/sansICA75.m#L78) update the number of subjects to be included.
3. Create the figures using the R script [RewardProcessing_Plots_and_Statistics.R](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/graphiques/RewardProcessing_Plots_and_Statistics.R). Note: the number of participants has to be updated to the number of participants included.

