% % % % % EEGLAB history file generated on the 04-Jan-2022
% % % % % ------------------------------------------------
% % % % % 
% % % % 
% % % % % 1st pass: detect bad electrodes using clean_artifacts
% % 
% % cd('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1'); %Find and change working folder to raw EEG data
% % filenames = dir('*.vhdr')
% % nb=500;
% % for participant = 1:nb %Cycle through participants
% %     
% % %     Get participant name information
% %     disp(['Participant: ', num2str(participant)]) %Display current participant being processed
% %     participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
% %  
% %     EEG = pop_loadbv('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/', filenames(participant).name);
% %     % ajouter chanlocs
% %     EEG=pop_chanedit(EEG, 'lookup','/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/eeglab2021.1/functions/supportfiles/Standard-10-20-Cap81.ced');
% % 
% %     % % passer à 32 channels: use the eeglab function
% %     % % 
% %     try
% %         if(EEG.nbchan > 32)
% %     EEG = pop_select(EEG, 'channel',{'Fp1'
% %     'Fz'
% %     'F3'
% %     'F7'
% %     'FC5'
% %     'FC1'
% %     'Cz'
% %     'C3'
% %     'T7'
% %     'CP5'
% %     'CP1'
% %     'Pz'
% %     'P3'
% %     'P7'
% %     'O1'
% %     'POz'
% %     'O2'
% %     'P4'
% %     'P8'
% %     'CP6'
% %     'CP2'
% %     'C4'
% %     'T8'
% %     'FC6'
% %     'FC2'
% %     'FCz'
% %     'F4'
% %     'F8'
% %     'Fp2'
% %     'TP10'
% %     'TP9'});
% %         end
% %     catch
% %         disp('Problem');
% %         rm_channels{participant}='';
% %         continue;
% %     end
% % 
% % EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',30);
% % [eeg2,HP,BUR,removed_channels] = clean_artifacts(EEG);
% % rm_channels{participant}=find(removed_channels);
% % end
% % save('eeglab_removedchans500','rm_channels');

% % 2nd pass: pre-process signals using the same paper's pipeline
clear all;
clc;
load('eeglab_removedchans500');
cd('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1'); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr')
nb=500;
for participant = 1:nb %Cycle through participants
    
    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
%     participant_varname = ['eeglab_RewardProcessing_S2Final_',participant_number{2}]; %Create new file name

    EEG = pop_loadbv('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/', filenames(participant).name);
    %ajouter chanlocs
    
    EEG=pop_chanedit(EEG, 'lookup','/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/eeglab2021.1/functions/supportfiles/Standard-10-20-Cap81.ced');

    %passer à 32 channels:  use the eeglab function
   
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
    % % interpolate the detected bad channels
    EEG = pop_interp(EEG, rm_channels{participant}, 'spherical');

    %renseigner les channels reference
    EEG=pop_chanedit(EEG, 'seteeglab',{'1:31','TP10 TP9'});
    EEG = pop_reref( EEG ,{'TP9','TP10'});

    %interpoler les channels eeglab == ici il faut pas interpolet TP9 et TP10,
    %mais AFZ

    %filtre passe bande 0.1-30
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',30);

    %segment data
    markers = {'S110','S111'}; %Loss, win
    [EEG] = doSegmentData(EEG,markers,[-500 1298]); %Segment Data (S110 = Loss, S111 = Win). The segment window of interest is -200 to 1000ms, and we here add 300 ms before and after this because time-frequency edge artifacts (this is different than the first pass because we were being more conservative then)   
    EEG = pop_rmbase( EEG, [-200/1000,0]);
    try
% %         trials removal
        EEG = pop_eegthresh(EEG,1,[1:29] ,-50,50,-0.2,1.2,0,1);
        %ERP
        [EEG.ERP] = doERP(EEG,markers,0); %Conduct ERP Analyses
        All_ERP_eeglab(:,:,:,participant) = EEG.ERP.data; %Store all the ERP data into a single variable
%         save(participant_varname,'EEG'); %Save the current output
       
    catch
        
        continue
    end
      
    catch
        continue
      
    end
end



save('All_ERP_eeglab500', 'All_ERP_eeglab'); %Save ERP Data

All_ERP=All_ERP_eeglab(:,151:750,:,:);
chanOfInterest=17;
% % channelof interest is FCz : 
% % =17 as resulted by EEGLAB

% %% RewP_Waveforms_AllPs      
tt1=squeeze(All_ERP(chanOfInterest,:,1,:));
tt2=squeeze(All_ERP(chanOfInterest,:,2,:));

idx1 = isnan(tt1) ;
[r1,c1]=find(tt1==0);
[r1,c3]=find(idx1);

% tt1(:,unique(c1))=[];
% tt2(:,unique(c1))=[];

idx2 = isnan(tt2) ;
[r2,c2]=find(tt2==0);
[r1,c4]=find(idx2);

% tt2(:,unique(c2))=[];
% tt1(:,unique(c2))=[];
% 
toberemoved=unique([unique(c1) ;unique(c2); unique(c3); unique(c4)]);
tKept1=[];tKept2=[];
kept_eeglab=[];
for su=1:500
     if(length(find(toberemoved==su))==0)
% %         the subject su is present
            kept_eeglab(end+1)=su;
            tKept1(:,end+1)=tt1(:,su);
            tKept2(:,end+1)=tt2(:,su);

    end
end
% %% RewP_Waveforms                                                   
csvwrite('eeglab_RewP_Waveforms_thresh100.csv',[(-200:2:998)',nanmean(squeeze(All_ERP(chanOfInterest,:,1,kept_eeglab)),2),nanmean(squeeze(All_ERP(chanOfInterest,:,2,kept_eeglab)),2),nanmean(squeeze(All_ERP(chanOfInterest,:,1,kept_eeglab)),2)-nanmean(squeeze(All_ERP(chanOfInterest,:,2,kept_eeglab)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
csvwrite('eeglab_RewP_Waveforms_AllPs_thresh100.csv',[tKept1,tKept2]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
% %% RewP_Latency 
[~,peak_loc] = max(squeeze(All_ERP(chanOfInterest,226:276,1,kept_eeglab))-squeeze(All_ERP(chanOfInterest,226:276,2,kept_eeglab))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
csvwrite('eeglab_RewP_Latency_thresh100.csv',peak_loc'); %Export data