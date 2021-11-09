% EEGLAB history file generated on the 02-Nov-2021
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','eeglab_data.set','filepath','/home/StageEEGpre/data/NDARAA075AMK/EEG/raw/mff_format/NDARAA075AMK');
% No history for pop_readegimff
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','EGI file 2nov 2','gui','off'); 
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite' ,'on','gui','off'); 
EEG = eeg_checkset( EEG );
pop_saveh( EEG.history, 'eeglabhist2nov.m', '/home/StageEEGpre/src/eeglabcode/');
eeglab redraw;
