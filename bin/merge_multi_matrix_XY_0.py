import sys
import pandas as pd

uniq_index_ID=[]
profileList=[]
with open(sys.argv[1],'r') as profileF:
	n=0
	for a in profileF:
		al=a.strip().split('\t')
		profile=pd.read_csv(al[1],sep="\t",index_col=0,low_memory=False)
		# newColumnsList = [(str(al[0])+'_'+item) for item in list(profile.columns)]
		newColumnsList = [(str(al[0]))]
		profile.columns = newColumnsList
		profileList.append(profile)
		#if n==0:
		#	uniq_index_ID=list(profile.index)
		#else:
		#	uniq_index_ID=list(set(uniq_index_ID).intersection(set(profile.index)))
		#n+=1
#newM=[]
#for b in profileList:
#	bb=b.loc[uniq_index_ID,:]
#	newM.append(bb)
result = pd.concat(profileList, axis=1)
result.to_csv(sys.argv[2],sep="\t",na_rep=0)

