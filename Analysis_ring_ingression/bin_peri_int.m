function res = bin_peri_int(bin_peri_coord,xdata,ydata)
%% This function bins x in bins of binwidth with x_bounds and computes the average +STD of ydata
% bin_peri_coord are the bin perimeter coordinates
binwidth = bin_peri_coord(2)-bin_peri_coord(1); 
for bin=1:length(bin_peri_coord)
    bin_mask = (xdata >= bin_peri_coord(bin)) & (xdata < bin_peri_coord(bin) + binwidth);
    bin_values = ydata(bin_mask);
    mean_val(bin) = mean(bin_values);
    std_val(bin) = std(bin_values);
end
res = [mean_val;std_val];
end