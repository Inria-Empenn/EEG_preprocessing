cd('/Users/ayakabbara/Desktop/projects/EEG_PreProcessing/Raw Data Part 1/set'); %Find and change working folder to raw EEG data

for participant = 1:500 %Cycle through participants
    
    disp(['Participant: ', num2str(participant)]) %Display current participant being processed
    participant_number = strsplit(filenames(participant).name(1:end-5),'_'); %Split filename into components
    SubjectName = ['Subject' participant_number{2}];
    mkdir(SubjectName);
    filename=['set_' participant_number{2} '.set'];
    movefile(filename,SubjectName);
end