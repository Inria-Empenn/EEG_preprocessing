
%compa
%init
% ordre generation fichiers dans allstep:
% 1/ EEGorig
% 2/ EEGPrep
% 3/ EEGFiltered
% 4/ EEG Regressed
% 5/ highvaried
% 6/min varied
% 7/ EEG Final
% 
% 8/Regressed


allgui=load('/home/Data/NDARAC462DZH_resting/EEG/raw_guihbn3_results/mat_format/allSteps_RestingState.mat');
allscript= load('/home/Data/NDARAC462DZH_resting/EEG/results_script/mat_format/allSteps_RestingState.mat');
DataField = fieldnames(allgui);

%guifinal=allgui.(DataField{1}).data;
 
for k=1:7

%tmp2=allgui.(DataField{k}).data;
allgui2=allgui.(DataField{k}).data;
allscript2=allscript.(DataField{k}).data;


diff=allgui2-allscript2;
diff = diff(~isnan(diff));
mat0=zeros(size(diff));

if diff==mat0 
     disp 'vrai'
     
else disp 'false'
    [I_row, I_col] = ind2sub(size(diff),I)
end

end

disp 'reduced data now : '

reducedgui=load('/home/Data/NDARAC462DZH_resting/EEG/raw_guihbn3_results/mat_format/reduced2_RestingState.mat');
reducedscript= load('/home/Data/NDARAC462DZH_resting/EEG/results_script/mat_format/reduced2_RestingState.mat');

gui=reducedgui.reduced.data;
script=reducedscript.reduced.data;

diff=gui-script;
diff = diff(~isnan(diff));
mat0=zeros(size(diff));


if diff==mat0 
     disp 'vrai'
     
else disp 'false'
end


 