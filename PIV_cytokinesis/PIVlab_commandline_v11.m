function PIVlab_commandline_v11(filename,specifyframes,PIV_box_size,mask)
% MAKE COMMENTS ON WHAT I CHANGED IN V11

% input arguments
% - mask should be a binary mask
% - filename = the full pathname of the tif stack on which PIV should be
%   done
% - PIV_box_size in pixels


dir_movie = fileparts(filename);
%Create save directory
if exist(strcat(dir_movie,filesep, 'PIV_analysis_v11', filesep, 'Results_PIVlab'),'dir') ~= 7 %check if the directory exists
   mkdir(strcat(dir_movie,filesep, 'PIV_analysis_v11', filesep, 'Results_PIVlab'));
end

%% Import movie inside current directory and multiply with mask
% replace zeros with nan's in the mask
mask = double(mask);
[i] = find(mask==0);    
mask(i) = nan;

% Create image sequence array
frame_inc = 1;
for p = specifyframes
    sequence(:,:,frame_inc) = double(imread(filename,specifyframes(frame_inc))).* mask; 
    sequence2(:,:,frame_inc) = double(imread(filename,specifyframes(frame_inc))); 
    frame_inc = frame_inc+1;
end
clear M indx_max

%% Standard PIV Settings
s = cell(10,2); % To make it more readable, let's create a "settings table"
%Parameter                       %Setting           %Options
s{1,1}= 'Int. area 1';           s{1,2}=PIV_box_size+16;         % window size of first pass (is 120 when imaged with new scope 100X W obj, is 70 when imaged with new Zeiss 60X)
s{2,1}= 'Step size 1';           s{2,2}=PIV_box_size+8;         % step of first pass
s{3,1}= 'Subpix. finder';        s{3,2}=1;          % 1 = 3point Gauss, 2 = 2D Gauss
s{4,1}= 'Mask';                  s{4,2}=[];         % If needed, generate via: imagesc(image); [temp,Mask{1,1},Mask{1,2}]=roipoly;
s{5,1}= 'ROI';                   s{5,2}=[];         % Region of interest: [x,y,width,height] in pixels, may be left empty
s{6,1}= 'Nr. of passes';         s{6,2}=3;          % 1-4 nr. of passes
s{7,1}= 'Int. area 2';           s{7,2}=PIV_box_size+8;         % second pass window size (is 36 when imaged with new Biocev Nikon SD 60X)
s{8,1}= 'Int. area 3';           s{8,2}=PIV_box_size;         % third pass window size (is 18 when imaged with new Biocev Nikon SD 60X)
s{9,1}= 'Int. area 4';           s{9,2}=NaN;        % fourth pass window size
s{10,1}='Window deformation';    s{10,2}='*spline'; % '*spline' is more accurate, but slower % linear or spline

%% PIV analysis loop
x = cell(length(specifyframes)-1,1);
y = x;
u = x;
v = x;
typevector = x;

% Settings
umin = -30; % minimum allowed u velocity
umax = 30; % maximum allowed u velocity
vmin = -30; % minimum allowed v velocity
vmax = 30; % maximum allowed v velocity
stdthresh = 3; % threshold for standard deviation check 
epsilon = 0.15; % epsilon for normalized median test
thresh = 3; % threshold for normalized median test

counter = 0;
PIVlab_res.u_filt = cell(length(specifyframes)-1,1);
PIVlab_res.v_filt = PIVlab_res.u_filt;
PIVlab_res.typevector_filt = PIVlab_res.u_filt;
    
%% PIV analysis loop:
for im=1:length(specifyframes)-1
    counter = counter+1;
    [x{counter} y{counter} u{counter} v{counter} typevector{counter}] = piv_FFTmulti_oldPIVlab(sequence(:,:,im),sequence(:,:,im+1),s{1,2},s{2,2},s{3,2},s{4,2},s{5,2},s{6,2},s{7,2},s{8,2},s{9,2},s{10,2});
    clc
    
    u_filtered = u{im,1}; % u matrix of current timepoint (im)
    v_filtered = v{im,1};
    typevector_filtered = typevector{im,1};
    %vellimit check
    u_filtered(u_filtered<umin) = NaN;
    u_filtered(u_filtered>umax) = NaN;
    v_filtered(v_filtered<vmin) = NaN;
    v_filtered(v_filtered>vmax) = NaN;
    % stddev check
    meanu = nanmean(nanmean(u_filtered));
    meanv = nanmean(nanmean(v_filtered));
    std2u = nanstd(reshape(u_filtered,size(u_filtered,1)*size(u_filtered,2),1));
    std2v = nanstd(reshape(v_filtered,size(v_filtered,1)*size(v_filtered,2),1));
    minvalu = meanu-stdthresh*std2u;
    maxvalu = meanu+stdthresh*std2u;
    minvalv = meanv-stdthresh*std2v;
    maxvalv = meanv+stdthresh*std2v;
    u_filtered(u_filtered<minvalu) = NaN;
    u_filtered(u_filtered>maxvalu) = NaN;
    v_filtered(v_filtered<minvalv) = NaN;
    v_filtered(v_filtered>maxvalv) = NaN;
    % normalized median check
    %Westerweel & Scarano (2005): Universal Outlier detection for PIV data
    [J,I] = size(u_filtered);
    medianres = zeros(J,I);
    normfluct = zeros(J,I,2);
    b=1;
    for c=1:2
        if c==1; velcomp=u_filtered;else;velcomp=v_filtered;end %#ok<*NOSEM>
        for i=1+b:I-b
            for j=1+b:J-b
                neigh=velcomp(j-b:j+b,i-b:i+b);
                neighcol=neigh(:);
                neighcol2=[neighcol(1:(2*b+1)*b+b);neighcol((2*b+1)*b+b+2:end)];
                med=median(neighcol2);
                fluct=velcomp(j,i)-med;
                res=neighcol2-med;
                medianres=median(abs(res));
                normfluct(j,i,c)=abs(fluct/(medianres+epsilon));
            end
        end
    end
    info1=(sqrt(normfluct(:,:,1).^2+normfluct(:,:,2).^2)>thresh);
    u_filtered(info1==1)=NaN;
    v_filtered(info1==1)=NaN;

    typevector_filtered(isnan(u_filtered))=2;
    typevector_filtered(isnan(v_filtered))=2;
    typevector_filtered(typevector{im,1}==0)=0; %restores typevector for mask
    
    %Interpolate missing data
    %u_filtered=inpaint_nans(u_filtered,4);      % remove these 2 lines to                          
    %v_filtered=inpaint_nans(v_filtered,4);      % prevent interpolation
    
    PIVlab_res.u_filt{im,1}=u_filtered;
    PIVlab_res.v_filt{im,1}=v_filtered;
    PIVlab_res.typevector_filt{im,1}=typevector_filtered;
    
    % Graphical output (disable to improve speed)
    %clf;imshow(imcomplement(sequence2(:,:,im+1)),[])  % use this line if you want PIV vectors on the inverted image
    clf;imshow(sequence2(:,:,im+1),[])  % use this line if you want PIV vectors on the original image
    hold on
    quiver(x{counter},y{counter},PIVlab_res.u_filt{counter},PIVlab_res.v_filt{counter},1,'g','LineWidth',3); % the '1' here is the scaling factor, normally it is set to '0'
    %title(['Frame ' num2str(specifyframes(im))]);
    
    export_fig(gcf,strcat(dir_movie,filesep, 'PIV_analysis_v11', filesep, 'Results_PIVlab', filesep, 'PIV_frame',num2str(specifyframes(im)),'.tif'),'-q101','-m2','-r200') % changed .pdf to .tif here    
end

PIVlab_res.x = x; PIVlab_res.y = y;
PIVlab_res.u = u; PIVlab_res.v = v;
PIVlab_res.mfile = 'PIV_commandline_v11.m';
save(strcat(dir_movie,filesep, 'PIV_analysis_v11', filesep, 'Results_PIVlab', filesep, 'PIVlab_res.mat'),'PIVlab_res')
close all
end
