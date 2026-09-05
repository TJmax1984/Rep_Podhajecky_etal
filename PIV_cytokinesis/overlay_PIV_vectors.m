function overlay_PIV_vectors(image,flow_field)

% input arguments
% - filename is full pathname of the tif file
% - t_number = number of the slice should the tif file be a tif stack
% - flow_field should be in the format x,y,vx,vy as columns
    imshow(image,[])
    hold on
    quiver(flow_field(:,1),flow_field(:,2),flow_field(:,3),flow_field(:,4),1,'g','LineWidth',1); % the '1' here is the scaling factor, normally it is set to '0'
end