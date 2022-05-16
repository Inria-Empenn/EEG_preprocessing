% ======= CREATE PROTOCOL =======
% The protocol name has to be a valid folder name (no spaces, no weird characters...)

todir='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';
BS_db='/Users/ayakabbara/Documents/brainstorm_db/';

ProtocolName = 'Protocol_PreProc';
% Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end
% Delete existing protocol
gui_brainstorm('DeleteProtocol', ProtocolName);
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);

cd(todir); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr')
nb=500;

for participant = 1:nb %Cycle through participants
    
%     Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components

RawFile = fullfile([todir '/set'],['set_' participant_number{2} '.set']);
SubjectName = ['participant_' participant_number{2}];


% Check if the folder contains the required files
if ~file_exist(RawFile)
    error(['The folder does not contain the folder from the file sample.']);
end


% ===== ACCESS RECORDINGS =====

% Process: Create link to raw file
sFiles = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
    'subjectname',    SubjectName, ...
    'datafile',       {RawFile,'EEG-EEGLAB'} , ...
    'channelreplace', 0, ...
    'channelalign',   0)



% % Input files

% % Start a new report
bst_report('Start', sFiles);

 % ===== EEG REFERENCE =====
       % Process: Re-reference EEG
sFiles=bst_process('CallProcess', 'process_eegref', sFiles, [], ...
              'eegref',      'TP9, TP10', ...
              'sensortypes', 'EEG');

 % % % ==== bad channel identification ===  
sFiles=bst_process('CallProcess', 'process_import_data_time', sFiles, [], ...
      'subjectname', SubjectName, ...
    'timewindow',  []);

% detect flat channels only
sFilesInterp=bst_process('CallProcess', 'process_detectbad', sFiles, [], ...
    'timewindow',  [], ...
 'eeg', [10,2000],'rejectmode',1);

% interpolate the flat channels
sFiles=bst_process('CallProcess', 'process_eeg_interpbad', [sFilesInterp], []);

% % ====filtering====
% Process: Notch filter: 50Hz 100Hz 150Hz
sFiles = bst_process('CallProcess', 'process_notch', sFiles, [], ...
    'sensortypes', 'EEG', ...
    'freqlist',    [50, 100, 150], ...
    'cutoffW',     2, ...
    'useold',      0, ...
    'read_all',    0);
 
% % Process: Band-pass:0.1Hz-30Hz
sFiles = bst_process('CallProcess', 'process_bandpass', sFiles, [], ...
    'sensortypes', 'EEG', ...
    'highpass',    0.1, ...
    'lowpass',     30, ...
    'tranband',    0, ...
    'attenuation', 'strict', ...  % 60dB
    'ver',         '2019', ...  % 2019
    'mirror',      0, ...
    'read_all',    0);          
          
%  % ===== Epoching =====

markers = {'S110','S111'}; %Loss, win
% toremove={'AF3','AF4','AF7','AF8','C1','C2','C5','C6','CP3','CPz','F1','F2','F5','F6','FC3','FC4','FT10','FT7','FT8','FT9','Oz','P1','P2','P5','P6','PO3','PO4','PO7','PO8','TP7','TP8','CP4'};
% sFiles=bst_process('CallProcess', 'process_channel_setbad', sFiles, [], ...
%               'sensortypes', toremove);
          
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

%  % ===== trials detection =====
sFilesEpochs3=bst_process('CallProcess', 'process_detectbad', [sFilesEpochs1], [], ...
    'timewindow',  [], ...
 'eeg', [0,100],'rejectmode',2);

% sFilesEpochs3=bst_process('CallProcess', 'process_eeg_interpbad', [sFilesEpochs3], []);
% sFilesEpochs3=bst_process('CallProcess', 'process_detectbad', [sFilesEpochs3], [], ...
%     'timewindow',  [], ...
%  'eeg', [0,100],'rejectmode',2);


sFilesEpochs4=bst_process('CallProcess', 'process_detectbad', [sFilesEpochs2], [], ...
    'timewindow',  [], ...
 'eeg', [0,100],'rejectmode',2);         
% sFilesEpochs4=bst_process('CallProcess', 'process_eeg_interpbad', [sFilesEpochs4], []);
% sFilesEpochs4=bst_process('CallProcess', 'process_detectbad', [sFilesEpochs4], [], ...
%     'timewindow',  [], ...
%  'eeg', [0,100],'rejectmode',2);

% % ===== erp computation =====
% 
  sFilesAvg = bst_process('CallProcess', 'process_average', [sFilesEpochs3, sFilesEpochs4], [], ...
   'avgtype',    5, ...  % By trial groups (folder average)
    'avg_func',   1, ...  % Arithmetic average: mean(x)
     'weighted',   0, ...
     'keepevents', 1);
%  
try
BS_db='/Users/ayakabbara/Documents/brainstorm_db/';
dirr=[BS_db ProtocolName '/data/' sFilesAvg(1).FileName];

FF=load(dirr);
All_ERP_BS(1,:,:,participant) = FF.F; %Store all the ERP data into a single variable
catch
%     rem_part(end+1)=participant;
end
try
dirr=[BS_db ProtocolName '/data/' sFilesAvg(2).FileName];
FF=load(dirr);
All_ERP_BS(2,:,:,participant) = FF.F; %Store all the ERP data into a single variable
catch
%         rem_part(end+1)=participant;
end

% % ===delete subject for space issues
% bst_process('CallProcess', 'process_delete','subjectname',    SubjectName)
end

save('AllERP_BS','All_ERP_BS');
