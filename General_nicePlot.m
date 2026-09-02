%% Make publication grade dotpot/boxplots 

% some general features:
my_font = 'Helvetica';
my_font_size = 20;
my_linewidth = 2;
my_font_weight = 'bold';
abs_height = 9; % plot height in centimeters (not figure height)


%set(gcf,'Interpreter','tex')
% get pixels per inch
% a = groot;
% pixels_inch = a.ScreenPixelsPerInch;
% pixels_mm = pixels_inch/25.4


fig = gcf;
fig.Units = 'centimeters'; % Position: [30.6211 6.9850 19.7556 14.8167]
fig.Position(2);


ax = gca;
ax.Units = 'centimeters';
%ax.Position = [ax.Position(1) 2*ax.Position(2) ax.Position(3) abs_height]; 

% count the number of conditions in the plot and set aspect ratio
% accordingly
%no_cond = length(ax.XTickLabel);


%pbaspect([0.25*no_cond 1 1]) % 0.25 pre-fac tor worked nicely, no particular reason
%x_limits = xlim;
%xlim([x_limits(1)+0.25 x_limits(end)-0.25])% again the 0.25 number just worked nicely, no particular reason

set(gca,'FontName',my_font,'FontSize',my_font_size,'LineWidth',my_linewidth,'Box','on','FontWeight',my_font_weight)

