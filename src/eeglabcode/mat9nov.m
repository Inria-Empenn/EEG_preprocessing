% EEGLAB history file generated on the 09-Nov-2021
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
mydata = load('-mat', '/home/StageEEGpre/data/NDARAA075AMK/EEG/raw/mat_format/RestingState.mat');
myeeg=mydata.EEG.data;
EEG = pop_importdata('dataformat','array','nbchan',0,'data','myeeg','srate',1,'pnts',0,'xmin',0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','matnov9','gui','off'); 
EEG = eeg_checkset( EEG );
eeglab redraw;
