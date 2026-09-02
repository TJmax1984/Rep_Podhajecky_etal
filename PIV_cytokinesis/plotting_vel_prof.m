function res = plotting_vel_prof
%% Plotting vx, vy, vmag profiles
% This code plots the velocity/speed profiles along the AP axis. It uses
% the binned velocities (in bins along the AP axis) generated in
% Cytokinesis_flows_v1.m (binning_flow_field.m subcode) which saved 
% binned_vectors_ummin.mat. 

% PRe-conditions:
% - Cytokinesis_flows_v1.m must be ran first. This generates 
%   binned_vectors_ummin.mat in each embryo directory
% - First row of  is binned_vectors_ummin the vx's, second the vy's, 3rd 
%   the vmag, all in um/min.
% - specify the directories of the conditions, as well as condition names
%   and colors, all to be specified in this code.

% output:
% - 3 plots of all the conditions

%% Specify where the data is and what it is
Path{1} = 'C:\Users\teije\Desktop\Fluo_measurements_midplaneAllan\nmy2GFP_unc60RNAi\1 L4440';
Path{2} = 'C:\Users\teije\Desktop\Fluo_measurements_midplaneAllan\nmy2GFP_unc60RNAi\2 L4440 unc60';

colori{1} =[0.6 0.6 0.6]; % usually do wt first as light grey
colori{2} = [0 0.1 0.9]; % Usually have overactive RHO-1 as red
colori{3} =  [1 0.6 0.6]; 

Caseleg={'L4440';'unc-60(RNAi)'};%

vx_fig = figure; hold on; title('vx profile') 
vy_fig = figure; hold on; title('vy profile') 
vmag_fig = figure; hold on; title('speed profile') 

for cond = 1:length(Path)
    
    dirOutput = subdir(fullfile(Path{cond},'binned_vectors_ummin.mat'));
    filenames = {dirOutput.name};
    Num_movies = length(filenames);
    Caseleg{cond} = strcat(Caseleg{cond},' (n=',num2str(Num_movies),')'); % Update the Caseleg matrix such that it includes n numbers

    for embryo = 1:length(dirOutput)
        load(filenames{embryo})
        vx_all_embs(embryo,:) = binned_vectors_ummin(1,:);
        vy_all_embs(embryo,:) = binned_vectors_ummin(2,:);
        vmag_all_embs(embryo,:) = binned_vectors_ummin(3,:);

        bin_no = length(binned_vectors_ummin(1,:));
        
        figure(vx_fig)
        %vx_f(cond) = plot([0 : 1/(bin_no-1) : 1],binned_vectors_ummin(1,:),'color',colori{cond}) % First it plots lines of individual embryos, use the minus sign if imaged with the new (Zeiss) scope
        figure(vy_fig)
        %vy_f(cond) = plot([0 : 1/(bin_no-1) : 1],binned_vectors_ummin(2,:),'color',colori{cond}) % 
        figure(vmag_fig)
        %vmag_f(cond) = plot([0 : 1/(bin_no-1) : 1],binned_vectors_ummin(3,:),'color',colori{cond}) % 
       
    end
    mean_vx = mean(vx_all_embs,1,'omitnan');
    sterr_vx = (std(vx_all_embs,1,'omitnan'))/sqrt(Num_movies);

    mean_vy = mean(vy_all_embs,1,'omitnan');
    sterr_vy = (std(vy_all_embs,1,'omitnan'))/sqrt(Num_movies);

    mean_vmag = mean(vmag_all_embs,1,'omitnan');
    sterr_vmag = (std(vmag_all_embs,1,'omitnan'))/sqrt(Num_movies);
    
    figure(vx_fig)
    vx_f(cond)=errorbar(mean_vx,sterr_vx,'o','color',colori{cond},'LineWidth',4,'MarkerFaceColor','w');% strcat('o-',colori(h))
    vx_f(cond).XData = [0 : 1/(bin_no-1) : 1];
    lg{cond}=Caseleg{cond};

    figure(vy_fig)
    vy_f(cond)=errorbar(mean_vy,sterr_vy,'o','color',colori{cond},'LineWidth',4,'MarkerFaceColor','w');% strcat('o-',colori(h))
    vy_f(cond).XData = [0 : 1/(bin_no-1) : 1];
    lg{cond}=Caseleg{cond};
    
    figure(vmag_fig)
    vmag_f(cond)=errorbar(mean_vmag,sterr_vmag,'o','color',colori{cond},'LineWidth',4,'MarkerFaceColor','w');% strcat('o-',colori(h))
    vmag_f(cond).XData = [0 : 1/(bin_no-1) : 1];
    lg{cond}=Caseleg{cond};

    clear vx_all_embs vy_all_embs vmag_all_embs
end

%% specify plot esthetics, eg. limits, plot a line as x-axis, label axes, etc.
xlimits = [-0.1, 1.1];

figure(vx_fig)
ylabel('x-velocity (\mum/min)','FontSize',18)
xlabel('AP axis','FontSize',18)
xlim(xlimits)
set(gca, 'YDir', 'reverse');  % invert the y-axis
legend(vx_f,lg,'location','northwest','FontSize',18)
yline(0,'k-','HandleVisibility','off');   
legend boxoff  
grid on
hold off
General_nicePlot

figure(vy_fig)
ylabel('y-velocity (\mum/min)','FontSize',18)
xlabel('AP axis','FontSize',18)
xlim(xlimits)
legend(vy_f,lg,'location','northwest','FontSize',18)
yline(0,'k-','HandleVisibility','off');   
legend boxoff  
grid on
hold off
General_nicePlot

figure(vmag_fig)
ylabel('speed (\mum/min)','FontSize',18)
xlabel('AP axis','FontSize',18)
xlim(xlimits)
legend(vmag_f,lg,'location','northwest','FontSize',18)
legend boxoff  
grid on
hold off
General_nicePlot
end