#First, set your working directory to the folder with all of the csv data files - you may need to do this manually
library(ggplot2)
library(reshape2)
library(effsize)
library(pwr)
library(RColorBrewer)
library(cowplot)
library(Rfast)
library(Hmisc)


nbparticipants=100;

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



#### Compute 95% confidence intervals                                     ####
#Figure 2 Error Bars  100=nbparticipants 200 le double car premier event puis deuxieme

for (counter in 1:600){ #Cycle through time
  t_data = pdata[,c(counter,601,602)] #Extract current time point
  data[counter,5] = qt(0.975,nbparticipants-1) * (sd(t_data[1:100,1])/sqrt(100)) #Determine 95% confidence interval for condition 1
  data[counter,6] = qt(0.975,nbparticipants-1) * (sd(t_data[101:200,1])/sqrt(100)) #Determine 95% confidence interval for condition 2
  data[counter,7] = qt(0.975,nbparticipants-1) * (sd(t_data[1:100,1]-t_data[101:200,1])/sqrt(100)) #Determine 95% confidence interval for difference
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




#### Statistics                                                           ####
##########################################################################
#### Table 1     
#### Figure 3     
pdata[1:100,1:600] = pdata[1:100,1:600]-pdata[101:200,1:600] #Create difference waves
pdata = pdata[1:100,1:600] #Remove non-difference wave data

p_diffdata = pdata #Recall difference pdata 
pdata = pdata_original #Recall original data 

dataDW = data[,c(1,4,7)] #Extract relevant data
colnames(dataDW) = c('Time','Amplitude','CI') #Rename columns

peak_time_gain=which(data$Gain==max(data$Gain))
peak_time_lose=which(data$Loss==max(data$Loss))


peak_time = which(dataDW$Amplitude==max(dataDW$Amplitude)) #Determine peak time of grand averaged difference wave (for N200)
base_time = which(dataDW$Amplitude[188:226]==min(dataDW$Amplitude[188:226]))+187 #Determine min peak time of the P200 qui se trouve en general entre 150 et 250 ms faire conversion pt temps
mean_peaks = rowMeans(p_diffdata[,sum(peak_time,-23):sum(peak_time,23)]) #Determine mean peak vlues around grand average peak for difference wave
gain_peaks = rowMeans(pdata[1:100,sum(peak_time_gain,-23):sum(peak_time_gain,23)]) #Determine mean peak values around grand average peak for gain waveform 239=max amplitude gain
lose_peaks = rowMeans(pdata[101:200,sum(peak_time_lose,-23):sum(peak_time_lose,23)]) #Determine mean peak values around grand average peak for loss waveform 246 = max lose 
max_peaks = apply(p_diffdata[,200:300], 1, max) #Determine max peak values around grand average peak
basetopeaks_peaks = apply(p_diffdata[,200:300], 1, max) - apply(p_diffdata[,175:225], 1, min) #Determine base-to-peak values around the N200 peak - P200 peak
base_peaks =  apply(p_diffdata[,175:225], 1, min) #Determine base peak values of the P200
#2500 -> 500 bc nb of subject different 
peak_measures = matrix(NA,500,2) #Create variable to store peaks
peak_measures[,1] = c(mean_peaks,max_peaks,basetopeaks_peaks,gain_peaks,lose_peaks) #Store all peak values
peak_measures[,2] = c(rep('Mean',nbparticipants),rep('Maximum', nbparticipants), rep('Base to Peak',nbparticipants),rep('Gain', nbparticipants),rep('Loss', nbparticipants)) #Create labels for each peak measure
peak_measures = as.data.frame(peak_measures) #Convert to data frame
colnames(peak_measures) = c('Amplitude','Condition') #Rename columns
peak_measures$Amplitude = as.numeric(as.character(peak_measures$Amplitude)) #Convert to numeric
peak_measures$Condition = factor(peak_measures$Condition, levels = c('Mean','Maximum','Base to Peak','Gain','Loss')) #Reorganize factor order

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

