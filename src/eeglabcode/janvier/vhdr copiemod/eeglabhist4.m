% EEGLAB history file generated on the 07-Jan-2022
% ------------------------------------------------
EEG = pop_eegfiltnew(EEG, 'locutoff',0.1,'hicutoff',30);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
