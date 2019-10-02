% -------------------------------------------------------------------------
% buildStrings.m
% This function takes the points for each tool position and adds the
% required letters and symbols. It also adds the G commands and Feed, then
% adds the rapid move to position up before the next code set
%
% inputs
%           g_xyz:        	x,y,z points of each tool position
%           feed:           feedrate for cutting moves
% outputs
%           g_strings:      string array points for each line of code
%
% written by: Jackson Rutledge 
% -------------------------------------------------------------------------
function [g_strings] = buildStrings(g_xyz,feed)

for i=1:1:3
    mx(i) = max(g_xyz(:,i));
end
[r,c] = size(g_xyz);

%% - First
% rapid to above first point
st_1 = strcat("G00 X",num2str(g_xyz(1,1))," Y",num2str(g_xyz(1,2))," Z",num2str(1.1*abs(mx(3))),';');

%% - Cutting Moves
st_2 = strcat("G01 F",num2str(feed),';');  % define feedrate for cutting
g_strings = [st_1 ; st_2];
for i=1:1:r
    st_x = strcat('X',num2str(g_xyz(i,1))," ");
    st_y = strcat('Y',num2str(g_xyz(i,2))," ");
    st_z = strcat('Z',num2str(g_xyz(i,3)),';');
    g_strings(2+i) = strcat(st_x,st_y,st_z);
end

%% - Last
% rapid to above last point
st_xx = strcat("G00 X",num2str(g_xyz(r,1))," Y",num2str(g_xyz(r,2))," Z",num2str(1.1*mx(3)),';');
g_strings(3+r) = st_xx;
