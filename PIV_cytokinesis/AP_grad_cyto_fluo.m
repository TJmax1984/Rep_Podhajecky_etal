%% Extract AP gradient of fluorescence
function res = AP_grad_cyto_fluo(im,bin_feats,halfstripewidth)
% pre-conditions:
% - im is the roated image, such that the AP axis is horizontal
% - bin_feats is a structure array that was made in binning_stripe_coords.m 

binwidth = bin_feats.bin_x_coords(2)-bin_feats.bin_x_coords(1);

% pre-allocate 
fluo_int = nan(1,length(bin_feats.bin_x_coords));
for bin = 1:length(bin_feats.bin_x_coords)
    int_vals_bin = im(bin_feats.ecenter_y-halfstripewidth:bin_feats.ecenter_y+halfstripewidth,bin_feats.bin_x_coords(bin):bin_feats.bin_x_coords(bin)+binwidth);
    int_vals_bin = int_vals_bin(:);
    
    fluo_int(bin) = mean(int_vals_bin,'omitnan');
end
res = fluo_int;
end
