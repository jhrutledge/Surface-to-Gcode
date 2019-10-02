% -------------------------------------------------------------------------
% runThis.m
% This is a simple script to call the buildGcode function to create the
% array of g_code lines, which can be printed to a file.
% 
% written by: Jackson Rutledge 
% -------------------------------------------------------------------------
% Clear matlab space
close all; clear all; clc; fclose all;

%% - Inputs
file_in = 'Rutledge_face.stl';  % stl file
path_file = 'Gcode_path.txt';   % output filename for g-code
% cutting parameters [ NT-100 , Robonano ]
z_dep = [0.4, 0.03];             % plunge depth
r_tool = [1, 0.25];              % tool radius
dim = [27, 67, 15; 6, 15, 3];       % cutting envelope
feed = 500;                     % maximum feedrate

mchn = 1;                       % 1=NT-1000 , 2=Robonano

%% - Call Function
g_code = buildGcode(file_in,z_dep(mchn),r_tool(mchn),dim(mchn,:),feed);

%% - Print Results to file
fileID = fopen(path_file,'w+');
fprintf(fileID,'%s\n',g_code);
fclose(fileID);
