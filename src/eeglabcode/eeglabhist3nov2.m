% EEGLAB history file generated on the 03-Nov-2021
% ------------------------------------------------
%2-426 secondes le resting state
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
mydata = load('-mat', '/home/StageEEGpre/data/NDARAA075AMK/EEG/raw/mat_format/RestingState.mat');
myeeg=mydata.EEG.data;
EEG = pop_importdata('dataformat','array','nbchan',0,'data','myeeg','srate',1,'pnts',0,'xmin',0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','NDARAA075AMK3nov2','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','NDARAA075AMK3nov2low','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','NDARAA075AMK3nov2ref','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','NDARAA075AMK3nov2ic','gui','off'); 
EEG = eeg_checkset( EEG );

eeglab redraw;
