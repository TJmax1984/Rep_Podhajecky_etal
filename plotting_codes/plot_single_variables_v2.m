function res = plot_single_variables_v2(data_table,savepath)
%% Plot bee swarms of mean ring ingression speed, cytokinesis duration, intensity ratio
% This function extracts mean ring ingression speed, cytokinesis duration, 
% intensity ratio from the data table and makes bee swarm plots

% Pre-conditions:
% - run cytokinesis_analysis.m, this generates the data table which serves as
%   input for this code
% - savepath is the directory where you want the plots to be saved

% Output:
% - plots for mean ring ingression velocity, cytokinesis duration, 
%   intensity ratio, saved in savepath 

% extract condition names and number of embryos per condition
[condNames, ~,G] = unique(data_table.condition, 'stable');
%[G, condNames] = findgroups(data_table.condition);
nRowsPerCond = splitapply(@numel, data_table.condition, G);

% generate plotting matrix that notBoxPlot accepts as input
plot_mat_AA_ring_onset = nan(max(nRowsPerCond),length(condNames));
plot_mat_int_ratio_RK = nan(max(nRowsPerCond),length(condNames));
plot_mat_AA_halfmax = nan(max(nRowsPerCond),length(condNames));
plot_mat_dur_fit = nan(max(nRowsPerCond),length(condNames));
plot_mat_dur65_end_fit = nan(max(nRowsPerCond),length(condNames));
plot_mat_vel_fit = nan(max(nRowsPerCond),length(condNames));
plot_mat_ratio_ch1_fit = nan(max(nRowsPerCond),length(condNames));
plot_mat_ratio_ch1_change_fit = nan(max(nRowsPerCond),length(condNames));

for cond = 1:length(condNames)
    % Extract data for current condition 'A'
    rows_cond = data_table.condition == condNames(cond);    
    plot_mat_AA_ring_onset(1:nRowsPerCond(cond),cond) = data_table.AA_ring_onset_fit(rows_cond);   % all numeric columns        
    plot_mat_AA_halfmax(1:nRowsPerCond(cond),cond) = data_table.AA_halfmax_ingr_fit(rows_cond);   % all numeric columns
    plot_mat_int_ratio_RK(1:nRowsPerCond(cond),cond) = data_table.int_ratio_ch1_RK(rows_cond);   % all numeric columns
    plot_mat_dur_fit(1:nRowsPerCond(cond),cond) = data_table.cyto_duration_fit(rows_cond);
    plot_mat_dur65_end_fit(1:nRowsPerCond(cond),cond) = data_table.duration_65_end_fit(rows_cond);
    plot_mat_vel_fit(1:nRowsPerCond(cond),cond) = data_table.mean_dia_vel_ummin_fit(rows_cond);
    plot_mat_ratio_ch1_fit(1:nRowsPerCond(cond),cond) = data_table.int_ratio_ch1_fitinterp(rows_cond); 
    plot_mat_ratio_ch1_change_fit(1:nRowsPerCond(cond),cond) = data_table.ratio_change_time_fitinterp(rows_cond); 
end

%% plot time anaphase onset until ring ingression onset
% this is the only plot that is done regardless of whether it was a TS
% experimnet.
plot_not_box = notBoxPlot(plot_mat_AA_ring_onset,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames)
ylabel('time AA - ingression (s)')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
General_nicePlot
savefig(strcat(savepath,filesep,'time_AA_ingr_onset.fig'))
saveas(gcf,strcat(savepath,filesep,'time_AA_ingr_onset.png'))
close all

%% plot ingression velocity (with fitting)
plot_not_box = notBoxPlot(plot_mat_vel_fit,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames)
ylabel('ingression velocity (um/min)')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
General_nicePlot
savefig(strcat(savepath,filesep,'ingression_velocity_fit.fig'))
saveas(gcf,strcat(savepath,filesep,'ingression_velocity_fit.png'))
close all

%% plot cyto duration (with fitting)
plot_not_box = notBoxPlot(plot_mat_dur_fit,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames);
ylabel('duration (s)')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
General_nicePlot
savefig(strcat(savepath,filesep,'cyto_duration_fit.fig'))
saveas(gcf,strcat(savepath,filesep,'cyto_duration_fit.png'))
close all

%% plot duration from 65% to end (with fitting)
plot_not_box = notBoxPlot(plot_mat_dur65_end_fit,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames);
ylabel('duration (s)')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
General_nicePlot
savefig(strcat(savepath,filesep,'duration_65_5_fit.fig'))
saveas(gcf,strcat(savepath,filesep,'duration_65_5_fit.png'))
close all

%% plot intensity ratio (with fitting and interpolation)
plot_not_box = notBoxPlot(plot_mat_ratio_ch1_fit,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames);
ylabel('intensity ratio')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
%yline(0,'k-','HandleVisibility','off');       
General_nicePlot
savefig(strcat(savepath,filesep,'intensity ratio fit.fig'))
saveas(gcf,strcat(savepath,filesep,'intensity ratio fit.png'))
close all

%% plot intensity ratio using Khalliulin normalization
plot_not_box = notBoxPlot(plot_mat_int_ratio_RK,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames);
ylabel('intensity ratio normalized (Khaliulin way)')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
%yline(0,'k-','HandleVisibility','off');       
General_nicePlot
savefig(strcat(savepath,filesep,'intensity ratio Khaliulin norm.fig'))
saveas(gcf,strcat(savepath,filesep,'intensity ratio Khaliulin norm.png'))
close all

%% plot intensity ratio normalized by duration 65%-end ring ingression (with fitting and interp)
plot_not_box = notBoxPlot(plot_mat_ratio_ch1_change_fit,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames);
ylabel('ratio / sec')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
%ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
%yline(0,'k-','HandleVisibility','off');       
General_nicePlot
savefig(strcat(savepath,filesep,'ratio chance per sec fit.fig'))
saveas(gcf,strcat(savepath,filesep,'ratio chance per sec fit.png'))
close all

%% plot time anaphase onset until 50% ingression
plot_not_box = notBoxPlot(plot_mat_AA_halfmax,[1:length(condNames)],'jitter',0.5,'interval','tInterval');
% Make the standard deviation invisible and give different colors
for k = 1:length(condNames)
    plot_not_box(k).sdPtch.EdgeAlpha = 0;
    plot_not_box(k).sdPtch.FaceAlpha = 0;
    plot_not_box(k).mu.Color = [174/256 214/256 241/256];
    plot_not_box(k).semPtch.FaceColor = [133/256 193/256 233/256] ;%[0.6 0.6 0.6];133, 193, 233 52, 152, 219 
    plot_not_box(k).semPtch.EdgeColor = [133/256 193/256 233/256];%[0.6 0.6 0.6];
    plot_not_box(k).semPtch.FaceAlpha = 0.4;
    plot_not_box(k).semPtch.EdgeAlpha = 0.4;
end
%boxplot(final_mat_vmag,'Colors','b') 
set(gca,'xtick',[1:length(condNames)],'xticklabel',condNames)
ylabel('time AA - 50% ingression (s)')
xtickangle(30)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
General_nicePlot
savefig(strcat(savepath,filesep,'time_AA_halfmax_ingr.fig'))
saveas(gcf,strcat(savepath,filesep,'time_AA_halfmax_ingr.png'))
close all
end