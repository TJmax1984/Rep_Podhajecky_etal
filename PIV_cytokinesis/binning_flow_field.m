function res = binning_flow_field(im,vector_field,bin_xcoords,emb_center_y,half_stripewidth)
%% This function does binning in a horizontal stripe
% As in Naganathan et al Elife 2016 and Middelkoop et al PNAS 2021

% Note: In Naganathan and Middelkoop et al there was an extra filtering in
% which the vectors larger than 2SD's in each bin were removed. Because
% there is already filtering done in the core PIV code I did not implement
% that step here.

% pre-conditons:
% - im: the original image, only for visualization purposes
% - vector_field should be a 2D array with 4 columns. Column 1: x
%   coordinates, Column 2: y-coordiantes, columns 3: vx, columns 4: vy
% - mask: logial matrix with the AP axis horizontal
% - No_bins = number of bins
% - half_stripewidth: half of the vertical width of the horizontal stripe
%   that will be used for the binning 

% Output:

close all

%% First extract variables to make the code more readable
x_values = vector_field(:,1);
y_values = vector_field(:,2);
vx = vector_field(:,3);
vy = vector_field(:,4);

%% Now subdivide in bins and average vectors in each bin
% Pre-allocate the variables
bin_width = bin_xcoords(2)-bin_xcoords(1);
No_bins = length(bin_xcoords);
vx_bins = NaN(1,No_bins);
vy_bins = NaN(1,No_bins);
mag_bins = NaN(1,No_bins);

for bin = 1:No_bins % Run the loop for each bin
        % The next line finds the x_rot and y_rot values for each bin and
        % puts it as one single row vector called stripe.         
        stripe = find(x_values >= bin_xcoords(bin) & x_values < bin_xcoords(bin)+bin_width & y_values >= (emb_center_y-half_stripewidth) & y_values <= (emb_center_y+half_stripewidth));
        
        % get all the velocities for the positions that you have chosen in the previous step
        vx_stripe = vx(stripe); % get the x velocities in current bin 
        vy_stripe = vy(stripe); % get the y velocities in current bin 
        mag_stripe = sqrt((vx_stripe.^2) + (vy_stripe.^2));% get the magnitudes in current bin 
        
        % Visual check whether the bin is generated correctly
        imagesc(im)
        axis image
        hold on
        quiver(x_values, y_values,vx,vy,'g','AutoScale','off')
        quiver(x_values(stripe), y_values(stripe),vx_stripe,vy_stripe,'r','AutoScale','off')
        hold off
        close all
        
        % Extract the mean in the current bin
        vx_mean(bin) = mean(vx_stripe,1,'omitnan');
        vy_mean(bin) = mean(vy_stripe,1,'omitnan');
        mag_mean(bin) = mean(mag_stripe,1,'omitnan');
end
res = [vx_mean;vy_mean;mag_mean];
end