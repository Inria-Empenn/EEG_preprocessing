# Successful reproduction of a large EEG study across software packages

by
Aya Kabbara
Nina Forde
Camille Maumet
Mahmoud Hassan

> This is a guide for researchers to reproduce the results and figures published in the paper "Successful reproduction of a large EEG study across software packages".
>This paper has been submitted for publication in NeuroImage Reports.

This study sheds light on how the software tool used to preprocess EEG signals impacts the analysis results and conclusions. EEGLAB, Brainstorm and FieldTrip were used to reproduce the same preprocessing pipeline of a published EEG study performed on 500 participants.

![](figures/figure1_preprocess.001.jpeg)

*The full pipeline of the study. (a) EEGs were acquired from 500 participants performing a simple gambling task of six blocks composed of 20 trials. (b) The same dataset was then preprocessed using the different software tools: Reference (using the code published by the original paper (Williams et al. 2021)), EEGLAB, Brainstorm and FieldTrip. The preprocessing steps to be performed in each tool includes: the reduction to 32 electrodes, the re-referencing, the automatic detection of bad electrodes, the band-pass filtering, the interpolation of bad channels, the segmentation into time-locked epochs and the removal of artifactual trials. (c) The preprocessed signals derived from the four preprocessing codes are used to validate and reproduce the reference statistics and hypotheses. A quantitative comparison between the resulting signals is also conducted in terms of signal features*


## Abstract

As an active field of research, Electroencephalography (EEG) analysis workflow has increasing flexibility and complexity, with a great variety of methodological options and tools to be selected at each step. This high analytical flexibility can be problematic as it can yield variability in research outcomes. Therefore, growing attention has been recently paid to understand the potential of different methodological decisions to influence the reproducibility of results. In this paper, we aim to examine how sensitive the results of EEG analyses are to variations in software tools. We reanalyzed shared EEG data (N=500) previously used in a published task EEG study using three of the most commonly used software tools: EEGLAB, Brainstorm and FieldTrip. After reproducing the same original preprocessing workflow in each software, the resultant evoked-related potentials (ERPs) were qualitatively and quantitatively compared in order to examine the degree of consistency/discrepancy between softwares. Our findings show a good degree of convergence in terms of the general profile of ERP waveforms, peak latencies and effect size estimates related to specific signal features. However, considerable variability was also observed between software packages as reflected by the similarity values and observed statistical differences at particular channels and time instants. In conclusion, we believe that this study provides valuable clues to better understand the impact of the software tool on analysis results of EEG.



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
