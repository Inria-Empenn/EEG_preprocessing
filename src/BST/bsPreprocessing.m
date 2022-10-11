% %  --- This is the preprocessing workflow reproduced by Brainstorm functions---
% % For contact: aya.kabbara7@gmail.com

cd('../../tools/brainstorm');
% ======= CREATE PROTOCOL =======
% The protocol name has to be a valid folder name (no spaces, no weird characters...)
ProtocolName = 'Protocol_PreProc';
% Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end
% Delete existing protocol
gui_brainstorm('DeleteProtocol', ProtocolName);
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);

% cd('data/Raw Data Part 1'); %Find and change working folder to raw EEG data
filenames = dir('../../data/*.dat')
nb=500;
trials_1=0;
trials_2=0;
load('channelsTokeep.mat');
BS_db='/Users/ayakabbara/Documents/brainstorm_db/';  %Changed this to the brainstorm_db directory

for participant =1:nb %Cycle through participants
    
    trials_1=0;
    trials_2=0;
%     Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components

    RawFile = ['/Users/ayakabbara/StageEEGpre/data/Raw Data Part 1/' filenames(participant).name];
    SubjectName = ['participant_' participant_number{2}];

    % Check if the folder contains the required files
    if ~file_exist(RawFile)
        error(['The folder does not contain the folder from the file sample.']);
    end
    % ===== ACCESS RECORDINGS =====

    % Process: Create link to raw file
    sFiles = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
        'subjectname',    SubjectName, ...
        'datafile',       {RawFile,'EEG-BRAINAMP'} , ...
        'channelreplace', 0, ...
        'channelalign',   0)

    % % Start a new report
    bst_report('Start', sFiles);

    %% ===== EEG REFERENCE =====
    sFiles=bst_process('CallProcess', 'process_eegref', sFiles, [], ...
                  'eegref',      'TP9, TP10', ...
                  'sensortypes', 'EEG');

    %%  ==== Bad channels identification ====
    p_chans = []; %Clear past participants electrode indices
    p_chans = strsplit(p_chanreject{participant,3}{1},' '); %Extract the indices of electrodes to remove
    All_rejChan(participant)=length(p_chans);
    try
        chans_to_remove = cellfun(@str2num,p_chans); %Clear past participants electrode labels
        a_t=load([BS_db ProtocolName '/data/' sFiles.ChannelFile])
        for ch=1:length(p_chans)
             chans_labels{ch}=a_t.Channel(chans_to_remove(ch)).Name;
        end
        sFiles=bst_process('CallProcess', 'process_channel_setbad', sFiles, [], ...
            'subjectname', SubjectName, ...
            'sensortypes',  chans_labels);
        %% ==== Bad channel interpolation ====
        sFiles=bst_process('CallProcess', 'process_eeg_interpbad', [sFiles], []);
    catch
    end
    %% ==== Filtering ====
    % Process: Notch filter: 50Hz 100Hz 150Hz
    sFiles = bst_process('CallProcess', 'process_notch', sFiles, [], ...
        'sensortypes', 'EEG', ...
        'freqlist',    [50, 100, 150], ...
        'cutoffW',     2, ...
        'useold',      0, ...
        'read_all',    0);

    % Process: Band-pass:0.1Hz-30Hz
    sFiles = bst_process('CallProcess', 'process_bandpass', sFiles, [], ...
        'sensortypes', 'EEG', ...
        'highpass',    0.1, ...
        'lowpass',     30, ...
        'tranband',    0, ...
        'attenuation', 'strict', ...  % 60dB
        'ver',         '2019', ...  % 2019
        'mirror',      0, ...
        'read_all',    0);

    %% ===== Epoching =====

    markers = {'S110','S111'}; %Loss, win

    sFilesEpochs1 = bst_process('CallProcess', 'process_import_data_event', sFiles, [], ...
       'subjectname', SubjectName, ...
       'eventname',   'S110', ...
        'timewindow',  [], ...
          'epochtime',   [-0.5, 1.3], ...
         'baseline',    [-0.2, 0]);

    sFilesEpochs2 = bst_process('CallProcess', 'process_import_data_event', sFiles, [], ...
           'subjectname', SubjectName, ...
        'eventname',   'S111', ...
        'timewindow',  [], ...
          'epochtime',   [-0.5, 1.3], ...
         'baseline',    [-0.2, 0]);

     sFilesEpochs1 = bst_process('CallProcess', 'process_baseline', sFilesEpochs1, [],'baseline',    [-0.2, 0])
     sFilesEpochs2 = bst_process('CallProcess', 'process_baseline', sFilesEpochs2, [],'baseline',    [-0.2, 0])

    %%  ===== Bad Trials detection =====
     sFilesEpochs3=bst_process('CallProcess', 'process_detectbad', [sFilesEpochs1], [], ...
        'timewindow',  [], ...
     'eeg', [0,100],'rejectmode',2);
 
     sFilesEpochs4=bst_process('CallProcess', 'process_detectbad', [sFilesEpochs2], [], ...
            'timewindow',  [], ...
         'eeg', [0,100],'rejectmode',2);
 
    %%  ===== ERP computation =====
    
     sFilesAvg = bst_process('CallProcess', 'process_average', [sFilesEpochs3, sFilesEpochs4], [], ...
       'avgtype',    5, ...  % By trial groups (folder average)
       'avg_func',   1, ...  % Arithmetic average: mean(x)
       'weighted',   0, ...
       'keepevents', 1);
     
    try
        dirr=[BS_db ProtocolName '/data/' sFilesAvg(1).FileName];

        FF=load(dirr);
        if(size(FF,1)>32)
                All_ERP_BS(1,:,:,participant) = FF.F(ChannelsTokeep(1:29),151:750); %Store all the ERP data into a single variable
        else
                All_ERP_BS(1,:,:,participant) = FF.F([1:9 11:20 22:31],151:750); %Store all the ERP data into a single variable

        end
        trials_1=trials_1+sFilesAvg(1).iStudy;
    catch
    end
        
    try
        dirr=[BS_db ProtocolName '/data/' sFilesAvg(2).FileName];
        FF=load(dirr);
           if(size(FF,1)>32)
             All_ERP_BS(2,:,:,participant) = FF.F(ChannelsTokeep(1:29),151:750); %Store all the ERP data into a single variable
           else
             All_ERP_BS(2,:,:,participant) = FF.F([1:9 11:20 22:31],151:750); %Store all the ERP data into a single variable
            end
        trials_2=trials_2+sFilesAvg(2).iStudy;

    catch
    %         rem_part(end+1)=participant;
    end
    All_trials(1,participant) = trials_1; %Store the number of trials
    All_trials(2,participant) = trials_2; %Store the number of trials
    All_trials(3,participant) = trials_1+trials_2; %Store the number of trials
    % delete  subject for space issues
    % bst_process('CallProcess', 'process_delete','subjectname',    SubjectName)
end

%% === Save variables and csv files ====
save('../../results/bs_All_ERP', 'All_ERP_BS'); %Save ERP Data
save('../../results/bs_All_trials', 'All_trials'); %Save ERP Data
save('../../results/bs_All_rejChan', 'All_rejChan'); %Save ERP Data

All_ERP=All_ERP(:,:,151:750,:).*1000000; % the unit in BS is in microVolts so it should be transfomed
channelOfInterest=26;
gain_erp=squeeze(All_ERP(1,channelOfInterest,:,:));
loss_erp=squeeze(All_ERP(2,channelOfInterest,:,:));
csvwrite('../../results/bs_RewP_Waveforms.csv',[(-200:2:998)',nanmean(squeeze(All_ERP(1,26,:,:)),2),nanmean(squeeze(All_ERP(2,26,:,:)),2),nanmean(squeeze(All_ERP(1,26,:,:)),2)-nanmean(squeeze(All_ERP(2,26,:,:)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
%% RewP_Waveforms_AllPs
csvwrite('../../results/bs_RewP_Waveforms_AllPs.csv',[gain_erp,loss_erp]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
%% RewP_Latency
[~,peak_loc] = max(squeeze(All_ERP(1,26,226:276,:))-squeeze(All_ERP(2,26,226:276,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
peak_loc(toberemoved)=[];
csvwrite('../../results/bs_RewP_Latency.csv',peak_loc'); %Export data
