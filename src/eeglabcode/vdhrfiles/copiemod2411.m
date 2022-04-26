% % % % % 
% % % % % %% PREPROCESSING                                                    
% % % % % %% Stage 1: Process data to determine noisy/faulty electrodes
% % % % % %%  Step 1.1: Pre-ICA                                               
% % % % % clear all; 
% % % % % % close all; 
% % % % % % clc; %First, clean the environment
% % % % % % folder = fileparts(which('/home/StageEEGpre'))
% % % % % % addpath(genpath(folder));
% % % % % % addpath('/home/StageEEGpre/src/eeglabcode/vdhrfiles/copiemod2411.m');
% % % % % % 
% % % % % % folder2 = fileparts(which('/home/dependencies/eeglab_current/')); 
% % % % % % addpath(genpath(folder2));
% % % % % % 
% % % % % % %addpath(genpath('/home/StageEEGpre'));
% % % % % % rmpath(genpath('/home/StageEEGpre/dependencies/eeglab_current/'));
% % % % % % rmpath('/home/StageEEGpre/dependencies/fieldtrip-lite-20211020');
% % % % % 
% % % % % % dossiersauv='/home/StageEEGpre/data/Rawdata10';
% % % % % %cd(uigetdir);
% % % % % dirdata='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';
% % % % % 
% % % % % cd(dirdata); %Find and change working folder to raw EEG data
% % % % % 
% % % % % cd(dirdata); %Find and change working folder to raw EEG data
% % % % % 
% % % % % filenames = dir('*.vhdr');
% % % % % filenames.name%Compile list of all data
% % % % % 
% % % % % %for participant = 1:length(filenames) %Cycle through participants
% % % % % for participant = 1:500%Cycle through participants
% % % % % 
% % % % %     %Get participant name information
% % % % %     disp(['Participant: ', num2str(participant)]) %Display current participant being processed
% % % % %     participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
% % % % %     participant_varname = ['Without_AKRewardProcessing_S1PostICA_',participant_number{2}]; %Create new file name
% % % % %     
% % % % %     %Load Data
% % % % %     EEG = []; %Clear past data
% % % % % 
% % % % %     [EEG] = doLoadBVData(filenames(participant).name  ); %Load raw EEG data
% % % % %     
% % % % %     %Make it a 32 channels cap - reduces any participants with a 64 channel system
% % % % %     if EEG.nbchan > 31 %Determine whether current participant is a 64 channel setup
% % % % %         %a=EEG;
% % % % %         [EEG] = doRemoveChannels(EEG,{'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'},EEG.chanlocs); %Removes electrodes that are not part of the 32 channel system 
% % % % %         %b=EEG
% % % % %         %AF3 AF4 AF7 AF8 C1 C2 C5 C6 CP3 CPz F1 F2 F5 F6 FC3 FC4 FT10 FT7 FT8 FT9 Oz P1 P2 P5 P6 PO3 PO4 PO7 PO8 TP7 TP8 CP4
% % % % %     end
% % % % %     
% % % % %     %Re-Reference
% % % % %     load('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
% % % % % %     chanlocsMaster([10,21]) = []; %Remove channels TP9 and TP10 as they will be the references
% % % % %     [EEG] = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs); %Reference all channels to an averaged TP9/TP10 (mastoids)
% % % % %     [EEG] = doRemoveChannels(EEG,{'TP9','TP10'},EEG.chanlocs); %Remove reference channels from the data
% % % % %     [EEG] = doInterpolate(EEG,chanlocsMaster,'spherical'); %Interpolate the electrode used as reference during recording (AFz)
% % % % % 
% % % % %     %Filter
% % % % %     [EEG] = doFilter(EEG,0.1,30,4,60,EEG.srate); %Filter data: Low cutoff 0.1, high cutoff 30, order 4, notch 60
% % % % %     
% % % % %     %ICA
% % % % % %     [EEG] = doICA(EEG,1); %Run ICA for use of eye blink removal
% % % % %     
% % % % %     %Save Output
% % % % %     save(participant_varname,'EEG'); %Save the current output so that the lengthy ICA process can run without user intervention
% % % % % end
% % % % % %%  Step 1.2: Post-ICA                                              
% % % % % clear all; close all; clc; %First, clean the environment
% % % % % dirdata='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';
% % % % % 
% % % % % cd(dirdata); %Find and change working folder to raw EEG data
% % % % % %Find and change working folder to saved data from last for loop
% % % % % filenames = dir('Without_AKRewardProcessing_S1PostICA*'); %Compile list of all data
% % % % % 
% % % % % %for participant = 1:length(filenames) %Cycle through participants
% % % % % for participant = 1:length(filenames)
% % % % %     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
% % % % %     participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
% % % % %     participant_varname = ['Without_AKRewardProcessing_S1Final_',participant_number{3}]; %Create new file name
% % % % %      
% % % % %     %Load Data
% % % % %     EEG = []; %Clear past data
% % % % %     load(filenames(participant).name); %Load participant output
% % % % %     
% % % % %     %Inverse ICA
% % % % % %     ICAViewer %Script to navigate ICA loading topographic maps and loadings in order to decide which component(s) reflect eye blinks
% % % % % %     [EEG] = doICARemoveComponents(EEG,str2num(cell2mat(EEG.ICAcomponentsRemoved))); %Remove identified components and reconstruct EEG data
% % % % % %     
% % % % % a2=EEG;
% % % % %     %Segment Data
% % % % %     [EEG] = doSegmentData(EEG,{'S110','S111'},[-500 1498]); %Segment Data (S110 = Loss, S111 = Win)
% % % % %   c2=EEG;  
% % % % %     %Baseline Correction
% % % % %     [EEG] = doBaseline(EEG,[-200,0]); %Baseline correction in ms
% % % % %     
% % % % %     %Artifact Rejection
% % % % %     [EEG] = doArtifactRejection(EEG,'Gradient',10); %Use a 10 uV/ms gradient criteria
% % % % %     [EEG] = doArtifactRejection(EEG,'Difference',100); %Use a 100 uV max-min criteria
% % % % %     
% % % % %     save(participant_varname,'EEG'); %Save the current output
% % % % % end
% % % % 
% % % % %%  Step 1.3: Determining faulty electrodes
% % % % % clear all; close all; clc; %First, clean the environment
% % % % dirdata='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';
% % % % 
% % % % cd(dirdata); %Find and change working folder to raw EEG data
% % % % %Find and change working folder to saved data from last for loop
% % % % filenames = dir('Without_AKRewardProcessing_S1Final_*'); %Compile list of all data
% % % % 
% % % % for participant = 318:length(filenames) %Cycle through participants
% % % %     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
% % % %     participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
% % % %      
% % % %     %Load Data
% % % %     EEG = []; %Clear past data
% % % %     load(filenames(participant).name); %Load participant output
% % % %     
% % % %     %Extract Artifact Rejection Output
% % % %     AR_indx = []; trials_removed = []; %Clear past participant data
% % % %     AR_indx = EEG.artifactPresent; %Reassign artifact rejection output
% % % %     AR_indx(AR_indx > 1)=1; %Re-ID any indication of a rejected segment to be identified as the number 1
% % % %     trials_removed = sum(AR_indx')/size(AR_indx,2); %Determine the percentage of segments removed for each electrode
% % % % 
% % % %     %Determines the number of electrodes that surpassed different percentages of rejections
% % % %     avg_removed(participant,1) = sum(trials_removed>.1);
% % % %     avg_removed(participant,2) = sum(trials_removed>.1);
% % % %     avg_removed(participant,3) = sum(trials_removed>.15);
% % % %     avg_removed(participant,4) = sum(trials_removed>.2);
% % % %     avg_removed(participant,5) = sum(trials_removed>.25);
% % % %     avg_removed(participant,6) = sum(trials_removed>.3);
% % % %     avg_removed(participant,7) = sum(trials_removed>.35);
% % % %     avg_removed(participant,8) = sum(trials_removed>.4);
% % % %     avg_removed(participant,9) = sum(trials_removed>.45);
% % % %     avg_removed(participant,10) = sum(trials_removed>.5);
% % % %     avg_removed(participant,11) = sum(trials_removed>.55);
% % % %     avg_removed(participant,12) = sum(trials_removed>.6);
% % % %     avg_removed(participant,13) = sum(trials_removed>.65);
% % % %     avg_removed(participant,14) = sum(trials_removed>.7);
% % % %     avg_removed(participant,15) = sum(trials_removed>.75);
% % % %     avg_removed(participant,16) = sum(trials_removed>.8);
% % % %     avg_removed(participant,17) = sum(trials_removed>.85);
% % % %     avg_removed(participant,18) = sum(trials_removed>.9);
% % % %     avg_removed(participant,19) = sum(trials_removed>.95);
% % % %    
% % % %    %Determine a level of rejection for each individual
% % % % %      rejection_level = find(avg_removed(participant,:)<11); %Uses a percentage within which less than 11 electrodes have been removed
% % % % %      rejection_level = rejection_level(1); %Uses the lowest rejection level within which less than 11 electrodes have been removed
% % % % %      
% % % %      %Save rejection information into a variable
% % % %      numbers = [10,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95]/100; %First, determine the levels of rejection. 10 is repeated twice because it used ti be 5 but we decided this was too strict
% % % %      p_chanreject{participant,1} = cellstr(participant_number{3}); %Insert participant number
% % % %      p_chanreject{participant,2} = cellstr(num2str(0.4)); %insert lowest level within which less than ten electrodes have been removed
% % % %      p_chanreject{participant,3} = cellstr(num2str(find(trials_removed>0.4))); %Determine the indices of electrodes to be removed
% % % % end
% % % % 
% % % % %Save channels to reject information into a mat file
% % % % save('Chans_rejected_auto500','p_chanreject');
%% Stage 2: Process data for analysis
%%  Step 2.1: Pre-ICA                                               
clear all; close all; clc; %First, clean the environment
dirdata='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';

cd(dirdata); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr'); %Compile list of all data

%Load list of electrodes to remove 
% load('Chans_rejected_auto500.mat');
% participant = [1:76 78:length(filenames)]
for participant = 1:length(filenames) %Cycle through participants

    %Get participant name information
    disp(['Participant: ', num2str(participant)]); %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    participant_varname = ['Without_AKRewardProcessing_S2PostICA_',participant_number{2}]; %Create new file name

    %Load Data
    EEG = []; %Clear past data
    [EEG] = doLoadBVData(filenames(participant).name  ); %Load raw EEG data
    
    %Make it a 32 channels cap - reduces any participants with a 64 channel system
    if EEG.nbchan > 31 %Determine whether current participant is a 64 channel setup
        [EEG] = doRemoveChannels(EEG,{'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'},EEG.chanlocs); %Removes electrodes that are not part of the 32 channel system 
    end
    
    %Re-Reference
    load('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
%     chanlocsMaster([10,21]) = []; %Remove channels TP9 and TP10 as they will be the references
    try
    %Note:Through visual inspection, some of the reference electrodes were deemed poor quality and were not used
    if str2num(participant_number{2}) == 164 || str2num(participant_number{2}) == 255 || str2num(participant_number{2}) == 277 %Participants with one noisy mastoid electrode
        [EEG] = doRereference(EEG,{'TP9'},{'ALL'},EEG.chanlocs); %Re-reference with only TP9
    elseif str2num(participant_number{2}) == 110 %Participants with one noisy mastoid electrode
        [EEG] = doRereference(EEG,{'TP10'},{'ALL'},EEG.chanlocs); %Re-reference with only TP10
    else
        [EEG] = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs); %Reference all channels to an averaged TP9/TP10 (mastoids)
    end
    [EEG] = doRemoveChannels(EEG,{'TP9','TP10'},EEG.chanlocs); %Remove reference channels from the data
    [EEG] = doInterpolate(EEG,chanlocsMaster,'spherical'); %Interpolate the electrode used as reference during recording (AFz)

%     %Remove Faulty Electrodes
%     p_chans = []; %Clear past participants electrode indices
%     p_chans = strsplit(p_chanreject{participant,3}{1},' '); %Extract the indices of electrodes to remove
%     chans_to_remove = []; %Clear past participants electrode labels
%     if ~isempty(p_chans{1}) %Determine whether electrodes need to be removed
%         x = 1; %Begin index count
%         for l = 1:size(p_chans,2) %Scroll through the electrodes
%             if str2num(p_chans{1,l}) ~= 26 %Ensure that FCz id not removed
%                 chans_to_remove{1,x} = chanlocsMaster(str2num(p_chans{1,l})).labels; %Create list of electrode labels to remove
%                 x = x+1; %Increase index count
%             end
%         end
%         [EEG] = doRemoveChannels(EEG,chans_to_remove,chanlocsMaster); %Remove electrodes
%     else %If there is no electrodes to remove
%         [EEG] = doRemoveChannels(EEG,{},chanlocsMaster); %Still run function, but do not remove any electrodes
%     end
    
    %Removed missed faulty electrodes on certain participants (determined on Step 1.2) - This was determined via visual inspection of the data after step 1.2
    if str2num(participant_number{2})==77
        [EEG] = doRemoveChannels(EEG,{'P8','CP6','AFz'},EEG.chanlocs);
    elseif str2num(participant_number{2})==199
        [EEG] = doRemoveChannels(EEG,{'FC1','O2'},EEG.chanlocs);
    elseif str2num(participant_number{2})==486
        [EEG] = doRemoveChannels(EEG,{'FC2'},EEG.chanlocs);
    else
        %Skip
    end

    %Filter
    [EEG] = doFilter(EEG,0.1,30,4,60,EEG.srate); %Filter da ta: Low cutoff 0.1, high cutoff 30, order 4, notch 60
    
    %ICA
%     [EEG] = doICA(EEG,1); %Run ICA for use of eye blink removal
    
    %Save output
    save(participant_varname,'EEG'); %Save the current output so that the lengthy ICA process can run without user intervention
    catch
    end
end
%%  Step 2.2: Post-ICA                                              
clear all; close all; clc; %First, clean the environment
dirdata='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';

cd(dirdata); %Find and change working folder to raw EEG data
%Find and change working folder to saved data from last for loop
filenames = dir('Without_AKRewardProcessing_S2PostICA*'); %Compile list of all data

for participant = 1:length(filenames) %Cycle through participants
    disp(['Participant: ', num2str(participant)]); %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
    participant_varname = ['Without_AKRewardProcessing_S2PostInvICA_',participant_number{3}]; %Create new file name
     
    %Load Data
    EEG = []; %Clear past data
    load(filenames(participant).name); %Load participant output
    
%     %Remove ICA Component
%     ICAViewer %Script to navigate ICA loading topographic maps and loadings in order to decide which component(s) reflect eye blinks
%     [EEG] = doICARemoveComponents(EEG,str2num(cell2mat(EEG.ICAcomponentsRemoved))); %Remove identified components and reconstruct EEG data
%     
    save(participant_varname,'EEG'); %Save the current output
end
%%  Step 2.3: Final                                                 
clear all; close all; clc; %First, clean the environment
dirdata='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';

cd(dirdata); %Find and change working folder to raw EEG data
filenames = dir('Without_AKRewardProcessing_S2PostICA*'); %Compile list of all data

for participant = 1:length(filenames) %Cycle through participants
    
    disp(['Participant: ', num2str(participant)]); %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
    participant_varname = ['thresh150Without_AKRewardProcessing_S2Final_',participant_number{4}]; %Create new file name
    
    %Load Data
    EEG = []; %Clear past data
    load(filenames(participant).name); %Load participant output
    
    %Topograpic Interpolation
    load('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
    [EEG] = doInterpolate(EEG,chanlocsMaster,'spherical'); %Interpolate electrodes which were previously removed

    %Determine markers of interest
    markers = {'S110','S111'}; %Loss, win
    
    %Segment Data
    [EEG] = doSegmentData(EEG,markers,[-500 1298]); %Segment Data (S110 = Loss, S111 = Win). The segment window of interest is -200 to 1000ms, and we here add 300 ms before and after this because time-frequency edge artifacts (this is different than the first pass because we were being more conservative then)
             
    %Baseline Correction
    [EEG] = doBaseline(EEG,[-200/1000,0]); %Baseline correction in ms
    
    %Artifact Rejection
    [EEG] = doArtifactRejection(EEG,'Gradient',10); %Use a 10 microvolt/ms gradient criteria
    [EEG] = doArtifactRejection(EEG,'Difference',300); %Use a 100 microvolt max-min criteria
    [EEG] = doRemoveEpochs(EEG,EEG.artifactPresent,0); %Remove segments that violated artifact rejection criteria
    
    %Save backup data because different window lengths for each processing type
%     EEG.backupdata = EEG.data;

%     try
% %     %Wavelet
%     [EEG.WAV] = doWAV(EEG,markers,[],1,30,30,6); %Conduct Time-Frequency Analyses: no baseline, ranging from frequencies 1 to 30 in 30 linear steps, using a Morlet parameter of 6
%     EEG.WAV.eegdata = EEG.data; %Copy WAV data
%     catch
%     end
%     %Reduce Data Length for FFT
% %     EEG.data = EEG.backupdata(:,1:750,:); %-500 to 1000ms 
%     
% %     %FFT
% try
%     [EEG.FFT] = doFFT(EEG,markers); %Conduct FFT Analyses
%    catch
% end
%     save(participant_varname,'EEG'); %Save the current output
    
    %Reduce Data Length for ERP
%     EEG.data = EEG.backupdata(:,151:750,:); %-200 to 1000ms
    
    %ERP
    try
    [EEG.ERP] =  doERP(EEG,markers,0); %Conduct ERP Analyses
    catch
        msgbox('Hello');
    end
    save(participant_varname,'EEG'); %Save the current output
end
%% EXTRACTION OF DATA %%
%% Aggregate data across participants                               
clear all; close all; clc; %First, clean the environment
dirdata='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';

cd(dirdata); %Find and change working folder to raw EEG data
 %Find and change working folder to saved data from last for loop
filenames = dir('thresh150Without_AKRewardProcessing_S2Final*'); %Compile list of all data

for participant = 1:500 %Cycle through participants
    disp(['Participant: ', num2str(participant)]); %Display current participant being processed

    %Load Data
    EEG = []; %Clear past data
    load(filenames(participant).name); %Load participant output
    
    All_ERP(:,:,:,participant) = EEG.ERP.data; %Store all the ERP data into a single variable
%     try
%     %FFT frequency resolution is 0.67, so must extract proper frequencies
%     All_FFT(:,1,:,participant) = mean(EEG.FFT.data(:,1:2,:),2); %Store all the FFT data into a single variable (1 Hz)
%     All_FFT(:,2,:,participant) = EEG.FFT.data(:,3,:); %Store all the FFT data into a single variable (2 Hz)
%     All_FFT(:,3,:,participant) = mean(EEG.FFT.data(:,4:5,:),2); %Store all the FFT data into a single variable (3 Hz)
%     All_FFT(:,4,:,participant) = EEG.FFT.data(:,6,:); %Store all the FFT data into a single variable (4 Hz)
%     All_FFT(:,5,:,participant) = mean(EEG.FFT.data(:,7:8,:),2); %Store all the FFT data into a single variable (5 Hz)
%     All_FFT(:,6,:,participant) = EEG.FFT.data(:,9,:); %Store all the FFT data into a single variable (6 Hz)
%     All_FFT(:,7,:,participant) = mean(EEG.FFT.data(:,10:11,:),2); %Store all the FFT data into a single variable (7 Hz)
%     All_FFT(:,8,:,participant) = EEG.FFT.data(:,12,:); %Store all the FFT data into a single variable (8 Hz)
%     All_FFT(:,9,:,participant) = mean(EEG.FFT.data(:,13:14,:),2); %Store all the FFT data into a single variable (9 Hz)
%     All_FFT(:,10,:,participant) = EEG.FFT.data(:,15,:); %Store all the FFT data into a single variable (10 Hz)
%     
%     All_WAV(:,:,:,:,participant) = EEG.WAV.data; %%Store all the WAV data into a single variable
%     catch 
%     end
end

save('Without_AKAR500_All_ERP_thresh150', 'All_ERP'); %Save ERP Data
% save('AR500_All_FFT', 'All_FFT'); %Save FFT Data
%Unfortunately, the WAV file is unable to save as it is too large, thus when using the All_WAV variable, this section must be run first
%% Load Data
% load('All_ERP.mat'); %Load saved ERP data
% load('All_FFT.mat'); %Load saved FFT data
% %% RewP_Waveforms                                                   
% csvwrite('RewP_Waveforms.csv',[(-200:2:998)',mean(squeeze(All_ERP(26,:,1,:)),2),mean(squeeze(All_ERP(26,:,2,:)),2),mean(squeeze(All_ERP(26,:,1,:)),2)-mean(squeeze(All_ERP(26,:,2,:)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
% %% RewP_Waveforms_AllPs                                             
% csvwrite('RewP_Waveforms_AllPs.csv',[squeeze(All_ERP(26,:,1,:)),squeeze(All_ERP(26,:,2,:))]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
% %% RewP_Latency                                                     
% [~,peWithout_AKloc] = max(squeeze(All_ERP(26,226:276,1,:))-squeeze(All_ERP(26,226:276,2,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
% peWithout_AKloc = (((peWithout_AKloc+225)*2)-200)/1000; %Convert into seconds
% csvwrite('RewP_Latency.csv',peWithout_AKloc'); %Export data
% %% RewP_FFT                                                         
% csvwrite('RewP_FFT.csv',[(1:1:10)',squeeze(mean(All_FFT(26,:,1,:),4))',squeeze(mean(All_FFT(26,:,2,:),4))',(squeeze(mean(All_FFT(26,:,1,:),4))-squeeze(mean(All_FFT(26,:,2,:),4)))']); %Export data. Conditions: Frequency, Loss, Win, Difference. Electrode 26 is FCz.
% %% RewP_FFT_AllPs                                                   
% csvwrite('RewP_FFT_AllPs.csv',[squeeze(All_FFT(26,:,1,:)),squeeze(All_FFT(26,:,2,:))]'); %Export data. Conditions: Loss, Win.
% %% RewP_WAV_Stats                                                   
% delta_extract=zeros(30,600); %Create empty matrix for delta extraction
% delta_extract(1:2,:)=(squeeze(mean(All_WAV(26,1:2,151:750,:,:),[4,5])))>5.5; %Determine delta effect via the collapsed localizer method with a power threshhold of 5.5
% theta_extract=zeros(30,600); %Create empty matrix for theta extraction
% theta_extract(3:7,:)=(squeeze(mean(All_WAV(26,3:7,151:750,:,:),[4,5])))>5.5; %Determine theta effect via the collapsed localizer method with a power threshhold of 5.5
% both_extract = (delta_extract+theta_extract>0); %Determine all effects via the collapsed localizer method 
% 
% WAV_data1 = permute(squeeze(All_WAV(26,:,151:750,1,:)),[3,1,2]); %Extract participants time-frequency condition 1
% WAV_data2 = permute(squeeze(All_WAV(26,:,151:750,2,:)),[3,1,2]); %Extract participants time-frequency condition 2
% WAV_diff = WAV_data1-WAV_data2; %Create difference wave
% nb=100;
% for participant = 1:nb %Cycle through participants
%     WAV_Delta(participant,:,:) = squeeze(WAV_diff(participant,:,:)).*delta_extract; %Confine data to significant delta activity for difference WAV
%     WAV_Theta(participant,:,:) = squeeze(WAV_diff(participant,:,:)).*theta_extract; %Confine data to significant theta activity for difference WAV
%     gain_WAV_Delta(participant,:,:) = squeeze(WAV_data1(participant,:,:)).*delta_extract; %Confine data to significant delta activity for condition 1
%     loss_WAV_Theta(participant,:,:) = squeeze(WAV_data2(participant,:,:)).*theta_extract; %Confine data to significant theta activity for condition 2
%     WAV_Both(participant,:,:) = squeeze(WAV_diff(participant,:,:)).*both_extract; %Determine all frequencies
% end
%  
% WAV_Delta(WAV_Delta==0) = nan; %Remove non-significant data
% WAV_Theta(WAV_Theta==0) = nan; %Remove non-significant data
% gain_WAV_Delta(WAV_Delta==0) = nan; %Remove non-significant data
% loss_WAV_Theta(WAV_Theta==0) = nan; %Remove non-significant data
% WAV_Both(WAV_Both==0) = nan; %Remove non-significant data
% 
% WAV_Extract(:,1) = nanmean(WAV_Theta,[2,3]); %Average data across resulting time and frequencies for theta of difference WAV
% WAV_Extract(:,2) = nanmean(WAV_Delta,[2,3]); %Average data across resulting time and frequencies for delta of difference WAV
% WAV_Extract(:,3) = nanmean(loss_WAV_Theta,[2,3]); %Average data across resulting time and frequencies for theta of condition 2
% WAV_Extract(:,4) = nanmean(gain_WAV_Delta,[2,3]); %Average data across resulting time and frequencies for delta of condition 1
% csvwrite('RewP_WAV_Stats.csv',WAV_Extract); %Export data
% %% RewP_WAV_Freqs                                                   
% [~,WAV_Extract_freq_time] = max(WAV_diff(:,1:2,:),[],3); %Determine max peak times for delta activity
% [~,WAV_Extract_freq_time(:,3:7)] = min(WAV_diff(:,3:7,:),[],3); %Determine min peak times for theta activity
% WAV_Time = -200:2:998; %Create a variable of time in milliseconds
% csvwrite('RewP_WAV_Freqs.csv',[nanmean(WAV_Both(:,1:7,:),3),WAV_Time(WAV_Extract_freq_time)]); %Export data
% 
