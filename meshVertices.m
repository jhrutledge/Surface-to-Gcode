% -------------------------------------------------------------------------
% meshVertices.m
% This function takes the Vertices and adjusts them to the desired
% envelope, and applies them to the correct resolution for defining the
% tool positions.
%
% inputs
%           res:        finishing or roughing pass (1 or 2)
%           Vert:     	Array of vertices from surface
%           t_0:        z-depth of cut
%           r_tool:     radius of tool
%           dim:        workpiece envelope
% outputs
%           xq:         x-mesh
%           yq:         y-mesh
%           zq:         z-mesh
%
% written by: Jackson Rutledge 
% -------------------------------------------------------------------------
function [xq,yq,zq] = meshVertices(res,Vert,t_0,r_tool,dim)

%% - Cutting dimensions for desired resolution
%
% or just do pitch calcs the same and supply different values
if res==1       % finishing pass
    pitch_y = t_0/3;        % y-pitch is path resolution
    pitch_x = r_tool/6;     % x-pitch is cutting edge engagement
else            % roughing pass
    pitch_y = t_0;          
    pitch_x = r_tool/2;     
end

%% - Translate Vertices to origin
for i=1:1:2
    mx(i) = max(Vert(:,i));
    mn(i) = min(Vert(:,i));
    Ran(i) = mx(i) - mn(i);
end
tx = -1*(mn(1) + (Ran(1)/2)); %x-direction move
ty = -1*(mn(2) + (Ran(2)/2)); %y-direction move
tz = 0;                       %already on z plane
M_t = makehgtform('translate',[tx ty tz]);
Vert(:,4) = 1;
[r,c] = size(Vert);
Vert(:,4) = 1;
for i=1:1:r
    Vert(i,:) = (M_t * (Vert(i,:).')).'; %new centered point cloud
end
% vertices centered to (0,0,z)

%% - Scale Vertices to fit machining envelope
for i=1:1:3
    mx(i) = max(Vert(:,i)); % max positve of points
    mn(i) = min(Vert(:,i)); % unnecessary
end
% scale vertices to y
scl = (dim(2)/2)/mx(2);
M_t = makehgtform('scale',scl); %scale vertices to fit in envelope
for i=1:1:r
    Vert(i,:) = (M_t * (Vert(i,:).')).';
end
% if new x_max exceeds dim(1)/2 scale vertices to x
mx(1) = max(Vert(:,1));
if mx(1)>dim(1)/2
    scl = (dim(1)/2)/mx(1);
    M_t = makehgtform('scale',scl); %scale vertices to fit in envelope
    for i=1:1:r
        Vert(i,:) = (M_t * (Vert(i,:).')).';
    end
end
% if new z_max exceeds dim(3) scale vertices to z
mx(3) = max(Vert(:,3));
if mx(3)>dim(3)
    scl = dim(3)/mx(3);
    M_t = makehgtform('scale',scl); %scale vertices to fit in envelope
    for i=1:1:r
        Vert(i,:) = (M_t * (Vert(i,:).')).';
    end
end
for i=1:1:3
    mx(i) = max(Vert(:,i)); % max range of points
end
% Vertices scaled to fit within defined envelope

%% - Interpolate Surface mesh from vertices
newVert = unique(Vert,'rows');  % remove extraneous points
for i=1:1:2
    mx(i) = max(newVert(:,i));
    mn(i) = min(newVert(:,i));
end
[xq,yq] = meshgrid(mn(1):pitch_x:mx(1), mn(2):pitch_y:mx(2));
zq = griddata(newVert(:,1),newVert(:,2),newVert(:,3),xq,yq);
% xq,yq,zq surface mesh

%% - Offset Surface in y,z for tool radius
[Nx,Ny,Nz] = surfnorm(xq,yq,zq);
% skip xq b/c passes are at constant x, x-step set by pitch
yq = yq + (Ny.*r_tool);     % apply tool radius to y
zq = zq + (Nz.*r_tool);     % and z components
% passes follow constant x for length of y
