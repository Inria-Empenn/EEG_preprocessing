##########################################################################
##Written by Chad C. Williams, PhD student in the Krigolson Lab, 2019   ##
##University of Victoria, British Columbia, Canada                      ##
##www.krigolsonlab.com                                                  ##
##www.chadcwilliams.com                                                 ##
##########################################################################
  
#### Setup Environment                                                    ####
#First, set your working directory to the folder with all of the csv data files - you may need to do this manually
library(ggplot2)
library(reshape2)
library(effsize)
library(pwr)
library(RColorBrewer)
library(cowplot)
library(Rfast)
library(Hmisc)


nbparticipants=73;

#Plotting Setup

#rm(list=ls())      pour effacer  les variables
#dev.off(dev.list()["RStudioGD"])



#Plotting Setup
colours = c('#FB6A4A','#6BAED6') #Determine colours
WAV.colors = (brewer.pal(9,"RdYlBu")) #Determine more colours

#Plotting Style
EEG_APA_Style = theme(axis.line.x = element_line(color="black", size = 0.5), #Add x axis line
                      axis.line.y = element_line(color="black", size = 0.5), #Add y axis line
                      axis.title.y = element_text(size = rel(1), angle = 90), #Rotate y axis title
                      panel.grid.major = element_blank(), #Remove major grid
                      panel.grid.minor = element_blank(), #Remove minor grid
                      panel.background = element_blank(), #Remove background
                      panel.border = element_blank(), #Remove border
                      legend.title=element_blank(), #Remove legend title
                      text = element_text(size=20)) #Make text 20 size

FFT_APA_Style = theme(axis.line.x = element_line(color="black", size = 0.5), #Add x axis line
                      axis.line.y = element_line(color="black", size = 0.5), #Add y axis line
                      axis.title.y = element_text(size = rel(1), angle = 90), #Rotate y axis title
                      panel.grid.major = element_blank(), #Remove major grid
                      panel.grid.minor = element_blank(), #Remove minor grid
                      panel.background = element_blank(), #Remove background
                      panel.border = element_blank(), #Remove border
                      legend.title=element_blank(), #Remove legend title
                      legend.text=element_text(size=30), #Make legend text 30 size
                      legend.key.width = unit(3,"cm"), #Determine legend width
                      text = element_text(size=40)) #Make text 20 size

#### Load and Manipulate Data                                             ####
#ERP
data = read.csv('RewP_Waveforms.csv',header = FALSE) #Load ERP data
colnames(data) = c('Time','Gain','Loss','Difference') #Rename columns
pdata = read.csv('RewP_Waveforms_AllPs.csv',header = FALSE) #Load participant ERP data
pdata$subject = as.factor(1:nbparticipants) #Add participant ID
pdata$condition = as.factor(c(rep(1,nbparticipants),rep(2,nbparticipants))) #Add condition ID
pdata_original = pdata #Re-allocate variable so not to lose it (later it gets modified)
data_Latency = read.csv('RewP_Latency.csv',header = FALSE)  #Load ERP peak time data

#FFT
data_FFT = read.csv('RewP_FFT.csv',header = FALSE) #Load FFT data 
colnames(data_FFT) = c("Frequency", "Gain", "Loss") #Rename columns
pdata_FFT = read.csv('RewP_FFT_AllPs.csv',header = FALSE) #Load participant FFT data
pdata_FFT$subject = as.factor(1:nbparticipants) #Add participant ID
pdata_FFT$condition = as.factor(c(rep(1,nbparticipants),rep(2,nbparticipants))) #Add condition ID
pdata_FFT_original = pdata_FFT #Re-allocate variable so not to lose it (later it gets modified)

#Time-Frequency Wavelets
data_WAV_stats = read.csv('RewP_WAV_Stats.csv',header = FALSE) #Load WAV data
data_WAV_freqs = read.csv('RewP_WAV_Freqs.csv',header = FALSE) #Load WAV data


#### Compute 95% confidence intervals                                     ####
#Figure 2 Error Bars
for (counter in 1:600){ #Cycle through time
  t_data = pdata[,c(counter,601,602)] #Extract current time point
  data[counter,5] = qt(0.975,nbparticipants-1) * (sd(t_data[1:500,1])/sqrt(500)) #Determine 95% confidence interval for condition 1
  data[counter,6] = qt(0.975,nbparticipants-1) * (sd(t_data[501:1000,1])/sqrt(500)) #Determine 95% confidence interval for condition 2
  data[counter,7] = qt(0.975,nbparticipants-1) * (sd(t_data[1:500,1]-t_data[501:1000,1])/sqrt(500)) #Determine 95% confidence interval for difference
}

#Figure 6 Error Bars
for (counter in 1:10){
  t_data = pdata_FFT[,c(counter,11,12)] #Extract current time point
  data_FFT[counter,5] = qt(0.975,nbparticipants-1) * (sd(t_data[1:500,1])/sqrt(500)) #Determine 95% confidence interval for condition 1
  data_FFT[counter,6] = qt(0.975,nbparticipants-1) * (sd(t_data[501:1000,1])/sqrt(500)) #Determine 95% confidence interval for condition 2
  data_FFT[counter,7] = qt(0.975,nbparticipants-1) * (sd(t_data[1:500,1]-t_data[501:1000,1])/sqrt(500)) #Determine 95% confidence interval for difference
}

##########################################################################
#### Plotting                                                             ####
##########################################################################
#### Figure 2                                                             ####
dataCW = data[,c(1,2,3)] #Extract relevant data
colnames(dataCW) = c("Time", "Gain", "Loss") #Rename columns
FreqCW = melt(dataCW, id = "Time", measured = c("Gain", "Loss")) #Transform data into long format
FreqCW$CI = c(data[,5],data[,6]) #Attach 95% confidence intervals
colnames(FreqCW) = c("Time", "Condition", "Amplitude","CI") #Rename columns
ylimcw = range(-5.5,15) #Determine y limits
ylabcw = expression(paste("Voltage (", mu, "V)", sep ="")) #Amplitude (μV) #Determine y label title
xlabcw = "Time (ms)" #Determine x label title

####  Figure 2A                                                           ####
PlotCW = ggplot(FreqCW, aes(x = Time, y = Amplitude, colour = Condition, linetype =  Condition))+ #Setup plot
  geom_ribbon(aes(ymin = FreqCW[,3] - FreqCW[,4], ymax = FreqCW[,3] + FreqCW[,4]), colour = NA, fill = c(rep(colours[1],600),rep(colours[2],600)), alpha = .2)+ #Add error bar ribbons
  geom_freqpoly(stat = "identity", size= 1,alpha = .8)+ #Add line plot
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="dotted")+ #Add time and amplitude = 0 indicator line
  scale_color_manual(values = colours)+ #Recolour the graph
  scale_linetype_manual(values = c('solid','solid'))+ #Make all lines solid
  scale_y_continuous(expand = c(0, 0))+ #Remove gap to x-axis
  coord_cartesian(ylim = ylimcw)+ #Determine y axis limits
  scale_x_continuous(breaks = round(seq(min(-200), max(1000), by = 100),1),expand = c(0,0))+ #Determine x axis tick labels
  xlab(xlabcw)+ylab(ylabcw)+ #Determine x and y label titles
  theme_bw() + theme(legend.position = c(.8, .7),legend.text=element_text(size=13), legend.key = element_rect(colour = "transparent", fill = "white"), legend.key.size = unit(.6, "cm"), #Modulate legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin widths
  guides(color=guide_legend(override.aes=list(fill=NA)))+ #Remove redundant legend
  EEG_APA_Style #Add EEG theme
PlotCW #Display plot

####  Figure 2B                                                           ####
dataDW = data[,c(1,4,7)] #Extract relevant data
colnames(dataDW) = c('Time','Amplitude','CI') #Rename columns

PlotDW = ggplot(dataDW, aes(x = Time, y = Amplitude))+ #Setup plot
  geom_ribbon(aes(ymin = dataDW[,2] - dataDW[,3], ymax = dataDW[,2] + dataDW[,3]), fill = "#F46D43", alpha = .5)+ #Add error bar ribbons
  geom_freqpoly(stat = "identity", size= 1,alpha = .8, colour = '#F46D43')+ #Add line plot
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="dotted")+ #Add time and amplitude = 0 indicator line
  scale_color_manual(values = colours[1])+ #Recolour the graph
  scale_y_continuous(expand = c(0, 0))+ #Expand y axis to touch x axis
  coord_cartesian(ylim = c(-3,6))+ #Determine y alimits
  scale_x_continuous(breaks = round(seq(min(-200), max(1000), by = 100),1),expand = c(0,0))+ #Add x axis tick labels
  xlab(xlabcw)+ylab(ylabcw)+ #Add axis titles
  theme_bw() + theme(legend.position = 'none', #Remove legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin size
  EEG_APA_Style #Add EEG formatting
PlotDW #Display plot

####  Figure 2C                                                           ####
pdata[1:500,1:600] = pdata[1:500,1:600]-pdata[501:1000,1:600] #Create difference waves
pdata = pdata[1:500,1:600] #Remove non-difference wave data
pdata$subject = as.factor(1:nbparticipants) #Add participant IDs
p_plotdata = melt(pdata[1:500,], identity = c('subject')) #Reshape into long format
p_plotdata$Time = dataDW$Time #Add time variable
p_plotdata$variable = as.numeric(p_plotdata$variable) #Convert condition into numeric
p_plotdata$variable = (p_plotdata$variable*2)-202 #Ensure that time begins at -200ms

PlotDW_ps = ggplot(p_plotdata, aes(x = variable, y = as.numeric(subject)))+ #Setup plot
  geom_tile(aes(fill = value),colour = "white")+  #Add participant data
  scale_fill_gradient2(low = WAV.colors[8],mid = 'white',high = WAV.colors[1],limits=c(-10,10))+ #Recolour plot and add limits
  scale_x_continuous(breaks = round(seq(min(-200), max(1000), by = 100),1),expand = c(0,0))+ #Determine x tick labels
  scale_y_continuous(expand = c(0,0))+ #Make y axis touch x axis
  ylab('Participant')+xlab('Time (ms)')+ #Add x and y labels
  theme(legend.position = 'none')+ #Remove legend
  EEG_APA_Style #Add formatting
PlotDW_ps #Display plot

####  Save Figure 2                                                       ####
plots = plot_grid(PlotCW,PlotDW,PlotDW_ps,labels = c('A', 'B', 'C'),ncol=1) #Combine plots
ggsave(plot = plots, filename = 'Figure 2 - ERPs.jpeg', width = 8.72, height = 12, dpi = 600) #Save plots

#### Figure 3                                                             ####
p_diffdata = pdata #Recall difference pdata 
pdata = pdata_original #Recall original data 

peak_time = which(dataDW$Amplitude==max(dataDW$Amplitude)) #Determine peak time of grand averaged difference wave (for N200)
base_time = which(dataDW$Amplitude[188:226]==min(dataDW$Amplitude[188:226]))+187 #Determine min peak time of the P200
mean_peaks = rowMeans(p_diffdata[,sum(peak_time,-23):sum(peak_time,23)]) #Determine mean peak vlues around grand average peak for difference wave
gain_peaks = rowMeans(pdata[1:nbparticipants,sum(239,-23):sum(239,23)]) #Determine mean peak values around grand average peak for gain waveform
lose_peaks = rowMeans(pdata[501:1000,sum(246,-23):sum(246,23)]) #Determine mean peak values around grand average peak for loss waveform
max_peaks = apply(p_diffdata[,200:300], 1, max) #Determine max peak values around grand average peak
basetopeaks_peaks = apply(p_diffdata[,200:300], 1, max) - apply(p_diffdata[,175:225], 1, min) #Determine base-to-peak values around the N200 peak - P200 peak
base_peaks =  apply(p_diffdata[,175:225], 1, min) #Determine base peak values of the P200

peak_measures = matrix(NA,2500,2) #Create variable to store peaks
peak_measures[,1] = c(mean_peaks,max_peaks,basetopeaks_peaks,gain_peaks,lose_peaks) #Store all peak values
peak_measures[,2] = c(rep('Mean',nbparticipants),rep('Maximum', nbparticipants), rep('Base to Peak',nbparticipants),rep('Gain', nbparticipants),rep('Loss', nbparticipants)) #Create labels for each peak measure
peak_measures = as.data.frame(peak_measures) #Convert to data frame
colnames(peak_measures) = c('Amplitude','Condition') #Rename columns
peak_measures$Amplitude = as.numeric(as.character(peak_measures$Amplitude)) #Convert to numeric
peak_measures$Condition = factor(peak_measures$Condition, levels = c('Mean','Maximum','Base to Peak','Gain','Loss')) #Reorganize factor order

####  Figure 3A                                                           ####
peaks_plot = ggplot(peak_measures[1:1500,],aes(x=Condition,y=Amplitude,fill = Condition))+ #Setup plot
  geom_hline(yintercept=0, linetype="dotted")+ #Insert y = 0 amplitude indicator line
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1)+ #Insert 95% confidence intervals
  geom_jitter(width = .035,alpha = .2)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab(ylabcw)+ #Remove x title label and determine y title label
  scale_fill_brewer(palette = 'RdYlBu')+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
peaks_plot #Display plot

####  Figure 3B                                                           ####
peaks_plot_conditional = ggplot(peak_measures[1501:2500,],aes(x=Condition,y=Amplitude,fill = Condition))+ #Setup plot
  geom_hline(yintercept=0, linetype="dotted")+ #Insert y = 0 amplitude indicator line
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1)+ #Insert 95% confidence intervals
  geom_jitter(width = .035,alpha = .2)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab(ylabcw)+ #Remove x title label and determine y title label
  scale_fill_brewer(palette = 'RdYlBu')+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
peaks_plot_conditional #Display plot

####  Figure 3C                                                           ####
colnames(data_Latency) = ('Amplitude') #Rename column
data_Latency$Amplitude = data_Latency$Amplitude*1000 #Turn data into milliseconds
data_Latency$Condition = as.factor(1) #Determine where on the x axis it will be
data_Latency[501:1000,1] = NA #This creates an empty 'second condition' so that the sizing of the chart is the same as the others

peaks_plot_time = ggplot(data_Latency,aes(x = Condition, y=Amplitude, fill = Condition))+ #Create plot
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1)+ #Insert 95% confidence intervals
  geom_jitter(width = .035,alpha = .2)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab('Time (ms)')+ #Remove x title label and determine y title label
  ylim(200,400)+ #Determine y limits
  scale_fill_brewer(palette = 'RdYlBu')+ #Determine colour of plot
  theme(axis.text.x = element_blank(), #Remove x axis text
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
peaks_plot_time #Display plot

####  Save Figure 3                                                       ####
plots = plot_grid(peaks_plot,peaks_plot_conditional,peaks_plot_time,labels = c('A', 'B', 'C'),ncol=3) #Combine plots
ggsave(plot = plots, filename = 'Figure 3 - Peak Values.jpeg', width = 8.72*3, height = 8, dpi = 600) #Save plots

#### Figure 4                                                             ####
mean_peaks_explore = matrix(NA,nbparticipants,251) #Create empty variable
max_peaks_explore = matrix(NA,nbparticipants,251) #Create empty variable
base_max_peaks_explore = matrix(NA,nbparticipants,251) #Create empty variable
base_mean_peaks_explore = matrix(NA,nbparticipants,251) #Create empty variable
for (counter in 1:251) #Cycle through different window sizes
{if (counter>1){ #If counter is larger than 1, use a range
  mean_peaks_explore[,counter] = rowMeans(p_diffdata[,sum(peak_time,-(counter-1)):sum(peak_time,(counter-1))]) #Extract mean of window
  max_peaks_explore[,counter] = rowMaxs(as.matrix(p_diffdata[,sum(peak_time,-(counter-1)):sum(peak_time,(counter-1))]),value=TRUE) #Extract max of window 
  base_max_peaks_explore[,counter] = rowMaxs(as.matrix(p_diffdata[,1:((counter-1)*2)+1]),value=TRUE) #Extract max of window in baseline
  base_mean_peaks_explore[,counter] = rowMeans(as.matrix(p_diffdata[,1:((counter-1)*2)+1])) #Extract max of window in baseline
  
}else{ #If counter is 1, simply use the peak time point
  mean_peaks_explore[,counter] = p_diffdata[,peak_time] #Extract the single point for mean
  max_peaks_explore[,counter] = p_diffdata[,peak_time] #Extract the single point for max
  base_mean_peaks_explore[,counter] = p_diffdata[,1] #Extract the single point for mean in baseline
  base_max_peaks_explore[,counter] = p_diffdata[,1]}} #Extract the single point for max in baseline

####  Figure 4A                                                           ####
mean_peaks_explore = as.data.frame(mean_peaks_explore) #Convert to data frame
mean_peak_e = melt(mean_peaks_explore) #Rearrange to long format
mean_peak_e$size = sort(rep(seq(0,nbparticipants,by=2),nbparticipants)) #Create window size variable

max_peaks_explore = as.data.frame(max_peaks_explore) #Convert to data frame
max_peak_e = melt(max_peaks_explore) #Rearrange to long format
max_peak_e$size = sort(rep(seq(0,nbparticipants,by=2),nbparticipants)) #Add window sizes

both_peak_e = rbind(mean_peak_e,max_peak_e) #Combine data across mean and peak
both_peak_e$method = as.factor(sort(rep(1:2,dim(both_peak_e)[1]/2))) #Add factor variable

both_explore_plot = ggplot(both_peak_e,aes(x=size,y=value,fill=method))+ #Create plot
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",alpha = .6)+ #Insert crossbars
  scale_fill_manual(values =c(WAV.colors[8], WAV.colors[2]))+ #Change graph colour
  xlim(-1,100.9)+ #Determine x limits
  xlab('Window Size (ms)')+ylab(ylabcw)+ #Determine x and y axis labels
  theme_bw() + theme(legend.position = 'none', #Remove legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin sizes
  EEG_APA_Style #Add formatting
both_explore_plot #Display plot

####  Figure 4B                                                           ####
base_mean_peaks_explore = as.data.frame(base_mean_peaks_explore) #Convert to data frame
base_mean_peak_e = melt(base_mean_peaks_explore) #Rearrange to long format
base_mean_peak_e$size = sort(rep(seq(0,nbparticipants,by=2),nbparticipants)) #Create window size variable

base_max_peaks_explore = as.data.frame(base_max_peaks_explore) #Convert to data frame
base_max_peak_e = melt(base_max_peaks_explore) #Rearrange to long format
base_max_peak_e$size = sort(rep(seq(0,nbparticipants,by=2),nbparticipants)) #Create window size variable

base_both_peak_e = rbind(base_mean_peak_e,base_max_peak_e)
base_both_peak_e$method = as.factor(sort(rep(1:2,dim(both_peak_e)[1]/2)))

base_both_explore_plot = ggplot(base_both_peak_e,aes(x=size,y=value,fill=method))+ #Create plot
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",alpha = .6)+ #Insert crossbars
  scale_fill_manual(values =c(WAV.colors[8], WAV.colors[2]))+ #Change graph colour
  xlim(-1,100.9)+ #Determine x limits
  xlab('Window Size (ms)')+ylab(ylabcw)+ #Determine x and y axis labels
  theme_bw() + theme(legend.position = 'none', #Remove legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin sizes
  EEG_APA_Style #Add formatting
base_both_explore_plot #Display plot

####  Saving Figure 4                                                     ####
plots = plot_grid(both_explore_plot,base_both_explore_plot,labels = c('A', 'B'),ncol=2)
ggsave(plot = plots, filename = 'Figure 4 - Window Sizes.jpeg', width = 12, height = 6, dpi = 600)

#### Figure 6                                                             ####
dataCW_FFT = data_FFT[,c(1,2,3)] #Extract relevant data
colnames(dataCW_FFT) = c("Frequency", "Gain", "Loss") #Rename columns
FreqCW_FFT = melt(dataCW_FFT, id = "Frequency", measured = c("Gain", "Loss")) #Reorganize data into long format
FreqCW_FFT$CI = c(data_FFT[,5],data_FFT[,6]) #Add 95% confidence intervals
colnames(FreqCW_FFT) = c("Frequency", "Condition", "Amplitude","CI") #Rename columns
ylimcw_FFT = range(0,25) #Determine y axis limits
ylabcw_FFT = expression(paste("Power (", mu, "V"^2,")", sep ="")) #Power (μV2) #Determine y axis title
xlabcw_FFT = "Frequency (Hz)"  #Determine x axis title

####  Figure 6A                                                           ####
PlotCW_FFT = ggplot(FreqCW_FFT, aes(x = Frequency, y = Amplitude, colour = Condition, linetype =  Condition))+ #Setup plot
  geom_ribbon(aes(ymin = FreqCW_FFT[,3] - FreqCW_FFT[,4], ymax = FreqCW_FFT[,3] + FreqCW_FFT[,4]), colour = NA, fill = c(rep(colours[1],10),rep(colours[2],10)), alpha = .2)+ #Add error bar ribbons
  geom_freqpoly(stat = "identity", size= 1,alpha = .8)+ #Add line plot
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="solid",size=1)+ #Add time and amplitude = 0 indicator line
  scale_color_manual(values = colours)+ #Recolour the graph
  scale_linetype_manual(values = c('solid','solid'))+ #Make all lines solid
  scale_y_continuous(expand = c(0, 0))+ #Remove gap to x-axis
  coord_cartesian(ylim = ylimcw_FFT,xlim=c(1,10))+ #Determine x and y axis limits
  scale_x_continuous(breaks = round(seq(min(1), max(30), by = 1),1),expand = c(0,0))+ #Determine x axis tick labels
  xlab(xlabcw_FFT)+ylab(ylabcw_FFT)+ #Determine x and y label titles
  theme_bw() + theme(legend.position = c(.8, .7),legend.text=element_text(size=13),legend.key.size = unit(.6, "cm"),legend.key = element_rect(colour = FALSE), #Modulate legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin widths
  guides(color=guide_legend(override.aes=list(fill=NA)))+ #Remove redundant legend
  EEG_APA_Style #Add EEG theme
PlotCW_FFT #Display plot

####  Figure 6B                                                           ####
dataDW_FFT = data_FFT[,c(1,4,7)] #Extract relevant data 
colnames(dataDW_FFT) = c('Frequency','Amplitude','CI') #Rename column

PlotDW_FFT = ggplot(dataDW_FFT, aes(x = Frequency, y = Amplitude))+ #Setup plot
  geom_ribbon(aes(ymin = dataDW_FFT[,2] - dataDW_FFT[,3], ymax = dataDW_FFT[,2] + dataDW_FFT[,3]), fill = "#F46D43", alpha = .5)+ #Add error bar ribbons
  geom_freqpoly(stat = "identity", size= 1,alpha = .8, colour = '#F46D43')+ #Add line plot
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="dotted")+ #Add time and amplitude = 0 indicator line
  scale_color_manual(values = colours[1])+ #Recolour the graph
  scale_y_continuous(expand = c(0, 0))+ #Remove gap to x-axis
  coord_cartesian(ylim = c(-2,2),xlim = c(1,10))+ #Determine x and y axis limits
  scale_x_continuous(breaks = round(seq(min(1), max(30), by = 1),1),expand = c(0,0))+ #Determine x axis tick labels
  xlab(xlabcw_FFT)+ylab(ylabcw_FFT)+ #Determine x and y label titles
  theme_bw() + theme(legend.position = 'none', #Remove legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin widths
  EEG_APA_Style#Add EEG theme
PlotDW_FFT #Display plot

####  Figure 6C                                                           ####
pdata_FFT[1:nbparticipants,1:10] = pdata_FFT[1:nbparticipants,1:10]-pdata_FFT[501:1000,1:10] #Create difference data 
p_plotdata_FFT = melt(pdata_FFT[1:nbparticipants,], identity = c('subject')) #Convert to long format
p_plotdata_FFT$Frequency = dataDW_FFT$Frequency #Frequency variable 
p_plotdata_FFT$variable = as.numeric(p_plotdata_FFT$variable) #Convert to numeric

PlotDW_ps_FFT = ggplot(p_plotdata_FFT, aes(x = variable, y = as.numeric(subject)))+ #Setup plot
  geom_tile(aes(fill = value),colour = "white")+ #Add participant data 
  scale_fill_gradient2(low = WAV.colors[9],mid = 'white',high = WAV.colors[1],limits=c(-6,6))+ #Recolour plot and add limits
  scale_x_continuous(breaks = round(seq(min(1), max(10), by = 1),1),limits = c(0.5,10.5),expand = c(0,0))+ #Add x tick labels
  scale_y_continuous(expand = c(0,0))+ #Expand y axis to touch x axis
  ylab('Participant')+xlab('Frequency (Hz)')+ #Add x and y axis labels
  theme(legend.position = 'none')+ #Remove legend
  EEG_APA_Style #Add formatting
PlotDW_ps_FFT #Display plot

####  Saving Figure 6                                                     ####
plots = plot_grid(PlotCW_FFT,PlotDW_FFT,PlotDW_ps_FFT,labels = c('A', 'B','C'),ncol=1) #Combine plots
ggsave(plot = plots, filename = 'Figure 6 - FFTs.jpeg', width = 8.72, height = 12, dpi = 600) #Save plots

#### Figure 7                                                             ####
pdata_FFT = pdata_FFT_original #Re-create the variable
pdata_FFTdiff = pdata_FFT[1:nbparticipants,1:7]-pdata_FFT[501:1000,1:7] #Create differences of each frequency
pdata_FFTTD = cbind(rowMeans(pdata_FFTdiff[,1:2]),rowMeans(pdata_FFTdiff[,3:7])) #Individually average delta and theta for difference data
pdata_FFTTD = as.data.frame(pdata_FFTTD) #Turn into data frame
pdata_FFTTD[,3] = rowMeans(pdata_FFT[1:nbparticipants,1:2]) #Individually average delta for the gain condition
pdata_FFTTD[,4] = rowMeans(pdata_FFT[501:1000,3:7]) #Individually average theta for the loss condition
colnames(pdata_FFTTD) = c('Delta','Theta','Gain-Related Delta','Loss-Related Theta') #Rename columns
pdata_FFTTD_long = melt(pdata_FFTTD[,c(1,2)]) #Rearrange difference data into long format
colnames(pdata_FFTTD_long) = c('Frequency','Power') #Rename columns
pdata_FFTTD_long_c = melt(pdata_FFTTD[,c(3,4)]) #Rearrange conditional data into long format
colnames(pdata_FFTTD_long_c) = c('Frequency','Power') #Rename columns
ylabcw_FFT = expression(paste("Power (", mu, "V"^2,")", sep ="")) #Power (μV2) #Determine y label title

####  Figure 7A                                                           ####
FFT_avg_plot = ggplot(pdata_FFTTD_long,aes(x=Frequency,y=Power,fill = Frequency))+ #Setup plot
  geom_hline(yintercept=0, linetype="dotted")+ #Create indicator of y = 0
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .3,size = .75)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab(ylabcw_FFT)+ #Remove x title label and determine y title label
  ylim(c(-20,30))+ #Determine y limits
  scale_fill_manual(values = WAV.colors[c(2,8)])+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
FFT_avg_plot #Display plot

####  Figure 7B                                                           ####
FFT_avg_plot_conditional = ggplot(pdata_FFTTD_long_c,aes(x=Frequency,y=Power,fill = Frequency))+ #Create plot
  geom_hline(yintercept=0, linetype="dotted")+ #Create indicator of y = 0
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .3,size = .75)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab(ylabcw_FFT)+ #Remove x title label and determine y title label
  scale_fill_manual(values = WAV.colors[c(2,8)])+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
FFT_avg_plot_conditional #Display plot

####  Saving Figure 7                                                     ####
plots = plot_grid(FFT_avg_plot,FFT_avg_plot_conditional,labels = c('A', 'B'),ncol=2) #Combine plots
ggsave(plot = plots, filename = 'Figure 7 - FFT Avg Values.jpeg', width = 8.72*2, height = 8, dpi = 600) #Save plots

#### Figure 8                                                             ####
pdata_FFT = pdata_FFT_original #Reallocate data 
pdata_FFTdiff = pdata_FFT[1:nbparticipants,1:7]-pdata_FFT[501:1000,1:7] #Create difference data
colnames(pdata_FFTdiff) = c('1Hz','2Hz','3Hz','4Hz','5Hz','6Hz','7Hz') #Rename columns
pdata_FFTdifflong = melt(pdata_FFTdiff) #Rearrange into long format
colnames(pdata_FFTdifflong) = c('Frequency','Power') #Rename columns

####  Figure 8A                                                           ####
FFTind_plot = ggplot(pdata_FFTdifflong,aes(x=Frequency,y=Power,fill = Frequency))+ #Create plot
  geom_hline(yintercept=0, linetype="dotted")+ #Insert y = 0 amplitude indicator line
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .1,size = .75)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('Frequency')+ylab(ylabcw_FFT)+ #Remove x title label and determine y title label
  #ylim(c(-20,30))+ #Set y axis limits
  scale_fill_brewer(palette = 'RdYlBu')+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
FFTind_plot #Display plot

####  Saving Figure 8                                                     ####
ggsave(plot = FFTind_plot, filename = 'Figure 8 - FFT Freq Values.jpeg', width = 8.72, height = 8, dpi = 600)

#### Figure 11                                                            ####
WAV_data_avg = data_WAV_stats[,c(2,1,4,3)] #Extract relevant data 
colnames(WAV_data_avg) = c('Delta','Theta','Gain-Related Delta','Loss-Related Theta') #Rename columns
WAV_data_avg = as.data.frame(WAV_data_avg) #Convert to dataframe
WAV_data_avg_long = melt(WAV_data_avg[,1:2]) #Rearrange into long format for Figure 9A
colnames(WAV_data_avg_long) = c('Frequency','Power') #Rename columns
WAV_data_avg_long_c = melt(WAV_data_avg[,3:4]) #Rearrange into long format for Figure 9B
colnames(WAV_data_avg_long_c) = c('Frequency','Power') #Rename columns

####  Figure 11A                                                          ####
WAV_plot_avg = ggplot(WAV_data_avg_long,aes(x=Frequency,y=Power,fill = Frequency))+ #Create plot
  geom_hline(yintercept=0, linetype="dotted")+
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .1)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab(ylabcw_FFT)+ #Remove x title label and determine y title label
  ylim(c(-12,12))+ #Set y axis limits
  scale_fill_manual(values = WAV.colors[c(2,8)])+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
WAV_plot_avg #Display plot

####  Figure 11B                                                          ####
WAV_plot_avg_conditional = ggplot(WAV_data_avg_long_c,aes(x=Frequency,y=Power,fill = Frequency))+ #Create plot
  geom_hline(yintercept=0, linetype="dotted")+ #Create indicator of y = 0
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .1)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab(ylabcw_FFT)+ #Remove x title label and determine y title label
  scale_fill_manual(values = WAV.colors[c(2,8)])+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
WAV_plot_avg_conditional #Display plot

####  Figure 11C                                                          ####
WAV_tdata_avg = cbind(rowMeans(data_WAV_freqs[,8:9]),rowMeans(data_WAV_freqs[,10:14])) #Extract and average relevant data
colnames(WAV_tdata_avg) = c('Delta','Theta') #Rename columns
WAV_tdata_avg = as.data.frame(WAV_tdata_avg) #Convert to data frame
WAV_tdata_avg_long = melt(WAV_tdata_avg) #Rearrange into long format
colnames(WAV_tdata_avg_long) = c('Frequency','Time') #Rename columns

WAV_tplot_avg = ggplot(WAV_tdata_avg_long,aes(x=Frequency,y=Time,fill = Frequency))+ #Create plot
  geom_hline(yintercept=0, linetype="dotted")+ #Create indicator of y = 0
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .1)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('')+ylab('Time (ms)')+ #Remove x title label and determine y title label
  scale_fill_manual(values = WAV.colors[c(2,8)])+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
WAV_tplot_avg #Display plot

####  Saving Figure 11                                                    ####
plots = plot_grid(WAV_plot_avg,WAV_plot_avg_conditional,WAV_tplot_avg,labels = c('A', 'B', 'C'),ncol=3) #Combine plots
ggsave(plot = plots, filename = 'Figure 11 - WAV Values.jpeg', width = 8.72*3, height = 8, dpi = 600) #Save FIgure 9

#### Figure 12                                                            ####
colnames(data_WAV_freqs) = c('1Hz','2Hz','3Hz','4Hz','5Hz','6Hz','7Hz','1Hz','2Hz','3Hz','4Hz','5Hz','6Hz','7Hz') #Rename columns
pdata_WAVdifflong = melt(data_WAV_freqs[,2:7]) #Rearrange data into long format
colnames(pdata_WAVdifflong) = c('Frequency','Power') #Rename columns

####  Figure 12A                                                          ####
WAVind_plot = ggplot(pdata_WAVdifflong,aes(x=Frequency,y=Power,fill = Frequency))+ #Create plot
  geom_hline(yintercept=0, linetype="dotted")+ #Insert y = 0 amplitude indicator line
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .1,size = .5)+ #Insert individual participant data
  theme(legend.position = 'none')+ #Remove legend
  xlab('Frequency')+ylab(ylabcw_FFT)+ #Remove x title label and determine y title label
  ylim(c(-20,15))+ #Set y axis limits
  scale_fill_brewer(palette = 'RdYlBu')+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
WAVind_plot #Display plot

####  Saving Figure 12                                                    ####
ggsave(plot = WAVind_plot, filename = 'Figure 12 - WAV Freq Values.jpeg', width = 8.72, height = 8, dpi = 600)

#### Figure 14                                                            ####
####  Figure 14A                                                          ####
pdata_FFT = pdata_FFT_original #Reallocate original data
p_diffdata_FFT = pdata_FFT[1:nbparticipants,1:10]-pdata_FFT[501:1000,1:10] #Create difference data
delta_peaks_FFT = rowMeans(p_diffdata_FFT[,1:2]) #Average delta
RewP_Delta_diff_FFT = as.data.frame(cbind(delta_peaks_FFT,mean_peaks)) #Combine data
colnames(RewP_Delta_diff_FFT) = c('Delta','RewP') #Rename columns
RewP_Delta_Plot_FFT = ggplot(aes(x=RewP,y=Delta),data=RewP_Delta_diff_FFT)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_x_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  xlab(expression(paste("Reward Positivity (", mu, "V",")", sep ="")))+ #Add x label
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add y label
  EEG_APA_Style #Format

####  Figure 14B                                                          ####
theta_peaks_FFT = rowMeans(p_diffdata_FFT[,3:7]) #Average theta
RewP_Theta_diff_FFT = as.data.frame(cbind(theta_peaks_FFT,mean_peaks)) #Combine data
colnames(RewP_Theta_diff_FFT) = c('Theta','RewP') #Rename columns
RewP_Theta_Plot_FFT = ggplot(aes(x=RewP,y=Theta),data=RewP_Theta_diff_FFT)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_x_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  xlab(expression(paste("Reward Positivity (", mu, "V",")", sep ="")))+ #Add x label
  ylab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add y label
  EEG_APA_Style #Format

####  Figure 14C                                                          ####
Delta_Theta_diff_FFT = as.data.frame(cbind(delta_peaks_FFT,theta_peaks_FFT)) #Combine data
colnames(Delta_Theta_diff_FFT) = c('Theta','Delta') #Rename columns
Delta_Theta_Plot_FFT = ggplot(aes(x=Delta,y=Theta),data=Delta_Theta_diff_FFT)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  xlab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add y label
  EEG_APA_Style #Format

####  Figure 14D                                                          ####
RewP_Delta_diff = as.data.frame(cbind(data_WAV_stats[,2],mean_peaks)) #Combine data
colnames(RewP_Delta_diff) = c('Delta','RewP') #Rename columns
RewP_Delta_Plot = ggplot(aes(x=RewP,y=Delta),data=RewP_Delta_diff)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_x_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  xlab(expression(paste("Reward Positivity (", mu, "V",")", sep ="")))+ #Add x label
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add y label
  EEG_APA_Style #Format

####  Figure 14E                                                          ####
RewP_Theta_diff = as.data.frame(cbind(data_WAV_stats[,1],mean_peaks)) #Combine data
colnames(RewP_Theta_diff) = c('Theta','RewP') #Rename columns
RewP_Theta_Plot = ggplot(aes(x=RewP,y=Theta),data=RewP_Theta_diff)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_x_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  xlab(expression(paste("Reward Positivity (", mu, "V",")", sep ="")))+ #Add x label
  ylab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add y label
  EEG_APA_Style #Format

####  Figure 14F                                                          ####
Delta_Theta_diff = as.data.frame(cbind(data_WAV_stats[,2],data_WAV_stats[,1])) #Combine data
colnames(Delta_Theta_diff) = c('Theta','Delta') #Rename columns
Delta_Theta_Plot = ggplot(aes(x=Delta,y=Theta),data=Delta_Theta_diff)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  xlab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add y label
  EEG_APA_Style #Format

####  Saving Figure 14                                                    ####
plots = plot_grid(RewP_Delta_Plot_FFT,RewP_Theta_Plot_FFT,Delta_Theta_Plot_FFT,RewP_Delta_Plot,RewP_Theta_Plot,Delta_Theta_Plot,labels = c('A', 'B','C','D','E','F'),ncol=3) #Combine plots
ggsave(plot = plots, filename = 'Figure 14 - Neural Correlations.jpeg', width = 13.08, height = 8, dpi = 600) #Save plot

#### Figure 15                                                            ####
p_demos_beh = read.csv('RewP_Demographics_Behavioural.csv',header = FALSE) #Load demographic data
colnames(p_demos_beh) = c('Gender','Age','Accuracy') #Rename columns

####  Figure 15A                                                          ####
RewP_Age_PlotData = as.data.frame(cbind(mean_peaks[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(RewP_Age_PlotData) = c('RewP','Age') #Rename columns
RewP_Age_Plot = ggplot(aes(x=Age,y=RewP),data=RewP_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Reward Positivity (", mu, "V",")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15B                                                          ####
FFT_Delta_Age_PlotData = as.data.frame(cbind(delta_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(FFT_Delta_Age_PlotData) = c('Delta','Age') #Rename columns
FFT_Delta_Age_Plot = ggplot(aes(x=Age,y=Delta),data=FFT_Delta_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 8),1))+ #Determine x axis tick labels
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15C                                                          ####
FFT_Theta_Age_PlotData = as.data.frame(cbind(theta_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(FFT_Theta_Age_PlotData) = c('Theta','Age') #Rename columns
FFT_Theta_Age_Plot = ggplot(aes(x=Age,y=Theta),data=FFT_Theta_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 1),1))+ #Determine x axis tick labels
  ylab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15D                                                          ####
WAV_Delta_Age_PlotData = as.data.frame(cbind(data_WAV_stats[,2][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(WAV_Delta_Age_PlotData) = c('Delta','Age') #Rename columns
WAV_Delta_Age_Plot = ggplot(aes(x=Age,y=Delta),data=WAV_Delta_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 2),1))+ #Determine x axis tick labels
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15E                                                          ####
WAV_Theta_Age_PlotData = as.data.frame(cbind(data_WAV_stats[,1][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(WAV_Theta_Age_PlotData) = c('Theta','Age') #Rename columns
WAV_Theta_Age_Plot = ggplot(aes(x=Age,y=Theta),data=WAV_Theta_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15F                                                          ####
RewP_Accuracy_PlotData = as.data.frame(cbind(mean_peaks,p_demos_beh$Accuracy)) #Create data frame
colnames(RewP_Accuracy_PlotData) = c('RewP','Accuracy') #Rename columns
RewP_Accuracy_Plot = ggplot(aes(x=Accuracy,y=RewP),data=RewP_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Reward Positivity (", mu, "V",")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15G                                                          ####
FFT_Delta_Accuracy_PlotData = as.data.frame(cbind(delta_peaks_FFT,p_demos_beh$Accuracy)) #Create data frame
colnames(FFT_Delta_Accuracy_PlotData) = c('Delta','Accuracy') #Rename columns
FFT_Delta_Accuracy_Plot = ggplot(aes(x=Accuracy,y=Delta),data=FFT_Delta_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 8),1))+ #Determine x axis tick labels
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15H                                                          ####
FFT_Theta_Accuracy_PlotData = as.data.frame(cbind(theta_peaks_FFT,p_demos_beh$Accuracy)) #Create data frame
colnames(FFT_Theta_Accuracy_PlotData) = c('Theta','Accuracy') #Rename columns
FFT_Theta_Accuracy_Plot = ggplot(aes(x=Accuracy,y=Theta),data=FFT_Theta_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 1),1))+ #Determine x axis tick labels
  ylab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15I                                                          ####
WAV_Delta_Accuracy_PlotData = as.data.frame(cbind(data_WAV_stats[,2],p_demos_beh$Accuracy)) #Create data frame
colnames(WAV_Delta_Accuracy_PlotData) = c('Delta','Accuracy') #Rename columns
WAV_Delta_Accuracy_Plot = ggplot(aes(x=Accuracy,y=Delta),data=WAV_Delta_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 15J                                                          ####
WAV_Theta_Accuracy_PlotData = as.data.frame(cbind(data_WAV_stats[,1],p_demos_beh$Accuracy)) #Create data frame
colnames(WAV_Theta_Accuracy_PlotData) = c('Theta','Accuracy') #Rename columns
WAV_Theta_Accuracy_Plot = ggplot(aes(x=Accuracy,y=Theta),data=WAV_Theta_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Saving Figure 15                                                    ####
plots = plot_grid(RewP_Age_Plot,FFT_Delta_Age_Plot,FFT_Theta_Age_Plot,WAV_Delta_Age_Plot,WAV_Theta_Age_Plot,RewP_Accuracy_Plot,FFT_Delta_Accuracy_Plot,FFT_Theta_Accuracy_Plot,WAV_Delta_Accuracy_Plot,WAV_Theta_Accuracy_Plot,labels = c('A', 'B','C','D','E','F','G','H','I','J'),ncol=5) #Combine plots
ggsave(plot = plots, filename = 'Figure 15 - Age and Accuracy Correlations.jpeg', width = 13.08, height = 5.33, dpi = 600) #Save plot

#### Figure 16                                                            ####
p_demos_beh = read.csv('RewP_Demographics_Behavioural.csv',header = FALSE) #Load demographic data
colnames(p_demos_beh) = c('Gender','Age','Accuracy') #Rename columns

####  Figure 16A                                                          ####
RewPGain_Age_PlotData = as.data.frame(cbind(gain_peaks[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(RewPGain_Age_PlotData) = c('Gain','Age') #Rename columns
RewPGain_Age_Plot = ggplot(aes(x=Age,y=Gain),data=RewPGain_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-8), max(32), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Gain ERP (", mu, "V",")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16B                                                          ####
RewPLoss_Age_PlotData = as.data.frame(cbind(lose_peaks[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(RewPLoss_Age_PlotData) = c('Loss','Age') #Rename columns
RewPLoss_Age_Plot = ggplot(aes(x=Age,y=Loss),data=RewPLoss_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Loss ERP (", mu, "V",")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16C                                                          ####
p_gaindata_FFT = pdata_FFT[1:nbparticipants,1:10] #Create difference data
deltaGain_peaks_FFT = rowMeans(p_gaindata_FFT[,1:2]) #Average delta
FFT_DeltaGain_Age_PlotData = as.data.frame(cbind(deltaGain_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(FFT_DeltaGain_Age_PlotData) = c('Delta','Age') #Rename columns
FFT_DeltaGain_Age_Plot = ggplot(aes(x=Age,y=Delta),data=FFT_DeltaGain_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(60), by = 8),1))+ #Determine x axis tick labels
  ylab(expression(paste("Gain Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16D                                                          ####
p_lossdata_FFT = pdata_FFT[501:1000,1:10] #Create difference data
thetaLoss_peaks_FFT = rowMeans(p_lossdata_FFT[,3:7]) #Average theta
FFT_ThetaLoss_Age_PlotData = as.data.frame(cbind(thetaLoss_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(FFT_ThetaLoss_Age_PlotData) = c('Theta','Age') #Rename columns
FFT_ThetaLoss_Age_Plot = ggplot(aes(x=Age,y=Theta),data=FFT_ThetaLoss_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 2),1))+ #Determine x axis tick labels
  ylab(expression(paste("Loss Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16E                                                          ####
WAV_DeltaGain_Age_PlotData = as.data.frame(cbind(data_WAV_stats[,4][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(WAV_DeltaGain_Age_PlotData) = c('Delta','Age') #Rename columns
WAV_DeltaGain_Age_Plot = ggplot(aes(x=Age,y=Delta),data=WAV_DeltaGain_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = .1),1))+ #Determine x axis tick labels
  ylab(expression(paste("Gain Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16F                                                          ####
WAV_ThetaLoss_Age_PlotData = as.data.frame(cbind(data_WAV_stats[,3][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2])) #Create data frame
colnames(WAV_ThetaLoss_Age_PlotData) = c('Theta','Age') #Rename columns
WAV_ThetaLoss_Age_Plot = ggplot(aes(x=Age,y=Theta),data=WAV_ThetaLoss_Age_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = .2),1))+ #Determine x axis tick labels
  ylab(expression(paste("Loss Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Age')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16G                                                          ####
RewPGain_Accuracy_PlotData = as.data.frame(cbind(gain_peaks,p_demos_beh$Accuracy)) #Create data frame
colnames(RewPGain_Accuracy_PlotData) = c('Gain','Accuracy') #Rename columns
RewPGain_Accuracy_Plot = ggplot(aes(x=Accuracy,y=Gain),data=RewPGain_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-8), max(32), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Gain ERP (", mu, "V",")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16H                                                          ####
RewPLoss_Accuracy_PlotData = as.data.frame(cbind(lose_peaks,p_demos_beh$Accuracy)) #Create data frame
colnames(RewPLoss_Accuracy_PlotData) = c('Loss','Accuracy') #Rename columns
RewPLoss_Accuracy_Plot = ggplot(aes(x=Accuracy,y=Loss),data=RewPLoss_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-8), max(20), by = 4),1))+ #Determine x axis tick labels
  ylab(expression(paste("Loss ERP (", mu, "V",")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16I                                                          ####
FFT_DeltaGain_Accuracy_PlotData = as.data.frame(cbind(deltaGain_peaks_FFT,p_demos_beh$Accuracy)) #Create data frame
colnames(FFT_DeltaGain_Accuracy_PlotData) = c('DeltaGain','Accuracy') #Rename columns
FFT_DeltaGain_Accuracy_Plot = ggplot(aes(x=Accuracy,y=DeltaGain),data=FFT_DeltaGain_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(60), by = 8),1))+ #Determine x axis tick labels
  ylab(expression(paste("Gain Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16J                                                          ####
FFT_ThetaLoss_Accuracy_PlotData = as.data.frame(cbind(thetaLoss_peaks_FFT,p_demos_beh$Accuracy)) #Create data frame
colnames(FFT_ThetaLoss_Accuracy_PlotData) = c('ThetaLoss','Accuracy') #Rename columns
FFT_ThetaLoss_Accuracy_Plot = ggplot(aes(x=Accuracy,y=ThetaLoss),data=FFT_ThetaLoss_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = 2),1))+ #Determine x axis tick labels
  ylab(expression(paste("Loss Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16K                                                          ####
WAV_DeltaGain_Accuracy_PlotData = as.data.frame(cbind(data_WAV_stats[,4],p_demos_beh$Accuracy)) #Create data frame
colnames(WAV_DeltaGain_Accuracy_PlotData) = c('DeltaGain','Accuracy') #Rename columns
WAV_DeltaGain_Accuracy_Plot = ggplot(aes(x=Accuracy,y=DeltaGain),data=WAV_DeltaGain_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = .1),1))+ #Determine x axis tick labels
  ylab(expression(paste("Gain Delta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Figure 16L                                                          ####
WAV_ThetaLoss_Accuracy_PlotData = as.data.frame(cbind(data_WAV_stats[,3],p_demos_beh$Accuracy)) #Create data frame
colnames(WAV_ThetaLoss_Accuracy_PlotData) = c('ThetaLoss','Accuracy') #Rename columns
WAV_ThetaLoss_Accuracy_Plot = ggplot(aes(x=Accuracy,y=ThetaLoss),data=WAV_ThetaLoss_Accuracy_PlotData)+ #Setup plot
  geom_point(colour = WAV.colors[2],alpha = .6)+ #Add scatter points
  geom_smooth(method='lm',formula='y~x',se=FALSE,colour = WAV.colors[8],alpha=.6)+ #Add regression line
  scale_y_continuous(breaks = round(seq(min(-20), max(20), by = .2),1))+ #Determine x axis tick labels
  ylab(expression(paste("Loss Theta (", mu, "V"^2,")", sep ="")))+ #Add x label
  xlab('Accuracy (%)')+ #Add y label
  EEG_APA_Style+ #Format
  theme(text = element_text(size=12)) #Make text 16 size

####  Saving Figure 16                                                    ####
plots = plot_grid(RewPGain_Age_Plot,RewPLoss_Age_Plot,FFT_DeltaGain_Age_Plot,FFT_ThetaLoss_Age_Plot,WAV_DeltaGain_Age_Plot,WAV_ThetaLoss_Age_Plot,RewPGain_Accuracy_Plot,RewPLoss_Accuracy_Plot,FFT_DeltaGain_Accuracy_Plot,FFT_ThetaLoss_Accuracy_Plot,WAV_DeltaGain_Accuracy_Plot,WAV_ThetaLoss_Accuracy_Plot,labels = c('A', 'B','C','D','E','F','G','H','I','J','K','L'),ncol=6) #Combine plots
ggsave(plot = plots, filename = 'Figure 16 - Conditional Age and Accuracy Correlations.jpeg', width = 13.08, height = 4.36, dpi = 600) #Save plot

#### Figure S1                                                            ####
flip_ps = c(which((mean_peaks<0)==TRUE),which((mean_peaks<0)==TRUE)+nbparticipants) #Determine which participants have a negative RewP Amplitude (and duplicate this list for condition 2)
flippedRewp = as.data.frame(pdata_original[flip_ps,]) #Extract flipped participants and convert to data frame
flip = matrix(NA,600*2,3) #Create empty variable
flip[,1] = rep(data[,1],2) #Insert time
flip[,2] = c(rep('Gain',600),rep('Loss',600)) #Insert conditions
flip[,3] = c(colMeans(flippedRewp[1:86,1:600]),colMeans(flippedRewp[87:172,1:600])) #Insert data
flip = as.data.frame(flip) #Convert to data frame
colnames(flip) = c('Time','Condition','Amplitude') #Rename columns
flip$Time = as.numeric(as.character(flip$Time)) #Convert to numeric
flip$Amplitude = as.numeric(as.character(flip$Amplitude)) #Convert to numeric
flip[,4] = NA #Create empty column

norm_ps = c(which((mean_peaks>0)==TRUE),which((mean_peaks>0)==TRUE)+nbparticipants)#Determine which participants have a positive RewP Amplitude (and duplicate this list for condition 2)
normRewp = as.data.frame(pdata_original[norm_ps,]) #Extract participants and convert to data frame
norm = matrix(NA,600*2,3) #Create empty variable
norm[,1] = rep(data[,1],2) #Insert time
norm[,2] = c(rep('Gain',600),rep('Loss',600)) #Insert conditions
norm[,3] = c(colMeans(normRewp[1:328,1:600]),colMeans(normRewp[329:656,1:600])) #Insert data
norm = as.data.frame(norm) #Convert to data frame
colnames(norm) = c('Time','Condition','Amplitude') #Rename columns
norm$Time = as.numeric(as.character(norm$Time)) #Convert to numeric
norm$Amplitude = as.numeric(as.character(norm$Amplitude)) #Convert to numeric
norm[,4] = NA #Create empty column

for (counter in 1:600){ #Cycle through time
  t_data = normRewp[,c(counter,601,602)] #Extract time point for normal participants
  t_data2 = flippedRewp[,c(counter,601,602)] #Extract time point for flipped participants
  flip[counter,4] = qt(0.975,73) * (sd(t_data2[1:74,1])/sqrt(74)) #Calculate 95% confidence interval for condition 1
  flip[sum(counter,600),4] = qt(0.975,73) * (sd(t_data2[75:148,1])/sqrt(74))#Calclate 95% confidence interval for condition 2
  norm[counter,4] = qt(0.975,425) * (sd(t_data[1:426,1])/sqrt(426)) #Calculate 95% confidence interval for condition 1
  norm[sum(counter,600),4] = qt(0.975,425) * (sd(t_data[427:582,1])/sqrt(426))} #Calculate 95% confidence interval for condition2

####  Figure S1A                                                          ####
flipCW = ggplot(flip, aes(x = Time, y = Amplitude, colour = Condition, linetype =  Condition))+ #Create plot
  geom_ribbon(aes(ymin = flip[,3] - flip[,4], ymax = flip[,3] + flip[,4]), colour = NA, fill = c(rep(colours[1],600),rep(colours[2],600)), alpha = .2)+ #Add error ribbon
  geom_freqpoly(stat = "identity", size= 1,alpha = .8)+ #Add line plots
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="dotted")+ #Add y and x = 0 indicator lines
  scale_color_manual(values = colours)+scale_linetype_manual(values = c('solid','solid'))+ #Determine lines to be solid
  scale_y_continuous(expand = c(0, 0))+ #Expand y axis to touch x axis
  coord_cartesian(ylim = ylimcw)+ #Determine y axis limits
  scale_x_continuous(breaks = round(seq(min(-200), max(1000), by = 100),1),expand = c(0,0))+ #Determine x axis tick labels
  xlab(xlabcw)+ylab(ylabcw)+ #Determine x and y axis titles
  theme_bw() + theme(legend.position = c(.8, .7),legend.text=element_text(size=13), legend.key = element_rect(colour = "transparent", fill = "white"), legend.key.size = unit(.6, "cm"), #Format legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin size
  guides(color = guide_legend(override.aes=list(fill=NA)))+ #Remove redundant legend
  EEG_APA_Style #Add formatting
flipCW #Display plot

####  Figure S1B                                                          ####
normCW = ggplot(norm, aes(x = Time, y = Amplitude, colour = Condition, linetype =  Condition))+ #Create plot
  geom_ribbon(aes(ymin = norm[,3] - norm[,4], ymax = norm[,3] + norm[,4]), colour = NA, fill = c(rep(colours[1],600),rep(colours[2],600)), alpha = .2)+#Add error ribbon
  geom_freqpoly(stat = "identity", size= 1,alpha = .8)+ #Add line plots
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="dotted")+ #Add y and x = 0 indicator lines
  scale_color_manual(values = colours)+scale_linetype_manual(values = c('solid','solid'))+ #Determine lines to be solid
  scale_y_continuous(expand = c(0, 0))+ #Expand y axis to touch x axis
  coord_cartesian(ylim = ylimcw)+ #Determine y axis limits
  scale_x_continuous(breaks = round(seq(min(-200), max(1000), by = 100),1),expand = c(0,0))+ #Determine x axis tick labels
  xlab(xlabcw)+ylab(ylabcw)+ #Determine x and y axis titles
  theme_bw() + theme(legend.position = c(.8, .7),legend.text=element_text(size=13), legend.key = element_rect(colour = "transparent", fill = "white"), legend.key.size = unit(.6, "cm"), #Format legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin size
  guides(color=guide_legend(override.aes=list(fill=NA)))+ #Remove redundant legend
  EEG_APA_Style #Add formatting
normCW #Display plot

####  Saving Figure S1                                                    ####
plots = plot_grid(normCW, flipCW, labels = c('A', 'B'),ncol=1) #Combine plots 
ggsave(plot = plots, filename = 'Figure S1 - ERPs - Flipped.jpeg', width = 8.72, height = 8, dpi = 600) #Save plots

#### Figure S2                                                            ####
pdata_FFTTD = cbind(rowMeans(pdata_FFTdiff[,1:2]),rowMeans(pdata_FFTdiff[,3:7])) #Individually average delta and theta for difference data
rev_FFTdata_Delta = pdata_FFT[rep(pdata_FFTTD[,1]<0,2),] #Determine which participants have a negative delta power
rev_FFTdata_Theta = pdata_FFT[rep(pdata_FFTTD[,2]>0,2),] #Determine which participants have a positive theta power

data_FFT_d = matrix(NA,10,7) #Create empty variable
data_FFT_t = matrix(NA,10,7) #Create empty variable
for (counter in 1:10){ #Cycle through frequencies
  t_data_d = rev_FFTdata_Delta[,c(counter,11,12)] #Extract current frequency delta data
  t_data_t = rev_FFTdata_Theta[,c(counter,11,12)] #Extract current frequency theta data
  
  data_FFT_d[counter,1] = counter #Add frequency number
  data_FFT_d[counter,2] = mean(rev_FFTdata_Delta[1:197,counter]) #Determine averaged condition 1 power for current frequency 
  data_FFT_d[counter,3] = mean(rev_FFTdata_Delta[198:394,counter]) #Determine averaged condition 2 power for current frequency
  data_FFT_d[counter,4] = data_FFT_d[counter,2]-data_FFT_d[counter,3] #Determine averaged difference power for frequency
  data_FFT_d[counter,5] = qt(0.975,195) * (sd(t_data_d[1:196,1])/sqrt(196)) #Determine 95% confidence interval for condition 1 at current frequency
  data_FFT_d[counter,6] = qt(0.975,195) * (sd(t_data_d[198:394,1])/sqrt(196)) #Determine 95% confidence interval for condition 2 at current frequency
  data_FFT_d[counter,7] = qt(0.975,195) * (sd(t_data_d[1:197,1]-t_data_d[198:394,1])/sqrt(196)) #Determine 95% confidence interval for difference at current frequency
  
  data_FFT_t[counter,1] = counter
  data_FFT_t[counter,2] = mean(rev_FFTdata_Theta[1:128,counter]) #Determine averaged condition 1 power for current frequency 
  data_FFT_t[counter,3] = mean(rev_FFTdata_Theta[129:256,counter]) #Determine averaged condition 2 power for current frequency
  data_FFT_t[counter,4] = data_FFT_t[counter,2]-data_FFT_t[counter,3] #Determine averaged difference power for frequency
  data_FFT_t[counter,5] = qt(0.975,127) * (sd(t_data_t[1:128,1])/sqrt(128)) #Determine 95% confidence interval for condition 1 at current frequency
  data_FFT_t[counter,6] = qt(0.975,127) * (sd(t_data_t[129:256,1])/sqrt(128)) #Determine 95% confidence interval for condition 2 at current frequency
  data_FFT_t[counter,7] = qt(0.975,127) * (sd(t_data_t[1:128,1]-t_data_t[129:256,1])/sqrt(128)) #Determine 95% confidence interval for difference at current frequency
}
data_FFT_d = as.data.frame(data_FFT_d) #Convert to data frame
data_FFT_t = as.data.frame(data_FFT_t) #Convert to data frame
colnames(data_FFT_d) = c('Frequency','Gain','Loss','Diff','Gain_CI','Loss_CI','Diff_CI') #Add column names
colnames(data_FFT_t) = c('Frequency','Gain','Loss','Diff','Gain_CI','Loss_CI','Diff_CI') #Add column names

####  Figure S2A                                                          ####
dataCW_FFT_d = data_FFT_d[,c(1,2,3)] #Extract relevant data
colnames(dataCW_FFT_d) = c("Time", "Gain", "Loss") #Add column names
FreqCW_FFT_d = melt(dataCW_FFT_d, id = "Time", measured = c("Gain", "Loss")) #Rearrange data into long format
FreqCW_FFT_d$CI = c(data_FFT_d[,5],data_FFT_d[,6]) #Determine confidence intervals
colnames(FreqCW_FFT_d) = c("Time", "Condition", "Amplitude","CI") #Add columns names
ylimcw_FFT = range(0,25) #Determine y axis limits
ylabcw_FFT = expression(paste("Power (", mu, "V"^2,")", sep ="")) #Determine y axis title
xlabcw_FFT = "Frequency (Hz)" #Determine x axis title

PlotCW_FFT_d = ggplot(FreqCW_FFT_d, aes(x = Time, y = Amplitude, colour = Condition, linetype =  Condition))+ #Create plot
  geom_ribbon(aes(ymin = FreqCW_FFT_d[,3] - FreqCW_FFT_d[,4], ymax = FreqCW_FFT_d[,3] + FreqCW_FFT_d[,4]), colour = NA, fill = c(rep(colours[1],10),rep(colours[2],10)), alpha = .2)+ #Add error bar ribbons
  geom_freqpoly(stat = "identity", size= 1,alpha = .8)+ #Add averaged data lines
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="solid",size=1)+ #Add x and y = 0 indicator lines
  scale_color_manual(values = colours)+ #Determine graph colour
  scale_linetype_manual(values = c('solid','solid'))+ #Make lines solid
  scale_y_continuous(expand = c(0, 0))+ #Expand y axis to touch x axis
  coord_cartesian(ylim = ylimcw_FFT,xlim=c(1,10.1))+ #Determine x and y limits
  scale_x_continuous(breaks = round(seq(min(1), max(30), by = 1),1),expand = c(0,0))+ #Determine x axis tick labels
  xlab(xlabcw_FFT)+ylab(ylabcw_FFT)+ #Add x and y label titles
  theme_bw() + theme(legend.position = c(.8, .7),legend.text=element_text(size=13), legend.key.size = unit(.6, "cm"),legend.key = element_rect(colour = FALSE), #Format legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin sizes
  guides(color=guide_legend(override.aes=list(fill=NA)))+ #Remove redundant legend
  FFT_APA_Style #Add formatting
PlotCW_FFT_d #Display plot

####  Figure S2B                                                          ####
dataCW_FFT_t = data_FFT_t[,c(1,2,3)] #Extract relevant data
colnames(dataCW_FFT_t) = c("Time", "Gain", "Loss") #Add column names
FreqCW_FFT_t = melt(dataCW_FFT_t, id = "Time", measured = c("Gain", "Loss")) #Rearrange data into long format
FreqCW_FFT_t$CI = c(data_FFT_t[,5],data_FFT_t[,6]) #Determine confidence intervals
colnames(FreqCW_FFT_t) = c("Time", "Condition", "Amplitude","CI") #Add columns names

PlotCW_FFT_t = ggplot(FreqCW_FFT_t, aes(x = Time, y = Amplitude, colour = Condition, linetype =  Condition))+ #Create plot
  geom_ribbon(aes(ymin = FreqCW_FFT_t[,3] - FreqCW_FFT_t[,4], ymax = FreqCW_FFT_t[,3] + FreqCW_FFT_t[,4]), colour = NA, fill = c(rep(colours[1],10),rep(colours[2],10)), alpha = .2)+ #Add error bar ribbons
  geom_freqpoly(stat = "identity", size= 1,alpha = .8)+ #Add averaged data lines
  geom_vline(xintercept=0, linetype="dotted")+geom_hline(yintercept=0, linetype="solid",size=1)+ #Add x and y = 0 indicator lines
  scale_color_manual(values = colours)+ #Determine graph colour
  scale_linetype_manual(values = c('solid','solid'))+ #Make lines solid
  scale_y_continuous(expand = c(0, 0))+ #Expand y axis to touch x axis
  coord_cartesian(ylim = ylimcw_FFT,xlim=c(1,10.1))+ #Determine x and y limits
  scale_x_continuous(breaks = round(seq(min(1), max(30), by = 1),1),expand = c(0,0))+ #Determine x axis tick labels
  xlab(xlabcw_FFT)+ylab(ylabcw_FFT)+ #Add x and y label titles
  theme_bw() + theme(legend.position = c(.8, .7),legend.text=element_text(size=13),legend.key.size = unit(.6, "cm"),legend.key = element_rect(colour = FALSE), #Format legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin sizes
  guides(color=guide_legend(override.aes=list(fill=NA)))+ #Remove redundant legend
  FFT_APA_Style #Add formatting
PlotCW_FFT_t #Display plot

####  Saving Figure S2                                                    ####
plots = plot_grid(PlotCW_FFT_d,PlotCW_FFT_t,labels = c('A', 'B'),ncol=2) #Combine plots
ggsave(plot = plots, filename = 'Figure S2 - FFT Flip Plot.jpeg', width = 8.72*2, height = 8, dpi = 600) #Save plots

#### Figure S3                                                            ####
pdata_WAVdifflong = melt(data_WAV_freqs[,9:14]) #Extract relevant data
colnames(pdata_WAVdifflong) = c('Frequency','Power') #Rename columns

####  Figure S3A                                                          ####
WAVind_plot_times = ggplot(pdata_WAVdifflong,aes(x=Frequency,y=Power,fill = Frequency))+ #Create plot
  geom_hline(yintercept=0, linetype="dotted")+ #Insert y = 0 amplitude indicator line
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .1, alpha = 1,fun.args = list(mult = 3),position = position_nudge(x = 0, y = 0))+ #Insert 3 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .2, alpha = 1,fun.args = list(mult = 2),position = position_nudge(x = 0, y = 0))+ #Insert 2 SD crossbar
  stat_summary(fun.data = "mean_sdl", geom = "crossbar",width = .3, alpha = 1,fun.args = list(mult = 1),position = position_nudge(x = 0, y = 0))+ #Insert 1 SD crossbar
  stat_summary(fun.data = "mean_cl_normal", geom = "crossbar",width = .5, alpha = 1,size = .2,position = position_nudge(x = 0, y = 0))+ #Insert 95% confidence intervals
  geom_jitter(width = .05,alpha = .1,size = .5)+ #Insert individual participant data
  scale_y_continuous(breaks=seq(-1000,1600,by=200),labels=seq(-1000,1600,by=200))+ #Determine y axis tick labels
  theme(legend.position = 'none')+ #Remove legend
  xlab('Frequency')+ylab('Time (ms)')+ #Remove x title label and determine y title label
  scale_fill_brewer(palette = 'RdYlBu')+ #Determine colour of plot
  theme(axis.text.x = element_text(size=20), #Determine x text size
        axis.text.y = element_text(size=20), #Determine y text size
        axis.ticks.y = element_blank(), #Remove y tick labels
        axis.ticks.x = element_blank(), #Remove x tick labels
        axis.line.y = element_blank(), #Remove y axis line
        axis.line.x = element_blank(), #Remove x axis line
        text = element_text(size=20), #Increase font size
        panel.grid.major = element_blank(), #Remove major grid
        panel.grid.minor = element_blank(), #Remove minor grid
        panel.background = element_blank(), #Remove background
        panel.border = element_blank()) #Remove border
WAVind_plot_times #Display plot

####  Saving Figure S3                                                    ####
ggsave(plot = WAVind_plot_times, filename = 'Figure S3 - WAV Freq Times.jpeg', width = 8.72, height = 8, dpi = 600) #Save plot

##########################################################################
#### Statistics                                                           ####
##########################################################################
#### Table 1                                                              ####
####  ERP                                                                 ####

ERPMean_TTest = t.test(mean_peaks,mu=0) #Conduct t-test
ERPMean_SD = sd(mean_peaks) #Determine standard deviation
ERPMean_Cohend = cohen.d(mean_peaks,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

ERPMax_TTest = t.test(max_peaks,mu=0) #Conduct t-test
ERPMax_SD = sd(max_peaks) #Determine standard deviation
ERPMax_Cohend = cohen.d(max_peaks,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

ERPBtP_TTest = t.test(basetopeaks_peaks,mu=0) #Conduct t-test
ERPBtP_SD = sd(basetopeaks_peaks) #Determine standard deviation
ERPBtP_Cohend = cohen.d(basetopeaks_peaks,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

ERPP200_TTest = t.test(base_peaks,mu=0) #Conduct t-test
ERPP200_SD = sd(base_peaks) #Determine standard deviation
ERPP200_Cohend = cohen.d(base_peaks,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

####  FFT                                                                 ####
pdata_FFT = pdata_FFT_original #Reallocate original data
p_diffdata_FFT = pdata_FFT[1:nbparticipants,1:10]-pdata_FFT[501:1000,1:10] #Create difference data

delta_peaks_FFT = rowMeans(p_diffdata_FFT[,1:2]) #Average delta
DeltaFFT_TTest = t.test(delta_peaks_FFT,mu=0) #Conduct t-test
DeltaFFT_SD = sd(delta_peaks_FFT) #Determine standard deviation
DeltaFFT_Cohend = cohen.d(delta_peaks_FFT,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

theta_peaks_FFT = rowMeans(p_diffdata_FFT[,3:7]) #Average theta
ThetaFFT_TTest = t.test(theta_peaks_FFT,mu=0) #Conduct t-test
ThetaFFT_SD = sd(theta_peaks_FFT) #Determine standard deviation
ThetaFFT_Cohend = cohen.d(theta_peaks_FFT,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

####  WAV                                                                 ####
DeltaWAV_TTest = t.test(data_WAV_stats[,2],mu=0) #Conduct t-test
DeltaWAV_SD = sd(data_WAV_stats[,2]) #Determine standard deviation
DeltaWAV_Cohend = cohen.d(data_WAV_stats[,2],rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

ThetaWAV_TTest = t.test(data_WAV_stats[,1],mu=0) #Conduct t-test
ThetaWAV_SD = sd(data_WAV_stats[,1]) #Determine standard deviation
ThetaWAV_Cohend = cohen.d(data_WAV_stats[,1],rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

#### Table 2                                                              ####
####  ERP                                                                 ####
ERPgain_TTest = t.test(gain_peaks,mu=0) #Conduct t-test
ERPgain_SD = sd(gain_peaks) #Determine standard deviation
ERPgain_Cohend = cohen.d(gain_peaks,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

ERPlose_TTest = t.test(lose_peaks,mu=0) #Conduct t-test
ERPlose_SD = sd(lose_peaks) #Determine standard deviation
ERPlose_Cohend = cohen.d(lose_peaks,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

####  FFT                                                                 ####
gain_delta_peaks_FFT = rowMeans(pdata_FFT[1:nbparticipants,1:2])
gain_DeltaFFT_TTest = t.test(gain_delta_peaks_FFT,mu=0) #Conduct t-test
gain_DeltaFFT_SD = sd(gain_delta_peaks_FFT) #Determine standard deviation
gain_DeltaFFT_Cohend = cohen.d(gain_delta_peaks_FFT,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

loss_theta_peaks_FFT = rowMeans(pdata_FFT[501:1000,3:7])
loss_ThetaFFT_TTest = t.test(loss_theta_peaks_FFT,mu=0) #Conduct t-test
loss_ThetaFFT_SD = sd(loss_theta_peaks_FFT) #Determine standard deviation
loss_ThetaFFT_Cohend = cohen.d(loss_theta_peaks_FFT,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

####  WAV                                                                 ####
gain_DeltaWAV_TTest = t.test(data_WAV_stats[,4],mu=0) #Conduct t-test
gain_DeltaWAV_SD = sd(data_WAV_stats[,4]) #Determine standard deviation
gain_DeltaWAV_Cohend = cohen.d(data_WAV_stats[,4],rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

loss_ThetaWAV_TTest = t.test(data_WAV_stats[,3],mu=0) #Conduct t-test
loss_ThetaWAV_SD = sd(data_WAV_stats[,3]) #Determine standard deviation
loss_ThetaWAV_Cohend = cohen.d(data_WAV_stats[,3],rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size

#### Table 3                                                              ####
####  ERP                                                                 ####
ERPMean_P80 = pwr.t.test(n = , d = ERPMean_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired"))
ERPMean_P85 = pwr.t.test(n = , d = ERPMean_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired"))
ERPMean_P90 = pwr.t.test(n = , d = ERPMean_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired"))
ERPMean_P95 = pwr.t.test(n = , d = ERPMean_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired"))
ERPMean_P99 = pwr.t.test(n = , d = ERPMean_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired"))

ERPMax_P80 = pwr.t.test(n = , d = ERPMax_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired"))
ERPMax_P85 = pwr.t.test(n = , d = ERPMax_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired"))
ERPMax_P90 = pwr.t.test(n = , d = ERPMax_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired"))
ERPMax_P95 = pwr.t.test(n = , d = ERPMax_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired"))
ERPMax_P99 = pwr.t.test(n = , d = ERPMax_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired"))

ERPBtP_P80 = pwr.t.test(n = , d = ERPBtP_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired"))
ERPBtP_P85 = pwr.t.test(n = , d = ERPBtP_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired"))
ERPBtP_P90 = pwr.t.test(n = , d = ERPBtP_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired"))
ERPBtP_P95 = pwr.t.test(n = , d = ERPBtP_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired"))
ERPBtP_P99 = pwr.t.test(n = , d = ERPBtP_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired"))

####  FFT                                                                 ####
FFTDelta_P80 = pwr.t.test(n = , d = DeltaFFT_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired"))
FFTDelta_P85 = pwr.t.test(n = , d = DeltaFFT_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired"))
FFTDelta_P90 = pwr.t.test(n = , d = DeltaFFT_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired"))
FFTDelta_P95 = pwr.t.test(n = , d = DeltaFFT_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired"))
FFTDelta_P99 = pwr.t.test(n = , d = DeltaFFT_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired"))

FFTTheta_P80 = pwr.t.test(n = , d = ThetaFFT_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired"))
FFTTheta_P85 = pwr.t.test(n = , d = ThetaFFT_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired"))
FFTTheta_P90 = pwr.t.test(n = , d = ThetaFFT_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired"))
FFTTheta_P95 = pwr.t.test(n = , d = ThetaFFT_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired"))
FFTTheta_P99 = pwr.t.test(n = , d = ThetaFFT_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired"))

####  WAV                                                                 ####
WAVDelta_P80 = pwr.t.test(n = , d = DeltaWAV_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired"))
WAVDelta_P85 = pwr.t.test(n = , d = DeltaWAV_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired"))
WAVDelta_P90 = pwr.t.test(n = , d = DeltaWAV_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired"))
WAVDelta_P95 = pwr.t.test(n = , d = DeltaWAV_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired"))
WAVDelta_P99 = pwr.t.test(n = , d = DeltaWAV_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired"))

WAVTheta_P80 = pwr.t.test(n = , d = ThetaWAV_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired"))
WAVTheta_P85 = pwr.t.test(n = , d = ThetaWAV_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired"))
WAVTheta_P90 = pwr.t.test(n = , d = ThetaWAV_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired"))
WAVTheta_P95 = pwr.t.test(n = , d = ThetaWAV_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired"))
WAVTheta_P99 = pwr.t.test(n = , d = ThetaWAV_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired"))

#### Table 4                                                              ####
####  FFT                                                                 ####
FFT1 = p_diffdata_FFT[,1] #Extract frequency data
FFT1_Cohend = cohen.d(FFT1,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
FFT1_P80 = pwr.t.test(n = , d = FFT1_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
FFT1_P85 = pwr.t.test(n = , d = FFT1_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
FFT1_P90 = pwr.t.test(n = , d = FFT1_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
FFT1_P95 = pwr.t.test(n = , d = FFT1_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
FFT1_P99 = pwr.t.test(n = , d = FFT1_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

FFT2 = p_diffdata_FFT[,2] #Extract frequency data
FFT2_Cohend = cohen.d(FFT2,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
FFT2_P80 = pwr.t.test(n = , d = FFT2_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
FFT2_P85 = pwr.t.test(n = , d = FFT2_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
FFT2_P90 = pwr.t.test(n = , d = FFT2_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
FFT2_P95 = pwr.t.test(n = , d = FFT2_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
FFT2_P99 = pwr.t.test(n = , d = FFT2_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

FFT3 = p_diffdata_FFT[,3] #Average delta
FFT3_Cohend = cohen.d(FFT3,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
FFT3_P80 = pwr.t.test(n = , d = FFT3_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
FFT3_P85 = pwr.t.test(n = , d = FFT3_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
FFT3_P90 = pwr.t.test(n = , d = FFT3_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
FFT3_P95 = pwr.t.test(n = , d = FFT3_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
FFT3_P99 = pwr.t.test(n = , d = FFT3_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

FFT4 = p_diffdata_FFT[,4] #Extract frequency data
FFT4_Cohend = cohen.d(FFT4,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
FFT4_P80 = pwr.t.test(n = , d = FFT4_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
FFT4_P85 = pwr.t.test(n = , d = FFT4_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
FFT4_P90 = pwr.t.test(n = , d = FFT4_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
FFT4_P95 = pwr.t.test(n = , d = FFT4_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
FFT4_P99 = pwr.t.test(n = , d = FFT4_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

FFT5 = p_diffdata_FFT[,5] #Extract frequency data
FFT5_Cohend = cohen.d(FFT5,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
FFT5_P80 = pwr.t.test(n = , d = FFT5_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
FFT5_P85 = pwr.t.test(n = , d = FFT5_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
FFT5_P90 = pwr.t.test(n = , d = FFT5_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
FFT5_P95 = pwr.t.test(n = , d = FFT5_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
FFT5_P99 = pwr.t.test(n = , d = FFT5_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

FFT6 = p_diffdata_FFT[,6] #Extract frequency data
FFT6_Cohend = cohen.d(FFT6,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
FFT6_P80 = pwr.t.test(n = , d = FFT6_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
FFT6_P85 = pwr.t.test(n = , d = FFT6_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
FFT6_P90 = pwr.t.test(n = , d = FFT6_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
FFT6_P95 = pwr.t.test(n = , d = FFT6_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
FFT6_P99 = pwr.t.test(n = , d = FFT6_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

FFT7 = p_diffdata_FFT[,7] #Extract frequency data
FFT7_Cohend = cohen.d(FFT7,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
FFT7_P80 = pwr.t.test(n = , d = FFT7_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
FFT7_P85 = pwr.t.test(n = , d = FFT7_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
FFT7_P90 = pwr.t.test(n = , d = FFT7_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
FFT7_P95 = pwr.t.test(n = , d = FFT7_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
FFT7_P99 = pwr.t.test(n = , d = FFT7_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

####  WAV                                                                 ####
WAV2 = data_WAV_freqs[,2] #Extract frequency data
WAV2_Cohend = cohen.d(WAV2,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
WAV2_P80 = pwr.t.test(n = , d = WAV2_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
WAV2_P85 = pwr.t.test(n = , d = WAV2_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
WAV2_P90 = pwr.t.test(n = , d = WAV2_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
WAV2_P95 = pwr.t.test(n = , d = WAV2_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
WAV2_P99 = pwr.t.test(n = , d = WAV2_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

WAV3 = data_WAV_freqs[,3] #Extract frequency data
WAV3_Cohend = cohen.d(WAV3,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
WAV3_P80 = pwr.t.test(n = , d = WAV3_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
WAV3_P85 = pwr.t.test(n = , d = WAV3_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
WAV3_P90 = pwr.t.test(n = , d = WAV3_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
WAV3_P95 = pwr.t.test(n = , d = WAV3_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
WAV3_P99 = pwr.t.test(n = , d = WAV3_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

WAV4 = data_WAV_freqs[,4] #Extract frequency data
WAV4_Cohend = cohen.d(WAV4,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
WAV4_P80 = pwr.t.test(n = , d = WAV4_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
WAV4_P85 = pwr.t.test(n = , d = WAV4_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
WAV4_P90 = pwr.t.test(n = , d = WAV4_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
WAV4_P95 = pwr.t.test(n = , d = WAV4_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
WAV4_P99 = pwr.t.test(n = , d = WAV4_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

WAV5 = data_WAV_freqs[,5] #Extract frequency data
WAV5_Cohend = cohen.d(WAV5,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
WAV5_P80 = pwr.t.test(n = , d = WAV5_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
WAV5_P85 = pwr.t.test(n = , d = WAV5_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
WAV5_P90 = pwr.t.test(n = , d = WAV5_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
WAV5_P95 = pwr.t.test(n = , d = WAV5_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
WAV5_P99 = pwr.t.test(n = , d = WAV5_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

WAV6 = data_WAV_freqs[,6] #Extract frequency data
WAV6_Cohend = cohen.d(WAV6,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
WAV6_P80 = pwr.t.test(n = , d = WAV6_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
WAV6_P85 = pwr.t.test(n = , d = WAV6_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
WAV6_P90 = pwr.t.test(n = , d = WAV6_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
WAV6_P95 = pwr.t.test(n = , d = WAV6_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
WAV6_P99 = pwr.t.test(n = , d = WAV6_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

WAV7 = data_WAV_freqs[,7] #Extract frequency data
WAV7_Cohend = cohen.d(WAV7,rep(0,nbparticipants),paired = TRUE) #Conduct cohen's d effect size
WAV7_P80 = pwr.t.test(n = , d = WAV7_Cohend[3]$estimate, sig.level = .05, power = .80, type = c("paired")) #Conduct power calculation
WAV7_P85 = pwr.t.test(n = , d = WAV7_Cohend[3]$estimate, sig.level = .05, power = .85, type = c("paired")) #Conduct power calculation
WAV7_P90 = pwr.t.test(n = , d = WAV7_Cohend[3]$estimate, sig.level = .05, power = .90, type = c("paired")) #Conduct power calculation
WAV7_P95 = pwr.t.test(n = , d = WAV7_Cohend[3]$estimate, sig.level = .05, power = .95, type = c("paired")) #Conduct power calculation
WAV7_P99 = pwr.t.test(n = , d = WAV7_Cohend[3]$estimate, sig.level = .05, power = .99, type = c("paired")) #Conduct power calculation

#### Table 5                                                              ####
####  FFT                                                                 ####
RewP_Delta_correlation_FFT = cor.test(delta_peaks_FFT,mean_peaks) #Correlate the reward positivity and delta activity of the difference data
RewP_Theta_correlation_FFT = cor.test(theta_peaks_FFT,mean_peaks) #Correlate the reward positivity and theta activity of the difference data
Delta_Theta_correlation_FFT = cor.test(delta_peaks_FFT,theta_peaks_FFT) #Correlate the delta and theta activity of the difference data

####  WAV                                                                 ####
RewP_Delta_correlation = cor.test(data_WAV_stats[,2],mean_peaks) #Correlate the reward positivity and delta activity of the difference data
RewP_Theta_correlation = cor.test(data_WAV_stats[,1],mean_peaks) #Correlate the reward positivity and theta activity of the difference data
Delta_Theta_correlation = cor.test(data_WAV_stats[,1],data_WAV_stats[,2]) #Correlate the delta and theta activity of the difference data

#### Table 6                                                              ####
####  ERP                                                                 ####
ERP_RewP_Gender = t.test(mean_peaks[p_demos_beh$Gender==2],mean_peaks[p_demos_beh$Gender==1]) #T-Test of gender effects on the reward positivity
ERP_RewP_Gender_d = cohen.d(mean_peaks[p_demos_beh$Gender==2],mean_peaks[p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on the reward positivity

####  FFT                                                                 ####
FFT_Delta_Gender = t.test(delta_peaks_FFT[p_demos_beh$Gender==2],delta_peaks_FFT[p_demos_beh$Gender==1]) #T-Test of gender effects on FFT delta
FFT_Delta_Gender_d = cohen.d(delta_peaks_FFT[p_demos_beh$Gender==2],delta_peaks_FFT[p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on FFT delta
FFT_Theta_Gender = t.test(theta_peaks_FFT[p_demos_beh$Gender==2],theta_peaks_FFT[p_demos_beh$Gender==1]) #T-Test of gender effects on FFT theta
FFT_Theta_Gender_d = cohen.d(theta_peaks_FFT[p_demos_beh$Gender==2],theta_peaks_FFT[p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on FFT theta

####  WAV                                                                 ####
WAV_Delta_Gender = t.test(data_WAV_stats[,2][p_demos_beh$Gender==2],data_WAV_stats[,2][p_demos_beh$Gender==1]) #T-Test of gender effects on WAV delta
WAV_Delta_Gender_d = cohen.d(data_WAV_stats[,2][p_demos_beh$Gender==2],data_WAV_stats[,2][p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on WAV delta
WAV_Theta_Gender = t.test(data_WAV_stats[,1][p_demos_beh$Gender==2],data_WAV_stats[,1][p_demos_beh$Gender==1]) #T-Test of gender effects on WAV theta
WAV_Theta_Gender_d = cohen.d(data_WAV_stats[,1][p_demos_beh$Gender==2],data_WAV_stats[,1][p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on WAV theta

#### Table 7                                                              ####
####  ERP                                                                 ####
ERP_RewPGain_Gender = t.test(gain_peaks[p_demos_beh$Gender==2],gain_peaks[p_demos_beh$Gender==1]) #T-Test of gender effects on the reward positivity
ERP_RewPGain_Gender_d = cohen.d(gain_peaks[p_demos_beh$Gender==2],gain_peaks[p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on the reward positivity
ERP_RewPLoss_Gender = t.test(lose_peaks[p_demos_beh$Gender==2],lose_peaks[p_demos_beh$Gender==1]) #T-Test of gender effects on the reward positivity
ERP_RewPLoss_Gender_d = cohen.d(lose_peaks[p_demos_beh$Gender==2],lose_peaks[p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on the reward positivity

####  FFT                                                                 ####
FFT_DeltaGain_Gender = t.test(gain_delta_peaks_FFT[p_demos_beh$Gender==2],gain_delta_peaks_FFT[p_demos_beh$Gender==1]) #T-Test of gender effects on FFT delta
FFT_DeltaGain_Gender_d = cohen.d(gain_delta_peaks_FFT[p_demos_beh$Gender==2],gain_delta_peaks_FFT[p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on FFT delta
FFT_ThetaLoss_Gender = t.test(loss_theta_peaks_FFT[p_demos_beh$Gender==2],loss_theta_peaks_FFT[p_demos_beh$Gender==1]) #T-Test of gender effects on FFT theta
FFT_ThetaLoss_Gender_d = cohen.d(loss_theta_peaks_FFT[p_demos_beh$Gender==2],loss_theta_peaks_FFT[p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on FFT theta

####  WAV                                                                 ####
WAV_DeltaGain_Gender = t.test(data_WAV_stats[,4][p_demos_beh$Gender==2],data_WAV_stats[,4][p_demos_beh$Gender==1]) #T-Test of gender effects on WAV delta
WAV_DeltaGain_Gender_d = cohen.d(data_WAV_stats[,4][p_demos_beh$Gender==2],data_WAV_stats[,4][p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on WAV delta
WAV_ThetaLoss_Gender = t.test(data_WAV_stats[,3][p_demos_beh$Gender==2],data_WAV_stats[,3][p_demos_beh$Gender==1]) #T-Test of gender effects on WAV theta
WAV_ThetaLoss_Gender_d = cohen.d(data_WAV_stats[,3][p_demos_beh$Gender==2],data_WAV_stats[,3][p_demos_beh$Gender==1],paired = FALSE) #Cohen's d of gender effects on WAV theta

#### Table 8                                                              ####
####  Age                                                                 ####
ERP_RewP_Age = cor.test(mean_peaks[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and the reward positivity
FFT_Delta_Age = cor.test(delta_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and FFT delta
FFT_Theta_Age = cor.test(theta_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and FFT theta
WAV_Delta_Age = cor.test(data_WAV_stats[,2][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and WAV delta
WAV_Theta_Age = cor.test(data_WAV_stats[,1][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and WAV theta

####  Accuracy                                                            ####
ERP_Rewp_Acc = cor.test(mean_peaks,p_demos_beh$Accuracy) #Correlation between accuracy and the reward positivity
FFT_Delta_Acc = cor.test(delta_peaks_FFT,p_demos_beh$Accuracy) #Correlation between accuracy and FFT delta
FFT_Theta_Acc = cor.test(theta_peaks_FFT,p_demos_beh$Accuracy) #Correlation between accuracy and FFT theta
WAV_Delta_Acc = cor.test(data_WAV_stats[,2],p_demos_beh$Accuracy) #Correlation between accuracy and WAV theta
WAV_Theta_Acc = cor.test(data_WAV_stats[,1],p_demos_beh$Accuracy) #Correlation between accuracy and WAV theta

#### Table 9                                                              ####
####  Age                                                                 ####
ERP_RewPGain_Age = cor.test(gain_peaks[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and the reward positivity
ERP_RewPLoss_Age = cor.test(lose_peaks[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and the reward positivity
FFT_DeltaGain_Age = cor.test(gain_delta_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and FFT delta
FFT_ThetaLoss_Age = cor.test(loss_theta_peaks_FFT[!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and FFT theta
WAV_DeltaGain_Age = cor.test(data_WAV_stats[,4][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and WAV delta
WAV_ThetaLoss_Age = cor.test(data_WAV_stats[,3][!is.na(p_demos_beh$Age)],p_demos_beh[!is.na(p_demos_beh$Age),2]) #Correlation between age and WAV theta

####  Accuracy                                                            ####
ERP_RewpGain_Acc = cor.test(gain_peaks,p_demos_beh$Accuracy) #Correlation between accuracy and the reward positivity
ERP_RewpLoss_Acc = cor.test(lose_peaks,p_demos_beh$Accuracy) #Correlation between accuracy and the reward positivity
FFT_DeltaGainn_Acc = cor.test(gain_delta_peaks_FFT,p_demos_beh$Accuracy) #Correlation between accuracy and FFT delta
FFT_ThetaLoss_Acc = cor.test(loss_theta_peaks_FFT,p_demos_beh$Accuracy) #Correlation between accuracy and FFT theta
WAV_DeltaGain_Acc = cor.test(data_WAV_stats[,4],p_demos_beh$Accuracy) #Correlation between accuracy and WAV theta
WAV_ThetaLoss_Acc = cor.test(data_WAV_stats[,3],p_demos_beh$Accuracy) #Correlation between accuracy and WAV theta

##########################################################################
#### END OF SCRIPT                                                        ####
##########################################################################