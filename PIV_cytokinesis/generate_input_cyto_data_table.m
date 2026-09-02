function res=generate_input_cyto_data_table(Path,Caseleg,varargin)
%% Generate an input data table for early flow analysis
% This function generates an input data table of all the movies for all the
% conditions specified in Path. This function is called in
% cytokinesisFlows_v1.m. For the timeframes it uses 15-30% ring ingression,
% as measured in ring_ingression_analysis.m
%
% input paramter:
% - Path should be a cell array with each element being the full pathname
%   of the directory of one conditions, in which all the sub-directories 
%   represent individual movies 
% - legend should be a cell array with each element containing the name of
%   the condition corresponding to those in Path.

% Pre-conditions:
% - Each directory specified in Path should refer to the directory in which 
%   all the subfolders of individual embryos are saved.
% - in each subfolder there should be the tif file of the movie and the paramters.txt file
% - the paramters.txt file should have rotation specified as the first
%   paramter
% - Before running this, the ring_ingression_analysis.m needs to be run.


%% generate large table with all info for all conditions
% pre-allocate table
varTypes = {'string','string','string','double','double','double','double','double','double','double'};
varNames = {'condition','movie_pathname','movie_path_only','rot_degree','first_frame','last_frame','im_center_x','im_center_y','x_emb_center_after_rot','y_emb_center_after_rot'};
sz = [1 length(varNames)];

temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
%InitialRow = {'missing','missing',nan,nan,nan,'missing',nan};
table_row = 1;
%temps(table_row,:) = InitialRow;

for cond = 1:length(Path) % loop through conditions

    %% get number of movies in current condition
    Movie_folders = dir(Path{cond});
    b = {Movie_folders.name};
    inc = 1;
    for i = 1:length(b)
        indices_b = strfind(b{i},'.');
        % find indices of b that contain the foldernames
        if isempty(indices_b)
            indices(inc) = i;
            inc = inc+1;
        end
    end
    Movie_foldername = b(indices);
    No_movies = length(Movie_foldername);
    clear indices

    %% loop through movies
    for i = 1:No_movies
        path_movie = [Path{cond} filesep Movie_foldername{i}];
        
        %% Extract tif file names
        curr_tif_file = dir([path_movie filesep '*.tif']);
        curr_tifs = {curr_tif_file.name};

        % if length(curr_tifs)~=2
        %     error('Unexpected number of tifs in folder - segmentation file (A0) or tif stack is missing')
        % end
        % determine which tif file is the segmentation file and which is 
        % the tif stack 
        length_file1 = length(imfinfo([path_movie filesep curr_tifs{1}]));
        length_file2 = length(imfinfo([path_movie filesep curr_tifs{2}]));
        lengths_files = [length_file1 length_file2];

        [M, indx_max] = max(lengths_files);
        indx_max = 2;
        movie_file_name = curr_tifs{indx_max};
        temps.movie_pathname(table_row) = [path_movie filesep movie_file_name];
        
        temps.condition(table_row) = Caseleg{cond};      
        temps.movie_path_only(table_row) = [path_movie];
        %temps.segmentation_file_pathname(table_row) = {[path_movie filesep segm_file_name]};

        % determine the image center
        info_image = imfinfo([path_movie filesep movie_file_name]);
        image_xmid = 0.5*info_image(1).Width;
        image_ymid = 0.5*info_image(1).Height;
        temps.im_center_x(table_row) = image_xmid;
        temps.im_center_y(table_row) = image_ymid;
        %% Extract the timepoints from Ring_closure.mat 
        load([path_movie filesep 'Ring_closure.mat'])
        dist_um = Ring_closure.distance_um;
        first = find(dist_um<=0.85*dist_um(1),1);
        last = find(dist_um<=0.7*dist_um(1),1);
        if isempty(last)
            last=first+2;
        end
        temps.first_frame(table_row) = first+Ring_closure.anaphase_onset-1; 
        temps.last_frame(table_row) = last+Ring_closure.anaphase_onset-1;

        %% Extract the embryo center coordinate after rotation 
        % (i.e. the point in the center of the ring at 0% ingression)
        temps.x_emb_center_after_rot(table_row) = 0.5*(Ring_closure.xy_coordinates(1,1,last)+Ring_closure.xy_coordinates(2,1,last)); % get x coordinates from a later frame, because initially it is unkown where exactly the ring will form. 
        temps.y_emb_center_after_rot(table_row) = 0.5*(Ring_closure.xy_coordinates(1,2,1)+Ring_closure.xy_coordinates(2,2,1)); % get y coordinates from the first clicked frame. 

        %% read in paramters txt file
        curr_txt_file = dir([path_movie filesep '*.txt']);
        curr_txts = {curr_txt_file.name};
        if length(curr_txts)~=1
            error('Unexpected number of txt files in folder - either parameters file is missing or there are extra txt files')
        end
        par_array = readcell(string(fullfile(path_movie,curr_txts)));
        degree = par_array{2};                
        %BG_fluorescence = par_array{7};
        temps.rot_degree(table_row) = degree;

        table_row = table_row+1;
    end
end
res = temps;
end