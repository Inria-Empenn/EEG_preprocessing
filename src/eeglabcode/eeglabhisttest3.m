% EEGLAB history file generated on the 03-Nov-2021
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
eeglab('redraw');
EEG = pop_mffimport({'/home/StageEEGpre/data/NDARAA075AMK/EEG/raw/mff_format/NDARAA075AMK'},{'code'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','NDARAA075AMKtest3nov','gui','off'); 
EEG = eeg_checkset( EEG );
figure; pop_spectopo(EEG, 1, [0  2700716], 'EEG' , 'percent', 50, 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
eeglab redraw;
