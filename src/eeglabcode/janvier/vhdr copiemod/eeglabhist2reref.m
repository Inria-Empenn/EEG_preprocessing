% EEGLAB history file generated on the 06-Jan-2022
% ------------------------------------------------
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'setref',{'1:31','TP10 TP9'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
eeglab redraw;
