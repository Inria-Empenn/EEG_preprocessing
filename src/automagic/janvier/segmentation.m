%dd
restoredefaultpath;
clear all; 
clc; 

addpath(genpath('/home/nforde/Documents/StageEEGpre/dependencies/article/MATLAB-EEG-preProcessing-master'))% pour doSegment
addpath(genpath('/home/nforde/Documents/StageEEGpre/dependencies/eeglab_current/eeglab2021.1'))% pour pop rmbase


dataFolder = '/home/nforde/Documents/StageEEGpre/data/formatBIDS_24janv_results2/sujets2';
cd(dataFolder)
filenames = dir('allSteps_RewardProcessing*') %Compile list of all data


for participant = 1:2%Cycle through participants
    
    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-4),'_') %Split filename into components
    participant_varname = ['segmented',participant_number{3}] %Create new file name
    EEG = []; %Clear past data
    file=load(filenames(participant).name); %Load participant output
    EEG=file.EEGFinal
    
    
    
    
     %Determine markers of interest for WAV later
    markers = {'S110','S111'}; %Loss, win

    
    [EEG] = doSegmentData(EEG,markers,[-500 1498]); %Segment Data (S110 = Loss, S111 = Win). The segment window of interest is -200 to 1000ms, and we here add 300 ms before and after this because time-frequency edge artifacts (this is different than the first pass because we were being more conservative then)
    %baseline correction
    EEG = pop_rmbase( EEG, [-200/1000,0]);
    save(participant_varname,'EEG') %Save the current output

end 
