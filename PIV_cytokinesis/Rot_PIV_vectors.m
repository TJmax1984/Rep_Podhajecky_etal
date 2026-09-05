function res = Rot_PIV_vectors(x,y,vx,vy,radians,im_center,im_center_rot)

% function to rotate the vectors and assign the vectors to the new rotated
% pixel positions

% Note that this code is saved in Sjak analysis, but it is used in other
% analysis as well, for example early flow analysis v11.

% I NEED TO VERIFY THE NEXT STEP OF FLIPPING THE VY, ALSO IN RELATION TO
% THE SIGN OF THE FLOW FIELD ROTATION
% Change sign of vy so as to bring vx and vy in the right handed coodinate
% system. This is to overcome the disrepancy between linear algebra (image
% visualization) coordinate system, which has incresasing y values from top to 
% bottom, and cartesian coordiante system which has the opposite
%vy = - (vy); % NOTE: this is obviously NOT to correct for the movies being
%mirror images, CHECK WHY IT IS!!

% rotation matrix to rotate vectors anticlockwise
R = [cos(radians) -sin(radians); sin(radians) cos(radians)];

%% First subtract the image center coordinates of the PIV xy coordinates
x=x-im_center(1);
y=y-im_center(2);

%% Now rotate the vy coordinates and the vectors 
for i = 1:length(vx)              
    Rot_xy = R * [x(i); y(i)];
    xrot(i) = Rot_xy(1);
    yrot(i) = Rot_xy(2);   

    Rot_vx_vy = R * [vx(i); vy(i)];
    vxrot(i) = Rot_vx_vy(1);
    vyrot(i) = Rot_vx_vy(2);        
end

%% Add now add the rotated image center coordinates to the PIV xy coordinates
xrot = xrot+im_center_rot(1);
yrot = yrot+im_center_rot(2);
xrot = xrot(:);
yrot = yrot(:);

vxrot = vxrot(:);
vyrot = vyrot(:);
%quiver(xrot,yrot,vxrot,vyrot,'r')
res = horzcat(xrot,yrot,vxrot,vyrot);
end

