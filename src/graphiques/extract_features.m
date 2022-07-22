function [peak_loc, mean_peaks, gain_peaks, lose_peaks, peak_time,base_time,basetopeaks_peaks]=extract_features(All_ERP)

[~,peak_loc] = max(squeeze(All_ERP(1,26,226:276,:))-squeeze(All_ERP(2,26,226:276,:))); %Determine where the peak amplitude is for each participant. Electrode 26 is FCz.
peak_loc = (((peak_loc+225)*2)-200)/1000; %Convert into seconds
peak_loc=peak_loc';
dataDW=nanmean(squeeze(All_ERP(1,26,:,:)),2)-nanmean(squeeze(All_ERP(2,26,:,:)),2)
p_diffdata=tKept1-tKept2; 
p_diffdata=p_diffdata';
tKept1=tKept1';
tKept2=tKept2';

peak_time = find(dataDW==max(dataDW));
peak_time=peak_time(1);
base_time = find(dataDW(188:226)==min(dataDW(188:226)))+187;

mean_peaks = mean(p_diffdata(:,peak_time-23:peak_time+23),2);
gain_peaks = mean(tKept1(:,239-23:239+23),2);
lose_peaks = mean(tKept2(:,246-23:246+23),2);

max_peaks = max(p_diffdata(:,200:300)');
max_peaks=max_peaks';
basetopeaks_peaks = max(p_diffdata(:,200:300)') - max(p_diffdata(:,175:225)');
base_peaks =  min(p_diffdata(:,175:225)');
basetopeaks_peaks=basetopeaks_peaks';
