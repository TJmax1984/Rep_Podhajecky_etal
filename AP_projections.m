% Pre-conditions:
% - first run proj_from_ND2_files.m
% - It is necessary to have a LR max porjection inside the 
%   Rotations_projections folder in each embryo directory

% Output:
% - Generates a file in the condition directory called ring_coords.mat,
%   which contain the x_coordinates (1st row) and y_coorindates (second row)
%   of the center of the cytokinetic ring (manually defined).
% - In the Rotations_projections folder it generates the AP projection as
%   tif file. It uses bilinear interpolation. 

clear all, close all

% initial paramters
no_z_slices = 24;
width_crop = 100; % width in number of pixels to crop the stack around the cytokinetic ring (omitting the A and P halves)
dz = 1; % in um
pixel_size =  0.1119; % in um

% specify the path of the condition
%Path = 'C:\Users\teije\Desktop\05112025 Github SWG59 unc60 24hr RNAi\L4440';
%% Extract the folder structure and loop through the movie folders
Path = uigetdir(path,'select directory of the condition to be analyzed');

% extract filenames of the full stacks
files = subdir([Path filesep 'mK_full_stack.tif']);
filenames = {files.name};
% and extract filenames of the paramters files
par_fil = subdir([Path filesep '*.txt']);
par_files = {par_fil.name};

% First run a loop separately to click on the ring and get its x coord
if exist([Path filesep 'ring_coords.mat']) ~= 2 %check if the file already exists
    for i = 1:length(filenames)
        % extract last frame from paramters file and load in last frame image
        % from LR max proj stack
        par_array = readcell(par_files{i});
        last = par_array{6};
        Pathname = fileparts(filenames{i});
        im_last = imread([Pathname filesep 'mK_LR_max_proj.tif'],last);
        imagesc(im_last)
        title('click on the center of the closed ring')
        [x,y] = ginput(1);
        x_coords(i) = x;
        y_coords(i) = y;
    end
    coords = vertcat(x_coords,y_coords);
    save([Path filesep 'ring_coords.mat'],'coords')
    clear coords x_coords y_coords
end
% load x and y coords again
load([Path filesep 'ring_coords.mat'])
x_coords = coords(1, :);
y_coords = coords(2, :);

% Now loop thoguh the data
for j = 1:length(filenames)
    Pathname = fileparts(filenames{j});
    % crop the full stack around the point ideintified as center of the
    % ring
    im_inf = imfinfo(filenames{j});
    no_slices_tot = length(im_inf);
    no_timepoints = no_slices_tot/no_z_slices;
    for slice = 1:no_slices_tot
        fullstack(:,:,slice) = imread(filenames{j},slice);
    end
    % crop full stack
    fullstack_crop = fullstack(:,round(x_coords(j)-0.5*width_crop):round(x_coords(j)+0.5*width_crop),:);
    slices = [1:no_z_slices:no_slices_tot];
    % now make the projection in each timepoint
    inc = 1;
    for m = slices
        crop_temp = fullstack_crop(:,:,m:m+no_z_slices-1);
        APproj(:,:,inc) = make_APproj_new(crop_temp,pixel_size,dz);
        inc=inc+1;
    end
    % save the AP projection
    if exist([Pathname filesep 'AP_proj.tif']) ~= 2 %check if the file already exists
        for time = 1:length(APproj(1,1,:))
            imwrite(uint16(APproj(:,:,time)),[Pathname filesep 'AP_proj.tif'],'WriteMode', 'append')
        end
    end
    x_coord = x_coords(j); 
    y_coord = y_coords(j);
    save([Pathname filesep 'x_coord_ring'],'x_coord')
    save([Pathname filesep 'y_coord_ring'],'y_coord')

    clear fullstack fullstack_crop APproj x_coord y_coord
end