 %load('/udd/nforde/fichiercompare.mat')
size1=41;
size2=921600;
mat0=zeros(size1,size2);
%diff1=icagui4-icascript3
%save fichiercompare.mat diff1
cheminbase='/udd/nforde/Nina/StageEEGpre/data/brainstorm_db/';

cheminsi=strcat(cheminbase,'TutorialEpilepsyScript/data/Subject01/');
chemingi=strcat(cheminbase,'TutorialEpilepsyGui/data/Subject01/');

k=1;
for k=1:2 

if k==1 
    terminaison='tutorial_eeg/data_block001.mat';
elseif k==2
    vari=int2str(k);
    terminaison=strcat('tutorial_eeg/data_block001_0',vari,'.mat');
%else
 %   terminaison='tutorial_eeg_band/data_block001.mat'
    
    
end
chemins=strcat(cheminsi,terminaison);
cheming=strcat(chemingi,terminaison);
%chemins='/udd/nforde/Nina/StageEEGpre/databrainstorm_db/TutorialEpilepsyScript/data/Subject01/tutorial_eeg_band/data_block001_03.mat'
%cheming='/udd/nforde/Nina/StageEEGpre/brainstorm_db/TutorialEpilepsyGui/data/Subject01/tutorial_eeg_band/data_block001_04.mat'
icascript1=load(chemins);
icagui1=load(cheming);



icascript1=icascript1.F;
icagui1=icagui1.F;

diff1=icascript1-icagui1;

%save fichiercompare.mat diff1
%save fichiercompare.mat mat0

 if diff1==mat0 
     disp 'vrai'
     
 else disp 'false'
 end
end