# -*- coding: utf-8 -*-
"""
Created on Tue Feb 26 16:54:33 2019

General particle stuff

@author: Mark
"""

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def get_expt_info(expt_file):
    #Read info from text file of experiment data. If you haven't done so already, convert the .m file to a .txt file. 
    #Should be able to deal with spaces and stuff. 
    expt = {}       #dict variable for experiment functions
    with open(expt_file) as f:
        for line in f:
            print(line)
            if "=" in line:
                L = line.split("=")
                new_key = L[0]
                new_key = new_key[5:].replace(' ','')
                nv = L[1].split(";")
                nv2 = nv[0]
                #new_val = nv2[2:-1]
#                if "'" in new_val:
#                    expt[new_key] = new_val
                if is_number(nv2):
                    if '.' in nv2:
                        expt[new_key] = float(nv2)
                    else:
                        expt[new_key] = int(nv2)
                elif "[" in nv2 and "]" in nv2:
                    nv2 = nv2.replace(' ','')
                    nv2 = nv2[1:-1]
                    val = nv2.split(',')
                    new_value = [];
                    for i in range(0,len(val)):
                        if ":" in val[i]:
                            print("Something")
                            nv3 = val[i].split(":")
                            if len(nv3) == 2:
                                for j in range(int(nv3[0]),int(nv3[1])+1):
                                    new_value.append(j)
                            elif len(nv3) == 3:
                                R = nompie.arange(float(nv3[0]), float(nv3[2]), float(nv3[1]))
                                for j in range(0,len(R)):
                                    new_value.append(R[j])
                            else:
                                print("Wtf")
                        else:
                            if is_number(val[i]):
                                try:
                                    new_value.append(int(val[i]))
                                except:
                                    new_value.append(float(val[i]))    
                            else:
                                new_value.append(val[i])
                    expt[new_key] = new_value
                    pass
                else:
                    expt[new_key] = nv2[2:-1]
                    pass
                
    return expt      