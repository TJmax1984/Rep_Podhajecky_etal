%% Extract the intensity at the leading edge
% This code takes midplane movies, and in those movies it extracts the
% 2 fronts of the ring leading edge (which were manually tracked by
% clicking in Ring_ingression_analysis.m) and extracts the instensity at
% those coordinates from a small ROI.

% pre-conditions: 
% - first run the Ring_ingression_analysis.m which saves the coordinates
%   of the leading and lagging edge of the ring in the midplane, which will be
%   opened in this function
% - When 1 channel is analyzed there should be only one tif file in the
%   embryo directory. 2 channels are analyzed, each embryo folder should 
%   contain 2 tif files, one for each channel. 
% - If more than 1 channel is analyzed, specify the channel names in the
%   pop-up window
% - If more than 1 channel is analyzed, each tif stack for each channel 
%   should contain the channel name, as specified in the pop-up window in 
%   this code, as exact match somewhere in the filename.
% - If more than 1 channel is analyzed, there should be only one
%   Ring_closure.mat file. So running the Ring_ingression_analysis.m should 
%   be done on only 1 channel (ideally the channel with the best s/n ratio)  
% - add legend manually and include strain name

% Output
% - the data table and the figures will be saved in the directory 1
%   upstream of the directory specified as the first path, i.e., Path{1}

% Notes: 
% - background subtraction: currently, I chose for manually defining a
%   single value as camera noise for each channel. This value should be 
%   specified in the GUI pop up window for each channel. One could also 
%   implement subtracting cytoplasmic background, but this has its own 
%   disadvantages.
% - When cytokinesis does not reach 95% ring ingression the code leaves the
%   ingression speed, cyto duration and intnesity ratio as nan

clear all, close all

%% Extract pathnames and few other pieces of infomation via GUI
% ask how many conditions
answer = inputdlg('How many conditions to analyze?', 'Input', [1 50]);
if isempty(answer)
    disp('User cancelled.');
else
    num = str2double(answer{1});
end

exp_info = getParameters(num);
Path = exp_info.directories;
Caseleg = exp_info.conditions;
pixelsize = exp_info.pixel_size;
channels{1}=exp_info.name_ch1;
BG_cam_noise_ch1 = exp_info.BG_ch1;
no_channels = exp_info.no_channels;
if no_channels==2
    channels{2}=exp_info.name_ch2;
    BG_cam_noise_ch2 = exp_info.BG_ch2;
end
[savepath,name,ext] = fileparts(Path{1});

% drop error if conditions are not specified properly
for i = 1:length(Path)
    if isempty(Caseleg{i}) 
        error('Strain name and/or condition not properly specified')
    end
end

%% Some initial parameters
crop_pix = 5; % number of pixels around the clicked coordinates used for instensity measurments (5 means 10*10 total, and works well when pixel size is ~0.1 um)
BG_dim = 40; % half of the width and height in pixels of the ROI in the center that will be used to measure the cytoplasmic background 
frac_begin = 0.65; % fraction of initial ring diamter used as the begin timepoint for the ratio measurement
frac_end = 0.05; % fraction of initial ring diamter used as the begin timepoint for the ratio measurement
% if temp shifts are done:
if exp_info.temp_shift
    lag_time = 4; % number of frames (not seconds!!) after and before temp shift where compution of ingression speed starts
    total_frames = 6; % number of frames (not seconds!!) used after 'lag time' used for computing ingression speed
end

%% Generate data table
% data table for either 1 or two channels
if no_channels==2
    data_table = generate_input_data_table_cyto(Path,Caseleg,channels{1},channels{2});   
else
   data_table = generate_input_data_table_cyto(Path,Caseleg);
end

%% Now add the desired single value columns to the table
% some metadata pre-allocation:
data_table.dt = NaN(height(data_table), 1); % dt in sec
data_table.pixel_size = NaN(height(data_table), 1); % in um

% Measurements pre-allocation:
data_table.embryo_dia_um = NaN(height(data_table), 1); % embryo diameter in um 
data_table.BG_ch1 = NaN(height(data_table), 1);
data_table.AA_ring_onset = NaN(height(data_table), 1); % time of AA until ring ingression onset

if exp_info.temp_shift
    data_table.preTS_ingr_vel = NaN(height(data_table), 1); % pre temp shift mean diameter reduction velocity (um/min)
    data_table.postTS_ingr_vel = NaN(height(data_table), 1); % post temp shift mean diameter reduction velocity (um/min)
    data_table.ratio_after_pre_vel = NaN(height(data_table), 1); % ratio of ring ingression velocity after by ring ingression velocity before
    data_table.TS_time_afterAA_sec = NaN(height(data_table), 1); % timepoint of the temp shift in seconds after anaphase onset 
    data_table.TS_time_afterAA_frames = NaN(height(data_table), 1); % timepoint of the temp shift in seconds after anaphase onset  
else
    data_table.mean_dia_vel_ummin = NaN(height(data_table), 1); % mean diameter reduction velocity (um/min)
    data_table.cyto_duration = NaN(height(data_table), 1); % duration of ring ingression (95% until 5%) in seconds
    data_table.int_ratio_ch1 = NaN(height(data_table), 1); % intensity ratio (end_int/begin_int)
    data_table.AA_halfmax_ingr = NaN(height(data_table), 1); % time of AA until 50% ring ingression
    data_table.int_ratio_ch1_RK = NaN(height(data_table), 1); % intensity ratio obtained by doing Khaliulin Elife type temporal normalization
    data_table.duration_65_5 = NaN(height(data_table), 1); % 
    
    data_table.cyto_duration_fit = NaN(height(data_table), 1); % 
    data_table.mean_dia_vel_ummin_fit = NaN(height(data_table), 1); % 
    data_table.AA_halfmax_ingr_fit=NaN(height(data_table), 1); % 
    data_table.duration_65_end_fit=NaN(height(data_table), 1); % 
    data_table.int_ratio_ch1_fitinterp=NaN(height(data_table), 1); % 
    data_table.ratio_change_time_fitinterp=NaN(height(data_table), 1); %
    data_table.int_ch1_change_time_fitinterp=NaN(height(data_table), 1); % 

end

if no_channels==2
    data_table.BG_ch2 = NaN(height(data_table), 1);
    data_table.int_ratio_ch2 = NaN(height(data_table), 1); % intensity ratio (end_int/begin_int)
end

%% Loop through all the embryo folders in all conditions, and extract info
for i = 1:height(data_table)
    load(join([data_table.movie_path_only(i) filesep 'Ring_closure.mat'],'')) % Ring_closure.mat is the result of running 'Ring_ingression_analysis.m'   
    % add some metadata to table:
    data_table.dt(i) = Ring_closure.dt; % dt in sec
    if isfield(Ring_closure,'pixelsize') 
        data_table.pixel_size(i) = Ring_closure.pixelsize; % in um
    else
        data_table.pixel_size(i) = pixelsize;
    end
    % now extract and add measurements:
    first_ringdia = Ring_closure.anaphase_onset;
    last_ringdia = Ring_closure.last_frame;
    dist_um = Ring_closure.distance_um;
    ring_time = [first_ringdia:last_ringdia];
    time_trace = ((1:length(ring_time))-1) *Ring_closure.dt; % time trace in seconds from anaphase onset 
    % put ring diameter time traces in table
    data_table.time_trace_sec(i) = {time_trace};
    data_table.ring_dia_um(i) = {Ring_closure.distance_um};
    data_table.ring_dia_norm(i) = {Ring_closure.distance_um./mean(Ring_closure.distance_um(1:2),'omitnan')};
    data_table.embryo_dia_um(i) = dist_um(1);
    % determine whether cytokinesis is completing beyong 95%
    ind_end = find(dist_um<=frac_end*dist_um(1)); 
    if isempty(ind_end)
        cyto_complete = 0;
    else
        cyto_complete = 1;
    end
    % compute time from AA to 5% ring ingression
    ind_95 = find(dist_um<=0.95*dist_um(1));
    if isempty(ind_95)
    else
        ind_95 = ind_95(1);
        data_table.AA_ring_onset(i)=time_trace(ind_95);  % time of AA until 5% ingression (i.e., ingression onset)
    end
    % compute the ingression speed and time AA until ingression onset if cytokinesis is complete 
    if cyto_complete            
        ind_end = ind_end(1); % is the first index where the diamter is smaller than 5% (frac_end, specified in beginning) of the initial diameter    
        ind_65 = find(dist_um<=frac_begin*dist_um(1));
        ind_65 = ind_65(1);
        % First I extract without fitting anything
        total_time_sec = time_trace(ind_end)-time_trace(ind_95);
        total_dist = dist_um(ind_95)-dist_um(ind_end);
        data_table.cyto_duration(i)=total_time_sec;
        data_table.mean_dia_vel_ummin(i) = 60*total_dist/total_time_sec; % speed - um per minute
        ind_50 = find(dist_um<=0.5*dist_um(1));
        ind_50 = ind_50(1);
        data_table.AA_halfmax_ingr(i)=time_trace(ind_50); % time of AA until 50% ingression        
        data_table.duration_65_5(i)= time_trace(ind_end)-time_trace(ind_65); % time it takes from 35% ingression to 95% ingression
        % Then extract the quantities by using fitting a straight line
        pfit = polyfit(time_trace(ind_95:ind_end),dist_um(ind_95:ind_end),1);
        t_end_fit = -pfit(2)/pfit(1); % timepoint at which the ring is at 0% of its initial value
        t_begin_fit = (0.95*dist_um(1)-pfit(2))/pfit(1); % timepoint at which the ring is at 95% of its initial value
        t_half_fit = (0.5*dist_um(1)-pfit(2))/pfit(1);
        t_sixtyfive_fit = (frac_begin*dist_um(1)-pfit(2))/pfit(1);
        data_table.cyto_duration_fit(i) = t_end_fit-t_begin_fit;
        data_table.mean_dia_vel_ummin_fit(i) = abs(pfit(1)*60); % convert to um/min and take absolute (cause it's always ingressing)
        data_table.AA_halfmax_ingr_fit(i)=t_half_fit;
        data_table.duration_65_end_fit(i)=t_end_fit-t_sixtyfive_fit;
        % test whether the fitting worked
        % scatter(time_trace,dist_um)
        % hold on
        % x = [time_trace(ind_95):0.01:time_trace(ind_end)];
        % y = pfit(1)*x + pfit(2);
        % plot(x,y)
        % xline(t_begin_fit,'r')
        % xline(t_sixtyfive_fit,'g')
        % xline(t_half_fit,'b')
        % xline(t_end_fit,'k')
    end

    % loop through all the slices and extract the ring intensity traces
    for p = 1:length(ring_time)
        im = double(imread(data_table.movie_pathname(i),ring_time(p)));
        im = imrotate(im,Ring_closure.degree);

        % Now extract the intensity at the ingressing fronts by taking
        % the maximum within a small ROI around the clicked coordinates        
        int_pole_one_ch1 = extract_max_from_ROI(im,Ring_closure.xy_coordinates(1,:,p),crop_pix);
        int_pole_two_ch1 = extract_max_from_ROI(im,Ring_closure.xy_coordinates(2,:,p),crop_pix);
        % Extract the mean of the two poles and do background subtraction
        int_leadlag_ch1(p) = mean([int_pole_one_ch1,int_pole_two_ch1])-BG_cam_noise_ch1; 

        if no_channels==2
            im_ch2 = double(imread(data_table.movie_pathname_ch2(i),ring_time(p)));
            im_ch2 = imrotate(im_ch2,Ring_closure.degree);
            int_pole_one_ch2 = extract_max_from_ROI(im_ch2,Ring_closure.xy_coordinates(1,:,p),crop_pix);
            int_pole_two_ch2 = extract_max_from_ROI(im_ch2,Ring_closure.xy_coordinates(2,:,p),crop_pix);
            % Extract the mean of the two poles and do background subtraction
            int_leadlag_ch2(p) = mean([int_pole_one_ch2,int_pole_two_ch2])-BG_cam_noise_ch2; 
        end
    end
    % put intensity time trace ch1 in the table
    data_table.int_trace_ch1(i)={int_leadlag_ch1};
    data_table.BG_ch1(i)=BG_cam_noise_ch1;
    % extract the ratio intensity end/intensity begin
    if cyto_complete            
        % without fitting or interp
        data_table.int_ratio_ch1(i)=int_leadlag_ch1(ind_end)/int_leadlag_ch1(ind_65);
        data_table.ratio_change_time(i)=(data_table.int_ratio_ch1(i)-1)/data_table.duration_65_5(i);
        % with fitting and interp
        ch_int_65 = interp1(time_trace,int_leadlag_ch1,t_sixtyfive_fit);
        ch_int_end = interp1(time_trace,int_leadlag_ch1,t_end_fit);
        data_table.int_ratio_ch1_fitinterp(i)=ch_int_end/ch_int_65;
        data_table.ratio_change_time_fitinterp(i)=(data_table.int_ratio_ch1_fitinterp(i)-1)/data_table.duration_65_end_fit(i);
        
        % with fitting and interp and fitting a line through the
        % intensities
            % ysmooth = sgolayfilt(data_table.int_trace_ch1{i},3,9); % Savitzky–Golay filter
            % ch1_int65_sgolay = interp1(time_trace,ysmooth,t_sixtyfive_fit); % extract the interpolated/fitted intensity at 65 
            % ch1_intend_sgolay = interp1(time_trace,ysmooth,t_end_fit); % extract the interpolated/fitted intensity at end
            % data_table.int_ratio_ch1_fitinterpfit(i)=ch1_intend_sgolay/ch1_int65_sgolay;
            % data_table.int_ratio_change_time_fitinterpfit(i) = (data_table.int_ratio_ch1_fitinterpfit(i)-1)/data_table.duration_65_end_fit(i);
        % extracting the total reduction in signla pert ime unit
            % ch1_tot_65 = interp1(time_trace,int_leadlag_ch1.*dist_um,t_sixtyfive_fit); % extract the total level (density times diameter)
            % ch1_tot_end = interp1(time_trace,int_leadlag_ch1.*dist_um,t_end_fit); % extract the total level (density times diameter) 
            % data_table.int_ch1_total_change_time_fitinterp(i) = (ch1_tot_65 -ch1_tot_end)/data_table.duration_65_end_fit(i);
        % test whether the fitting and interpolation worked well 
            % plot(time_trace,data_table.int_trace_ch1{i})
            % hold on
            % scatter(t_sixtyfive_fit,ch_int_65,[],'g','filled')
            % scatter(t_end_fit,ch_int_end,[],'r','filled')
            % scatter(time_trace(ind_65),int_leadlag_ch1(ind_65),'k')
            % scatter(time_trace(ind_end),int_leadlag_ch1(ind_end),'k')
            % test smoothing
            %f = fit(time_trace',data_table.int_trace_ch1{i}','smoothingspline','SmoothingParam',0.1);
            % ysmooth11 = sgolayfilt(data_table.int_trace_ch1{i},3,11); % Savitzky–Golay filter
            % ysmooth9 = sgolayfilt(data_table.int_trace_ch1{i},3,9); % Savitzky–Golay filter
            % gprMdl = fitrgp(time_trace',data_table.int_trace_ch1{i}');
            % xq = linspace(min(time_trace),max(time_trace),500)';
            % [yq,ysd] = predict(gprMdl,xq);                       
            % plot(time_trace,ysmooth11,'b')
            % plot(time_trace,ysmooth9,'r')
    end

    % now for Channel 2 if it exists    
    if no_channels==2
        % put intensity time trace ch2 in the table
        data_table.int_trace_ch2(i)={int_leadlag_ch2};
        data_table.BG_ch2(i)=BG_cam_noise_ch2;
        data_table.ratio_ch2ch1_trace(i)={int_leadlag_ch2./int_leadlag_ch1};
        % extract the ratio intensity end/intensity begin    
        if cyto_complete 
            data_table.int_ratio_ch2(i)=int_leadlag_ch2(ind_end)/int_leadlag_ch2(ind_begin);
        end        
    end

    %% Now do the normalization as in Khaliullin (RK) Elife, 2018
    % normalize time
    if cyto_complete 
        norm_parameters_RK = norm_time_calculator(ring_time,dist_um); % take the time window from 30% ingression to 80% ingression
        norm_time_RK = norm_parameters_RK{1};
        t0_RK = norm_parameters_RK{2};
        t_ck_RK = norm_parameters_RK{3};
        ind_norm_int = find(norm_time_RK>=0);
        ind_norm_int = ind_norm_int(1);
        inten_norm_ch1 = int_leadlag_ch1./int_leadlag_ch1(ind_norm_int);
        data_table.time_trace_norm_RK(i) = {norm_time_RK};
        data_table.int_norm_trace_ch1_RK(i) = {inten_norm_ch1};
        ind_normtime_end = find(norm_time_RK>=(1-frac_end));
        if isempty(ind_normtime_end)
        else            
            ind_normtime_end = ind_normtime_end(1);
            ind_normtime_begin = find(norm_time_RK>=(1-frac_begin));
            ind_normtime_begin = ind_normtime_begin(1);
            data_table.int_ratio_ch1_RK(i) = inten_norm_ch1(ind_normtime_end)/inten_norm_ch1(ind_normtime_begin); % get the value at normalized timepoint 1, this is equivalent to the ratio obtained in the other way
        end
    end    
    
    %% Now extract the parameters specific for experiments in which temperature shifts are done
    if exp_info.temp_shift
        % extract temp shift time point from paramters.txt file > It would
        % be better to extract this in the generate_data_table code. This
        % is a point for improvement...
        curr_txt_file = dir([char(data_table.movie_path_only(i)) filesep '*.txt']);
        curr_txts = {curr_txt_file.name};
        if length(curr_txts)~=1
            error('Unexpected number of txt files in folder - either parameters file is missing or there are extra txt files')
        end
        par_array = readcell(string(fullfile(char(data_table.movie_path_only(i)),curr_txts)));
        if length(par_array)~=8
            error('Temp shift not properly indicated in paramters.txt files')
        end
        % compute velocities pre and post temp shift treatment
        TS_time_point = par_array{8}; % temp shift timepoint, frame of the movie
        TS_time_AA_frames = TS_time_point-data_table.anaphase_onset(i); % temp shift timepoint, number of frames after AA        
        TS_time_AA_sec = time_trace(TS_time_AA_frames); % temp shift timepoint, number of sec after AA   
        dist_um_preTS = dist_um(TS_time_AA_frames-total_frames)-dist_um(TS_time_AA_frames);
        vel_preTS = 60*dist_um_preTS/(total_frames*data_table.dt(i)); % pre TS velocity of ring, um/min
        dist_um_postTS = dist_um(TS_time_AA_frames+lag_time)-dist_um(TS_time_AA_frames+lag_time+total_frames);      
        vel_postTS=60*dist_um_postTS/(total_frames*data_table.dt(i));
        data_table.TS_time_afterAA_frames(i) = TS_time_AA_frames; % temp shift timepoint, number of frames after AA        
        data_table.TS_time_after_AA_sec(i) = TS_time_AA_sec;        
        data_table.preTS_ingr_vel(i) = vel_preTS;
        data_table.postTS_ingr_vel(i) = vel_postTS;
        data_table.ratio_after_pre_vel(i) = vel_postTS/vel_preTS;
        data_table.TS_time_afterAA_sec(i) = TS_time_AA_sec; % time after AA in seconds
        data_table.int_at_TS_ch1(i) =  mean(data_table.int_trace_ch1{i}(TS_time_AA_frames-2:TS_time_AA_frames-1)); % intensity at the timepoint right before the temp shift
    end
        
    clear int_leadlag_ch1 int_leadlag_ch2
end 

%% Save data table
save(strcat(savepath,filesep,'data_table.mat'),'data_table')
writetable(data_table,strcat(savepath,filesep,'data_table.xlsx'))

%% Plotting
plot_traces(data_table,savepath)
plot_single_variables(data_table,savepath)
