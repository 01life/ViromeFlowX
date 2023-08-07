import sys

with open(sys.argv[1],'r') as gffF, open(sys.argv[2],'w') as bebF:
    for a in gffF:
        if a[0] != "#":
            al  = a.strip().split('\t')
            if al[2] == "CDS":
                cdsID  = al[8].split(";")[0].split("_")[1]
                newGeneID = al[0] + "_" + cdsID
                outlist = [al[0],al[3],al[4],newGeneID]
                bebF.write("\t".join(outlist) + '\n')
