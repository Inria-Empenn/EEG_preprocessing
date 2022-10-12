#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Sep 29 21:58:03 2022

@author: ayakabbara
"""
import scipy.io
import seaborn as sns
import matplotlib.pyplot as plt

mat = scipy.io.loadmat('mat_dif.mat')
aa=mat.get("matt_corr_diff")
names_list=['Reference','EEEGLAB','Brainstorm','FieldTrip']
ax = sns.heatmap(aa,linewidths=.5,square=True,xticklabels=names_list,yticklabels=names_list)
fig = ax.get_figure()
fig.savefig("corrstudy_diff.png",dpi=300)

mat = scipy.io.loadmat('mat_cor.mat')
aa=mat.get("mat_cor")
names_list=['Reference','EEEGLAB','Brainstorm','FieldTrip']
ax = sns.heatmap(aa,linewidths=.5,square=True,xticklabels=names_list,yticklabels=names_list)
fig = ax.get_figure()
fig.savefig("corrstudy_gainloss.png",dpi=300) 
