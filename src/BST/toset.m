% EEGLAB history file generated on the 04-Jan-2022
% ------------------------------------------------
% 
cd('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1'); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr')
nb=500;
for participant = 1:nb %Cycle through participants
    
    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    participant_varname = ['set_',participant_number{2}]; %Create new file name
    EEG = pop_loadbv('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/', filenames(participant).name);
    %ajouter chanlocs
    EEG= pop_chanedit(EEG, 'lookup','/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/eeglab2021.1/functions/supportfiles/Standard-10-20-Cap81.ced');
    save(['/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/set/' participant_varname '.set'],'EEG');
end