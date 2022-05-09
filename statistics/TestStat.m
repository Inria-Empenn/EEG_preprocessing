nbchan=29;
nbpt=600;
P_Bonf=0.01/nbchan/nbpt;

% % Section 1: Compute the statistical map(channels x time) showing the difference between EEGLAB and paper results in terms of conditional erp

StatDiff=zeros(nbchan,nbpt)

% orderEEGlab adjusts the order of channels to be like the one used by
% Williams et al

orderEEglab=[8
22
7
11
21
10
20
3
27
4
28
2
6
25
5
24
26
1
29
15
17
13
18
14
19
12
16
9
23];


load('Ref_All_ERP.mat')
load('eeglab_All_ERP.mat')
All_ERP2=All_ERP_eeglab;

% re-order channs for eeglab erps
All_ERP2=All_ERP2(orderEEglab,151:750,:,:);
All_ERP=All_ERP(:,151:750,:,:);

condition_name={'Win','Loss'};

for condition=1:2
    StatDiff=zeros(nbchan,nbpt)

    for channel=1:nbchan
        for t=1:nbpt
            Presults(channel,t)=ranksum(squeeze(All_ERP(channel,t,condition,:)),squeeze(All_ERP4(channel,t,condition,:)));
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

figure;
imagesc(StatDiff)
xlabels = cellstr(namesChan);  %time labels
ylabels = num2cell(tt);
set(gca, 'YTick', 0.5:28.5, 'YTickLabel', xlabels,'XTick', 0:50:600, 'XTickLabel', ylabels);
xlabel('Time(ms)');
ylabel('Channels');
title([condition_name{condition} ' condition: difference between EEGLAB and the paper']);
end

% % Section 2: Plot FCz conditional erps on the same plot
figure;
t=-200:2:998;

channelOfInterest=26;
% extract the main ERP period from -200 to 1200 ms
Moyenne1=squeeze(nanmean(All_ERP(channelOfInterest,:,:,:),4));
Moyenne2=squeeze(nanmean(All_ERP4(channelOfInterest,:,:,:),4));

plot(t,Moyenne1(:,1),'LineWidth',3);
hold on;
plot(t,Moyenne2(:,1),'LineWidth',3);
title('Grand averaged conditional: gain');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
grid
legend('Paper','EEGLAB');

figure;
plot(t,Moyenne1(:,2),'LineWidth',3);
hold on;
plot(t,Moyenne2(:,2),'LineWidth',3);

title('Grand averaged conditional: loss');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
grid


% %  Section 3: Compute the statistical difference between the resulted grand averaged difference

StatDiff=zeros(nbchan,nbpt)
legend('Paper','EEGLAB');
for channel=1:nbchan
        for t=1:nbpt
            Presults(channel,t)=ranksum(squeeze(All_ERP(channel,t,1,:)-All_ERP(channel,t,2,:)),squeeze(All_ERP4(channel,t,1,:)-All_ERP4(channel,t,2,:)));
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

figure;
imagesc(StatDiff)
xlabels = cellstr(namesChan);  %time labels
ylabels = num2cell(tt);
set(gca, 'YTick', 0.5:28.5, 'YTickLabel', xlabels,'XTick', 0:50:600, 'XTickLabel', ylabels);
xlabel('Time(ms)');
ylabel('Channels');
title('grand averaged difference: difference between EEGLAB and the paper');
t=-200:2:998;

% % Section 4: Plot FCz grand averaged difference on the same plot

channelOfInterest=26;
% extract the main ERP period from -200 to 1200 ms
diff1=nanmean(squeeze(All_ERP(channelOfInterest,:,1,:)-All_ERP(channelOfInterest,:,2,:)),2);
diff2=nanmean(squeeze(All_ERP4(channelOfInterest,:,1,:)-All_ERP4(channelOfInterest,:,2,:)),2);
figure;
plot(t,diff1,'LineWidth',3);
hold on;
plot(t,diff2,'LineWidth',3);
title('difference between conditions');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
grid
legend('Paper','EEGLAB');
