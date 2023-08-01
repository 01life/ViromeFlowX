import sys,numpy

parent_child_Dir , childValueDir, allitem= {},{},[]
#software = sys.argv[3]

with open(sys.argv[1],'r') as mpaF, open(sys.argv[2],'w') as outF:
    outF.write("child\tparent\tgrandsonNumber\tabundance\n")
    for a in mpaF:
        al = a.strip().split('\t')
        idline = al[0].split("|")
        if len(idline) > 1 and a[0] in ["d","k"]:
            parent_child_Dir.setdefault(idline[-2],[]).append(idline[-1])
            avgAbundance = numpy.average(list(map(float, al[1:])))
            childValueDir[idline[-1]] = [idline[-2],avgAbundance] # 加和所有标本总丰度
            allitem.append(idline[-1])


        else:
            if a[0] in ["d","k"] :
                childValueDir[al[0]] = ["",al[-1]]
                allitem.append(al[0])

    for b in set(allitem):
        if b in parent_child_Dir:
            outputline = "%s\t%s\t%s\t%s\n"%(b,childValueDir[b][0],str(len(parent_child_Dir[b])),str(childValueDir[b][1]))
            
        
        else:
            if b[0] == "s":
                outputline = "%s\t%s\t%s\t%s\n"%(b,childValueDir[b][0],"1",str(childValueDir[b][1]))
            else:
                outputline = "%s\t%s\t%s\t%s\n"%(b,",",str(len(parent_child_Dir[b])),str(childValueDir[b][1]))
        outF.write(str(outputline))




    


