function res = binning_stripe_coords_cyto(x_coord,y_coord,bin_size)

Apole = x_coord-100; Ppole =x_coord+100; 
No_binseq =round(Apole:bin_size:Ppole);

bin_feats.bin_x_coords = No_binseq;
bin_feats.ecenter_y = y_coord;
bin_feats.Apole = Apole; bin_feats.Ppole = Ppole;
res = bin_feats;
end