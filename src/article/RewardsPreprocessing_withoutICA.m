  % %% PREPROCESSING
 % %% Stage 1: Process data to determine noisy/faulty electrodes
 % %%  Step 1.1: Pre-ICA
 clear all;
 dirdata='data/Raw Data Part 1';
 cd(dirdata); %Find and change working folder to raw EEG data
 filenames = dir('*.vhdr');

 for participant = 1:500 %Cycle through participants

     %Get participant name information
     disp(['Participant: ', num2str(participant)]) %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
     participant_varname = ['RewardProcessing_S1Post_',participant_number{2}]; %Create new file name
     
     %Load Data
     EEG = []; %Clear past data
     [EEG] = doLoadBVData(filenames(participant).name  ); %Load raw EEG data
     
     %Make it a 32 channels cap - reduces any participants with a 64 channel system
     if EEG.nbchan > 31 %Determine whether current participant is a 64 channel setup
         [EEG] = doRemoveChannels(EEG,{'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'},EEG.chanlocs); %Removes electrodes that are not part of the 32 channel system
     end
     
     %Re-Reference
     load('ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
 %     chanlocsMaster([10,21]) = []; %Remove channels TP9 and TP10 as they will be the references
     [EEG] = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs); %Reference all channels to an averaged TP9/TP10 (mastoids)
     [EEG] = doRemoveChannels(EEG,{'TP9','TP10'},EEG.chanlocs); %Remove reference channels from the data
     [EEG] = doInterpolate(EEG,chanlocsMaster,'spherical'); %Interpolate the electrode used as reference during recording (AFz)

     %Filter
     [EEG] = doFilter(EEG,0.1,30,4,60,EEG.srate); %Filter data: Low cutoff 0.1, high cutoff 30, order 4, notch 60
     
%      %ICA
 %     [EEG] = doICA(EEG,1); %Run ICA for use of eye blink removal
    
     %Segment Data  
     [EEG] = doSegmentData(EEG,{'S110','S111'},[-500 1498]); %Segment Data (S110 = Loss, S111 = Win)
     
     %Baseline Correction
     [EEG] = doBaseline(EEG,[-200,0]); %Baseline correction in ms
    
     %Artifact Rejection
     [EEG] = doArtifactRejection(EEG,'Gradient',10); %Use a 10 uV/ms gradient criteria
     [EEG] = doArtifactRejection(EEG,'Difference',100); %Use a 100 uV max-min criteria

     %Extract Artifact Rejection Output
     AR_indx = []; trials_removed = []; %Clear past participant data
     AR_indx = EEG.artifactPresent; %Reassign artifact rejection output
     AR_indx(AR_indx > 1)=1; %Re-ID any indication of a rejected segment to be identified as the number 1
     trials_removed = sum(AR_indx')/size(AR_indx,2); %Determine the percentage of segments removed for each electrode
    
     %Save rejection information into a variable: electrodes with a trial rejection rate greater than 40% were tagged for removal
      p_chanreject{participant,1} = cellstr(participant_number{2}); %Insert participant number
      p_chanreject{participant,2} = cellstr(num2str(0.4)); %insert lowest level within which less than ten electrodes have been removed
      p_chanreject{participant,3} = cellstr(num2str(find(trials_removed>0.4))); %Determine the indices of electrodes to be removed      

     %Save Output
%      save(participant_varname,'EEG'); %Save the current output so that the lengthy ICA process can run without user intervention
 end
    %Save channels to reject information into a mat file
 save('Chans_rejected500.mat','p_chanreject');
 
 %% Stage 2: Process data for analysis
 clear all; close all; clc; %First, clean the environment
%  dirdata='data/Raw Data Part 1';
%  cd(dirdata); %Find and change working folder to raw EEG data
 filenames = dir('*.vhdr'); %Compile list of all data
load('Chans_rejected500.mat');

 %Load list of electrodes to remove
 for participant = 1:500 %Cycle through participants

     %Get participant name information
     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
     participant_varname = ['RewardProcessing_S2Post_',participant_number{2}]; %Create new file name

     %Load Data
     EEG = []; %Clear past data
    [EEG] = doLoadBVData(filenames(participant).name); %Load raw EEG data
     
     %Make it a 32 channels cap - reduces any participants with a 64 channel system
     if EEG.nbchan > 31 %Determine whether current participant is a 64 channel setup
         [EEG] = doRemoveChannels(EEG,{'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'},EEG.chanlocs); %Removes electrodes that are not part of the 32 channel system
     end
     
     %Re-Reference
     load('ChanlocsMaster.mat');
     [EEG] = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs); %Reference all channels to an averaged TP9/TP10 (mastoids)
     [EEG] = doRemoveChannels(EEG,{'TP9','TP10'},EEG.chanlocs); %Remove reference channels from the data
     [EEG] = doInterpolate(EEG,chanlocsMaster,'spherical'); %Interpolate the electrode used as reference during recording (AFz)

     
     %Load channel location file, please make sure the location of this file is in your path
 %    chanlocsMaster([10,21]) = []; %Remove channels TP9 and TP10 as they will be the references
    
    %  This manual removal has been removed from this code as well as in other software codes    
     %Note:Through visual inspection, some of the reference electrodes were deemed poor quality and were not used
%      if str2num(participant_number{2}) == 164 || str2num(participant_number{2}) == 255 || str2num(participant_number{2}) == 277 %Participants with one noisy mastoid electrode
%          [EEG] = doRereference(EEG,{'TP9'},{'ALL'},EEG.chanlocs); %Re-reference with only TP9
%      elseif str2num(participant_number{2}) == 110 %Participants with one noisy mastoid electrode
%          [EEG] = doRereference(EEG,{'TP10'},{'ALL'},EEG.chanlocs); %Re-reference with only TP10
%      else
%      [EEG] = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs); %Reference all channels to an averaged TP9/TP10 (mastoids)
%      end
        
     %Remove faulty electrodes
    p_chans = []; %Clear past participants electrode indices
    p_chans = strsplit(p_chanreject{participant,3}{1},' '); %Extract the indices of electrodes to remove
    %     save the number of channels removed/interpolated
    All_rejChan(participant)=length(p_chans);

    chans_to_remove = []; %Clear past participants electrode labels
    if ~isempty(p_chans{1}) %Determine whether electrodes need to be removed
        x = 1; %Begin index count
        for l = 1:size(p_chans,2) %Scroll through the electrodes
            if str2num(p_chans{1,l}) ~= 26 %Ensure that FCz is not removed
                chans_to_remove{1,x} = chanlocsMaster(str2num(p_chans{1,l})).labels; %Create list of electrode labels to remove
                x = x+1; %Increase index count
            end
        end
        [EEG] = doRemoveChannels(EEG,chans_to_remove,chanlocsMaster); %Remove electrodes
    else %If there is no electrodes to remove
        [EEG] = doRemoveChannels(EEG,{},chanlocsMaster); %Still run function, but do not remove any electrodes
    end
    
     
     %  This manual removal has been removed from this code as well as in other software codes    
     %Removed missed faulty electrodes on certain participants (determined on Step 1.2) - This was determined via visual inspection of the data after step 1.2
%      if str2num(participant_number{2})==77
%          [EEG] = doRemoveChannels(EEG,{'P8','CP6','AFz'},EEG.chanlocs);
%      elseif str2num(participant_number{2})==199
%          [EEG] = doRemoveChannels(EEG,{'FC1','O2'},EEG.chanlocs);
%      elseif str2num(participant_number{2})==486
%          [EEG] = doRemoveChannels(EEG,{'FC2'},EEG.chanlocs);
%      else
%          %Skip
%      end


     %Filter
     [EEG] = doFilter(EEG,0.1,30,4,60,EEG.srate); %Filter da ta: Low cutoff 0.1, high cutoff 30, order 4, notch 60
     
     %ICA
 %     [EEG] = doICA(EEG,1); %Run ICA for use of eye blink removal
     
     %Topograpic Interpolation
     load('ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
     [EEG] = doInterpolate(EEG,chanlocsMaster,'spherical'); %Interpolate electrodes which were previously removed

    %Determine markers of interest
     markers = {'S110','S111'}; %Loss, win
     
     %Segment Data
     [EEG] = doSegmentData(EEG,markers,[-500 1298]); %Segment Data (S110 = Loss, S111 = Win). The segment window of interest is -200 to 1000ms, and we here add 300 ms before and after this because time-frequency edge artifacts (this is different than the first pass because we were being more conservative then)
              
     %Baseline Correction
     [EEG] = doBaseline(EEG,[-200/1000,0]); %Baseline correction in ms
     
     %Artifact Rejection
     [EEG] = doArtifactRejection(EEG,'Gradient',10); %Use a 10 microvolt/ms gradient criteria
     [EEG] = doArtifactRejection(EEG,'Difference',100); %Use a 100 microvolt max-min criteria
     [EEG] = doRemoveEpochs(EEG,EEG.artifactPresent,0); %Remove segments that violated artifact rejection criteria
     
     %ERP
     try
         [EEG.ERP] =  doERP(EEG,markers,0); %Conduct ERP Analyses
         All_ERP(:,:,:,participant) = EEG.ERP.data; %Store all the ERP data into a single variable
         All_trials(1,participant) = EEG.ERP.epochCount(1); %Store the number of trials
         All_trials(2,participant) = EEG.ERP.epochCount(2); 
         All_trials(3,participant) = EEG.ERP.totalEpochs; 
     catch
         msgbox('No remained data for this participant after trial rejection');
         All_ERP(:,:,:,participant) = []; 
         All_trials(1,participant) = 0; 
         All_trials(2,participant) = 0; 
         All_trials(3,participant) = 0; 

     end
     %Save output
     save(participant_varname,'EEG'); %Save the current output so that the lengthy ICA process can run without user intervention
 end
 
 save('Ref_All_ERP', 'All_ERP'); %Save ERP Data
 save('All_trials', 'All_trials'); %Save ERP Data
 save('All_rejChan', 'All_rejChan'); %Save ERP Data

%  All_ERP=All_ERP(:,151:750,:,:);
%  % %% RewP_Waveforms
%  csvwrite('Ref_RewP_Waveforms.csv',[(-200:2:998)',nanmean(squeeze(All_ERP(26,:,1,:)),2),nanmean(squeeze(All_ERP(26,:,2,:)),2),nanmean(squeeze(All_ERP(26,:,1,:)),2)-nanmean(squeeze(All_ERP(26,:,2,:)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
%  % %% RewP_Waveforms_AllPs
%  tt1=squeeze(All_ERP(26,:,1,:));
%  tt2=squeeze(All_ERP(26,:,2,:));
% 
%  csvwrite('Ref_RewP_Waveforms_AllPs.csv',[tt1,tt2]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
%  % %% RewP_Latency
%  [~,peak_loc] = max(squeeze(All_ERP(26,226:276,1,:))-squeeze(All_ERP(26,226:276,2,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
%  peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
%  peak_loc(toberemoved)=[];
%  csvwrite('Ref_RewP_Latency.csv',peak_loc'); %Export data
