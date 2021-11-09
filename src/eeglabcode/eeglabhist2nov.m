% EEGLAB history file generated on the 02-Nov-2021
% ------------------------------------------------

EEG.etc.eeglabvers = '2021.1'; % this tracks which version of EEGLAB is being used, you may ignore it
% No history for pop_readegimff
EEG = pop_mffimport({'/home/StageEEGpre/data/NDARAA075AMK/EEG/raw/mff_format/NDARAA075AMK'},{'code'});

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','NDARAA075AMKtest3nov','gui','on'); 
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
EEG = eeg_checkset( EEG );
