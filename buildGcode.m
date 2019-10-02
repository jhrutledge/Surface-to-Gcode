% -------------------------------------------------------------------------
% buildGcode.m
% This function takes the vertices of a surface from an stl file, then
% sends the points to meshVertices which returns a mesh adjusted to the
% working envelope and scaled and offset for the tool size. This mesh is
% used to define an ordered array of the points for each tool position 
% in a single pass of the surface, this is repeated until full depth.
% This array is used to build an array of strings of each line of g-code
% required. Then the same is done for a finishing pass at the position of
% the final cut. This string is concatenated to the output.
%
% inputs
%           file_in:        string filename for stl of surface to cut
%           t_0:            depth of cut
%           r_tool:         radius of tool
%           dim:            maximum envelope of machine
%           feed:           feed rate for cutting moves
% outputs
%           g_strings_code: array strings defining points for each line of code
%
% written by: Jackson Rutledge 
% -------------------------------------------------------------------------
function [g_strings_code] = buildGcode(file_in,t_0,r_tool,dim,feed)

%% - Read File
[Face,Vert,Norm] = stlread(file_in);
% assumes file has desired surface pointing towards z+ and lowest vertices at z=0

%% - Create Roughing mesh
res = 2;
[xq,yq,zq] = meshVertices(res,Vert,t_0,r_tool,dim);

%% - Setup G-code points for roughing
max_z = max(max(zq));  % return height
[r,c] = size(xq);
nm_ps = ceil(max_z/t_0); % number of passes
% first pass of face
g_xyz = zeros(3);
ln_tmp = 0;       % length of g_code
for i=1:1:c         % step through columns
    for j=1:1:r         %step through rows (y)
        if ~isnan(zq(j,i))
            g_xyz(j,:) = [xq(j,i),yq(j,i),zq(j,i)];
        end
    end
    g_xyz = g_xyz(any(g_xyz,2),:);      % remove unused cells
    ln_p = length(g_xyz);
    if mod(i,2)     % reverse order for odd rows
        g_xyz = flipud(g_xyz);
    end
    if ln_p>3       % if g_xyz has points
        if ln_tmp~=0
            g_tmp(ln_tmp+1:ln_tmp+ln_p,:) = g_xyz;
        else        % if first pass of tool
            g_tmp = g_xyz;
        end
        ln_tmp = length(g_tmp);
        g_xyz = zeros(3);    % clear gxyz
    end
end
ln_tmp = length(g_tmp);
for k=1:1:nm_ps
    g_code((k-1)*ln_tmp+1:k*ln_tmp,:) = g_tmp; % add to main array
    g_tmp(:,3) = g_tmp(:,3) - t_0;      % decrement z value
    g_tmp = flipud(g_tmp);          % flip coordinates to cut in reverse
end
z_dep = nm_ps * t_0;   % offset depth

%% - Create Strings of roughing
g_strings = buildStrings(g_code,feed);
g_strings_code = g_strings;
ln_strs = length(g_strings_code);

%% - Create Finishing mesh
res = 1;
[xq,yq,zq] = meshVertices(res,Vert,t_0,r_tool,dim);
zq = zq - (z_dep+(t_0/3));

%% - Create G-code points for finishing
[r,c] = size(xq);
% first pass of face
g_xyz = zeros(3);
ln_tmp = 0;       % length of g_code
for i=1:1:c         % step through columns
    for j=1:1:r         %step through rows (y)
        if ~isnan(zq(j,i))
            g_xyz(j,:) = [xq(j,i),yq(j,i),zq(j,i)];
        end
    end
    g_xyz = g_xyz(any(g_xyz,2),:);      % remove unused cells
    ln_p = length(g_xyz);
    if mod(i,2)     % reverse order for odd rows
        g_xyz = flipud(g_xyz);
    end
    if ln_p>3       % if g_xyz has points
        if ln_tmp~=0
            g_tmp(ln_tmp+1:ln_tmp+ln_p,:) = g_xyz;
        else        % if first pass of tool
            g_tmp = g_xyz;
        end
        ln_tmp = length(g_tmp);
        g_xyz = zeros(3);    % clear gxyz
    end
end

%% - Create Strings of finishing
feed_fin = feed * 0.4;
g_strings = buildStrings(g_tmp,feed_fin);
ln_tmp = length(g_strings);
g_strings_code(ln_strs+1:ln_strs+ln_tmp,:) = g_strings;
