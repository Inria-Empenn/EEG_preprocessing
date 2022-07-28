import seaborn as sns
import matplotlib.pyplot as plt % matplotlib inline
ax = sns.heatmap(aa,linewidths=.5,square=True,xticklabels=names_list,yticklabels=names_list)
fig = ax.get_figure()
fig.savefig("corrstudy_matrix.png",dpi=300) 
