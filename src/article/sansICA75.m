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


% addpath('/home/StageEEGpre/dependencies/eeglab_current/eeglab2021.1')

addpath(genpath('/home/dependencies/eeglab_current/eeglab2021.1'))



%% EXTRACTION OF DATA %%
%% Aggregate data across participants                               
clear all; close all; clc; %First, clean the environment
cd('/home/StageEEGpre/data/Rawdata10'); %Find and change working folder to saved data from last for loop
filenames = dir('RewardProcessing_S2Final*'); %Compile list of all data

for participant = 1:length(filenames) %Cycle through participants
    disp(['Participant: ', num2str(participant)]); %Display current participant being processed

    %Load Data
    EEG = []; %Clear past data
    load(filenames(participant).name); %Load participant output
    
    All_ERP(:,:,:,participant) = EEG.ERP.data; %Store all the ERP data into a single variable
    
    %FFT frequency resolution is 0.67, so must extract proper frequencies
    All_FFT(:,1,:,participant) = mean(EEG.FFT.data(:,1:2,:),2); %Store all the FFT data into a single variable (1 Hz)
    All_FFT(:,2,:,participant) = EEG.FFT.data(:,3,:); %Store all the FFT data into a single variable (2 Hz)
    All_FFT(:,3,:,participant) = mean(EEG.FFT.data(:,4:5,:),2); %Store all the FFT data into a single variable (3 Hz)
    All_FFT(:,4,:,participant) = EEG.FFT.data(:,6,:); %Store all the FFT data into a single variable (4 Hz)
    All_FFT(:,5,:,participant) = mean(EEG.FFT.data(:,7:8,:),2); %Store all the FFT data into a single variable (5 Hz)
    All_FFT(:,6,:,participant) = EEG.FFT.data(:,9,:); %Store all the FFT data into a single variable (6 Hz)
    All_FFT(:,7,:,participant) = mean(EEG.FFT.data(:,10:11,:),2); %Store all the FFT data into a single variable (7 Hz)
    All_FFT(:,8,:,participant) = EEG.FFT.data(:,12,:); %Store all the FFT data into a single variable (8 Hz)
    All_FFT(:,9,:,participant) = mean(EEG.FFT.data(:,13:14,:),2); %Store all the FFT data into a single variable (9 Hz)
    All_FFT(:,10,:,participant) = EEG.FFT.data(:,15,:); %Store all the FFT data into a single variable (10 Hz)
    
    All_WAV(:,:,:,:,participant) = EEG.WAV.data; %%Store all the WAV data into a single variable
end

save('All_ERP', 'All_ERP'); %Save ERP Data
save('All_FFT', 'All_FFT'); %Save FFT Data
%Unfortunately, the WAV file is unable to save as it is too large, thus when using the All_WAV variable, this section must be run first
%% Load Data
load('All_ERP.mat'); %Load saved ERP data
load('All_FFT.mat'); %Load saved FFT data
%% RewP_Waveforms                                                   
csvwrite('RewP_Waveforms.csv',[(-200:2:998)',mean(squeeze(All_ERP(26,:,1,:)),2),mean(squeeze(All_ERP(26,:,2,:)),2),mean(squeeze(All_ERP(26,:,1,:)),2)-mean(squeeze(All_ERP(26,:,2,:)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
%% RewP_Waveforms_AllPs                                             
csvwrite('RewP_Waveforms_AllPs.csv',[squeeze(All_ERP(26,:,1,:)),squeeze(All_ERP(26,:,2,:))]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
%% RewP_Latency                                                     
[~,peak_loc] = max(squeeze(All_ERP(26,226:276,1,:))-squeeze(All_ERP(26,226:276,2,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
csvwrite('RewP_Latency.csv',peak_loc'); %Export data
%% RewP_FFT                                                         
csvwrite('RewP_FFT.csv',[(1:1:10)',squeeze(mean(All_FFT(26,:,1,:),4))',squeeze(mean(All_FFT(26,:,2,:),4))',(squeeze(mean(All_FFT(26,:,1,:),4))-squeeze(mean(All_FFT(26,:,2,:),4)))']); %Export data. Conditions: Frequency, Loss, Win, Difference. Electrode 26 is FCz.
%% RewP_FFT_AllPs                                                   
csvwrite('RewP_FFT_AllPs.csv',[squeeze(All_FFT(26,:,1,:)),squeeze(All_FFT(26,:,2,:))]'); %Export data. Conditions: Loss, Win.
%% RewP_WAV_Stats                                                   
delta_extract=zeros(30,600); %Create empty matrix for delta extraction
delta_extract(1:2,:)=(squeeze(mean(All_WAV(26,1:2,151:750,:,:),[4,5])))>5.5; %Determine delta effect via the collapsed localizer method with a power threshhold of 5.5
theta_extract=zeros(30,600); %Create empty matrix for theta extraction
theta_extract(3:7,:)=(squeeze(mean(All_WAV(26,3:7,151:750,:,:),[4,5])))>5.5; %Determine theta effect via the collapsed localizer method with a power threshhold of 5.5
both_extract = (delta_extract+theta_extract>0); %Determine all effects via the collapsed localizer method 

WAV_data1 = permute(squeeze(All_WAV(26,:,151:750,1,:)),[3,1,2]); %Extract participants time-frequency condition 1
WAV_data2 = permute(squeeze(All_WAV(26,:,151:750,2,:)),[3,1,2]); %Extract participants time-frequency condition 2
WAV_diff = WAV_data1-WAV_data2; %Create difference wave
nb=75;
for participant = 1:nb %Cycle through participants
    WAV_Delta(participant,:,:) = squeeze(WAV_diff(participant,:,:)).*delta_extract; %Confine data to significant delta activity for difference WAV
    WAV_Theta(participant,:,:) = squeeze(WAV_diff(participant,:,:)).*theta_extract; %Confine data to significant theta activity for difference WAV
    gain_WAV_Delta(participant,:,:) = squeeze(WAV_data1(participant,:,:)).*delta_extract; %Confine data to significant delta activity for condition 1
    loss_WAV_Theta(participant,:,:) = squeeze(WAV_data2(participant,:,:)).*theta_extract; %Confine data to significant theta activity for condition 2
    WAV_Both(participant,:,:) = squeeze(WAV_diff(participant,:,:)).*both_extract; %Determine all frequencies
end
 
WAV_Delta(WAV_Delta==0) = nan; %Remove non-significant data
WAV_Theta(WAV_Theta==0) = nan; %Remove non-significant data
gain_WAV_Delta(WAV_Delta==0) = nan; %Remove non-significant data
loss_WAV_Theta(WAV_Theta==0) = nan; %Remove non-significant data
WAV_Both(WAV_Both==0) = nan; %Remove non-significant data

WAV_Extract(:,1) = nanmean(WAV_Theta,[2,3]); %Average data across resulting time and frequencies for theta of difference WAV
WAV_Extract(:,2) = nanmean(WAV_Delta,[2,3]); %Average data across resulting time and frequencies for delta of difference WAV
WAV_Extract(:,3) = nanmean(loss_WAV_Theta,[2,3]); %Average data across resulting time and frequencies for theta of condition 2
WAV_Extract(:,4) = nanmean(gain_WAV_Delta,[2,3]); %Average data across resulting time and frequencies for delta of condition 1
csvwrite('RewP_WAV_Stats.csv',WAV_Extract); %Export data
%% RewP_WAV_Freqs                                                   
[~,WAV_Extract_freq_time] = max(WAV_diff(:,1:2,:),[],3); %Determine max peak times for delta activity
[~,WAV_Extract_freq_time(:,3:7)] = min(WAV_diff(:,3:7,:),[],3); %Determine min peak times for theta activity
WAV_Time = -200:2:998; %Create a variable of time in milliseconds
csvwrite('RewP_WAV_Freqs.csv',[nanmean(WAV_Both(:,1:7,:),3),WAV_Time(WAV_Extract_freq_time)]); %Export data
