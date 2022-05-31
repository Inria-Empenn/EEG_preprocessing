channelOfInterest=26; 

All_ERP_ft=All_ERP_ft(:,:,151:750,:);
% %% RewP_Waveforms_AllPs      
tt1=squeeze(All_ERP_ft(1,26,:,:));
tt2=squeeze(All_ERP_ft(2,26,:,:));

idx1 = isnan(tt1) ;
[r1,c1]=find(tt1==0);
% tt1(:,unique(c1))=[];
% tt2(:,unique(c1))=[];

idx2 = isnan(tt2) ;
[r2,c2]=find(tt2==0);
% tt2(:,unique(c2))=[];
% tt1(:,unique(c2))=[];
toberemoved=unique([unique(c1) ;unique(c2)]);
tKept1=[];tKept2=[];
kept_ft=[];
for su=1:500
     if(length(find(toberemoved==su))==0)
% %         the subject su is present
            kept_ft(end+1)=su;
            tKept1(:,end+1)=tt1(:,su);
            tKept2(:,end+1)=tt2(:,su);

    end
end

csvwrite('ft_RewP_Waveforms_final22.csv',[(-200:2:998)',nanmean(squeeze(All_ERP_ft(1,26,:,kept_ft)),2),nanmean(squeeze(All_ERP_ft(2,26,:,kept_ft)),2),nanmean(squeeze(All_ERP_ft(1,26,:,kept_ft)),2)-nanmean(squeeze(All_ERP_ft(2,26,:,kept_ft)),2)]); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.

csvwrite('ft_RewP_Waveforms_AllPs_final22.csv',[tKept1,tKept2]'); %Export data. Conditions: Loss, Win. Electrode 26 is FCz.
% %% RewP_Latency 

[~,peak_loc] = max(squeeze(All_ERP_ft(1,26,226:276,kept_ft))-squeeze(All_ERP_ft(2,26,226:276,kept_ft))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
csvwrite('ft_RewP_Latency_final22.csv',peak_loc'); %Export data
