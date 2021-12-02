% EEGLAB history file generated on the 15-Nov-2021
% ------------------------------------------------
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
EEG = pop_importdata('dataformat','matlab','nbchan',128,'data','/home/StageEEGpre/data/NDARAC462DZH_resting/EEG/raw/mat_format/RestingState.mat','setname','eeglabmat1511','srate',512,'pnts',0,'xmin',0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
pop_saveh( ALLCOM, 'E1511.m', '/home/StageEEGpre/results/eeglab/mat files/');
EEG = pop_importdata('dataformat','matlab','nbchan',128,'data','/home/StageEEGpre/data/NDARAC462DZH_resting/EEG/raw/mat_format/RestingState.mat','srate',512,'pnts',0,'xmin',0,'chanlocs','/home/StageEEGpre/data/GSN_HydroCel_129.sfp');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','E15112','gui','off'); 
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/home/StageEEGpre/data/GSN_HydroCel_129.sfp','setref',{'129','Cz'});
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
