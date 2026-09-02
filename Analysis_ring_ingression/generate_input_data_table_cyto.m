function res=generate_input_data_table_cyto(Path,Caseleg,varargin)
%% Generate an input data table for early flow analysis
% This function generates an input data table of all the movies for all the
% conditions specified in Path.
%
% input parameter:
% - Path should be a cell array with each element being the full pathname
%   of the directory of one conditions, in which all the sub-directories 
%   represent individual movies 
% - legend should be a cell array with each element containing the name of
%   the condition corresponding to those in Path.
% - varargin = names of the channels. They should be 2 strings that are
%   concatenated into varargin, for which the first element is the name of
%   the 1st channel, and the second element the name of the second channel.
% 
% Pre-conditions:
% - Each directory specified in Path should refer to the directory in which 
%   all the subfolders of individual embryos are saved.
% - in each subfolder there should be the tif file of the movie and the 
%   parameters.txt file
% - the parameters.txt file should be like this: 
%   'rotation -90 anaphase 82 last 121'

%% generate large table with all info for all conditions
% pre-allocate table
if nargin == 4
    varTypes = {'string','string','string','string','double','double','double'};
    varNames = {'condition','movie_pathname','movie_pathname_ch2','movie_path_only','rot_degree','anaphase_onset','last_frame'};
    sz = [1 length(varNames)];
else
    varTypes = {'string','string','string','double','double','double'};
    varNames = {'condition','movie_pathname','movie_path_only','rot_degree','anaphase_onset','last_frame'};
    sz = [1 length(varNames)];
end

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
        if nargin==4
            if length(curr_tifs)~=2
                error('Unexpected number of tifs in folder - it should have only 2 (1 per channel)')
            end
            % determine which tif file is the segmentation file and which is 
            % the channel 1 tif stack, and which one is the channel 2 tif stack 
            length_file1 = length(imfinfo([path_movie filesep curr_tifs{1}]));
            length_file2 = length(imfinfo([path_movie filesep curr_tifs{2}]));
            lengths_files = [length_file1 length_file2];    
            % find which is channel 1 filename, and which is channel 2
            % filename
            movie_file_name = curr_tifs{contains(curr_tifs,varargin{1})};
            movie_file_name_ch2 = curr_tifs{contains(curr_tifs,varargin{2})};           
            temps.movie_pathname(table_row) = [path_movie filesep movie_file_name];
            temps.movie_pathname_ch2(table_row) = [path_movie filesep movie_file_name_ch2];
        else
            if length(curr_tifs)~=1
                error('Unexpected number of tifs in folder - it should have only 1')
            end
            movie_file_name = curr_tifs{1};
            temps.movie_pathname(table_row) = [path_movie filesep movie_file_name];
        end
        
        temps.condition(table_row) = Caseleg{cond};      
        temps.movie_path_only(table_row) = [path_movie];

        %% read in paramters txt file
        curr_txt_file = dir([path_movie filesep '*.txt']);
        curr_txts = {curr_txt_file.name};
        if length(curr_txts)~=1
            error('Unexpected number of txt files in folder - either parameters file is missing or there are extra txt files')
        end
        par_array = readcell(string(fullfile(path_movie,curr_txts)));
        degree = par_array{2};        
        anaphase_onset = par_array{4};
        last = par_array{6};
        temps.rot_degree(table_row) = degree;
        temps.anaphase_onset(table_row) = anaphase_onset;
        temps.last_frame(table_row) = last;
        
        table_row = table_row+1;
    end
end
res = temps;
end