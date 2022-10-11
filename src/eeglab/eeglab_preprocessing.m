
% %  --- This is the preprocessing workflow reproduced by EEGLAB functions---
% % For contact: aya.kabbara7@gmail.com

cd('../../tools/eeglab2022.1');
%% === 1st pass: Detect bad channels ====

filenames = dir('../../data/*.vhdr')
nb=500;
for participant = 1:nb %Cycle through participants
   
    % Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    % Load EEG data
    EEG = pop_loadbv('../../data/', filenames(participant).name);
   
    % Add the channel location file
    EEG=pop_chanedit(EEG, 'lookup','functions/supportfiles/Standard-10-20-Cap81.ced');

    % Reduce into 32 channels
    try
        if(EEG.nbchan > 32)
            EEG = pop_select(EEG, 'channel',{'Fp1'
            'Fz'
            'F3'
            'F7'
            'FC5'
            'FC1'
            'Cz'
            'C3'
            'T7'
            'CP5'
            'CP1'
            'Pz'
            'P3'
            'P7'
            'O1'
            'POz'
            'O2'
            'P4'
            'P8'
            'CP6'
            'CP2'
            'C4'
            'T8'
            'FC6'
            'FC2'
            'FCz'
            'F4'
            'F8'
            'Fp2'
            'TP10'
            'TP9'});
        end
    catch
        disp('Problem');
        rm_channels{participant}='';
    end
    
    %Filter data
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',30);
    
    %% === Segmentation ====
    markers = {'S110','S111'}; %Loss, win
    [EEG] = doSegmentData(EEG,markers,[-500 1298]); %Segment Data (S110 = Loss, S111 = Win). The segment window of interest is -200 to 1000ms, and we here add 300 ms before and after this because time-frequency edge artifacts (this is different than the first pass because we were being more conservative then)

    %% === Baseline adjustment ====
    EEG = pop_rmbase( EEG, [-200/1000,0]);
    
    %% === Bad trial identification and removal ====
    for chan=1:29
         [EEG1 Indexes] = pop_eegthresh(EEG,1,chan,-150,150,0,1.2,0,0);
         trials_removed(chan)=length(Indexes)/size(EEG.data,3);
    end   
     %Save rejection information into a variable: electrodes with a trial rejection rate greater than 40% were tagged for removal
      p_chanreject{participant,1} = cellstr(participant_number{2}); %Insert participant number
      p_chanreject{participant,2} = cellstr(num2str(0.4)); %insert lowest level within which less than ten electrodes have been removed
      p_chanreject{participant,3} = cellstr(num2str(find(trials_removed>0.4))); %Determine the indices of electrodes to be removed      

end
%% === Save the detected bad channels ====
save('chans_eeglab','p_chanreject');

%% === 2nd pass: process data ====
clear all;
clc;
load('chans_eeglab');
filenames = dir('*.vhdr')
nb=500;
for participant = 1:nb %Cycle through participants
    
    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components

    %% === Read data ====
    EEG = pop_loadbv('../../data/', filenames(participant).name);
    
    %% === Add the channel location file ====
    EEG=pop_chanedit(EEG, 'lookup','eeglab2022.1/functions/supportfiles/Standard-10-20-Cap81.ced');
    %% === reduce into 32 channels ====

    try
      if(EEG.nbchan > 32)
        EEG = pop_select(EEG, 'channel',{'Fp1'
        'Fz'
        'F3'
        'F7'
        'FC5'
        'FC1'
        'Cz'
        'C3'
        'T7'
        'CP5'
        'CP1'
        'Pz'
        'P3'
        'P7'
        'O1'
        'POz'
        'O2'
        'P4'
        'P8'
        'CP6'
        'CP2'
        'C4'
        'T8'
        'FC6'
        'FC2'
        'FCz'
        'F4'
        'F8'
        'Fp2'
        'TP10'
        'TP9'});
      end
      
   %% === Interpolate bad channels ====

    p_chans = []; %Clear past participants electrode indices
    p_chans = strsplit(p_chanreject{participant,3}{1},' '); %Extract the indices of electrodes to remove
    %     save the number of channels removed/interpolated
    All_rejChan(participant)=length(p_chans);
    chans_to_remove = cellfun(@str2num,p_chans); %Clear past participants electrode labels
    EEG = pop_interp(EEG, chans_to_remove, 'spherical');
    
    %% === Re-referencing ====
    EEG = pop_chanedit(EEG, 'seteeglab',{'1:31','TP10 TP9'});
    EEG = pop_reref( EEG ,{'TP9','TP10'});

    %% === Filtering ====
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',30);

    %% === Segmentation ====
    markers = {'S110','S111'}; %Loss, win
    [EEG] = doSegmentData(EEG,markers,[-500 1298]); %Segment Data (S110 = Loss, S111 = Win). The segment window of interest is -200 to 1000ms, and we here add 300 ms before and after this because time-frequency edge artifacts (this is different than the first pass because we were being more conservative then)

    %% === Baseline adjustment ====
    EEG = pop_rmbase( EEG, [-200/1000,0]);
    
    %% === Bad trial identification and removal ====
    EEG = pop_eegthresh(EEG,1,[1:29] ,-100,100,0,1.2,0,1);

    %% === ERP ====
    try
        [EEG.ERP] = doERP(EEG,markers,0);
        All_ERP(:,:,:,participant) = EEG.ERP.data; %Store all the ERP data into a single variable  
        All_trials(1,participant) = EEG.ERP.epochCount(1); %Store the number of trials
        All_trials(2,participant) = EEG.ERP.epochCount(2); 
        All_trials(3,participant) = EEG.ERP.totalEpochs; 

    catch  
        All_trials(1,participant) = 0; %Store the number of trials
        All_trials(2,participant) = 0; 
        All_trials(3,participant) = 0; 
    end
      
    catch
        continue  
    end
end

%% === Save variables and csv files ====

save('../../results/EEGLAB_All_ERP_samePipe', 'All_ERP'); %Save ERP Data
save('../../results/EEGLAB_All_trials_samePipe', 'All_trials'); %Save ERP Data
save('../../results/EEGLAB_All_rejChan_samePipe', 'All_rejChan'); %Save ERP Data

All_ERP=All_ERP_eeglab(:,151:750,:,:);
chanOfInterest=17;
% channel of interest 17 is FCz
%% RewP_Waveforms_AllPs
win_erp=squeeze(All_ERP(chanOfInterest,:,1,:));
loss_erp=squeeze(All_ERP(chanOfInterest,:,2,:));
% %% RewP_Waveforms
csvwrite('../../results/eeglab_RewP_Waveforms.csv',[(-200:2:998)',nanmean(squeeze(All_ERP(chanOfInterest,:,1,:)),2),nanmean(squeeze(All_ERP(chanOfInterest,:,2,:)),2),nanmean(squeeze(All_ERP(chanOfInterest,:,1,:)),2)-nanmean(squeeze(All_ERP(chanOfInterest,:,2,:)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
csvwrite('../../results/eeglab_RewP_Waveforms_AllPs.csv',[win_erp,loss_erp]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
% %% RewP_Latency
[~,peak_loc] = max(squeeze(All_ERP(chanOfInterest,226:276,1,:))-squeeze(All_ERP(chanOfInterest,226:276,2,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
csvwrite('../../results/eeglab_RewP_Latency.csv',peak_loc'); %Export data
