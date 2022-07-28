function [loss_corr, gain_corr, diff_corr]=similarity_calc(All_ERP11,All_ERP12)

nbchan=29;
nbsubjects=498;
gain_cor=[];
loss_cor=[];
diff_cor=[];

for subject=1:nbsubjects
tt1=squeeze(All_ERP12(1,26,:,subject));
tt2=squeeze(All_ERP11(26,:,1,subject));
if(sum(tt1)*sum(tt2)>0)
    for chan=1:nbchan
            cc=corrcoef(squeeze(All_ERP2(1,chan,:,subject)),squeeze(All_ERP1(chan,:,1,subject)));
            gain_cor(chan,count+1)=cc(1,2);
            
            cc=corrcoef(squeeze(All_ERP2(2,chan,:,subject)),squeeze(All_ERP1(chan,:,2,subject)));
            loss_cor(chan,count+1)=cc(1,2);

            cc=corrcoef(squeeze(All_ERP2(1,chan,:,subject))-squeeze(All_ERP2(2,chan,:,subject)),squeeze(All_ERP1(chan,:,1,subject))-squeeze(All_ERP1(chan,:,2,subject)));
            diff_cor(chan,count+1)=cc(1,2);

    end
end
end

gain_corr=nanmean(gain_cor)';
loss_corr=nanmean(loss_cor)';
diff_corr=nanmean(diff_cor)';

loss_corr = loss_corr(~isnan(loss_corr));
diff_corr = diff_corr(~isnan(diff_corr));
gain_corr = gain_corr(~isnan(gain_corr));