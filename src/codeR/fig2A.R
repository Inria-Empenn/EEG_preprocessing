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





#### Compute 95% confidence intervals                                     ####
#Figure 2 Error Bars

for (counter in 1:600){ #Cycle through time
  t_data = pdata[,c(counter,601,602)] #Extract current time point
  data[counter,5] = qt(0.975,nbparticipants-1) * (sd(t_data[1:500,1])/sqrt(500)) #Determine 95% confidence interval for condition 1
  data[counter,6] = qt(0.975,nbparticipants-1) * (sd(t_data[501:1000,1])/sqrt(500)) #Determine 95% confidence interval for condition 2
  data[counter,7] = qt(0.975,nbparticipants-1) * (sd(t_data[1:500,1]-t_data[501:1000,1])/sqrt(500)) #Determine 95% confidence interval for difference
}

##########################################################################
#### Plotting                                                             ####
##########################################################################
#### Figure 2                                                             ####
dataCW = data[,c(1,2,3)] #Extract relevant data
colnames(dataCW) = c("Time", "Gain", "Loss") #Rename columns
FreqCW = melt(dataCW, id = "Time", measured = c("Gain", "Loss")) #Transform data into long format
#FreqCW$CI = c(data[,5],data[,6]) #Attach 95% confidence intervals
#colnames(FreqCW) = c("Time", "Condition", "Amplitude","CI") #Rename columns
colnames(FreqCW) = c("Time", "Condition", "Amplitude") #Rename columns
#ylimcw = range(-5.5,15) #Determine y limits
ylimcw = range(-5,15) #Determine y limits

ylabcw = expression(paste("Voltage (", mu, "V)", sep ="")) #Amplitude (μV) #Determine y label title
xlabcw = "Time (ms)" #Determine x label title

####  Figure 2A                                                           ####
PlotCW = ggplot(FreqCW, aes(x = Time, y = Amplitude, colour = Condition, linetype =  Condition))+ #Setup plot
  # geom_ribbon(aes(ymin = FreqCW[,3] - FreqCW[,4], ymax = FreqCW[,3] + FreqCW[,4]), colour = NA, fill = c(rep(colours[1],600),rep(colours[2],600)), alpha = .2)+ #Add error bar ribbons
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
