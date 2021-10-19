 function scripthbnbst(tutorial_dir)

% Script generated by Brainstorm (14-Oct-2021)
% ======= FILES TO IMPORT =======
% You have to specify the folder in which the tutorial dataset is unzipped
if (nargin == 0) || isempty(tutorial_dir) || ~file_exist(tutorial_dir)
    error('The first argument must be the full path to the tutorial dataset folder.');
end
% Build the path of the files to import
RawFile = fullfile(tutorial_dir, 'mff_format','NDARAA075AMK');


% Check if the folder contains the required files
if ~file_exist(RawFile)
    error(['The folder ' tutorial_dir ' does not contain the folder from the file sample_epilepsy.zip.']);
end

% ======= CREATE PROTOCOL =======
% The protocol name has to be a valid folder name (no spaces, no weird characters...)
ProtocolName = 'HBN_Script_bst';
% Start brainstorm without the GUI
if ~brainstorm('status')
    brainstorm nogui
end
% Delete existing protocol
gui_brainstorm('DeleteProtocol', ProtocolName);
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);

% Subject name
SubjectName = 'Subject01';
SubjectNames = {...
    'Subject01'};


% ===== ACCESS RECORDINGS =====

% Process: Create link to raw file
sFiles = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
    'subjectname',    SubjectName, ...
    'datafile',       {RawFile,'EEG-EGI-MFF'} , ...
    'channelreplace', 0, ...
    'channelalign',   0)



% % Input files
% sFiles = {...
%     'Subject01/@rawNDARAA075AMK/data_0raw_NDARAA075AMK.mat'};

% Start a new report
bst_report('Start', sFiles);

% Process: Remove linear trend: [0.000s,2700.716s]
sFiles = bst_process('CallProcess', 'process_detrend', sFiles, [], ...
    'timewindow',  [0, 2700.716], ...
    'sensortypes', 'MEG, EEG', ...
    'read_all',    0);

% Process: DC offset correction: [0.000s,2700.716s]
sFiles = bst_process('CallProcess', 'process_baseline', sFiles, [], ...
    'baseline',    [0, 2700.716], ...
    'sensortypes', 'MEG, EEG', ...
    'method',      'bl', ...  % DC offset correction:    x_std = x - &mu;
    'read_all',    0);

% Process: Notch filter: 50Hz 100Hz 150Hz
sFiles = bst_process('CallProcess', 'process_notch', sFiles, [], ...
    'sensortypes', 'MEG, EEG', ...
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
% Process: Import MEG/EEG: Time  RAS
sFiles = bst_process('CallProcess', 'process_import_data_time', sFiles, [], ...
    'subjectname', SubjectNames{1}, ...
    'condition',   '', ...
    'timewindow',  [], ...
    'split',       0, ...
    'ignoreshort', 1, ...
    'usectfcomp',  1, ...
    'usessp',      1, ...
    'freq',        [], ...
    'baseline',    []);
% Read file
 DataMat3 = in_bst_data(sFiles(1).FileName); 

% Process: SSP ECG: cardiac
sFiles = bst_process('CallProcess', 'process_ssp_ecg', sFiles, [], ...
    'eventname',   'cardiac', ...
    'sensortypes', 'EEG', ...
    'usessp',      1, ...
    'select',      1);

% Process: SSP EOG: blink
sFiles = bst_process('CallProcess', 'process_ssp_eog', sFiles, [], ...
    'eventname',   'blink', ...
    'sensortypes', 'EEG', ...
    'usessp',      1, ...
    'select',      1);
% Process: Import MEG/EEG: Time  RAS
sFiles = bst_process('CallProcess', 'process_import_data_time', sFiles, [], ...
    'subjectname', SubjectNames{1}, ...
    'condition',   '', ...
    'timewindow',  [], ...
    'split',       0, ...
    'ignoreshort', 1, ...
    'usectfcomp',  1, ...
    'usessp',      1, ...
    'freq',        [], ...
    'baseline',    []);
% Read file
% DataMat3 = in_bst_data(sFiles(1).FileName); 

% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);
% bst_report('Export', ReportFile, ExportDir);

