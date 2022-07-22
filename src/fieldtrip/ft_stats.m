close all
% clear

nbchan=29;
nbpt=600;
P_Bonf=0.01/nbchan/nbpt;

% % Section 1: Compute the statistical map(channels x time) showing the difference between FieldTrip and paper results in terms of conditional erp

StatDiff=zeros(nbchan,nbpt);

load('All_ERP_ft.mat')
All_ERP2=All_ERP_ft;

load('All_ERP_ref.mat')


All_ERP=All_ERP(:,151:750,:,:);

tt1=squeeze(All_ERP2(1,26,:,:));
tt2=squeeze(All_ERP2(2,26,:,:));

% % remove zeros and nan
idx1 = isnan(tt1) ;
[r1,c1]=find(tt1==0);
[r1,c3]=find(idx1);

% tt1(:,unique(c1))=[];
% tt2(:,unique(c1))=[];

idx2 = isnan(tt2) ;
[r2,c2]=find(tt2==0);
[r1,c4]=find(idx2);

% tt2(:,unique(c2))=[];
% tt1(:,unique(c2))=[];
%
toberemoved=unique([unique(c1) ;unique(c2); unique(c3); unique(c4)]);
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

% %
All_ERP2=All_ERP2(:,:,151:750,kept_ft);



condition_name={'Win','Loss'};

for condition=1:2
    StatDiff=zeros(nbchan,nbpt);

    for channel=1:nbchan
        for t=1:nbpt
            Presults(channel,t)=ranksum(squeeze(All_ERP(channel,t,condition,:)),squeeze(All_ERP2(condition,channel,t,:)));
        if(Presults(channel,t)<P_Bonf)
            StatDiff(channel,t)=1;
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

if(condition==1)
    mymap = [234/255 234/255 234/255
        1 0 0
        0 1 0
        0 0 1
        66/255 66/255 66/255];
        gain_btw(1,4)=length(find(StatDiff));

else
    mymap = [234/255 234/255 234/255
    1 0 0
    0 1 0
    0 0 1
    66/255 66/255 66/255];
    loss_btw(1,4)=length(find(StatDiff));


end
ax(condition)=subplot(2,3,condition);
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

% % Section 2: Plot FCz conditional erps on the same plot
% figure;
t=-200:2:998;

channelOfInterest=26;
Moyenne1_gain=nanmean(squeeze(All_ERP(channelOfInterest,:,1,:)),2);
Moyenne2_gain=nanmean(squeeze(All_ERP2(1,channelOfInterest,:,:)),2);
Moyenne1_loss=nanmean(squeeze(All_ERP(channelOfInterest,:,2,:)),2);
Moyenne2_loss=nanmean(squeeze(All_ERP2(2,channelOfInterest,:,:)),2);
subplot(2,3,4)

plot(t,Moyenne1_gain,'LineWidth',2,'Color',[0.6,0.6,0.6]);
hold on;
plot(t,Moyenne2_gain,'LineWidth',2,'Color',[213,23,0]/255);
title('Grand averaged conditional: gain (FCz)');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
grid
legend('Paper','FieldTrip');

% figure;
subplot(2,3,5)

plot(t,Moyenne1_loss,'LineWidth',2,'Color',[0.6,0.6,0.6]);
hold on;
plot(t,Moyenne2_loss,'LineWidth',2,'Color',[129/255,183/255,216/255]);

title('Grand averaged conditional: loss (FCz)');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
grid
legend('Paper','FieldTrip');


% %  Section 3: Compute the statistical difference between the resulted grand averaged difference

StatDiff=zeros(nbchan,nbpt);
for channel=1:nbchan
        for t=1:nbpt
            Presults(channel,t)=ranksum(squeeze(All_ERP(channel,t,1,:)-All_ERP(channel,t,2,:)),squeeze(All_ERP2(1,channel,t,:)-All_ERP2(2,channel,t,:)));
        if(Presults(channel,t)<P_Bonf)
            StatDiff(channel,t)=1;
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
tt=-200:100:1000;

ax(3)=subplot(2,3,3)
    mymap = [234/255 234/255 234/255
    234/255 234/255 234/255
   234/255 234/255 234/255
    234/255 234/255 234/255
    66/255 66/255 66/255];
diff_btw(1,4)=length(find(StatDiff));

imagesc(StatDiff)
colormap(ax(3),mymap)
xlabels = cellstr(namesChan);  %time labels
ylabels = num2cell(tt);
set(gca, 'YTick', 0.5:28.5, 'YTickLabel', xlabels,'XTick', 0:100:600, 'XTickLabel', ylabels);
xlabel('Time(ms)');
ylabel('Channels');
grid;
title('Grand averaged difference ');
t=-200:2:998;

% % Section 4: Plot FCz grand averaged difference on the same plot

channelOfInterest=26;
% extract the main ERP period from -200 to 1200 ms
diff1=nanmean(squeeze(All_ERP(channelOfInterest,:,1,:)-All_ERP(channelOfInterest,:,2,:)),2);
diff2=nanmean(squeeze(All_ERP2(1,channelOfInterest,:,:)-All_ERP2(2,channelOfInterest,:,:)),2);
subplot(2,3,6)
plot(t,diff1,'LineWidth',2,'Color',[0.6,0.6,0.6]);
hold on;
plot(t,diff2,'LineWidth',2,'Color',[242/255, 125/255,82/255]);
title('Difference between conditions (FCz)');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
grid
legend('Paper','FieldTrip');
