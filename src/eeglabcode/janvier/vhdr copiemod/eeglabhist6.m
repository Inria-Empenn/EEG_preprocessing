% EEGLAB history file generated on the 08-Jan-2022
% ------------------------------------------------
EEG = eeg_checkset( EEG );
EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_subcomp( EEG, [1], 0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'gui','off'); 
pop_saveh( ALLCOM, 'eeglabhist5.m', '/home/nforde/Documents/StageEEGpre/src/eeglabcode/janvier/vhdr copiemod/');
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {  'S110'  'S111'  }, [-1  2], 'newname', 'oneingterpol pruned with ICA epochs', 'valuelim', [-500  1498], 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-200 0] ,[]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'gui','off'); 
eeglab redraw;
