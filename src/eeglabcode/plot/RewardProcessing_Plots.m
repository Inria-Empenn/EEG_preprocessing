%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Written by Chad C. Williams, PhD student in the Krigolson Lab, 2019   %%
%%University of Victoria, British Columbia, Canada                      %%
%%www.krigolsonlab.com                                                  %%
%%www.chadcwilliams.com                                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup environment                                                
clearvars -except All_WAV; clc; close all; %Clean environment
cd(uigetdir); %Select directory

load('All_ERP.mat'); %Load ERP data
load('All_FFT.mat'); %Load FFT data
load('ChanlocsMaster.mat'); %Load channel locations
%% Figure 1 Data
%%   Figure 1 Plots                                                 
ax = subplot_tight(1,1,1); %Create subplot to control x and y axes
topoplot([],chanlocsMaster,'style','blank','electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot electrodes on montage
xlim(ax,[-.6 .6]);ylim(ax,[-.6 .6]); %Determine x and y axis limits
%%   Saving Figure 1                                                
print(gcf,'Figure 1 - Montage.jpeg','-djpeg','-r600'); %Save plot
close all %Close window for next plot
%% Figure 5 Data                                                    
%Normal topographic maps
topo = mean(squeeze(All_ERP(:,255-23:255+23,1,:)-All_ERP(:,255-23:255+23,2,:)),[2,3]); %Average data across each electrodes for difference plot
win_topo = mean(squeeze(All_ERP(:,239-23:239+23,1,:)),[2,3]); %Average data across each electrodes for condition 1
lose_topo = mean(squeeze(All_ERP(:,246-23:246+23,2,:)),[2,3]);%Average data across each electrodes for condition 2

%Percent of participants with max peak at each electrode
for electrode = 1:30 %Cycle through through electrodes
    diff_wave = squeeze(All_ERP(electrode,:,1,:)-All_ERP(electrode,:,2,:)); %Create difference wave of current electrode
    win_wave = squeeze(All_ERP(electrode,:,1,:)); %Extract condition 1 wave of current electrode
    lose_wave = squeeze(All_ERP(electrode,:,2,:)); %Extract condition 2 wave of current electrode
    mean_peaks(:,electrode) = mean(diff_wave(255-23:255+23,:))'; %Average data around peak for difference wave of current electrode. 264 - 356 ms.
    win_peaks(:,electrode) = mean(win_wave(239-23:239+23,:))'; %Average data around peak for condition 1 of current electrode. 232 - 324 ms.
    lose_peaks(:,electrode) = mean(lose_wave(246-23:246+23,:))'; %Average data around peak for condition 2 of current electrode. 246 - 338 ms.
end

[~, topoloc] = max(mean_peaks,[],2); %Determine which electrodes was location of peak for difference wave
[~, wintopoloc] = max(win_peaks,[],2); %Determine which electrodes was location of peak for condition 1
[~, losetopoloc] = max(lose_peaks,[],2); %Determine which electrodes was location of peak for condition 2

topomax = zeros(500,30); %Create empty variable to count number of peaks for each electrode for difference wave
win_topomax = zeros(500,12); %Create empty variable to count number of peaks for each electrode for condition 1
lose_topomax = zeros(500,12); %Create empty variable to count number of peaks for each electrode for condition 2
for counter = 1:length(topoloc) %Cycle through participants
    topomax(counter,topoloc(counter)) = 1; %Signify where the peak was for current participant for difference wave
    win_topomax(counter,wintopoloc(counter)) = 1; %Signify where the peak was for current participant for condition 1
    lose_topomax(counter,losetopoloc(counter)) = 1; %Signify where the peak was for current participant for condition 2
end

label = round((sum(topomax)/500)*100); %Determine percetange that each electrode had a max peak for difference wave
win_label = round((sum(win_topomax)/500)*100); %Determine percetange that each electrode had a max peak for condition 1
lose_label = round((sum(lose_topomax)/500)*100); %Determine percetange that each electrode had a max peak for condition 2

maxchans = chanlocsMaster; %Reallocate the electrode channel list for modification
win_maxchans = chanlocsMaster; %Reallocate the electrode channel list for modification
lose_maxchans = chanlocsMaster; %Reallocate the electrode channel list for modification
for counter = 1:length(sum(topomax)) %Cycle through electrodes 
    maxchans(counter).labels = [num2str(label(counter)),'%']; %Create labels indicating percent of peaks rather than electrode name for difference wave
    win_maxchans(counter).labels = [num2str(win_label(counter)),'%']; %Create labels indicating percent of peaks rather than electrode name for condition 1
    lose_maxchans(counter).labels = [num2str(lose_label(counter)),'%']; %Create labels indicating percent of peaks rather than electrode name for condition 2
end
%%   Figure 5 Plots                                                 
figure('position',[0 0 1200 800]) %Setup plot
ax1 = subplot_tight(2,3,1); %Figure 5A
topoplot(topo,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',30,'headcolor',[.7 .7 .7]); %Plot topographic map
caxis([0 4]); %Set colour limits
ax2 = subplot_tight(2,3,2); %Figure 5B
topoplot(win_topo,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',30,'headcolor',[.7 .7 .7]); %Plot topographic map
caxis([0 9]);  %Set colour limits
ax3 = subplot_tight(2,3,3); %Figure 5C
topoplot(lose_topo,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',30,'headcolor',[.7 .7 .7]); %Plot topographic map
caxis([0 6]); %Set colour limits
ax4 = subplot_tight(2,3,4); %Figure 5D
topoplot(sum(topomax),maxchans,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax5 = subplot_tight(2,3,5); %Figure 5E
topoplot(sum(win_topomax),win_maxchans,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax6 = subplot_tight(2,3,6); %Figure 5F
topoplot(sum(lose_topomax),lose_maxchans,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
set(gcf,'color','w'); %Set background colour
xlim(ax1,[-.6 .6]);ylim(ax1,[-.6 .6]); %Set x and y axis limits
xlim(ax2,[-.6 .6]);ylim(ax2,[-.6 .6]); %Set x and y axis limits
xlim(ax3,[-.6 .6]);ylim(ax3,[-.6 .6]); %Set x and y axis limits
xlim(ax4,[-.6 .6]);ylim(ax4,[-.6 .6]); %Set x and y axis limits
xlim(ax5,[-.6 .6]);ylim(ax5,[-.6 .6]); %Set x and y axis limits
xlim(ax6,[-.6 .6]);ylim(ax6,[-.6 .6]); %Set x and y axis limits
colormap(flipud(cbrewer2('div','RdBu',9))); %Determine graph colour
%%   Saving Figure 5                                                
print(gcf,'Figure 5 - ERP Topoplot.jpeg','-djpeg','-r600'); %Save plot
close all %Close window for next plot
%% Figure 9 Data                                                    
%Normal topographic maps
topo_FFT_delta = mean(squeeze(All_FFT(:,1:2,1,:)-All_FFT(:,1:2,2,:)),[2,3]); %Average delta data across each electrodes for difference plot
topo_FFT_theta = mean(squeeze(All_FFT(:,3:7,1,:)-All_FFT(:,3:7,2,:)),[2,3]); %Average theta data across each electrodes for difference plot
gain_topo_FFT_delta = mean(squeeze(All_FFT(:,1:2,1,:)),[2,3]); %Average delta data across each electrodes for condition 1
loss_topo_FFT_theta = mean(squeeze(All_FFT(:,3:7,2,:)),[2,3]); %Average theta data across each electrodes for condition 2

%Percent of participants with max peak at each electrode
for electrode = 1:30 %Cycle through through electrodes
    diff_FFT = squeeze(All_FFT(electrode,:,1,:)-All_FFT(electrode,:,2,:)); %Create difference wave of current electrode
    gain_FFT = squeeze(All_FFT(electrode,:,1,:)); %Extract condition 1 wave of current electrode
    loss_FFT = squeeze(All_FFT(electrode,:,2,:)); %Extract condition 2 wave of current electrode
    mean_peaks_fft(:,electrode,1) = mean(diff_FFT(1:2,:))'; %Average delta data for difference wave of current electrode
    mean_peaks_fft(:,electrode,2) = mean(diff_FFT(3:7,:))'; %Average theta data for difference wave of current electrode
    gainloss_mean_peaks_fft(:,electrode,1) = mean(gain_FFT(1:2,:))'; %Average delta data for condition 1 of current electrode
    gainloss_mean_peaks_fft(:,electrode,2) = mean(loss_FFT(3:7,:))'; %Average theta data for condition 2 of current electrode
end

[~, topoloc_FFT_delta] = max(squeeze(mean_peaks_fft(:,:,1)),[],2); %Determine which electrodes was location of delta max for difference wave
[~, topoloc_FFT_theta] = min(squeeze(mean_peaks_fft(:,:,2)),[],2); %Determine which electrodes was location of theta max for difference wave
[~, gain_topoloc_FFT_delta] = max(squeeze(gainloss_mean_peaks_fft(:,:,1)),[],2); %Determine which electrodes was location of delta peak for condition 1
[~, loss_topoloc_FFT_theta] = max(squeeze(gainloss_mean_peaks_fft(:,:,2)),[],2); %Determine which electrodes was location of theta peak for condition 2

topomax_FFT_delta = zeros(500,30); %Create empty variable to count number of peaks for each electrode for difference wave
topomax_FFT_theta = zeros(500,30); %Create empty variable to count number of peaks for each electrode for difference wave
gain_topomax_FFT_delta = zeros(500,30); %Create empty variable to count number of peaks for each electrode for condition 1
loss_topomax_FFT_theta = zeros(500,30);  %Create empty variable to count number of peaks for each electrode for condition 2
for counter = 1:length(topoloc_FFT_delta) %Cycle through participants
    topomax_FFT_delta(counter,topoloc_FFT_delta(counter)) = 1; %Signify where the delta peak was for current participant for difference wave
    topomax_FFT_theta(counter,topoloc_FFT_theta(counter)) = 1; %Signify where the theta peak was for current participant for difference wave
    gain_topomax_FFT_delta(counter,gain_topoloc_FFT_delta(counter)) = 1; %Signify where the delta peak was for current participant for condition 1
    loss_topomax_FFT_theta(counter,loss_topoloc_FFT_theta(counter)) = 1; %Signify where the theta peak was for current participant for condition 2
end

label_FFT_delta = round((sum(topomax_FFT_delta)/500)*100); %Determine percetange that each electrode had a max delta peak for difference wave
label_FFT_theta = round((sum(topomax_FFT_theta)/500)*100); %Determine percetange that each electrode had a max theta peak for difference wave
gain_label_FFT_delta = round((sum(gain_topomax_FFT_delta)/500)*100); %Determine percetange that each electrode had a max delta peak for condition 1
loss_label_FFT_theta = round((sum(loss_topomax_FFT_theta)/500)*100); %Determine percetange that each electrode had a max theta peak for condition 2

maxchans_FFT_delta = chanlocsMaster; %Reallocate the electrode channel list for modification
maxchans_FFT_theta = chanlocsMaster; %Reallocate the electrode channel list for modification
gain_maxchans_FFT_delta = chanlocsMaster; %Reallocate the electrode channel list for modification
loss_maxchans_FFT_theta = chanlocsMaster; %Reallocate the electrode channel list for modification
for counter = 1:length(sum(topomax_FFT_delta)) %Cycle through electrodes
    maxchans_FFT_delta(counter).labels = [num2str(label_FFT_delta(counter)),'%']; %Create labels indicating percent of delta peaks rather than electrode name for difference wave
    maxchans_FFT_theta(counter).labels = [num2str(label_FFT_theta(counter)),'%']; %Create labels indicating percent of theta peaks rather than electrode name for difference wave
    gain_maxchans_FFT_delta(counter).labels = [num2str(gain_label_FFT_delta(counter)),'%']; %Create labels indicating percent of delta peaks rather than electrode name for condition 1
    loss_maxchans_FFT_theta(counter).labels = [num2str(loss_label_FFT_theta(counter)),'%']; %Create labels indicating percent of theta peaks rather than electrode name for condition 2
end
%%   Figure 9 Plots                                                 
figure('position',[0 0 1200 700]) %Create figure
marg = .005; %Set smaller margins
ax1 = subplot_tight(2,4,1,[marg, marg]); %Figure 9A
topoplot(topo_FFT_delta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
caxis([-1 1]);  %Set colour limits
ax2 = subplot_tight(2,4,2,[marg, marg]); %Figure 9B
topoplot(topo_FFT_theta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
caxis([-.7 .7]);  %Set colour limits
ax3 = subplot_tight(2,4,3,[marg, marg]); %Figure 9C
topoplot(gain_topo_FFT_delta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
ax4 = subplot_tight(2,4,4,[marg, marg]); %Figure 9D
topoplot(loss_topo_FFT_theta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
ax5 = subplot_tight(2,4,5,[marg, marg]); %Figure 9E
topoplot(sum(topomax_FFT_delta),maxchans_FFT_delta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax6 = subplot_tight(2,4,6,[marg, marg]); %Figure 9F
topoplot(sum(topomax_FFT_theta*-1),maxchans_FFT_theta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax7 = subplot_tight(2,4,7,[marg, marg]); %Figure 9G
topoplot(sum(gain_topomax_FFT_delta),gain_maxchans_FFT_delta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax8 = subplot_tight(2,4,8,[marg, marg]); %Figure 9H
topoplot(sum(loss_topomax_FFT_theta),loss_maxchans_FFT_theta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map

set(gcf,'color','w'); %Set background to white
xlim(ax1,[-.6 .6]);ylim(ax1,[-.6 .6]); %Set x and y axis limits
xlim(ax2,[-.6 .6]);ylim(ax2,[-.6 .6]); %Set x and y axis limits
xlim(ax3,[-.6 .6]);ylim(ax3,[-.6 .6]); %Set x and y axis limits
xlim(ax4,[-.6 .6]);ylim(ax4,[-.6 .6]); %Set x and y axis limits
xlim(ax5,[-.6 .6]);ylim(ax5,[-.6 .6]); %Set x and y axis limits
xlim(ax6,[-.6 .6]);ylim(ax6,[-.6 .6]); %Set x and y axis limits
xlim(ax7,[-.6 .6]);ylim(ax7,[-.6 .6]); %Set x and y axis limits
xlim(ax8,[-.6 .6]);ylim(ax8,[-.6 .6]); %Set x and y axis limits
colormap(flipud(cbrewer2('div','RdBu',9))); %Set colours of graph
%%   Saving Figure 9                                                
print(gcf,'Figure 9 - FFT Topoplot.jpeg','-djpeg','-r600'); %Save figure
close all %Close window for next plot
%% Figure 10 Data                                                    
WAV_data1 = permute(squeeze(All_WAV(26,:,151:750,1,:)),[3,1,2]); %Extract participants time-frequency condition 1
WAV_data2 = permute(squeeze(All_WAV(26,:,151:750,2,:)),[3,1,2]); %Extract participants time-frequency condition 2
WAV_diff = squeeze(mean(WAV_data1-WAV_data2)); %Extract grand averaged time-frequency difference
delta_extract=zeros(30,600); %Create empty matrix for delta extraction
delta_extract(1:2,:)=(squeeze(mean(All_WAV(26,1:2,151:750,:,:),[4,5])))>5.5; %Determine delta effect via the collapsed localizer method with a power threshhold of 5.5
theta_extract=zeros(30,600); %Create empty matrix for theta extraction
theta_extract(3:10,:)=(squeeze(mean(All_WAV(26,3:10,151:750,:,:),[4,5])))>5.5; %Determine theta effect via the collapsed localizer method with a power threshhold of 5.5
delta_contour = delta_extract; %Extract data for contour lines in plots
theta_contour = theta_extract; %Extract data for contour lines in plots
theta_extract(8:20,:) = 0; %Remove non-theta activity
both_extract = (delta_extract+theta_extract>0); %Determine all effects via the collapsed localizer method 
both_extract = both_extract(1:20,:); %Reduce to frequencies 1 to 20

%%   Figure 10 Plots                                                 
marginsx = .05; %Determine subplot margins
marginsy = .07; %Determine subplot margins

figure('position',[0 0 1440 960]) %Create figure
subplot_tight(2,2,1,[marginsx,marginsy]) %Figure 10A
pcolor(squeeze(mean(WAV_data1))); %Plot wavelet
shading interp; %Remove cell borders
set(gca, 'YTick', 1:20, 'YTickLabel', 1:20); %Determine y tick labels
set(gca, 'XTick', [1,50:50:550,599], 'XTickLabel', {'-200','-100','0','100','200','300','400','500','600','700','800','900','1000'}); %Determine x tick labels
caxis([0 10]); %Determine colour scale
ylim([1,20]); %Determine y axis limits
ylabel('Frequency (Hz)'); xlabel('Time (ms)'); %Determine x and y labels
colormap(flipud(cbrewer2('div','RdBu',9))); %Determine colourmap
colorbar %Show colourbar
ax = gca; %Extract fplit properties
ax.FontSize = 12; %Determine font size
set(gca,'Box','off') %Remove plot border
xline(1) %Insert y-axis line
title('A                                                                                                                                                             '); %Insert figure indicator and very sloppily left justify it

subplot_tight(2,2,2,[marginsx,marginsy]) %Figure 10B
pcolor(squeeze(mean(WAV_data2))); %Plot wavelet
shading interp; %Remove cell borders
set(gca, 'YTick', 1:20, 'YTickLabel', 1:20); %Determine y tick labels
set(gca, 'XTick', [1,50:50:550,599], 'XTickLabel', {'-200','-100','0','100','200','300','400','500','600','700','800','900','1000'}); %Determine x tick labels
caxis([0 10]); %Determine colour scale
ylim([1,20]);  %Determine y axis limits
ylabel('Frequency (Hz)'); xlabel('Time (ms)'); %Determine x and y labels
colormap(flipud(cbrewer2('div','RdBu',9))); %Determine colourmap
colorbar %Show colourbar
ax = gca; %Extract fplit properties
ax.FontSize = 12; %Determine font size
set(gca,'Box','off') %Remove plot border
xline(1) %Insert y-axis line
title('B                                                                                                                                                             '); %Insert figure indicator and very sloppily left justify it

subplot_tight(2,2,3,[marginsx,marginsy]) %Figure 10C
pcolor(squeeze(mean(All_WAV(26,:,151:751,:,:),[4,5]))); %Plot wavelet
shading interp; %Remove cell borders
set(gca, 'YTick', 1:20, 'YTickLabel', 1:20);  %Determine y tick labels
set(gca, 'XTick', [1,50:50:550,599], 'XTickLabel', {'-200','-100','0','100','200','300','400','500','600','700','800','900','1000'}); %Determine x tick labels
caxis([0 8]); %Determine colour scale
ylim([1,20]);   %Determine y axis limits
ylabel('Frequency (Hz)'); xlabel('Time (ms)'); %Determine x and y labels
hold on; contour(delta_contour,1,'black','linewidth',1); %Add Delta contour line
hold on; contour(theta_contour,1,'black','linewidth',1); %Add Theta contour line
colormap(flipud(cbrewer2('div','RdBu',9))); %Determine colourmap
colorbar; %Show colourbar
ax = gca; %Extract fplit properties
ax.FontSize = 12; %Determine font size
set(gca,'Box','off') %Remove plot border
xline(1) %Insert y-axis line
title('C                                                                                                                                                             '); %Insert figure indicator and very sloppily left justify it

subplot_tight(2,2,4,[marginsx,marginsy]) %Figure 10D
pcolor(WAV_diff); %Plot wavelet
shading interp; %Remove cell borders
set(gca, 'YTick', 1:20, 'YTickLabel', 1:20);  %Determine y tick labels
set(gca, 'XTick', [1,50:50:550,599], 'XTickLabel', {'-200','-100','0','100','200','300','400','500','600','700','800','900','1000'}); %Determine x tick labels
caxis([-1 1]); %Determine colour scale
ylim([1,20]);   %Determine y axis limits
ylabel('Frequency (Hz)'); xlabel('Time (ms)'); %Determine x and y labels
hold on; contour(delta_contour,1,'black','linewidth',1); %Add Delta contour line
hold on; contour(theta_contour,1,'black','linewidth',1); %Add Theta contour line
colormap(flipud(cbrewer2('div','RdBu',9))); %Determine colourmap
colorbar; %Show colourbar
ax = gca; %Extract fplit properties
ax.FontSize = 12; %Determine font size
set(gca,'Box','off') %Remove plot border
xline(1) %Insert y-axis line
title('D                                                                                                                                                             '); %Insert figure indicator and very sloppily left justify it

%%   Saving Figure 10                                                
print(gcf,'Figure 10 - Wavelet.jpeg','-djpeg','-r1000') %Save plot
close all %Close window for next plot
%% Figure 13 Data                                                   
%NOTE: Must run part of RewardProcessing_Preprocessing.m to get All_WAV variable
%Normal topographic maps
diff_WAV = squeeze(All_WAV(:,1:20,151:750,1,:)-All_WAV(:,1:20,151:750,2,:));%Average data across each electrodes for difference plot
gain_temp_WAV = squeeze(All_WAV(:,1:20,151:750,1,:)); %Average data across each electrodes for condition 1
loss_temp_WAV = squeeze(All_WAV(:,1:20,151:750,2,:)); %Average data across each electrodes for condition 2

for electrode = 1:30 %Cycle through through electrodes
    diff_WAV(electrode,:,:,:) = squeeze(diff_WAV(electrode,:,:,:)).*both_extract; %Manipulate differenc WAV to only include significant clusters
    gain_temp_WAV(electrode,:,:,:) = squeeze(gain_temp_WAV(electrode,:,:,:)).*both_extract; %Manipulate condition 1 WAV to only include significant clusters
    loss_temp_WAV(electrode,:,:,:) = squeeze(loss_temp_WAV(electrode,:,:,:)).*both_extract; %Manipulate condition 2 WAV to only include significant clusters
end
diff_WAV(diff_WAV==0) = NaN; %Convert any non-significant points to NaN
gain_temp_WAV(gain_temp_WAV==0) = NaN; %Convert any non-significant points to NaN
loss_temp_WAV(loss_temp_WAV==0) = NaN; %Convert any non-significant points to NaN
topo_WAV_delta = nanmean(diff_WAV(:,1:2,:,:),[2,3,4]); %Average delta data for each electrode for the difference WAV
topo_WAV_theta = nanmean(diff_WAV(:,3:7,:,:),[2,3,4]); %Average theta data for each electrode for the difference WAV
gain_topo_WAV_delta = nanmean(gain_temp_WAV(:,1:2,:,:),[2,3,4]); %Average delta data for each electrode for condition 1
loss_topo_WAV_theta = nanmean(loss_temp_WAV(:,3:7,:,:),[2,3,4]); %Average theta data for each electrode for condition 2

%Percent of participants with max peak at each electrode
for electrode = 1:30 %Cycle through through electrodes
    diff_WAV = squeeze(All_WAV(electrode,1:20,151:750,1,:)-All_WAV(electrode,1:20,151:750,2,:)); %Create difference WAV of current electrode
    diff_WAV = diff_WAV.*both_extract; %Extract only significant regions
    gain_WAV = squeeze(All_WAV(electrode,1:20,151:750,1,:)); %Extract condition 1 wave of current electrode
    gain_WAV = gain_WAV.*both_extract; %Extract only significant regions
    loss_WAV = squeeze(All_WAV(electrode,1:20,151:750,2,:)); %Extract condition 2 wave of current electrode
    loss_WAV = loss_WAV.*both_extract; %Extract only significant regions
    mean_peaks_WAV(:,electrode,1) = squeeze(mean(diff_WAV(1:2,:,:),[1,2])); %Average delta data for difference WAV of current electrode
    mean_peaks_WAV(:,electrode,2) = squeeze(mean(diff_WAV(3:7,:,:),[1,2])); %Average theta data for difference WAV of current electrode
    gain_mean_peaks_WAV(:,electrode,1) = squeeze(mean(gain_WAV(1:2,:,:),[1,2])); %Average delta data for condition 1 of current electrode
    loss_mean_peaks_WAV(:,electrode,2) = squeeze(mean(loss_WAV(3:7,:,:),[1,2])); %Average theta data for condition 2 of current electrode
end

[~, topoloc_WAV_delta] = max(squeeze(mean_peaks_WAV(:,:,1)),[],2); %Determine which electrodes was location of delta max for difference WAV
[~, topoloc_WAV_theta] = min(squeeze(mean_peaks_WAV(:,:,2)),[],2); %Determine which electrodes was location of theta max for difference WAV
[~, gain_topoloc_WAV_delta] = max(squeeze(gain_mean_peaks_WAV(:,:,1)),[],2); %Determine which electrodes was location of delta peak for condition 1
[~, loss_topoloc_WAV_theta] = max(squeeze(loss_mean_peaks_WAV(:,:,2)),[],2); %Determine which electrodes was location of theta peak for condition 2

topomax_WAV_delta = zeros(500,30); %Create empty variable to count number of peaks for each electrode for difference WAV
topomax_WAV_theta = zeros(500,30); %Create empty variable to count number of peaks for each electrode for difference WAV
gain_topomax_WAV_delta = zeros(500,30); %Create empty variable to count number of peaks for each electrode for condition 1
loss_topomax_WAV_theta = zeros(500,30); %Create empty variable to count number of peaks for each electrode for condition 2
for counter = 1:length(topoloc_WAV_delta) %Cycle through participants
    topomax_WAV_delta(counter,topoloc_WAV_delta(counter)) = 1; %Signify where the delta peak was for current participant for difference WAV
    topomax_WAV_theta(counter,topoloc_WAV_theta(counter)) = 1; %Signify where the theta peak was for current participant for difference WAV
    gain_topomax_WAV_delta(counter,gain_topoloc_WAV_delta(counter)) = 1; %Signify where the delta peak was for current participant for condition 1
    loss_topomax_WAV_theta(counter,loss_topoloc_WAV_theta(counter)) = 1; %Signify where the theta peak was for current participant for condition 2
end

label_WAV_delta = round((sum(topomax_WAV_delta)/500)*100); %Determine percetange that each electrode had a max delta peak for difference WAV
label_WAV_theta = round((sum(topomax_WAV_theta)/500)*100); %Determine percetange that each electrode had a max theta peak for difference WAV
gain_label_WAV_delta = round((sum(gain_topomax_WAV_delta)/500)*100); %Determine percetange that each electrode had a max delta peak for condition 1
loss_label_WAV_theta = round((sum(loss_topomax_WAV_theta)/500)*100); %Determine percetange that each electrode had a max theta peak for condition 2

maxchans_WAV_delta = chanlocsMaster; %Reallocate the electrode channel list for modification
maxchans_WAV_theta = chanlocsMaster; %Reallocate the electrode channel list for modification
gain_maxchans_WAV_delta = chanlocsMaster; %Reallocate the electrode channel list for modification
loss_maxchans_WAV_theta = chanlocsMaster; %Reallocate the electrode channel list for modification
for counter = 1:length(sum(topomax_WAV_delta)) %Cycle through electrodes
    maxchans_WAV_delta(counter).labels = [num2str(label_WAV_delta(counter)),'%']; %Create labels indicating percent of delta peaks rather than electrode name for difference WAV
    maxchans_WAV_theta(counter).labels = [num2str(label_WAV_theta(counter)),'%']; %Create labels indicating percent of delta peaks rather than electrode name for difference WAV
    gain_maxchans_WAV_delta(counter).labels = [num2str(gain_label_WAV_delta(counter)),'%']; %Create labels indicating percent of delta peaks rather than electrode name for condition 1
    loss_maxchans_WAV_theta(counter).labels = [num2str(loss_label_WAV_theta(counter)),'%']; %Create labels indicating percent of delta peaks rather than electrode name for condition 2
end
%%   Figure 13 Plots                                                
figure('position',[0 0 1200 700]) %Create figure
marg = .005; %Set smaller margins
ax1 = subplot_tight(2,4,1,[marg, marg]); %Figure 13A
topoplot(topo_WAV_delta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
caxis([-.6 .6]); %Set colour limits
ax2 = subplot_tight(2,4,2,[marg, marg]); %Figure 13B
topoplot(topo_WAV_theta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
caxis([-1.5 1.5]);  %Set colour limits
ax3 = subplot_tight(2,4,3,[marg, marg]); %Figure 13C
topoplot(gain_topo_WAV_delta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
ax4 = subplot_tight(2,4,4,[marg, marg]); %Figure 13D
topoplot(loss_topo_WAV_theta,chanlocsMaster,'conv','on','gridscale',1000,'emarkersize',20,'headcolor',[.7 .7 .7]); %Plot topographic map
ax5 = subplot_tight(2,4,5,[marg, marg]); %Figure 13E
topoplot(sum(topomax_WAV_delta),maxchans_WAV_delta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax6 = subplot_tight(2,4,6,[marg, marg]); %Figure 13F
topoplot(sum(topomax_WAV_theta*-1),maxchans_WAV_theta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax7 = subplot_tight(2,4,7,[marg, marg]); %Figure 13G
topoplot(sum(gain_topomax_WAV_delta),gain_maxchans_WAV_delta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map
ax8 = subplot_tight(2,4,8,[marg, marg]); %Figure 13H
topoplot(sum(loss_topomax_WAV_theta),loss_maxchans_WAV_theta,'electrodes','labels','gridscale',1000,'efontsize',16,'headcolor',[.7 .7 .7]); %Plot topographic map

set(gcf,'color','w'); %Set background to white
xlim(ax1,[-.6 .6]);ylim(ax1,[-.6 .6]); %Set x and y axis limits
xlim(ax2,[-.6 .6]);ylim(ax2,[-.6 .6]); %Set x and y axis limits
xlim(ax3,[-.6 .6]);ylim(ax3,[-.6 .6]); %Set x and y axis limits
xlim(ax4,[-.6 .6]);ylim(ax4,[-.6 .6]); %Set x and y axis limits
xlim(ax5,[-.6 .6]);ylim(ax5,[-.6 .6]); %Set x and y axis limits
xlim(ax6,[-.6 .6]);ylim(ax6,[-.6 .6]); %Set x and y axis limits
xlim(ax7,[-.6 .6]);ylim(ax7,[-.6 .6]); %Set x and y axis limits
xlim(ax8,[-.6 .6]);ylim(ax8,[-.6 .6]); %Set x and y axis limits
colormap(flipud(cbrewer2('div','RdBu',9))); %Set colours of graph
%%   Saving Figure 13                                               
print(gcf,'Figure 13 - WAV Topoplot.jpeg','-djpeg','-r600'); %Save figure
close all %Close window for next plot
%% Figure S4 Data                 
WAV_diff_participants = squeeze(All_WAV(26,:,151:750,1,:)-All_WAV(26,:,151:750,2,:)); %Creates a difference WAV (Condition 1 - Condition 2) for all partitipants
for participant = 1:500 %Cycle through participants
    WAV_p_delta(:,:,participant) = WAV_diff_participants(:,:,participant).*delta_extract; %Extract regions of signicance for delta
    WAV_p_theta(:,:,participant) = WAV_diff_participants(:,:,participant).*theta_extract; %Extract regions of signicance for theta
end

delta_rev = squeeze(mean(WAV_p_delta,[1,2]))<0; %Determine which participants had a negative delta difference
theta_rev = squeeze(mean(WAV_p_theta,[1,2]))>0; %Determine which participants had a positive theta difference
WAV_delta_rev = WAV_diff_participants(:,:,delta_rev); %Extract participants data with a reversed delta burst
WAV_theta_rev = WAV_diff_participants(:,:,theta_rev); %Extract participants data with a reversed theta burst
%%   Figure S4 Plots                                                
figure('position',[0 0 1200 360]) %Create figure
subplot(1,2,1) %Figure S4A
pcolor(mean(WAV_delta_rev,3)); %Plot wavelet
shading interp; %Remove cell borders
set(gca, 'YTick', 1:20, 'YTickLabel', 1:20); %Add y axis tick labels
set(gca, 'XTick', [1,50:50:550,599], 'XTickLabel', {'-200','-100','0','100','200','300','400','500','600','700','800','900','1000'}); %Add x axis tick labels
caxis([-1 1]); %Set colour limits
ylim([1,20]); %Set y axis limits
ylabel('Frequency (Hz)'); xlabel('Time (ms)'); %Set x and y axis titles
hold on; contour(delta_contour,1,'black','linewidth',1); %Add significant delta contour line
hold on; contour(theta_contour,1,'black','linewidth',1); %Add significant theta contour line
colormap(flipud(cbrewer2('div','RdBu',9))); %Determine colour of graph
colorbar %Show colourbar
ax = gca; %Extract figure properties
ax.FontSize = 12; %Set font size
set(gca,'Box','off') %Remove plot border
xline(1) %Add y-axis axis line
title('A                                                                                                                  '); %Insert figure indicator and very sloppily left justify it

subplot(1,2,2) %Figure S4B
pcolor(mean(WAV_theta_rev,3));  %Plot wavelet
shading interp; %Remove cell borders
set(gca, 'YTick', 1:20, 'YTickLabel', 1:20); %Add y axis tick labels
set(gca, 'XTick', [1,50:50:550,599], 'XTickLabel', {'-200','-100','0','100','200','300','400','500','600','700','800','900','1000'}); %Add x axis tick labels
caxis([-1 1]); %Set colour limits
ylim([1,20]); %Set y axis limits
ylabel('Frequency (Hz)'); xlabel('Time (ms)'); %Set x and y axis titles
hold on; contour(delta_contour,1,'black','linewidth',1); %Add significant delta contour line
hold on; contour(theta_contour,1,'black','linewidth',1); %Add significant theta contour line
colormap(flipud(cbrewer2('div','RdBu',9))); %Determine colour of graph
colorbar %Show colourbar
ax = gca; %Extract figure properties
ax.FontSize = 12; %Set font size
set(gca,'Box','off') %Remove plot border
xline(1) %Add y-axis axis line
title('B                                                                                                                  '); %Insert figure indicator and very sloppily left justify it
%%   Saving Figure S4                                               
print(gcf,'Figure S4 - Reversed Wavelet.jpeg','-djpeg','-r1000') %Save plot
close all %Close window for next plot