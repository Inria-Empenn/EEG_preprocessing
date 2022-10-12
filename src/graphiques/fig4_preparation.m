cd('../../results');
% % reference results
load('Ref_All_ERP.mat');
All_ERP=All_ERP(:,151:750,:,:);
[peak_loc_ref, mean_peaks_ref, gain_peaks_ref, lose_peaks_ref, peak_time_ref,base_time_ref,basetopeaks_peaks_ref]=ext_features(All_ERP,26);

% % bs results
load('bs_All_ERP_samepipe.mat');
All_ERP=All_ERP_BS;
All_ERP=All_ERP.*1000000; % the unit in BS is in microVolts so it should be transfomed
[peak_loc_bs, mean_peaks_bs, gain_peaks_bs, lose_peaks_bs, peak_time_bs,base_time_bs,basetopeaks_peaks_bs]=ext_features(All_ERP,26);

% % eeglab results
load('EEGLAB_All_ERP_samePipe.mat');
All_ERP=All_ERP(:,151:750,:,:);
[peak_loc_eeglab, mean_peaks_eeglab, gain_peaks_eeglab, lose_peaks_eeglab, peak_time_eeglab,base_time_eeglab,basetopeaks_peaks_eeglab]=ext_features(All_ERP,17);

% % ft results
load('ft_All_ERP_samePipe.mat');
All_ERP_ft=All_ERP(:,:,151:750,:);
   All_ERP=[];
All_ERP(1,:,:,:)=All_ERP_ft(2,:,:,:);
All_ERP(2,:,:,:)=All_ERP_ft(1,:,:,:);
[peak_loc_ft, mean_peaks_ft, gain_peaks_ft, lose_peaks_ft, peak_time_ft,base_time_ft,basetopeaks_peaks_ft]=ext_features(All_ERP,26);

% % save results
csvwrite('peak_loc_samepipe.csv',[peak_loc_ref peak_loc_eeglab peak_loc_bs peak_loc_ft]);
csvwrite('mean_peaks_samepipe.csv',[mean_peaks_ref mean_peaks_eeglab mean_peaks_bs mean_peaks_ft]);
csvwrite('gain_peaks_samepipe.csv',[gain_peaks_ref gain_peaks_eeglab gain_peaks_bs gain_peaks_ft]);
csvwrite('lose_peaks_samepipe.csv',[lose_peaks_ref lose_peaks_eeglab lose_peaks_bs lose_peaks_ft]);
csvwrite('peak_time_samepipe.csv',[peak_time_ref peak_time_eeglab peak_time_bs peak_time_ft]);
csvwrite('basetopeaks_peaks_samepipe.csv',[basetopeaks_peak_ref basetopeaks_peak_eeglab basetopeaks_peak_bs basetopeaks_peak_ft]);