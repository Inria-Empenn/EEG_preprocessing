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
dataframe = pd.read_csv("gain_peaks.csv", error_bad_lines=False, encoding="ISO-8859-1")

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
fig.savefig("gain-peaks.png") 

# Figure 4 B
dataframe = pd.read_csv("lose_peaks.csv", error_bad_lines=False, encoding="ISO-8859-1")

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
fig.savefig("lose_peaks.png") 

# Figure 4 C
dataframe = pd.read_csv("mean_peaks.csv", error_bad_lines=False, encoding="ISO-8859-1")

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
fig.savefig("mean_peaks.png") 

# Figure 4 D
dataframe = pd.read_csv("max_peaks.csv", error_bad_lines=False, encoding="ISO-8859-1")

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
fig.savefig("max-peaks.png") 

# Figure 4 E
dataframe = pd.read_csv("basetopeaks_peaks.csv", error_bad_lines=False, encoding="ISO-8859-1")

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
fig.savefig("basetopeaks_peaks.png") 

# Figure 4 F
dataframe = pd.read_csv("peak_loc.csv", error_bad_lines=False, encoding="ISO-8859-1")

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
fig.savefig("peak_loc.png") 

