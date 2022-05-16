
% ------------------------------------------------
%

todir='/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1';
cd(todir'); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr')
nb=500;
for participant = 1:nb %Cycle through participants
    
    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    participant_varname = ['set_',participant_number{2}]; %Create new file name
    EEG = pop_loadbv(to dir, filenames(participant).name);
    %ajouter chanlocs
    EEG= pop_chanedit(EEG, 'lookup',[todir '/supportfiles/Standard-10-20-Cap81.ced']);
   save([todir '/set/' participant_varname '.set'],'EEG');
end
