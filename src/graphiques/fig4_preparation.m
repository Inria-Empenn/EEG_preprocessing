% % reference results
load('Ref_All_ERP.mat');
[peak_loc_ref, mean_peaks_ref, gain_peaks_ref, lose_peaks_ref, peak_time_ref,base_time_ref,basetopeaks_peaks_ref]=extract_features(All_ERP);

% % bs results
load('All_ERP_BS.mat');
[peak_loc_bs, mean_peaks_bs, gain_peaks_bs, lose_peaks_bs, peak_time_bs,base_time_bs,basetopeaks_peaks_bs]=extract_features(All_ERP_BS);

% % eeglab results
load('All_ERP_eeglab.mat');
[peak_loc_eeglab, mean_peaks_eeglab, gain_peaks_eeglab, lose_peaks_eeglab, peak_time_eeglab,base_time_eeglab,basetopeaks_peaks_eeglab]=extract_features(All_ERP_eeglab);

% % ft results
load('All_ERP_ft.mat');
[peak_loc_ft, mean_peaks_ft, gain_peaks_ft, lose_peaks_ft, peak_time_ft,base_time_ft,basetopeaks_peaks_ft]=extract_features(All_ERP_ft);

% % save results
csvwrite('peak_loc.csv',[peak_loc_ref peak_loc_eeglab peak_loc_bs peak_loc_ft]);
csvwrite('mean_peaks.csv',[mean_peaks_ref mean_peaks_eeglab mean_peaks_bs mean_peaks_ft]);
csvwrite('gain_peaks.csv',[gain_peaks_ref gain_peaks_eeglab gain_peaks_bs gain_peaks_ft]);
csvwrite('lose_peaks.csv',[lose_peaks_ref lose_peaks_eeglab lose_peaks_bs lose_peaks_ft]);
csvwrite('peak_time.csv',[peak_time_ref peak_time_eeglab peak_time_bs peak_time_ft]);
csvwrite('basetopeaks_peaks.csv',[basetopeaks_peak_ref basetopeaks_peak_eeglab basetopeaks_peak_bs basetopeaks_peak_ft]);