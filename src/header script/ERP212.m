%%%% script démarrage pre process copimod2411
restoredefaultpath;
clear all; 
% close all; 
clc; %First, clean the environment
addpath(genpath('/home/StageEEGpre/src'))

addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-fileIO-master'))
addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-icaTools-master'))
addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-preProcessing-master'))
addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-timeFrequencyAnalysis-master'))



addpath(genpath('/home/dependencies/eeglab_current/eeglab2021.1'))



copiemod2411