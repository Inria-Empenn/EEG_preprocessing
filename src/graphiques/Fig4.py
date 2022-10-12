#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: ayakabbara
"""

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

colors_list = ['#505050', '#9DBCEA',  '#F78A88',  '#FFD384']


# Figure 4 A
dataframe = pd.read_csv("gain_peaks_samepipe.csv", error_bad_lines=False, encoding="ISO-8859-1")

print(dataframe.head())
print(dataframe.isnull().values.any())
dataframe=dataframe.iloc[:,0:4];
dataframe.columns = ['Reference', 'EEGLAB','BrainStorm','FieldTrip']


sns.set_theme()

aa=sns.violinplot(data=dataframe,palette=colors_list,inner="box")
plt.ylabel('Voltage(μV)', fontsize=16);
plt.tick_params(axis='both', which='major', labelsize=14)

plt.show()
fig = aa.get_figure()
fig.savefig("gainpeat100.png") 

# Figure 4 B
dataframe = pd.read_csv("lose_peaks_samepipe.csv", error_bad_lines=False, encoding="ISO-8859-1")

print(dataframe.head())
print(dataframe.isnull().values.any())
dataframe=dataframe.iloc[:,0:4];
dataframe.columns = ['Reference', 'EEGLAB','BrainStorm','FieldTrip']


sns.set_theme()

aa=sns.violinplot(data=dataframe,palette=colors_list,inner="box")
plt.ylabel('Voltage(μV)', fontsize=16);
plt.tick_params(axis='both', which='major', labelsize=14)

plt.show()
fig = aa.get_figure()
fig.savefig("losepeaks_t100.png") 

# Figure 4 C
dataframe = pd.read_csv("meanpeaks_samepipe.csv", error_bad_lines=False, encoding="ISO-8859-1")

print(dataframe.head())
print(dataframe.isnull().values.any())
dataframe=dataframe.iloc[:,0:4];
dataframe.columns = ['Reference', 'EEGLAB','BrainStorm','FieldTrip']


sns.set_theme()

aa=sns.violinplot(data=dataframe,palette=colors_list,inner="box")
plt.ylabel('Voltage(μV)', fontsize=16);
plt.tick_params(axis='both', which='major', labelsize=14)

plt.show()
fig = aa.get_figure()
fig.savefig("meanpeaks_t100.png") 

# Figure 4 D
dataframe = pd.read_csv("maxpeaks_samepipe.csv", error_bad_lines=False, encoding="ISO-8859-1")

print(dataframe.head())
print(dataframe.isnull().values.any())
dataframe=dataframe.iloc[:,0:4];
dataframe.columns = ['Reference', 'EEGLAB','BrainStorm','FieldTrip']


sns.set_theme()

aa=sns.violinplot(data=dataframe,palette=colors_list,inner="box")
plt.ylabel('Voltage(μV)', fontsize=16);
plt.tick_params(axis='both', which='major', labelsize=14)

plt.show()
fig = aa.get_figure()
fig.savefig("maxpeaks_t100.png") 

# Figure 4 E
dataframe = pd.read_csv("basetopeaks_samepipe.csv", error_bad_lines=False, encoding="ISO-8859-1")

print(dataframe.head())
print(dataframe.isnull().values.any())
dataframe=dataframe.iloc[:,0:4];
dataframe.columns = ['Reference', 'EEGLAB','BrainStorm','FieldTrip']


sns.set_theme()

aa=sns.violinplot(data=dataframe,palette=colors_list,inner="box")
plt.ylabel('Voltage(μV)', fontsize=16);
plt.tick_params(axis='both', which='major', labelsize=14)

plt.show()
fig = aa.get_figure()
fig.savefig("basetopeaks_t100.png") 

# Figure 4 F
dataframe = pd.read_csv("peak_loc_samepipe.csv", error_bad_lines=False, encoding="ISO-8859-1")

print(dataframe.head())
print(dataframe.isnull().values.any())
dataframe=dataframe.iloc[:,0:4];
dataframe.columns = ['Reference', 'EEGLAB','BrainStorm','FieldTrip']


sns.set_theme()

aa=sns.violinplot(data=dataframe,palette=colors_list,inner="box")
plt.ylabel('Time(ms)', fontsize=16);
plt.tick_params(axis='both', which='major', labelsize=14)

plt.show()
fig = aa.get_figure()
fig.savefig("peak_loc_t100.png") 

