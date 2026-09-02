function res = generate_coarse_mask(x_coord,y_coord,rot_degree,filename)
%% This function makes a coarse mask, based on the embryo midpoint
% This function uses the center point between the first clicked points that
% mark the ring in Ring_ingression_analysis.m. These clicked points are
% areleady from a rotated embryo, so the mask has to be rotated back.

% it generates a 400*200 mask around the embryo midpoint, and returns is as
% a logical image array, in the unrotated format. 

im = imread(filename,1);
im_rot = imrotate(im,rot_degree);
% imagesc(im_rot)
% hold on, scatter(x_coord,y_coord,'r')
mask_rotated = zeros(length(im_rot(:,1)),length(im_rot(1,:)));
mask_rotated(y_coord-100:y_coord+100,x_coord-200:x_coord+200)=1;
mask_back = imrotate(mask_rotated,-rot_degree);
mask_back = im2bw(mask_back);

[H,W] = size(mask_back);
[h,w] = size(im);


row_start = floor((H-h)/2) + 1;
col_start = floor((W-w)/2) + 1;

mask = mask_back(row_start:row_start+h-1, col_start:col_start+w-1);

% figure
% imagesc(mask)
res = mask;    
    
end