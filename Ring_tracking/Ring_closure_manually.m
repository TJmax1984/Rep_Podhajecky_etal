function res=Ring_closure_manually(filename,degree,anaphase_onset,last_frame,pixel_size,dt)
    %% Tracking ring closure manually
    % In this function, you will track the front of the ingressing ring from
    % midplane movies by clicking on it. 
    
    % Preconditions:
    % - Input parameters are the rotation degree, anaphase onset, the last
    %   frame (when the ring is closed), and the time point of when the 
    %   temperature shift in case there was a temp shift.

    % Output:
    % - it saves Ring_closure.mat in the current rirectory which contains all the info 
    
    %% Generate variables & pre-allocate
    specifyframes = [anaphase_onset : last_frame];
    distance = nan(length(specifyframes),1);
    xy_coordinates = nan(2,2,length(specifyframes));

    if exist('analyzed_slices','dir') ~= 7
        mkdir('analyzed_slices')
    end
    %% Loop through the time points
    inc = 1;
    for time = specifyframes;  
        im = imread(filename,time);
        im = imrotate(im,degree);
        imagesc(im)
        axis image
        zoom(1.5)                
        title(['slice ',num2str(time)])
        [x, y] = ginput(2);
        hold on
        scatter(x(1), y(1),'r','filled')
        scatter(x(2), y(2),'g','filled')
        hold off
        
        saveas(gcf,[cd,filesep,'analyzed_slices',filesep,'timepoint',num2str(time),'.png'])
        xy_coordinates(:,:,inc) = [x(1) y(1);x(2) y(2)];
        dx = x(1)-x(2);
        dy = y(1)-y(2);
        distance_pix(inc) = sqrt((dx^2)+(dy^2));
        inc = inc+1;
    end
    distance_um = distance_pix*pixel_size;
    Ring_closure.degree = degree;
    Ring_closure.anaphase_onset = anaphase_onset;
    %Ring_closure.temp_shift = temp_shift;
    Ring_closure.last_frame = last_frame;
    Ring_closure.xy_coordinates = xy_coordinates;
    Ring_closure.distance_pix = distance_pix;
    Ring_closure.distance_um = distance_um;
    Ring_closure.dt = dt;
    Ring_closure.filename = filename;
    Ring_closure.pixelsize = pixel_size;

    save('Ring_closure.mat','Ring_closure')
    clear specifyframes distance_pix  distance_um inc im xy_coordinates distance x y filename degree anaphase_onset last_frame temp_shift
end