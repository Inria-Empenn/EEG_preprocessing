% % ERP + Diff
% % channelof interest is FCz : 
% % =26 as resulted by the paper's code
% % =17 as resulted by EEGLAB


channelOfInterest=34; 
t=-200:2:998;

figure;
subplot(2,1,1)
% % extract the main ERP period from -200 to 1200 ms
Moyenne=squeeze(nanmean(All_ERP(channelOfInterest,151:750,:,:),4));
Diff=nanmean(squeeze(All_ERP(channelOfInterest,151:750,1,:)),2)-nanmean(squeeze(All_ERP(channelOfInterest,151:750,2,:)),2); %Export data. Conditions: Time, Loss, Win, Difference. Electrode 26 is FCz.
plot(t,Moyenne(:,1),'LineWidth',3);
hold on;
plot(t,Moyenne(:,2),'LineWidth',3);
hold off;
title('Grand averaged conditional');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
legend('Win','Loss');
axis tight
grid
% % plot the difference between the two ERP conditions
subplot(2,1,2)
plot(t,Diff,'LineWidth',3);
title('Grand averaged difference');
ylabel('Voltage (uV)');
xlabel('Time (ms)');
axis tight
grid

x=squeeze(All_ERP(channelOfInterest,151:750,:,:));
SEM = nanstd(x,0,3)/sqrt(size(x,3));               % Standard Error
ts = tinv([0.025  0.975],length(x)-1);      % T-Score
CI_min = nanmean(x,3) + ts(1)*SEM;   
CI_max = nanmean(x,3) + ts(2)*SEM;

figure
plot(t(:),CI_min(:,1),'r'); 
hold on;
plot(t(:),(CI_max(:,1)),'r');
patch([t(:); flipud(t(:))],[CI_min(:,1); flipud(CI_max(:,1))], 'r', 'FaceAlpha',0.2, 'EdgeColor','none');
plot(t(:), nanmean(x(:,1,:),3), 'r')

plot(t(:),CI_min(:,2),'b'); 
hold on;
plot(t(:),(CI_max(:,2)),'b')
patch([t(:); flipud(t(:))],[CI_min(:,2); flipud(CI_max(:,2))], 'b', 'FaceAlpha',0.2, 'EdgeColor','none');
plot(t(:), nanmean(x(:,2,:),3), 'b')

% hold ofb
% % % % change t for the other variables..
% % t=-500:2:1298;
% % 
% % figure
% % % Topography
% % subplot(2,4,1)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==-100),1,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Loss at -100ms');
% % 
% % subplot(2,4,2)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==100),1,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Loss at 100ms');
% % 
% % subplot(2,4,3)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==300),1,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Loss at 300ms');
% % 
% % subplot(2,4,4)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==400),1,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Loss at 400ms');
% % 
% % 
% % subplot(2,4,5)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==-100),2,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Win at -100ms');
% % 
% % subplot(2,4,6)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==100),2,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Win at 100ms');
% % 
% % subplot(2,4,7)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==300),2,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Win at 300ms');
% % 
% % subplot(2,4,8)
% % % 
% % topoplot(nanmean(squeeze(All_ERP(:,find(t==400),2,:)),2),EEG.chanlocs,'electrodes','labels')
% % title('Win at 400ms');