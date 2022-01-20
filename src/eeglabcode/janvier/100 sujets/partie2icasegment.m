% EEGLAB history file generated on the 04-Jan-2022
% ------------------------------------------------
% 
% restoredefaultpath;
% clear all; 
% clc; %First, clean the environment


% dirprinc='/home/nforde/Documents/';
% addpath(dirprinc+'StageEEGpre/data/Raw Data Part 1')

addpath('/home/nforde/Documents/StageEEGpre/data/Raw Data Part 1');
addpath('/home/nforde/Documents/StageEEGpre/dependencies/eeglab_current/eeglab2021.1')
addpath(genpath('/home/nforde/Documents/StageEEGpre/dependencies/article/MATLAB-EEG-preProcessing-master'))


dirdata='/home/nforde/Documents/StageEEGpre/data/Raw Data Part 13';
cd(dirdata);
filenames = dir('*.vhdr')

for participant = 90:90 %length(filenames) %Cycle through participants


    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    participant_varname = ['RewardProcessing_S1Final_',participant_number{2}]; %Create new file name
    



[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%chargement data
EEG = pop_loadbv('/home/nforde/Documents/StageEEGpre/data/Raw Data Part 13/', filenames(participant).name);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','one','gui','off'); 
EEG = eeg_checkset( EEG );


%ajouter chanlocs
EEG=pop_chanedit(EEG, 'lookup','/home/nforde/Documents/StageEEGpre/dependencies/eeglab_current/eeglab2021.1/functions/supportfiles/Standard-10-20-Cap81.ced');

%passer à 32 channels
[EEG] = doRemoveChannels(EEG,{'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'},EEG.chanlocs); %Removes electrodes that are not part of the 32 channel system 

EEG=pop_chanedit(EEG, 'setref',{'1:31','TP10 TP9'});

% load('ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
% chanlocsMaster([10,21]) = []; %Remove channels TP9 and TP10 as they will be the references
%  
%renseigner les channels reference
 EEG = pop_reref( EEG ,{'TP9','TP10'});

 %interpoler les channels ref
EEG = pop_interp(EEG, EEG.chaninfo.nodatchans([1  2]), 'spherical');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','oneingterpol','gui','off'); 

[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%filtre passe bande 0,1 30
EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',30);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
EEG = eeg_checkset( EEG );

%ICA
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%identifier differents artifacts correspondants
[EEG, varargout] = pop_iclabel(EEG, 'default')

EEG = eeg_checkset( EEG );

%flag sur les artifact
EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

%supprimer artifact eye
EEG = pop_subcomp( EEG, [1], 0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'gui','off'); 
pop_saveh( ALLCOM, 'eeglabhist5.m', '/home/nforde/Documents/StageEEGpre/src/eeglabcode/janvier/vhdr copiemod/');
EEG = eeg_checkset( EEG );
eeglab redraw;
save(participant_varname,'EEG'); %Save the current output

end

filenames = dir('RewardProcessing_S1Final*');
for participant = 1:length(filenames) %Cycle through participants


    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    participant_varname = ['RewardProcessing_S2Final_',participant_number{2}]; %Create new file name
    

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%chargement data
EEG = pop_loadbv('/home/nforde/Documents/StageEEGpre/data/Raw Data Part 13/', filenames(participant).name);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','one','gui','off'); 
EEG = eeg_checkset( EEG );





%segment data
 %Determine markers of interest for WAV later
    markers = {'S110','S111'}; %Loss, win
    
[EEG] = doSegmentData(EEG,markers,[-500 1298]); %Segment Data (S110 = Loss, S111 = Win). The segment window of interest is -200 to 1000ms, and we here add 300 ms before and after this because time-frequency edge artifacts (this is different than the first pass because we were being more conservative then)
%    
% EEG = pop_epoch( EEG, {  'S110'  'S111'  }, [-1  2], 'newname', 'oneingterpol pruned with ICA epochs', 'valuelim', [-500  1498], 'epochinfo', 'yes');
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 
%  EEG = eeg_checkset( EEG );
% eeglab redraw;
%baseline correction
EEG = pop_rmbase( EEG, [-0,2 0] ,[]);
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'gui','off'); 

%bad segment
% EEG = eeg_checkset( EEG );
EEG = pop_eegthresh(EEG,1,[1:31] ,-50,50,-1,1.998,0,0);

%[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);



%Save backup data because different window lengths for each processing type
    EEG.backupdata = EEG.data; 
    

addpath(genpath('/home/nforde/Documents/StageEEGpre/dependencies/article/MATLAB-EEG-timeFrequencyAnalysis-master'));


  %Wavelet
    [EEG.WAV] = doWAV(EEG,markers,[],1,30,30,6); %Conduct Time-Frequency Analyses: no baseline, ranging from frequencies 1 to 30 in 30 linear steps, using a Morlet parameter of 6
    EEG.WAV.eegdata = EEG.data; %Copy WAV data
    
%     %Reduce Data Length for FFT
%     EEG.data = EEG.backupdata(:,1:750,:); %-500 to 1000ms 
%     
%     %FFT
%     [EEG.FFT] = doFFT(EEG,markers); %Conduct FFT Analyses
%     
%     save(participant_varname,'EEG'); %Save the current output
%     [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

    %Reduce Data Length for ERP
    EEG.data = EEG.backupdata(:,151:750,:); %-200 to 1000ms
    

    
    %ERP
    [EEG.ERP] = doERP(EEG,markers,0); %Conduct ERP Analyses
    EEG.ERP.data;
%[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    save(participant_varname,'EEG'); %Save the current output

end   


% % a=mean(EEG.ERP.data, [1, 3]);
% % plot(a)
% % a=mean(EEG.ERP.data, [1]);
% % plot(a)