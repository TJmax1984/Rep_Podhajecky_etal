function res = AP_grad_cyto_fluo_cont(im,bin_feats,halfstripewidth)
% pre-conditions:
% - im is the roated image, such that the AP axis is horizontal
% - bin_feats is a structure array that was made in binning_stripe_coords.m 

fluo_int_cont = nan(1,length(im(1,:)));

binwidth = bin_feats.bin_x_coords(2)-bin_feats.bin_x_coords(1);
% crop image to stripe
%im_crop = im(bin_feats.ecenter_y-halfstripewidth:bin_feats.ecenter_y+halfstripewidth,bin_feats.bin_x_coords(1):bin_feats.bin_x_coords(end)+binwidth);
im_crop = im(bin_feats.ecenter_y-halfstripewidth:bin_feats.ecenter_y+halfstripewidth,bin_feats.bin_x_coords(1):bin_feats.bin_x_coords(end));

fluo_int_cont = mean(im_crop,1,'omitnan');

res = fluo_int_cont;

end