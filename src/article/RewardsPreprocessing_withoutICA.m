  % %% PREPROCESSING
 % %% Stage 1: Process data to determine noisy/faulty electrodes
 % %%  Step 1.1: Pre-ICA
 clear all;
 dirdata='/Raw Data Part 1';

 cd(dirdata); %Find and change working folder to raw EEG data
 filenames = dir('*.vhdr');
 filenames.name%Compile list of all data

 %for participant = 1:length(filenames) %Cycle through participants
 for participant = 1:500 %Cycle through participants

     %Get participant name information
     disp(['Participant: ', num2str(participant)]) %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
     participant_varname = ['RewardProcessing_S1PostICA_',participant_number{2}]; %Create new file name
     
     %Load Data
     EEG = []; %Clear past data

     [EEG] = doLoadBVData(filenames(participant).name  ); %Load raw EEG data
     
     %Make it a 32 channels cap - reduces any participants with a 64 channel system
     if EEG.nbchan > 31 %Determine whether current participant is a 64 channel setup
         %a=EEG;
         [EEG] = doRemoveChannels(EEG,{'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'},EEG.chanlocs); %Removes electrodes that are not part of the 32 channel system
         %b=EEG
         %AF3 AF4 AF7 AF8 C1 C2 C5 C6 CP3 CPz F1 F2 F5 F6 FC3 FC4 FT10 FT7 FT8 FT9 Oz P1 P2 P5 P6 PO3 PO4 PO7 PO8 TP7 TP8 CP4
     end
     
     %Re-Reference
     load('/ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
 %     chanlocsMaster([10,21]) = []; %Remove channels TP9 and TP10 as they will be the references
     [EEG] = doRereference(EEG,{'TP9','TP10'},{'ALL'},EEG.chanlocs); %Reference all channels to an averaged TP9/TP10 (mastoids)
     [EEG] = doRemoveChannels(EEG,{'TP9','TP10'},EEG.chanlocs); %Remove reference channels from the data
     [EEG] = doInterpolate(EEG,chanlocsMaster,'spherical'); %Interpolate the electrode used as reference during recording (AFz)

     %Filter
     [EEG] = doFilter(EEG,0.1,30,4,60,EEG.srate); %Filter data: Low cutoff 0.1, high cutoff 30, order 4, notch 60
     
     %ICA
 %     [EEG] = doICA(EEG,1); %Run ICA for use of eye blink removal
     
     %Save Output
     save(participant_varname,'EEG'); %Save the current output so that the lengthy ICA process can run without user intervention
 end
 %%  Step 1.2: Post-ICA
 clear all; close all; clc; %First, clean the environment
 dirdata='/Raw Data Part 1';

 cd(dirdata); %Find and change working folder to raw EEG data
 %Find and change working folder to saved data from last for loop
 filenames = dir('RewardProcessing_S1PostICA*'); %Compile list of all data

 %for participant = 1:length(filenames) %Cycle through participants
 for participant = 1:length(filenames)
     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
     participant_varname = ['RewardProcessing_S1Final_',participant_number{3}]; %Create new file name
      
     %Load Data
     EEG = []; %Clear past data
     load(filenames(participant).name); %Load participant output
     
     %Inverse ICA
 %     ICAViewer %Script to navigate ICA loading topographic maps and loadings in order to decide which component(s) reflect eye blinks
 %     [EEG] = doICARemoveComponents(EEG,str2num(cell2mat(EEG.ICAcomponentsRemoved))); %Remove identified components and reconstruct EEG data
 %
 a2=EEG;
     %Segment Data
     [EEG] = doSegmentData(EEG,{'S110','S111'},[-500 1498]); %Segment Data (S110 = Loss, S111 = Win)
   c2=EEG;
     %Baseline Correction
     [EEG] = doBaseline(EEG,[-200,0]); %Baseline correction in ms
     
     %Artifact Rejection
     [EEG] = doArtifactRejection(EEG,'Gradient',10); %Use a 10 uV/ms gradient criteria
     [EEG] = doArtifactRejection(EEG,'Difference',100); %Use a 100 uV max-min criteria
     
     save(participant_varname,'EEG'); %Save the current output
 end

 %%  Step 1.3: Determining faulty electrodes
 % clear all; close all; clc; %First, clean the environment
 dirdata='/Raw Data Part 1';

 cd(dirdata); %Find and change working folder to raw EEG data
 %Find and change working folder to saved data from last for loop
 filenames = dir('RewardProcessing_S1Final_*'); %Compile list of all data

 for participant = 318:length(filenames) %Cycle through participants
     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
      
     %Load Data
     EEG = []; %Clear past data
     load(filenames(participant).name); %Load participant output
     
     %Extract Artifact Rejection Output
     AR_indx = []; trials_removed = []; %Clear past participant data
     AR_indx = EEG.artifactPresent; %Reassign artifact rejection output
     AR_indx(AR_indx > 1)=1; %Re-ID any indication of a rejected segment to be identified as the number 1
     trials_removed = sum(AR_indx')/size(AR_indx,2); %Determine the percentage of segments removed for each electrode

     %Determines the number of electrodes that surpassed different percentages of rejections
     avg_removed(participant,1) = sum(trials_removed>.1);
     avg_removed(participant,2) = sum(trials_removed>.1);
     avg_removed(participant,3) = sum(trials_removed>.15);
     avg_removed(participant,4) = sum(trials_removed>.2);
     avg_removed(participant,5) = sum(trials_removed>.25);
     avg_removed(participant,6) = sum(trials_removed>.3);
     avg_removed(participant,7) = sum(trials_removed>.35);
     avg_removed(participant,8) = sum(trials_removed>.4);
     avg_removed(participant,9) = sum(trials_removed>.45);
     avg_removed(participant,10) = sum(trials_removed>.5);
     avg_removed(participant,11) = sum(trials_removed>.55);
     avg_removed(participant,12) = sum(trials_removed>.6);
     avg_removed(participant,13) = sum(trials_removed>.65);
     avg_removed(participant,14) = sum(trials_removed>.7);
     avg_removed(participant,15) = sum(trials_removed>.75);
     avg_removed(participant,16) = sum(trials_removed>.8);
     avg_removed(participant,17) = sum(trials_removed>.85);
     avg_removed(participant,18) = sum(trials_removed>.9);
     avg_removed(participant,19) = sum(trials_removed>.95);
    
    %Determine a level of rejection for each individual
 %      rejection_level = find(avg_removed(participant,:)<11); %Uses a percentage within which less than 11 electrodes have been removed
 %      rejection_level = rejection_level(1); %Uses the lowest rejection level within which less than 11 electrodes have been removed
 %
      %Save rejection information into a variable
      numbers = [10,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95]/100; %First, determine the levels of rejection. 10 is repeated twice because it used ti be 5 but we decided this was too strict
      p_chanreject{participant,1} = cellstr(participant_number{3}); %Insert participant number
      p_chanreject{participant,2} = cellstr(num2str(0.4)); %insert lowest level within which less than ten electrodes have been removed
      p_chanreject{participant,3} = cellstr(num2str(find(trials_removed>0.4))); %Determine the indices of electrodes to be removed
 end

 %Save channels to reject information into a mat file
 save('Chans_rejected_auto500','p_chanreject');
 %% Stage 2: Process data for analysis
 %%  Step 2.1: Pre-ICA
 clear all; close all; clc; %First, clean the environment
 dirdata='/Raw Data Part 1';

 cd(dirdata); %Find and change working folder to raw EEG data
 filenames = dir('*.vhdr'); %Compile list of all data

 %Load list of electrodes to remove
 for participant = 1:length(filenames) %Cycle through participants

     %Get participant name information
     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
     participant_varname = ['RewardProcessing_S2PostICA_',participant_number{2}]; %Create new file name

     %Load Data
     EEG = []; %Clear past data
     [EEG] = doLoadBVData(filenames(participant).name  ); %Load raw EEG data
     
     %Make it a 32 channels cap - reduces any participants with a 64 channel system
     if EEG.nbchan > 31 %Determine whether current participant is a 64 channel setup
         [EEG] = doRemoveChannels(EEG,{'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'},EEG.chanlocs); %Removes electrodes that are not part of the 32 channel system
     end
     
     %Re-Reference
     load('/ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
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
 dirdata='/Raw Data Part 1';

 cd(dirdata); %Find and change working folder to raw EEG data
 %Find and change working folder to saved data from last for loop
 filenames = dir('RewardProcessing_S2PostICA*'); %Compile list of all data

 for participant = 1:length(filenames) %Cycle through participants
     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
     participant_varname = ['RewardProcessing_S2PostInvICA_',participant_number{3}]; %Create new file name
      
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
 dirdata='/Raw Data Part 1';

 cd(dirdata); %Find and change working folder to raw EEG data
 filenames = dir('RewardProcessing_S2PostICA*'); %Compile list of all data

 for participant = 1:length(filenames) %Cycle through participants
     
     disp(['Participant: ', num2str(participant)]); %Display current participant being processed
     participant_number = strsplit(filenames(participant).name(1:end-4),'_'); %Split filename into components
     participant_varname = ['RewardProcessing_S2Final_',participant_number{4}]; %Create new file name
     
     %Load Data
     EEG = []; %Clear past data
     load(filenames(participant).name); %Load participant output
     
     %Topograpic Interpolation
     load('/ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
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
     catch
         msgbox('Hello');
     end
     save(participant_varname,'EEG'); %Save the current output
 end
 %% EXTRACTION OF DATA %%
 %% Aggregate data across participants
 clear all; close all; clc; %First, clean the environment
 dirdata='/Raw Data Part 1';

 cd(dirdata); %Find and change working folder to raw EEG data
  %Find and change working folder to saved data from last for loop
 filenames = dir('RewardProcessing_S2Final*'); %Compile list of all data

 for participant = 1:length(filenames) %Cycle through participants
     disp(['Participant: ', num2str(participant)]); %Display current participant being processed

     %Load Data
     EEG = []; %Clear past data
     load(filenames(participant).name); %Load participant output
     
     All_ERP(:,:,:,participant) = EEG.ERP.data; %Store all the ERP data into a single variable
 end

 save('Ref_All_ERP', 'All_ERP'); %Save ERP Data

 All_ERP=All_ERP(:,151:750,:,:);

 % %% RewP_Waveforms
 csvwrite('Ref_RewP_Waveforms.csv',[(-200:2:998)',nanmean(squeeze(All_ERP(26,:,1,:)),2),nanmean(squeeze(All_ERP(26,:,2,:)),2),nanmean(squeeze(All_ERP(26,:,1,:)),2)-nanmean(squeeze(All_ERP(26,:,2,:)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
 % %% RewP_Waveforms_AllPs
 tt1=squeeze(All_ERP(26,:,1,:));
 tt2=squeeze(All_ERP(26,:,2,:));

 csvwrite('Ref_RewP_Waveforms_AllPs.csv',[tt1,tt2]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
 % %% RewP_Latency
 [~,peak_loc] = max(squeeze(All_ERP(26,226:276,1,:))-squeeze(All_ERP(26,226:276,2,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
 peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
 peak_loc(toberemoved)=[];
 csvwrite('Ref_RewP_Latency.csv',peak_loc'); %Export data
