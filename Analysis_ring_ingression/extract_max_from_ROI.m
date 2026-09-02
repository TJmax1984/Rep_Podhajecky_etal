function res = extract_max_from_ROI(im,xy_coords,half_ROI_length);

%   crop ROI at around each leading end ring end number 1
x_start = xy_coords(1)-half_ROI_length;
x_end = xy_coords(1)+half_ROI_length;

y_start = xy_coords(2)-half_ROI_length;
y_end = xy_coords(2)+half_ROI_length;

% visualize the ROI
% mask = zeros(size(im));
% mask(y_start:y_end,x_start:x_end)=1;
% mask = im2bw(mask);
% mask_outline = bwperim(mask);
%im_overlaid = imoverlay(uint8(im), mask_outline,[1 0 0]);
%imshow(im_overlaid)

% Extract the maximum from the ROI
im_ROI = im(y_start:y_end,x_start:x_end);

res=max(im_ROI(:));

end