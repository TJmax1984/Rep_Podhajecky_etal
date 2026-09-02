%% This code loops though embryo folders and measures ring ingression
% it runs Ring_closure_manually.m in which you manually track ring
% ingression from a midplane movie by clicking. 

% Pre-conditions
% - Specify the path where the data is stored
% - In Path, there should be subfolders, not important what they are called
% - In each subfolder there should be a midplane tif file
% - there should be ONLY ONE tif file in the folder
% - in addition there should be a paramters.txt file in each folder. In
%   this paramters.txt file there should be the follwoing info organized like in 
%   the following example: 'rotation 70 anaphase 58 last 66'  
clear all, close all

answer = inputdlg('specify dt (sec)', 'Input', [1 50],{'20'});
if isempty(answer)
    disp('User cancelled.');
else
    dt = str2double(answer{1});
end

answer = inputdlg('specify pixel_size (um)', 'Input', [1 50],{'0.1123'});
if isempty(answer)
    disp('User cancelled.');
else
    pixel_size = str2double(answer{1});
end

Path = uigetdir(path,'select directory of the condition to be analyzed');

%% Determine how many movies (folders) there are
Movie_folders = dir(Path);
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
clear inc b Movie_folders indices

No_movies = length(Movie_foldername);

%% Loop though the directories and run Rin_closure_manually.m for each movie
for movie =  1:No_movies; 
    cd([Path,filesep,Movie_foldername{movie}])
    movie_path = cd;
    if exist([movie_path,filesep,'Ring_closure.mat']) ~= 2
        fileinfo = dir('*.tif');
        [degree] = textread('parameters.txt','%*s %d',1);               % Skips the first string s (Parameters) and reads one (specified last) integer after it  
        [anaphase_onset] = textread('parameters.txt','%*s %*d %*s %d',1);    % Skips the first string s, the following integer d, the following string (Frames) and takes the integer after that
        [last_frame] = textread('parameters.txt','%*s %*d %*s %*d %*s %d',1);       % and so on...
        Ring_closure_manually(fileinfo.name,degree,anaphase_onset,last_frame,pixel_size,dt);
    end
end 

