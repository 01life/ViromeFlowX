#! usr/bin/env python
import re
import os
import sys
import shlex
import subprocess
import argparse

def parse_arguments(args):
    parser = argparse.ArgumentParser(
    description= "use bowtie2 to remove host and not save sam file\n",
    formatter_class=argparse.RawTextHelpFormatter)
    
    parser.add_argument(
        "-i1","--input1",
        help="input fastq file Pair 1, or Single",
        required=True)
    parser.add_argument(
        "-i2","--input2",
        help="input fastq file Pair 2")
    parser.add_argument(
        "--bowtie2-options",
        help="bowtie2 options",
        default="--very-sensitive --no-head --reorder")
    parser.add_argument(
        "-db","--database",
        help="reference database",
        required=True)
    parser.add_argument(
        "-t","--threads",
        type=int,
        help="the number of threads to use, default all",
        default=len(os.sched_getaffinity(0)))
    parser.add_argument(
        "-o",
        dest="output",
        help="output prefix",
        required=True)
    parser.add_argument(
        "--gzip",
        action="store_true",
        help="gzip the output,if not add, output fastq",
        default=False)
    
    return parser.parse_args()

def rmhost_with_bowtie(pair1,pair2,database,threads,options,out,gzip):
    
    command=['bowtie2','--threads',str(threads),'-x',database]
    command+=shlex.split(options)

    if pair2:
        out1 = out+'_rmhost_1.fq'
        out2 = out+'_rmhost_2.fq'
        pair1_unaligned=open(out1,"wt")
        pair2_unaligned=open(out2,"wt")
        command+=['-1',pair1,'-2',pair2]
    else:
        out1 = out+'_rmhost.fq'
        pair1_unaligned=open(out1,"wt")
        command+=[pair1]

    p = subprocess.Popen(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    reads_surviving=0

    if pair2:
        for line in p.stdout:
            data=line.decode('utf-8').rstrip().split("\t")
            flag=int(data[1])
 
            if (flag & 4) and (flag & 8): # other mode: "(flag & 4) or (flag & 8)"
                if flag & 64:
                    pair1_unaligned.write("\n".join(["@"+data[0]+"/1",data[9],"+",data[10]])+"\n")
                    reads_surviving+=1
                else:
                    pair2_unaligned.write("\n".join(["@"+data[0]+"/2",data[9],"+",data[10]])+"\n")

        pair1_unaligned.close()
        pair2_unaligned.close()
          
        if gzip:
            subprocess.check_call(['pigz','-f','-p',str(threads),out1,out2])
    else:
        for line in p.stdout:
            data=line.decode('utf-8').rstrip().split("\t")
            flag=int(data[1])
 
            if flag & 4: 
                reads_surviving+=1
                pair1_unaligned.write("\n".join(["@"+data[0],data[9],"+",data[10]])+"\n")

        pair1_unaligned.close()
          
        if gzip:
            subprocess.check_call(['pigz','-f','-p',str(threads),out1])

    reads_total=0
    for line in p.stderr:
        line=line.decode('utf-8')
        print(line,end='')
        if reads_total>0:
            continue
        searchObj=re.search( r'^(\d+) reads', line)
        if searchObj is not None:
            reads_total=int(searchObj.group(1))
    print("Input Reads: "+str(reads_total)+"\nSurviving Reads: "+str(reads_surviving),file=sys.stderr)

def main():
    # parse the command line arguments
    args = parse_arguments(sys.argv)

    path = os.path.dirname(args.output)
    if path and not os.path.isdir(path):
        os.makedirs(path)

    rmhost_with_bowtie(args.input1,args.input2,args.database,args.threads,args.bowtie2_options,args.output,args.gzip)

if __name__ == "__main__":
    main()
