library(ggplot2)
library(reshape2)
library(effsize)
library(pwr)
library(RColorBrewer)
library(cowplot)
library(Rfast)
library(Hmisc)

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
nbsubjects=500;
#### Load and Manipulate Data                                             ####
#ERP
data = read.csv('RewP_Waveforms.csv',header = FALSE) #Load ERP data
colnames(data) = c('Time','Gain','Loss','Difference') #Rename columns
pdata = read.csv('RewP_Waveforms_AllPs.csv',header = FALSE) #Load participant ERP data
pdata$subject = as.factor(1:nbsubjects) #Add participant ID
pdata$condition = as.factor(c(rep(1,nbsubjects),rep(2,nbsubjects))) #Add condition ID
pdata_original = pdata #Re-allocate variable so not to lose it (later it gets modified)
data_Latency = read.csv('RewP_Latency.csv',header = FALSE)  #Load ERP peak time data

#### Compute 95% confidence intervals                                     ####
#Figure 2 Error Bars
for (counter in 1:600){ #Cycle through time
  t_data = pdata[,c(counter,601,602)] #Extract current time point
  data[counter,5] = qt(0.975,499) * (sd(t_data[1:nbsubjects,1])/sqrt(nbsubjects)) #Determine 95% confidence interval for condition 1
  data[counter,6] = qt(0.975,499) * (sd(t_data[(nbsubjects+1):(nbsubjects*2),1])/sqrt(nbsubjects)) #Determine 95% confidence interval for condition 2
  data[counter,7] = qt(0.975,499) * (sd(t_data[1:nbsubjects,1]-t_data[(nbsubjects+1):(nbsubjects*2),1])/sqrt(nbsubjects)) #Determine 95% confidence interval for difference
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
ylimcw = range(-5.5,20) #Determine y limits
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
  coord_cartesian(ylim = c(-3,8))+ #Determine y alimits
  scale_x_continuous(breaks = round(seq(min(-200), max(1000), by = 100),1),expand = c(0,0))+ #Add x axis tick labels
  xlab(xlabcw)+ylab(ylabcw)+ #Add axis titles
  theme_bw() + theme(legend.position = 'none', #Remove legend
                     plot.margin=unit(c(.5,.5,.5,.5),"cm"))+ #Determine margin size
  EEG_APA_Style #Add EEG formatting
PlotDW #Display plot

plots = plot_grid(PlotCW,PlotDW,labels = c('A', 'B'),ncol=1) #Combine plots
ggsave(plot = plots, filename = 'Figure 2 - ERPs.jpeg', width = 8.72, height = 12, dpi = 600) #Save plots


#### Figure 3                                                             ####
p_diffdata = pdata #Recall difference pdata
pdata = pdata_original #Recall original data
p_diffdata=-pdata[1:nbsubjects,1:600]+pdata[(nbsubjects+1):(nbsubjects*2),1:600];

peak_time = which(dataDW$Amplitude==max(dataDW$Amplitude)) #Determine peak time of grand averaged difference wave (for N200)
base_time = which(dataDW$Amplitude[188:226]==min(dataDW$Amplitude[188:226]))+187 #Determine min peak time of the P200
mean_peaks = rowMeans(p_diffdata[,sum(peak_time,-23):sum(peak_time,23)]) #Determine mean peak vlues around grand average peak for difference wave
gain_peaks = rowMeans(pdata[1:nbsubjects,sum(239,-23):sum(239,23)]) #Determine mean peak values around grand average peak for gain waveform
lose_peaks = rowMeans(pdata[(nbsubjects+1):(nbsubjects*2),sum(246,-23):sum(246,23)]) #Determine mean peak values around grand average peak for loss waveform
max_peaks = apply(p_diffdata[,200:300], 1, max) #Determine max peak values around grand average peak
basetopeaks_peaks = apply(p_diffdata[,200:300], 1, max) - apply(p_diffdata[,175:225], 1, min) #Determine base-to-peak values around the N200 peak - P200 peak
base_peaks =  apply(p_diffdata[,175:225], 1, min) #Determine base peak values of the P200

peak_measures = matrix(NA,nbsubjects*5,2) #Create variable to store peaks
peak_measures[,1] = c(mean_peaks,max_peaks,basetopeaks_peaks,gain_peaks,lose_peaks) #Store all peak values
peak_measures[,2] = c(rep('Mean',nbsubjects),rep('Maximum', nbsubjects), rep('Base to Peak',nbsubjects),rep('Gain', nbsubjects),rep('Loss', nbsubjects)) #Create labels for each peak measure
peak_measures = as.data.frame(peak_measures) #Convert to data frame
colnames(peak_measures) = c('Amplitude','Condition') #Rename columns
peak_measures$Amplitude = as.numeric(as.character(peak_measures$Amplitude)) #Convert to numeric
peak_measures$Condition = factor(peak_measures$Condition, levels = c('Mean','Maximum','Base to Peak','Gain','Loss')) #Reorganize factor order

####  Figure 3A                                                           ####
peaks_plot = ggplot(peak_measures[1:nbsubjects*3,],aes(x=Condition,y=Amplitude,fill = Condition))+ #Setup plot
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
peak_plot_conditional = ggplot(peak_measures[(nbsubjects*3):(nbsubjects*5),],aes(x=Condition,y=Amplitude,fill = Condition))+ #Setup plot
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
peak_plot_conditional #Display plot

####  Figure 3C                                                           ####
colnames(data_Latency) = ('Amplitude') #Rename column
data_Latency$Amplitude = data_Latency$Amplitude*1000 #Turn data into milliseconds
data_Latency$Condition = as.factor(1) #Determine where on the x axis it will be
data_Latency[(nbsubjects+1):(nbsubjects*2),1] = NA #This creates an empty 'second condition' so that the sizing of the chart is the same as the others

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


##########################################################################
#### Statistics                                                           ####
##########################################################################
#### Table 1                                                              ####
####  ERP                                                                 ####

ERPMean_TTest = t.test(mean_peaks,mu=0) #Conduct t-test
ERPMean_SD = sd(mean_peaks) #Determine standard deviation
ERPMean_Cohend = cohen.d(mean_peaks,rep(0,nbsubjects),paired = TRUE) #Conduct cohen's d effect size

ERPMax_TTest = t.test(max_peaks,mu=0) #Conduct t-test
ERPMax_SD = sd(max_peaks) #Determine standard deviation
ERPMax_Cohend = cohen.d(max_peaks,rep(0,nbsubjects),paired = TRUE) #Conduct cohen's d effect size

ERPBtP_TTest = t.test(basetopeaks_peaks,mu=0) #Conduct t-test
ERPBtP_SD = sd(basetopeaks_peaks) #Determine standard deviation
ERPBtP_Cohend = cohen.d(basetopeaks_peaks,rep(0,nbsubjects),paired = TRUE) #Conduct cohen's d effect size

ERPP200_TTest = t.test(base_peaks,mu=0) #Conduct t-test
ERPP200_SD = sd(base_peaks) #Determine standard deviation
ERPP200_Cohend = cohen.d(base_peaks,rep(0,nbsubjects),paired = TRUE) #Conduct cohen's d effect size

matrix1 <- matrix(c(ERPMean_TTest$estimate, ERPMax_TTest$estimate, ERPBtP_TTest$estimate, ERPMean_SD, ERPMax_SD, ERPBtP_SD,ERPMean_Cohend$estimate,ERPMax_Cohend$estimate,ERPBtP_Cohend$estimate), nrow = 3)
#### Table 2                                                              ####
####  ERP                                                                 ####
ERPgain_TTest = t.test(gain_peaks,mu=0) #Conduct t-test
ERPgain_SD = sd(gain_peaks) #Determine standard deviation
ERPgain_Cohend = cohen.d(gain_peaks,rep(0,nbsubjects),paired = TRUE) #Conduct cohen's d effect size

ERPlose_TTest = t.test(lose_peaks,mu=0) #Conduct t-test
ERPlose_SD = sd(lose_peaks) #Determine standard deviation
ERPlose_Cohend = cohen.d(lose_peaks,rep(0,nbsubjects),paired = TRUE) #Conduct cohen's d effect size

matrix2 <- matrix(c(ERPgain_TTest$estimate, ERPlose_TTest$estimate, ERPgain_SD, ERPlose_SD, ERPgain_Cohend$estimate,ERPlose_Cohend$estimate), nrow = 2)

