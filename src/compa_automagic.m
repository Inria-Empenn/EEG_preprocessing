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


%A80
allgui=load('/tmp/DataResults/dataorigin3_results/A80/allSteps_A80 20170712 0853003.mat');
allscript= load('/tmp/DataResults/commandline_results/A80/allSteps_A80 20170712 0853003.mat');
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

reducedgui=load('/tmp/DataResults/dataorigin3_results/A80/reduced2_A80 20170712 0853003.mat');
reducedscript= load('/tmp/DataResults/commandline_results/A80/reduced2_A80 20170712 0853003.mat');

gui=reducedgui.reduced.data;
script=reducedscript.reduced.data;

diff=gui-script;
diff = diff(~isnan(diff));
mat0=zeros(size(diff));


if diff==mat0 
     disp 'vrai'
     
else disp 'false'
end


 