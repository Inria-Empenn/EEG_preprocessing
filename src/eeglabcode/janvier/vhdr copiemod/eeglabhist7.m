% EEGLAB history file generated on the 11-Jan-2022
% ------------------------------------------------
EEG = eeg_checkset( EEG );
EEG = pop_eegthresh(EEG,1,[1:31] ,-50,50,-1,1.998,0,0);
eeglab redraw;
