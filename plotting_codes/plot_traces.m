function res = plot_traces(data_table,savepath)
%% Generate time traces and scatterplots
% Pre-conditions:
% - run Cytokinesis_analysis.m, this generates the data table which serves as
%   input for this code
% - savepath is the directory where you want the plots to be saved
% Output:
% - plots various traces, saved in savepath

close all

%% two initial parameters
dia_bin_width = 5; % in um
normtime_bin_width = 0.1;

%% Extract condition names (order as they appear in the table 
[~, ia, G] = unique(data_table.condition, 'stable');
condNames = data_table.condition(ia);

colori{1} =[0.6 0.6 0.6]; % usually do wt first as light grey
colori{2} = [0, 0, 1];
colori{3} = [0.9 0 0]; % Usually have overactive RHO-1 as red
colori{4} =  [0.3, 0.1, 0.14]; 
colori{5} = [0.3, 0.9, 0.14] ;
colori{6} = [0.3, 0.1, 0.14] ;

%% Pre-allocate figures
abs_ring_fig = figure; hold on; title('ring diameter'); % absolute ring diameter in um over time
norm_dia_fig = figure; hold on; title('normalized diameter'); % normalized ring diameter in um over time
int_ch1_fig = figure; hold on; title('fluo density'); % intensity over time 
dia_vs_int = figure; hold on; title('diameter vs density'); % ring diamter vs intensity over time
binned_int_fig = figure; hold on; title('binned diameter vs density'); % binned diameter vs density
binned_norm_int_f = figure; hold on; title('binned normtime vs normdensity'); % binned diameter vs density
if ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
    norm_dia_pre_fig = figure; hold on; title('normalized diameter (pre TS)'); % binned diameter vs density
    norm_dia_post_fig = figure; hold on; title('normalized diameter (post TS)'); % binned diameter vs density
    int_pre_fig = figure; hold on; title('intensity (pre TS)'); % binned diameter vs density

else
    norm_int_RK_fig = figure; hold on; title('normalized time vs normalized intensity'); % As done in Khaliulin et al, Elife
end

%% Make diameter and normalized time bins
allDiameters = [data_table.ring_dia_um{:}];
binned_dia_axis = [min(allDiameters) : dia_bin_width : max(allDiameters)];
if ~ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
    allNormtimes = [data_table.time_trace_norm_RK{:}];
    binned_normtime_axis= [min(allNormtimes): normtime_bin_width: max(allNormtimes)];
end

%% loop through the conditions and embryos
for cond = 1:length(condNames)
    % Extract data for current condition 'A'
    rows_cond = data_table.condition == condNames(cond);
    %table_cond = data_table(rows_cond,:);
    itr=1;
    for emb = 1:height(data_table)
        
        if rows_cond(emb)
            
            figure(abs_ring_fig)
            h_abs_ring_fig(cond)=plot(data_table.time_trace_sec{emb},data_table.ring_dia_um{emb},'color',colori{cond},'LineWidth',2);
            
            figure(norm_dia_fig)
            h_norm_dia_fig(cond)=plot(data_table.time_trace_sec{emb},data_table.ring_dia_norm{emb},'color',colori{cond},'LineWidth',2);
            
            figure(int_ch1_fig)
            h_int_ch1_fig(cond)=plot(data_table.time_trace_sec{emb},data_table.int_trace_ch1{emb},'color',colori{cond},'LineWidth',2);
            
            figure(dia_vs_int)
            h_dia_vs_int(cond)=scatter(data_table.ring_dia_um{emb},data_table.int_trace_ch1{emb},'MarkerEdgeColor',colori{cond},'MarkerFaceColor',colori{cond});
            
             
            if ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
                figure(norm_dia_pre_fig)
                time_trace = data_table.time_trace_sec{emb};
                time_trace_pre = time_trace(1:data_table.TS_time_afterAA_frames(emb));
                time_trace_post = time_trace(data_table.TS_time_afterAA_frames(emb):end);

                norm_dia = data_table.ring_dia_norm{emb};
                norm_dia_pre = norm_dia(1:data_table.TS_time_afterAA_frames(emb));
                norm_dia_post = norm_dia(data_table.TS_time_afterAA_frames(emb):end);                
                int_trace = data_table.int_trace_ch1{emb}; 
                int_trace_pre = int_trace(1:data_table.TS_time_afterAA_frames(emb)); % extract intensity trace before temp shift

                h_norm_dia_pre_fig(cond)=plot(time_trace_pre,norm_dia_pre,'color',colori{cond},'LineWidth',2);

                figure(norm_dia_post_fig)
                h_norm_dia_post_fig(cond)=plot(time_trace_post,norm_dia_post,'color',colori{cond},'LineWidth',2);

                figure(int_pre_fig)
                h_int_pre_fig(cond)=plot(time_trace_pre,int_trace_pre,'color',colori{cond},'LineWidth',2);
            else
                figure(norm_int_RK_fig)
                if isempty(data_table.time_trace_norm_RK{emb})
                else
                    h_norm_int_RK_fig(cond)=plot(data_table.time_trace_norm_RK{emb},data_table.int_norm_trace_ch1_RK{emb},'color',colori{cond},'LineWidth',2);                 
                end
            end
            
            % for making diameter bins, extract the diameter+intensity data from the
            % data_table. Same for doing time binning on the Khaliulin 
            % normalized data, extract all the normalized time intensity 
            % data from the data_table             
            if itr==1
                % First the diameters and intensities  
                all_dia_cond = data_table.ring_dia_um{emb};
                all_int_cond = data_table.int_trace_ch1{emb};
                if ~ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
                    % Then the normalized time and intensities 
                    all_norm_time_cond = data_table.time_trace_norm_RK{emb};
                    all_norm_int_cond = data_table.int_norm_trace_ch1_RK{emb};
                end

            else
                % First the diameters and intensities 
                all_dia_cond = horzcat(all_dia_cond,data_table.ring_dia_um{emb});
                all_int_cond = horzcat(all_int_cond,data_table.int_trace_ch1{emb});
                if ~ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
                    % Then the normalized time and intensities
                    all_norm_time_cond = horzcat(all_norm_time_cond,data_table.time_trace_norm_RK{emb});
                    all_norm_int_cond = horzcat(all_norm_int_cond,data_table.int_norm_trace_ch1_RK{emb});
                end
            end
            itr = itr+1;
        end
    end
    % bin diameters and get mean/std for corresponding intesity 
    figure(binned_int_fig)
    binned_int_std = bin_peri_int(binned_dia_axis,all_dia_cond,all_int_cond);    
    binned_int(cond,:) = binned_int_std(1,:);
    binned_std(cond,:) = binned_int_std(2,:);
    shadedErrorBar(binned_dia_axis,binned_int(cond,:),binned_std(cond,:),'lineProps',{'-', 'Color',colori{cond}});
    yl = ylim;        % get current [ymin ymax]
    ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
    
    if ~ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
        % bin normalized time and get mean/std for corresponding normalized intesity 
        figure(binned_norm_int_f)
        binned_int_std = bin_peri_int(binned_normtime_axis,all_norm_time_cond,all_norm_int_cond);    
        binned_norm_int(cond,:) = binned_int_std(1,:);
        binned_norm_std(cond,:) = binned_int_std(2,:);
        shadedErrorBar(binned_normtime_axis,binned_norm_int(cond,:),binned_norm_std(cond,:),'lineProps',{'-', 'Color',colori{cond}});
        yl = ylim;        % get current [ymin ymax]
        ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
    end
end

%% specify plot esthetics, eg. limits, plot a line as x-axis, label axes, etc.
figure(abs_ring_fig)
ylabel('ring diameter (\mum)','FontSize',12)
xlabel('time (s)','FontSize',12)
%legend(h_abs_ring_fig,condNames,'location','northeast','FontSize',18)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
hold off
General_nicePlot
savefig(strcat(savepath,filesep,'ring_diameter_trace.fig'))
saveas(gcf,strcat(savepath,filesep,'ring_diameter_trace.png'))

figure(norm_dia_fig)
ylabel('normalized ring diameter','FontSize',12)
xlabel('time (s)','FontSize',12)
%legend(h_norm_dia_fig,condNames,'location','northeast','FontSize',18)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
hold off
General_nicePlot
title('')
legend off
savefig(strcat(savepath,filesep,'norm_ring_diameter_trace.fig'))
saveas(gcf,strcat(savepath,filesep,'norm_ring_diameter_trace.png'))

figure(int_ch1_fig)
ylabel('Fluorescence density (a.u./\mum','FontSize',12)
xlabel('time (s)','FontSize',12)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  
legend(h_int_ch1_fig,condNames,'location','northwest','FontSize',12)
hold off
General_nicePlot
savefig(strcat(savepath,filesep,'fluo_density_trace.fig'))
saveas(gcf,strcat(savepath,filesep,'fluo_density_trace.png'))

figure(dia_vs_int)
ylabel('Fluorescence density (a.u./\mum)','FontSize',12)
xlabel('ring diameter (\mum)','FontSize',12)
legend(h_dia_vs_int,condNames,'location','northwest','FontSize',12)
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
set(gca, 'XDir', 'reverse');  % invert the y-axis
hold off
General_nicePlot
savefig(strcat(savepath,filesep,'fluo_density_dia_trace.fig'))
saveas(gcf,strcat(savepath,filesep,'fluo_density_dia_trace.png'))

if ~ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
    figure(norm_int_RK_fig)
    ylabel('Normalized fluo density','FontSize',12)
    xlabel('time - normalized','FontSize',12)
    %legend(h_norm_int_RK_fig,condNames,'location','northwest','FontSize',18)
    yl = ylim;        % get current [ymin ymax]
    ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
    xlim([0 1.3])
    hold off
    General_nicePlot
    title('')
    legend off
    savefig(strcat(savepath,filesep,'norm_fluo_density_trace_RK.fig'))
    saveas(gcf,strcat(savepath,filesep,'norm_fluo_density_dia_trace_RK.png'))

    figure(binned_norm_int_f)
    ylabel('Normalized fluo density','FontSize',12)
    xlabel('time - normalized','FontSize',12)
    xlim([0 1.3])
    yl = ylim;        % get current [ymin ymax]
    ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
    hold off
    General_nicePlot
    savefig(strcat(savepath,filesep,'norm_fluo_density_trace_mean.fig'))
    saveas(gcf,strcat(savepath,filesep,'norm_fluo_density_trace_mean.png'))
end

figure(binned_int_fig)
ylabel('Fluorescence density (a.u./\mum)','FontSize',12)
xlabel('ring diameter (\mum)','FontSize',12)
set(gca, 'XDir', 'reverse');  % invert the y-axis
yl = ylim;        % get current [ymin ymax]
ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
hold off
General_nicePlot
savefig(strcat(savepath,filesep,'fluo_density_ring_trace_mean.fig'))
saveas(gcf,strcat(savepath,filesep,'fluo_density_ring_trace_mean.png'))


if ismember('preTS_ingr_vel', data_table.Properties.VariableNames)
    figure(norm_dia_pre_fig)
    ylabel('normalized ring diameter','FontSize',12)
    xlabel('time (s)','FontSize',12)
    %legend(h_norm_dia_pre_fig,condNames,'location','northeast','FontSize',18)
    yl = ylim;        % get current [ymin ymax]
    ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
    hold off
    General_nicePlot
    title('')
    legend off
    savefig(strcat(savepath,filesep,'norm_ring_dia_preTS_trace.fig'))
    saveas(gcf,strcat(savepath,filesep,'norm_ring_dia_preTS_trace.png'))


    figure(norm_dia_post_fig)
    ylabel('normalized ring diameter','FontSize',12)
    xlabel('time (s)','FontSize',12)
    %legend(h_norm_dia_post_fig,condNames,'location','northeast','FontSize',18)
    yl = ylim;        % get current [ymin ymax]
    ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
    hold off
    General_nicePlot
    title('')
    legend off
    savefig(strcat(savepath,filesep,'norm_ring_dia_postTS_trace.fig'))
    saveas(gcf,strcat(savepath,filesep,'norm_ring_dia_postTS_trace.png'))

    figure(int_pre_fig)
    ylabel('Fluorescence density (a.u./\mum)','FontSize',18)
    xlabel('time (s)','FontSize',18)
    legend(h_int_pre_fig,condNames,'location','northeast','FontSize',18)
    yl = ylim;        % get current [ymin ymax]
    ylim([0 yl(2)]);  % set ymin = 0, keep ymax unchanged
    hold off
    General_nicePlot
    savefig(strcat(savepath,filesep,'fluo_density_preTS_trace.fig'))
    saveas(gcf,strcat(savepath,filesep,'fluo_density_preTS_trace.png'))
end
close  all
end
