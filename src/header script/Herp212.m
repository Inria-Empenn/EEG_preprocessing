%%%% script démarrage pre process copimod2411

clear all; 
% close all; 
clc; %First, clean the environment
addpath('/home/StageEEGpre/')

folder = fileparts(which('/home/StageEEGpre'))
addpath(genpath(folder));
addpath('/home/StageEEGpre/src/eeglabcode/vdhrfiles/copiemod2411.m')

folder2 = fileparts(which('/home/dependencies/eeglab_current/')); 
addpath(genpath(folder2));

%addpath(genpath('/home/StageEEGpre'));
rmpath(genpath('/home/StageEEGpre/dependencies/eeglab_current/'));
rmpath('/home/StageEEGpre/dependencies/fieldtrip-lite-20211020');

copiemod2411