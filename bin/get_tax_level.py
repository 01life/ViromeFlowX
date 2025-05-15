import argparse
import os

def extract(lines, level, path):
    """
    :param  lines:       lines of the input abundance table with taxid
    :param  level:       phylum/genus/species
    :param  path:       Output path

    """

    flag = level.strip()[0]
    n = 1
    #content = []
    out = open(os.path.join(path, level+".pr"), "w")
    #遍历文件所有行数据
    for line in lines:
        #跳过第一行
        cols = line.strip().split('\t')
        if line[0] != '#' :
            #处理头信息
            if cols[0]=='Taxonomy':
                content = "\t"+"\t".join(cols[1:]) + '\n'
                out.write(content)
            else:
            #提取门属种级别丰度信息
                lev = cols[0].strip().split(";")[-1]
                if(flag==lev[0]):
                    newID=lev.split("__")[1]
                    if (newID == ""):
                        newID = 'unclassify'+str(n)
                        n += 1
                    content = str(newID)+"\t"+"\t".join(cols[1:]) + '\n'
                    #content += "\t".join(x for x in cols) + "\n"
                    out.write(content)
    
    #print(content)
    # out.writelines(content)
    # out.flush()
    out.close()        

argp = argparse.ArgumentParser(prog="mpa_tax_level.py",
                               description="Abundance of diferent taxonomy.")
argp.add_argument("-i", help="abundance table with taxid")
argp.add_argument("-l", help="level")
argp.add_argument('-o', help="path of output file")
argp.add_argument('--overwrite', default=False, action='store_true', help="Overwrite output file if exists")

def main( ):

    args = argp.parse_args()

    if not args.l:
        print("missing level argument!")

    if args.i:
        lines = [ x.strip() for x in open(args.i)]
        extract(lines, args.l, args.o if args.o else os.getcwd())
    else:
        print("missing input argument!")


if __name__ == '__main__':
    main()
