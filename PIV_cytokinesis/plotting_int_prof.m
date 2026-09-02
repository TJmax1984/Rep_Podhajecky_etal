function res = plotting_int_prof
%% Plotting vx, vy, vmag profiles
% This code plots the intensity profiles along the AP axis. It uses
% the binned velocities (in bins along the AP axis) generated in
% Cytokinesis_flows_v1.m (binning_flow_field.m subcode) which saved 
% binned_vectors_ummin.mat. In addition, it also extracts the non-binned
% intensities from the same stripe.

% FIX THE AP AXIS TITLE, IT CAN BE ABSOLUTE FOR BOTH BINNING, TO DIST FROM
% RING

% PRe-conditions:
% - Cytokinesis_flows_v1.m must be ran first. This generates 
%   fluo_int.mat in each embryo directory
% - specify the directories of the conditions, as well as condition names
%   and colors, all to be specified in this code.

% output:
% - 2 plots: binned and continuous intensity profile

%% Specify where the data is and what it is
Path{1} = 'C:\Users\teije\Desktop\Fluo_measurements_midplaneAllan\nmy2GFP_unc60RNAi\1 L4440';
Path{2} = 'C:\Users\teije\Desktop\Fluo_measurements_midplaneAllan\nmy2GFP_unc60RNAi\2 L4440 unc60';

colori{1} =[0.6 0.6 0.6]; % usually do wt first as light grey
colori{2} = [0 0.1 0.9]; % Usually have overactive RHO-1 as red
colori{3} =  [1 0.6 0.6]; 

pixel_size = 0.1119; % in um. Biocev Nikon SD 60x (w/o optovar) = 0.1119 um
BG_fluo = 100; % camera noise

Caseleg={'L4440';'unc-60(RNAi)'};%

intprof_bin_fig = figure; hold on; title('Cortical levels') 
intprof_cont_fig = figure; hold on; title('Cortical levels') 

for cond = 1:length(Path)
    
    dirOutput_bin = subdir(fullfile(Path{cond},'fluo_int_bin.mat'));    
    filenames_bin = {dirOutput_bin.name};

    dirOutput_cont = subdir(fullfile(Path{cond},'fluo_int_cont.mat'));
    filenames_cont = {dirOutput_cont.name};

    Num_movies = length(filenames_bin);
    Caseleg{cond} = strcat(Caseleg{cond},' (n=',num2str(Num_movies),')'); % Update the Caseleg matrix such that it includes n numbers

    for embryo = 1:length(dirOutput_bin)
        load(filenames_bin{embryo})
        int_binall_embs(embryo,:) = fluo_int_bins;

        bin_no = length(fluo_int_bins(1,:));
        
        %figure(intprof_bin_fig)
        %vx_f(cond) = plot([0 : 1/(bin_no-1) : 1],binned_vectors_ummin(1,:),'color',colori{cond}) % First it plots lines of individual embryos, use the minus sign if imaged with the new (Zeiss) scope
        
        load(filenames_cont{embryo})
        int_contall_embs(embryo,:) = fluo_int_cont;

    end
    mean_int_bin = mean(int_binall_embs,1,'omitnan')-BG_fluo;
    sterr_int_bin = (std(int_binall_embs,1,'omitnan'))/sqrt(Num_movies);

    mean_int_cont = mean(int_contall_embs,1,'omitnan')-BG_fluo;
    sterr_int_cont = (std(int_contall_embs,1,'omitnan'))/sqrt(Num_movies);

    figure(intprof_bin_fig)
    int_f_bin(cond)=errorbar(mean_int_bin,sterr_int_bin,'o','color',colori{cond},'LineWidth',4,'MarkerFaceColor','w');% strcat('o-',colori(h))
    %int_f_bin(cond).XData = [0 : 1/(bin_no-1) : 1];
    lg{cond}=Caseleg{cond};

    figure(intprof_cont_fig)
    center = round(0.5*length(mean_int_cont));
    xaxis = pixel_size*((1:length(mean_int_cont))-center);
    %int_f_cont(cond)=errorbar(mean_int_cont,sterr_int_cont,'o','color',colori{cond},'LineWidth',4,'MarkerFaceColor','w');% strcat('o-',colori(h))
    int_f_cont(cond)=shadedErrorBar(xaxis,mean_int_cont,sterr_int_cont,'lineProps',{'Color', colori{cond}});%'o','color',colori{cond},'LineWidth',4,'MarkerFaceColor','w');% strcat('o-',colori(h))    
    %int_f_cont(cond).XData = (int_f_cont(cond).XData-center)*pixel_size;
    lg{cond}=Caseleg{cond};

    clear int_binall_embs
end

%% specify plot esthetics, eg. limits, plot a line as x-axis, label axes, etc.
%xlimits = [-0.1, 1.1];

figure(intprof_bin_fig)
ylabel('cortex levels (a.u.)','FontSize',18)
xlabel('AP bins','FontSize',18)
%xlim(xlimits)
%set(gca, 'YDir', 'reverse');  % invert the y-axis
legend(int_f_bin,lg,'location','northwest','FontSize',18)
yline(0,'k-','HandleVisibility','off');   
legend boxoff  
grid on
hold off
General_nicePlot

figure(intprof_cont_fig)
ylabel('cortex levels (a.u.)','FontSize',18)
xlabel('Distance from ring (um)','FontSize',18)
%xlim(xlimits)
%set(gca, 'YDir', 'reverse');  % invert the y-axis
legend(int_f_cont,lg,'location','northwest','FontSize',18)
yline(0,'k-','HandleVisibility','off');   
legend boxoff  
grid on
hold off
General_nicePlot

end