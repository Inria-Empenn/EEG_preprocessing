close all
% clear
nbchan=29;
nbpt=600;

% % Section 1: Compute the statistical map(channels x time) showing the difference between FieldTrip and paper results in terms of conditional erp
load('results/Ref_All_ERP.mat')
All_ERP1=All_ERP;
load('results/eeglab_All_ERP_samePipe.mat')
All_ERP2=All_ERP;
All_ERP1=All_ERP1(:,151:750,:,:);
All_ERP2=All_ERP2(:,151:750,:,:);

condition_name={'Win','Loss','Difference'};
matp=zeros(29,600,3);
for cond=1:3 
    for ch=1:29
        ch
        if(cond==3)
            x1=squeeze(All_ERP1(ch,:,1,:))-squeeze(All_ERP1(ch,:,2,:));
            x2=squeeze(All_ERP2(ch,:,1,:))-squeeze(All_ERP2(ch,:,2,:));
        else
          x1=squeeze(All_ERP1(ch,:,cond,:));
          x2=squeeze(All_ERP2(ch,:,cond,:));
        end

        [clusters, p_values, t_sums, permutation_distribution ] = permutest(x1,x2,false,0.005,10000,true);
        
        for cl=1:length(clusters)
            if(p_values(cl)<0.005)
                significant_samples=clusters{cl};
                matp(ch,clusters{cl},cond)=1;
            end
        end
    end
end

namesChan={'Fp1'
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
'Fp2'};


timeToPlot=-200:2:1000;
tt=-200:200:1000;

        mymap = [234/255 234/255 234/255
        1 0 0
        0 1 0
        0 0 1
        66/255 66/255 66/255];

for condition=1:3
    StatDiff=matp(:,:,condition);
    ax(condition)=subplot(1,3,condition);
    imagesc(StatDiff)
    colormap(ax(condition),mymap)
    xlabels = cellstr(namesChan);  %time labels
    ylabels = num2cell(tt);
    set(gca, 'YTick', 0.5:28.5, 'YTickLabel', xlabels,'XTick', 0:100:600, 'XTickLabel', ylabels);
    grid
    xlabel('Time(ms)');
    ylabel('Channels');
    title([condition_name{condition} ' condition']);
end
save('matp_eeglab','matp');