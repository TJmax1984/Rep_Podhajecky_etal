%% This function does PIV,plots and saves the results, and does intensity measurements
% This code is derived from Early_flows_v11.m

% First the ingressing ring fronts need to be tracked by running
% Ring_ingression_analysis.m. 
% Differences from EralyFlows_v11:
% - Timepoints will be derived with respect to ring ingression status.
% - No mask will be made, PIV will be done on a square surrounding the
%   clicked first coordinates of the ring. Bins will be made according to the
%   center of the clicked coordiantes 
% - It only does PIV and intensity measurements on 1 channel, no other channels incliuded

% pre-conditions:
% - have all the data of 1 condition saved in 1 folder that you specify under 'Path'
%   Have the folders with the conditions all in the same directory.
%       1) A tif stack that contains the entire movie of the cortical
%          plane, on which the PIV will be done. If two channels are
%          analyzed then there also should be a tif stack of the other
%          channel. This ch2 movie should have the same length as the other
%          movie. So if timepoints were skipped, it should contain
%          duplicate slices!! This is the default if going from nd2 file to
%          tif stack. 
%       2) Each tif stack for each channel should contain the channel name,
%          as specified in the pop-up window in this code, as exact match 
%          somewhere in the filename. 
%       3) paramters.txt file with rotation and (in
%          case of fluorescence intensity measurments) background fluo
%          (camera noise level). 

% - Specify initial parameters:
%       1) specify number of bins, frame interval, pixelsize, ant bins, pos
%          bins and half stripewidth
%       2) Specify the final PIV box size, it will run a 3-step PIV with increment
%          of 9 pixels each step.
%       3) Specify whether the movie is mirror image
%       4) Specify the middle bins that will be used to extract the mean
%          fluo intensity

% Output:
% - saved as mat files and as plots, one folder up from Path{1}
% - Quantities as in Middelkoop et al 2021, note especially the flow speed
%   and the chiral ratio definitions.
% - No normalization of the intensity levels is done

% Notes:
% - there shall be no dots in any of the the foldernames. So do not name a folder like
%   this 'randomfolder.wt', instead use 'randomfolder_wt' or something like
%   that
% - The timeframes used for the intensity analysis: start with the
%   first time frame, as used in PIV code, until int_frames 
%   later (this number of frames needs to be specified under 'Some initial 
%   parameters').  

% NEXT TIME: 
% - FOR THE INTENSITY MEASURMENTS, FIX THE ap AXIS LABEL ON THE PLOTS, SAME
% FOR THE FLOW SPEED, VX, VY MEASURMENT PLOTS

clear all, close all % clear all varialbes, close figures

%% Specify where the data is and what it is
Path{1} = 'C:\Users\teije\Desktop\Fluo_measurements_midplaneAllan\nmy2GFP_unc60RNAi\1 L4440';
Path{2} = 'C:\Users\teije\Desktop\Fluo_measurements_midplaneAllan\nmy2GFP_unc60RNAi\2 L4440 unc60';

%Caseleg={'L4440';'rga-3';'ani-1';'rga-3;ani-1'}; %
Caseleg={'L4440';'unc-60';'+ cyk-1 12 hr';'+ cyk-1 18 hr';'+ cyk-1 24 hr';'+ cyk-1 48 hr'}; %

%% Some initial parameters
bins_size = 20; % in pixels 
pixelsize = 0.1119; % in um. Biocev Nikon SD 60x (w/o optovar) = 0.1119 um
% antbin = [3:6]; % anterior bins for computing vc, vmag etc. Change if No_bins changes
% posbin = [13:16]; % posteiror bins for computing vc, vmag etc. Change if No_bins changes
frameinterval = 5; % time interval in seconds, was 5 sec in PNAS cyk-1 paper 2021
PIV_box_size = 30; % final box size in pixels, was 18 in Middelkoop et al, but this is a bit small
mirror_im = 'y'; % specify whether the movie, as it comes from the microscope, is flipped ('y') or not ('n'). It usually is flipped...
int_frames = 3; % how many frames, starting from the onset of flows (first time frame) should be used for intensity measurements? This was 20 in PNAS cyk-1 paper 2021, in which was dt=5sec
middle_bins = [6:10]; % bins that will be used to extract mean fluointensity
half_stripewidth = 60; % in number of pixels (typically 60 when using 60x Obj with ~0.1 um pixel size, typically 90 when imaged 100X Obj), was 60 for cyk-1 paper
%skipped_frames = 5; % number of skipped frames for the non-PIV channel

convert_pix_ummin = (pixelsize*60)/frameinterval; % conversion factor going from pixels per frame to um/min

%% Generate data table
% remove slashes in the end of the pathname should there be one
for cond = 1:length(Path)
    if Path{cond}(end) == '/' || Path{cond}(end) == '\'
        Path{cond} = Path{cond}(1:end-1);
    end
end
data_table = generate_input_cyto_data_table(Path,Caseleg);
data_table.mean_int_ch1 = NaN(height(data_table), 1); 

% Now add the desired results columns to the table and pre-allocate 
data_table.vc = NaN(height(data_table), 1);   
data_table.vx_pos = NaN(height(data_table), 1);   
data_table.vmag = NaN(height(data_table), 1);   
data_table.cr = NaN(height(data_table), 1);   

%% Loop through the conditions and run PIV 
for i = 1:height(data_table)
    
    % generate mask
    mask = generate_coarse_mask(data_table.x_emb_center_after_rot(i),data_table.y_emb_center_after_rot(i),data_table.rot_degree(i), data_table.movie_pathname(i));

    specifyframes = [data_table.first_frame(i):data_table.last_frame(i)];

    %% Run PIVlab
    % check whether it has been run first
    if exist(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep, 'Results_PIVlab',filesep,'PIVlab_res.mat')) ~= 2 %check if the directory exists
        PIVlab_commandline_v11(data_table.movie_pathname(i),specifyframes,PIV_box_size,mask)
    end
    load(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep, 'Results_PIVlab',filesep,'PIVlab_res.mat'))
    
    %% Rotate velocity fields
    % Generate rotated flow analysis folder if it doesn't yet exist
    if exist(strcat(data_table.movie_path_only(i),filesep, 'PIV_analysis_v11', filesep, 'Rotated_flow_field'),'dir') ~= 7 %check if the directory exists
        mkdir(strcat(data_table.movie_path_only(i),filesep, 'PIV_analysis_v11', filesep, 'Rotated_flow_field'));
        % rotate the mask
        mask_rot = imrotate(mask,data_table.rot_degree(i));
        save(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'mask_rot.mat'),'mask_rot')
        
        % pre-allocate rotated vectors
        no_rows=length(PIVlab_res.x{1}(:,1));
        no_cols=length(PIVlab_res.x{1}(1,:));
        rotated_vectors = nan(no_rows*no_cols,4,length(PIVlab_res.u_filt));
        % loop though timepoints and rotate the images + flow fields
        for time = 1:length(PIVlab_res.u_filt)
            % rotate image
            im = double(imread(data_table.movie_pathname(i),data_table.first_frame(i)+time-1));
            im_rot = imrotate(im,data_table.rot_degree(i),'bilinear');           
            if time == 1
                save(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'im_rot.mat'),'im_rot')
            end
            im_x_center_rot = 0.5*length(im_rot(1,:));
            im_y_center_rot = 0.5*length(im_rot(:,1));
            im_center_xy_rot = [im_x_center_rot, im_y_center_rot];
            % rotate vectors, output has as columns xrot, yrot, vxrot,
            % vyrot. Note: the minus sign for the flow field rotation. Flow
            % field needs to be rotated in the direction opposite of the
            % image itself...
            rot_flow = Rot_PIV_vectors(PIVlab_res.x{time}(:),PIVlab_res.y{time}(:),PIVlab_res.u_filt{time}(:),PIVlab_res.v_filt{time}(:),-deg2rad(data_table.rot_degree(i)),[data_table.im_center_x(i), data_table.im_center_y(i)],im_center_xy_rot);
            % overlay rotated vectors
            overlay_PIV_vectors(im_rot,rot_flow);
            title(strcat('frame ',num2str(specifyframes(time))))
            export_fig(gcf,strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'frame',num2str(specifyframes(time)),'.tif'),'-q101','-m2','-r200')
            rotated_vectors(:,:,time) = rot_flow;
            % assemble rotated movie in 3D array
            if time == 1
                rotated_movie = nan(length(im_rot(:,1)),length(im_rot(1,:)),length(PIVlab_res.u_filt));
            end
            rotated_movie(:,:,time) = im_rot;
        end
        % save rotated movie as mat file
        save(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'rotated_movie.mat'),'rotated_movie')
        % save rotated vectors as mat file
        save(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'rotated_vectors.mat'),'rotated_vectors')
        clear rotated_vectors im_rot mask_rot rotated_movie rotated_movie_ch2
    end % end of if statement that asks whether Rotated_flowfield exists
    
    %% Use the rotated mask to do binning
    % Using the embryo center, as idedntifed in Ring_ingression_analysis.m
    % we now do binning from -100 pixel until + 100 pixels (~10 um on each
    % side)
    
    % % Load the roated mask
    % load(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'mask_rot.mat'));

     % Do binning
    if exist(strcat(data_table.movie_path_only(i),filesep, 'AP_cyto_bins'),'dir') ~= 7
        mkdir(strcat(data_table.movie_path_only(i),filesep, 'AP_cyto_bins'));      
        bin_features = binning_stripe_coords_cyto(data_table.x_emb_center_after_rot(i),data_table.y_emb_center_after_rot(i),bins_size);
    
        save(strcat(data_table.movie_path_only(i),filesep,'AP_cyto_bins',filesep,'bin_features.mat'),'bin_features')
        clear bin_features
    end

    %% Perform binning of the flow field
    if exist(strcat(data_table.movie_path_only(i),filesep, 'PIV_analysis_v11', filesep, 'Binning_flow_field'),'dir') ~= 7 %check if the directory exists
        mkdir(strcat(data_table.movie_path_only(i),filesep, 'PIV_analysis_v11', filesep, 'Binning_flow_field'));
        
        % first take a time average of the flow period. Note: This removes
        % information in chaotic behavior, i.e., fast chaotic flows will
        % give the same mean values as slow consistent flows.
        load(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'rotated_vectors.mat'));
        rot_vec_mean = mean(rotated_vectors,3,'omitnan');
        % load the rotated image mat file
        load(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'im_rot.mat'));
        load(strcat(data_table.movie_path_only(i),filesep,'AP_cyto_bins',filesep,'bin_features.mat'))
        bin_xcoords = bin_features.bin_x_coords;   
        emb_center_y = bin_features.ecenter_y;
        
        % now do the binning on the time-averaged flow field
        binned_vectors = binning_flow_field(im_rot,rot_vec_mean,bin_xcoords,emb_center_y,half_stripewidth);
        save(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Binning_flow_field',filesep,'binned_vectors.mat'),'binned_vectors')
        % convert to um/min. Note: this is the first thime that is done
        binned_vectors_ummin = binned_vectors*convert_pix_ummin;
        save(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Binning_flow_field',filesep,'binned_vectors_ummin.mat'),'binned_vectors_ummin')
        % And plot the AP velocity/speed profiles
        plot(binned_vectors_ummin(1,:),'r') % plot x vel
        hold on
        plot(binned_vectors_ummin(2,:),'b') % plot y vel
        plot(binned_vectors_ummin(3,:),'g') % plot mag
        ylabel('velocity/speed (\mum/min)')
        xlabel('bin')
        yline(0,'k-','HandleVisibility','off');        
        legend({'X velocity','Y velocity','Speed'})
        grid on
        hold off
        export_fig(gcf,strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'velocity_prof.jpg'))
        close all
        clear binned_vectors binned_vectors_ummin
    end
    %% Now extract the vc, vx posbin, vy posbin, vmag (as in cyk-1 PNAS paper) and cr (as in cyk-1 PNAS paper)
    % load(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Binning_flow_field',filesep,'binned_vectors_ummin.mat'));
    % vx = mean(binned_vectors_ummin(1,posbin),'omitnan');
    % vc = mean(binned_vectors_ummin(2,posbin),'omitnan') - mean(binned_vectors_ummin(2,antbin),'omitnan');
    % vmag = 0.5*(mean(binned_vectors_ummin(3,posbin),'omitnan') + mean(binned_vectors_ummin(3,antbin),'omitnan'));
    % cr = vc/(2*vmag); % chiral ratio
    % data_table.vc(i)=vc;
    % data_table.vx_pos(i)=vx;
    % data_table.vmag(i)=vmag;
    % data_table.cr(i)=cr;

    %% Now extract the fluorescence intensity of the channel used for PIV
    if exist(strcat(data_table.movie_path_only(i),filesep, 'fluo_intensities'),'dir') ~= 7 %check if the directory exists
        mkdir(strcat(data_table.movie_path_only(i),filesep, 'fluo_intensities'));
        % load the entire rotated movie
        load(strcat(data_table.movie_path_only(i),filesep,'PIV_analysis_v11', filesep,'Rotated_flow_field',filesep,'rotated_movie.mat'));       
        % take the mean over time, from the first timepoint analyzed by PIV to 'int_frames' later  
        if length(rotated_movie(1,1,:))<int_frames % in case the total length is smaller than int_frames, then just take the mean over all timeframes
            mean_fluo_im = mean(rotated_movie(:,:,:),3,'omitnan');
        else
           mean_fluo_im = mean(rotated_movie(:,:,1:int_frames),3,'omitnan');        
        end
        % now extract the gradient along the AP axis in the same bins as used
        % for PIV analysis
        load(strcat(data_table.movie_path_only(i),filesep,'AP_cyto_bins',filesep,'bin_features.mat'))
        fluo_int_bins = AP_grad_cyto_fluo(mean_fluo_im,bin_features,half_stripewidth);
        % save fluorescence intensity profile
        save(strcat(data_table.movie_path_only(i),filesep, 'fluo_intensities',filesep,'fluo_int_bin.mat'),'fluo_int_bins')        % put mean intensity in middle bins in the data table
        % And also extract the gradient along the AP axis without binning,
        % while taking the same ROI around the ring
        fluo_int_cont = AP_grad_cyto_fluo_cont(mean_fluo_im,bin_features,half_stripewidth);
        save(strcat(data_table.movie_path_only(i),filesep, 'fluo_intensities',filesep,'fluo_int_cont.mat'),'fluo_int_cont')
        
        % show rotated time averaged and int profile plot and save
        t = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
        nexttile([2 1])
        im_mean = mean_fluo_im(bin_features.ecenter_y-3*half_stripewidth:bin_features.ecenter_y+3*half_stripewidth,bin_features.Apole:bin_features.Ppole); % show the image with the analyzed x axis, and 3* half_stripewidth above and below
        imagesc(im_mean)
        axis image
        title('time averaged image')
        hold on 
        yline(0.5*length(im_mean(:,1))+half_stripewidth)  % draw the stripe in the image for visual inspection
        yline(0.5*length(im_mean(:,1))-half_stripewidth)  % draw the stripe in the image for visual inspection
        nexttile  
        x_axis_corr = pixelsize*((1:length(im_mean(1,:)))- round(0.5*length(im_mean(1,:))));
        plot(x_axis_corr,fluo_int_cont,'b') 
        ylabel('fluorescence intensity (a.u.)')
        xlabel('distance from ring (um)')
        title('intensity along AP axis')
        export_fig(gcf,strcat(data_table.movie_path_only(i),filesep, 'fluo_intensities',filesep,'time_averaged_int_grad.jpg'))
        clear fluo_int_bins
    end            
    % Add mean intensity of the middle bins to the data_table
    load(strcat(data_table.movie_path_only(i),filesep, 'fluo_intensities',filesep,'fluo_int_bin.mat'),'fluo_int_bins')
    data_table.mean_int_ch1(i) = mean(fluo_int_bins(middle_bins));
    close all
    clear fluo_int_bins

end