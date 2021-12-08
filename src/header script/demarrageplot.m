restoredefaultpath;
clear all; 
% close all; 
clc; %First, clean the environment
% addpath(genpath('/home/StageEEGpre/src'))
% 
% addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-fileIO-master'))
% addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-icaTools-master'))
% addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-preProcessing-master'))
% addpath(genpath('/home/StageEEGpre/dependencies/article/MATLAB-EEG-timeFrequencyAnalysis-master'))


addpath(genpath('/home/StageEEGpre/dependencies/article/croco_tools-master-Visualization_tools/'))

addpath(genpath('/home/StageEEGpre/src/graphiques'))

% addpath('/home/StageEEGpre/dependencies/eeglab_current/eeglab2021.1')

addpath(genpath('/home/dependencies/eeglab_current/eeglab2021.1'))


% folder = fileparts(which('/home/StageEEGpre'))
% addpath(genpath(folder));
% folder2 = fileparts(which('/home/dependencies/eeglab_current/')); 
% addpath(genpath(folder2));
% 
% addpath('/home/StageEEGpre/src/eeglabcode/vdhrfiles/')
% 
% 
% 
% %addpath(genpath('/home/StageEEGpre'));
% rmpath(genpath('/home/StageEEGpre/dependencies/eeglab_current/'));
% rmpath('/home/StageEEGpre/dependencies/fieldtrip-lite-20211020');

RewardProcessing_Plots
