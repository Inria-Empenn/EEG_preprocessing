% %  load channel list
load('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/set/Subject001/channelsTokeep.mat');
% % prepare neighborhood template for bad channels interpolation
reduced_subjects=ss;
cfg = [];
cfg.dataset = '/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/set/Subject001/set_001.set';
cfg.continuous  = 'yes';              % force it to be continuous
cfg.channel     = ChannelsTokeep;                     
data_prepare  = ft_preprocessing(cfg);
cfg=[];
cfg.method ='distance';
cfg.neighbourdist=0.7;
[neighbours, cfg] = ft_prepare_neighbours(cfg, data_prepare)

% % go to folder
cd('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1'); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr')
nb=500;
trials_loss=[];
trials_win=[];

for participant =1:500 %Cycle through participants
    
%     Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components

    RawFile = ['/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/set/Subject' participant_number{2} '/set_' participant_number{2} '.set'];
    SubjectName = ['participant_' participant_number{2}];

%     % Check if the folder contains the required files
%     if ~file_exist(RawFile)
%         error(['The folder does not contain the folder from the file sample.']);
%     end
    % % read data
    cfg = [];
    cfg.dataset = RawFile;
    cfg.continuous  = 'yes';  
    
    % force it to be continuous
    if(length(find(reduced_subjects==participant))==0)
        cfg.channel     = ChannelsTokeep;  
    end
    % % re-referencing
    cfg.reref       = 'yes';
    cfg.refchannel  = {'TP9', 'TP10'}; 
    
    data_eeg    = ft_preprocessing(cfg);

    % % REMOVE THE REF CHANNELS
    cfg=[];
    
    if(length(find(reduced_subjects==participant))==0)
    cfg.channel     = [1:29];
    else
    cfg.channel     = [1:9 11:20 22:31];
    end
    
    data_eeg    = ft_preprocessing(cfg,data_eeg);

    % % filtering
    cfg=[];
    cfg.bpfilter='yes';
    cfg.bpfreq=[0.1 30];
    cfg.bpfiltord=4;
    cfg.bpfilttype='but';
    data_eeg_filtered= ft_preprocessing(cfg,data_eeg);

    % % detect channels
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


    % % repair bad channels
    cfg=[];
    cfg.badchannel     = bad_detected;
    cfg.neighbours     = neighbours(index_bad_detected);
    try
    [data_interp] = ft_channelrepair(cfg, data_eeg_filtered)

    % % define trials, segment 
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

    % % baseline correction
    cfg=[];
    cfg.demean        = 'yes';
    cfg.baselinewindow = [-0.2 0];
    data_loss_corrected= ft_preprocessing(cfg,data_loss);
    data_win_corrected= ft_preprocessing(cfg,data_win);

    % % artifact detection for loss condition
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
    % % calculate erp
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

 save('All_ERP_ft_final.mat','All_ERP_ft');