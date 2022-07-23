% %  --- This is the preprocessing workflow reproduced by FieldTrip functions---
% % For contact: aya.kabbara7@gmail.com

%% === Regulate some parameters that will be used in interpolation ====

load('src/channelsTokeep.mat');

% prepare neighborhood template for bad channels interpolation
reduced_subjects=ss;
cfg = [];
cfg.dataset = '/Raw Data Part 1/set/Subject001/set_001.set';
cfg.continuous  = 'yes';              % force it to be continuous
cfg.channel     = ChannelsTokeep;
data_prepare  = ft_preprocessing(cfg);
cfg=[];
cfg.method ='distance';
cfg.neighbourdist=0.7;
[neighbours, cfg] = ft_prepare_neighbours(cfg, data_prepare)

% % go to data folder
cd('/Raw Data Part 1'); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr')
nb=500;
trials_loss=[];
trials_win=[];

%% === Start ====

for participant =1:500 %Cycle through participants
    
%     Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components

    RawFile = ['/Raw Data Part 1/set/Subject' participant_number{2} '/set_' participant_number{2} '.set'];
    SubjectName = ['participant_' participant_number{2}];

%     % Check if the folder contains the required files
%     if ~file_exist(RawFile)
%         error(['The folder does not contain the folder from the file sample.']);
%     end
    %% === Read data ====
    cfg = [];
    cfg.dataset = RawFile;
    cfg.continuous  = 'yes';
    
    % force it to be continuous
    if(length(find(reduced_subjects==participant))==0)
        cfg.channel     = ChannelsTokeep;
    end
    %% === Re-referencing ====
    cfg.reref       = 'yes';
    cfg.refchannel  = {'TP9', 'TP10'};
    data_eeg    = ft_preprocessing(cfg);

    %% === Remove the reference channels ====
    cfg=[];
  if(length(find(reduced_subjects==participant))==0)
    cfg.channel     = [1:29];
    else
    cfg.channel     = [1:9 11:20 22:31];
    end
    
    data_eeg    = ft_preprocessing(cfg,data_eeg);

    %% === Filtering ====
    cfg=[];
    cfg.bpfilter='yes';
    cfg.bpfreq=[0.1 30];
    cfg.bpfiltord=4;
    cfg.bpfilttype='but';
    data_eeg_filtered=ft_preprocessing(cfg,data_eeg);

    %% === Detect bad channels ====
    cfg=[];
    bad_detected={};
    index_bad_detected=[];

    cfg.artfctdef.clip.timethreshold = 5;
    cfg.artfctdef.clip.amplthreshold = 1;
    cfg.continuous                   = 'yes' ;
    for ch=1:length(data_eeg_filtered.label)
        cfg.artfctdef.clip.channel = data_eeg_filtered.label{ch};
        [cfg, artifact] = ft_artifact_clip(cfg, data_eeg_filtered);
        if(length(artifact)>1)
            bad_detected{end+1}= data_eeg_filtered.label{ch};
            index_bad_detected(end+1)=ch;
        end
    end


    %% === Interpolate bad channels ====
    cfg=[];
    cfg.badchannel     = bad_detected;
    cfg.neighbours     = neighbours(index_bad_detected);
    try
    [data_interp] = ft_channelrepair(cfg, data_eeg_filtered)

    %% === Segmentation into time-locked epochs ====
    cfg = [];
    cfg.dataset= RawFile;
    cfg.trialdef.eventtype = 'Stimulus';
    cfg.trialdef.prestim    = 0.5;
    cfg.trialdef.poststim   = 1.3;

    % loss
    cfg.trialdef.eventvalue = {'S110'};
    cfg_loss = ft_definetrial(cfg);
    % win
    cfg.trialdef.eventvalue = {'S111'};
    cfg_win= ft_definetrial(cfg);

    data_loss = ft_redefinetrial(cfg_loss, data_interp);
    data_win  = ft_redefinetrial(cfg_win, data_interp);

    %% === Baseline correction ====
    cfg=[];
    cfg.demean        = 'yes';
    cfg.baselinewindow = [-0.2 0];
    data_loss_corrected= ft_preprocessing(cfg,data_loss);
    data_win_corrected= ft_preprocessing(cfg,data_win);

    %% === Bad trials identification and removal ====

    %  artifact detection for loss condition
    cfg=[];
    cfg.trl=cfg_loss.trl;
    cfg.continuous = 'no';
    cfg.artfctdef.threshold.range=200;
%     cfg.artfctdef.threshold.min       = -50;
%     cfg.artfctdef.threshold.max       = 50;
    cfg.artfctdef.threshold.bpfilter  = 'yes';
    cfg.artfctdef.threshold.bpfreq    = [0.1 30];
    [cfg, artifact] = ft_artifact_threshold(cfg, data_loss_corrected)

    % % artifact rejection for loss condition
    try
    data_loss_final = ft_rejectartifact(cfg, data_loss_corrected)
    catch
    end
    % % win condition
    cfg=[];
    cfg.trl=cfg_win.trl;
    cfg.continuous = 'no';
    cfg.artfctdef.threshold.range=100;
%     cfg.artfctdef.threshold.min       = -50;
%     cfg.artfctdef.threshold.max       = 50;
    cfg.artfctdef.threshold.bpfilter  = 'yes';
    cfg.artfctdef.threshold.bpfreq    = [0.1 30];
    [cfg, artifact] = ft_artifact_threshold(cfg, data_win_corrected)
    % % artifact rejection for win condition
  try
    data_win_final = ft_rejectartifact(cfg, data_win_corrected)
  catch
  end
    %% === ERP calculation ====
    cfg=[];
    try
    [timelock] = ft_timelockanalysis(cfg, data_loss_final);
    trials_loss(participant)=length(data_loss_final.trial);
    All_ERP_ft(1,:,:,participant) = timelock.avg;
    catch
    end
    

    try
    [timelock] = ft_timelockanalysis(cfg, data_win_final);
    trials_win(participant)=length(data_win_final.trial);
    All_ERP_ft(2,:,:,participant) = timelock.avg;
    catch
    end
    catch
    end
end

%% === Save variables and csv files ====

 save('All_ERP_ft.mat','All_ERP_ft');
channelOfInterest=26;

All_ERP_ft=All_ERP_ft(:,:,151:750,:);
% %% RewP_Waveforms_AllPs
tt1=squeeze(All_ERP_ft(1,26,:,:));
tt2=squeeze(All_ERP_ft(2,26,:,:));

csvwrite('ft_RewP_Waveforms_final22.csv',[(-200:2:998)',nanmean(squeeze(All_ERP_ft(1,26,:,:)),2),nanmean(squeeze(All_ERP_ft(2,26,:,:)),2),nanmean(squeeze(All_ERP_ft(1,26,:,:)),2)-nanmean(squeeze(All_ERP_ft(2,26,:,:)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.

csvwrite('ft_RewP_Waveforms_AllPs_final22.csv',[tt1,tt2]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
% % %% RewP_Latency
%
[~,peak_loc] = max(squeeze(All_ERP_ft(1,26,226:276,:))-squeeze(All_ERP_ft(2,26,226:276,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
csvwrite('ft_RewP_Latency.csv',peak_loc'); %Export data

