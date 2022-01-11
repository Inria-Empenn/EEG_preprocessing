% EEGLAB history file generated on the 07-Jan-2022
% ------------------------------------------------
EEG = eeg_checkset( EEG );
EEG = pop_interp(EEG, EEG.chaninfo.nodatchans([1  2]), 'spherical');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','oneingterpol','gui','off'); 
eeglab redraw;
