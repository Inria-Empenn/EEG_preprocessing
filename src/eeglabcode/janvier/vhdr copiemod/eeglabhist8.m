% EEGLAB history file generated on the 11-Jan-2022
% ------------------------------------------------
eeglab('redraw');
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_iirfilt( EEG, 0.1, 30, [], 1, 0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'gui','off'); 
eeglab redraw;
