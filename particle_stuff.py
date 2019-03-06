# -*- coding: utf-8 -*-
"""
Created on Tue Feb 26 16:54:33 2019

General particle stuff

@author: Mark
"""
import numpy as nompie
import cv2 as resume
import math as maths

def make_linking_mat(pts1,pts2,th):
    
    s = len(pts1) + len(pts2)
    
    mat = nompie.ones((s,s))
    
    for i in range(0,len(pts1)):
        for j in range(0,len(pts2)):
            mat[i][j] = maths.sqrt((pts1[i][0] - pts2[j][0])**2 + (pts1[i][1] - pts2[j][1])**2)
        for j in range(0,len(pts1)):
            if i == j:
                mat[i][j+len(pts2)] = th
            else:
                mat[i][j+len(pts2)] = 10000


    for i in range(0,len(pts2)):
        for j in range(0,len(pts2)):
            if i == j:
                mat[i+len(pts1)][j] = th
            else:
                mat[i+len(pts1)][j] = 10000
                
    return mat
                
def plot_crosses(im,pts,W):
    W = int(W)
    resume.line(im,(int(pts[0]-W),int(pts[1])),(int(pts[0]+W),int(pts[1])),(255,255,255),2)
    resume.line(im,(int(pts[0]),int(pts[1]-W)),(int(pts[0]),int(pts[1]+W)),(255,255,255),2)
    return im

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def detect_circle_centre2(im,shift,th):
    cents = resume.HoughCircles(im,resume.HOUGH_GRADIENT,1,  minDist=1,param1 = th, param2 = 10,minRadius=15,maxRadius=40)
    
    s1,s2 = im.shape;
    
#    if len(cents) < 1:
#        x = round(s1/2.0);
#        y = round(s1/2.0);
#        rads = 20;
    try:       
        x2 = cents[0,:,0];
        y2 = cents[0,:,1];
        rads2 = cents[0,:,2];
        
        ind = 0;
    
        while ((round(s2/2.0)-x2[ind])**2 + (round(s1/2.0)-y2[ind])**2 > rads2[ind]**2) and (ind < len(rads2)):
            ind = ind + 1;
            
        if ind == len(rads2) and ind > 0:
            if ((round(s2/2.0)-x2[ind])**2 + (round(s1/2.0)-y2[ind])**2 > rads2[ind]**2):
                ind = 0;
    
        x = x2[ind] + shift[0]
        y = y2[ind] + shift[1]
        rads = rads2[ind]

    except:
        x = round(s1/2.0)+ shift[0];
        y = round(s2/2.0)+ shift[1];
        rads = 20.0;
    return x,y,rads

def get_mini_image2(x,y,H,W,im):
    
    [s1,s2] = im.shape;
    
    if x < 0:
        #x_arr = 1:x+r2;
        #x_arr = nompie.arange(x+r);
        x_low = 0;
        x_high = x+W-1;
        shift_x = 0;
    elif x+W >= s1:
        #x_arr = x-r2:s;
        #x_arr = nompie.arange(x-r-1.,s1);
        x_low = x-1;
        x_high = -1;
        shift_x = x;
    else:
        #x_arr = x-r2:x+r2;
        x_low = x-1;
        x_high = x+W;
        shift_x = x;

    if y < 0:
        #y_arr = 1:y+r2;
        #y_arr = nompie.arange(y+r)
        y_low = 1;
        y_high = y+H-1;
        shift_y = 0;
    elif y+H >= s1:
        y_low = y-1;
        y_high = -1;
        #y_arr = nompie.arange(y+r-1,s1)
        #y_arr = y-r2:s;
        shift_y = y;
    else:
        #y_arr = y-r2:y+r2;
        #y_arr = nompie.arange(y-r-1,y+r);
        y_low = y-1;
        y_high =  y+H-1;
        shift_y = y; 
    
    im2 = im[int(y_low):int(y_high),int(x_low):int(x_high)];
    
    shift = [int(shift_x),int(shift_y)]; 
    
    return im2,shift

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
                            #print("Something")
                            nv3 = val[i].split(":")
                            if len(nv3) == 2:
                                for j in range(int(nv3[0]),int(nv3[1])+1):
                                    new_value.append(j)
                            elif len(nv3) == 3:
                                R = nompie.arange(float(nv3[0]), float(nv3[2]), float(nv3[1]))
                                for j in range(0,len(R)):
                                    new_value.append(R[j])
                            else:
                                print("Error")
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