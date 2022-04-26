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

2. Run the analysis and create the intermediatary file that processes the subject results to estimate the means etc [RewardProcessing_Plots.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/eeglabcode/plot/RewardProcessing_Plots.m). 
3. Create the figures using the R script [RewardProcessing_Plots_and_Statistics.R](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/graphiques/RewardProcessing_Plots_and_Statistics.R). 

We obtain [this figure](https://github.com/Inria-Empenn/StageEEGpre/blob/main/figures/articke%20fig2/preprocessed100.png)

### Using the code provided with the paper and the raw datasets (without ICA manual)

1. Add path to dependencies with [demarragemaison.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/header%20script/demarragemaison.m). Note: this file has to be edited to include your own pathes.
3. Run the analysis and create the intermediatary file that processes the subject results to estimate the means etc [sansICA75.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/article/sansICA75.m). Note: this file has to be edited to include your own pathes and [at this line](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/article/sansICA75.m#L78) update the number of subjects to be included.
4. Create the figures using the R script [RewardProcessing_Plots_and_Statistics.R](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/graphiques/RewardProcessing_Plots_and_Statistics.R). Note: the number of participants has to be updated to the number of participants included.

We obtain [this figure](https://github.com/Inria-Empenn/StageEEGpre/blob/main/figures/articke%20fig2/noica73.png)

### Using EEGlab and the raw datasets

3. Run the analysis [version100sujets.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/eeglabcode/janvier/100%20sujets/version100sujets.m). Note: this file has to be edited to include your own pathes and [at these lines](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/eeglabcode/janvier/100%20sujets/version100sujets.m#L20-L21) update the number of subjects to be included.
4. Create the intermediary file with [variablespourfig1.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/eeglabcode/janvier/figure1/variablespourfig1.m)
5. Create the figures using the R script [fig2Av2.R](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/codeR/fig2Av2.R). Note: the number of participants has to be updated to the number of participants included.

We obtain [this figure](https://github.com/Inria-Empenn/StageEEGpre/blob/main/figures/articke%20fig2/100sujetseeglabfinal.png)

### Using automagic and the raw datasets (work-in-progress)

1. Format the dataset using BIDS so that it can be recognized by automagic
2. Run the analysis with [script25janv.m](https://github.com/Inria-Empenn/StageEEGpre/blob/main/src/automagic/janvier/script25janv.m) Note: this code is not ready-to-use yet but includes importing the data and creating a project, the pipeline is to be updated to match the paper as well as the intiatization of the project.

Test Aya
