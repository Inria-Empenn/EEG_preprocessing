% EEGLAB history file generated on the 03-Nov-2021
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% No history for pop_readegimff
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','EGI file hey','gui','off'); 
pop_saveh( ALLCOM, 'eeglabhisttest.m', '/home/StageEEGpre/src/eeglabcode/');
EEG = eeg_checkset( EEG );
figure; pop_spectopo(EEG, 1, [0  2700716], 'EEG' , 'percent', 50, 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
eeglab redraw;
