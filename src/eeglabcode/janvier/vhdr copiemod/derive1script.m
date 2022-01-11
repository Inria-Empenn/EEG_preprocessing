% EEGLAB history file generated on the 04-Jan-2022
% ------------------------------------------------
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
eeglab('redraw');
EEG = pop_loadbv('/home/nforde/Documents/StageEEGpre/data/Raw Data Part 1/', 'RewardProcessing_001.vhdr', [1 336262], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','one','gui','off'); 
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/home/nforde/Documents/StageEEGpre/dependencies/eeglab_current/eeglab2021.1/functions/supportfiles/Standard-10-20-Cap81.ced');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%%remove channels 
%% 
%Re-Reference
    load('ChanlocsMaster.mat'); %Load channel location file, please make sure the location of this file is in your path
    chanlocsMaster([10,21]) = []; %R
eeglab redraw;
