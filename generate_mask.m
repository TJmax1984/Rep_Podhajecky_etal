function res = generate_mask(filename)
%% generate mask (from A0.tif file for usage in PIVlab) 
% generates binary mask, zeros are BG, ones are embryo

I = imread(filename);      % Note: A0 needs to be 8-bit, otherwise it sometimes doesn't work

% This gaussian just blurs the whole image
h=fspecial('gaussian', 10, 5);
% h=fspecial('gaussian', 80, 40);
Ifilt = imfilter(I,h);
It = im2bw(Ifilt,graythresh(Ifilt));

% Subtraction of the thresholded image from the dilated one, gives the outline of the embryo approximately
% Not perfect though
I1 = (imdilate(It,strel('disk',2)) - It);
If = imfill(I1,'holes');
% erode once to partially reconstruct the thresholded image
I2 = imerode(If,strel('disk',2));

% Remove anything with area less than 40 pixels. this basically removes
% the background around the embryo
bw = bwareaopen(I2,40);

Ilabel = bwlabel(bw);
Iarea = regionprops(Ilabel, 'area');
D = [Iarea.Area];                           % get all area sizes from the image and put them in a normal 1D array called D
% find biggest object and assign as the embryo
[~,ind] = max(D);                           % get the indexnumber of the largest area (the embryo)
%gives the index of where the embryo's located
[i] = find(Ilabel==ind);                    % get all the indices of where the embryo is  

mask = zeros(size(I));
mask(i) = 1;                            % Note there are two files now that are similar but not the same: PIBlab_res.mask has NaN outside of embryo, mask has 0 outside of embryo. Indices of embryos are 1 in both and are the same 
mask_peri = bwperim(mask);              % Creates an array that has the embryos border set at '1' and the rest at '0' 
I = im2double(I);
I_threshold_overlay = imoverlay(I,mask_peri);  % overlays the mask_peri and the original A0 image named I

close all
figure,imshow(I_threshold_overlay)
mask = im2bw(mask);
%saveas(gcf,fullfile(fileparts(filename),'segmented_image'),'png') % saved bordered image
close all
res = mask;
end
