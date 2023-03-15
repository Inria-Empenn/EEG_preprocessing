% %  code to save .set file for each vhdr file
% % Contact: aya.kabbara7@gmail.com

cd('/Raw Data Part 1'); %Find and change working folder to raw EEG data
filenames = dir('*.vhdr')
nb=500;
for participant = 1:nb %Cycle through participants
    
    %Get participant name information
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    participant_varname = ['set_',participant_number{2}]; %Create new file name
    EEG = pop_loadbv('/Raw Data Part 1/', filenames(participant).name);
    %add chanloc file
    EEG= pop_chanedit(EEG, 'lookup','/eeglab2021.1/functions/supportfiles/Standard-10-20-Cap81.ced');

    EEG = pop_select(EEG, 'channel',{'Fp1'
            'Fz'
            'F3'
            'F7'
            'FC5'
            'FC1'
            'Cz'
            'C3'
            'T7'
            'CP5'
            'CP1'
            'Pz'
            'P3'
            'P7'
            'O1'
            'POz'
            'O2'
            'P4'
            'P8'
            'CP6'
            'CP2'
            'C4'
            'T8'
            'FC6'
            'FC2'
            'FCz'
            'F4'
            'F8'
            'Fp2'
            'TP10'
            'TP9'});
    end

    save(['/data/set/' participant_varname '.set'],'EEG');


end
