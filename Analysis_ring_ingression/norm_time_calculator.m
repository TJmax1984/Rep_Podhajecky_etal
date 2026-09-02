function res = norm_time_calculator(ring_time,dist_um)
%% This function normalizes time with respect to ring ingression 
% as in Khaliullin Elife, 2018, used 30%-80% as in the Elife paper.
% Unlike the Elife paper, I did not do any refinement of t0 and t_ck as in 
% the elife paper. 

% Input:
% - ring_time = time frames from the original movie used. First timepoint 
%   is the frame of anaphase onset. 
% - dist_um = ring diamter over time in um. Note: should correspond to the 
%   timepoints in ring_time.  

onset_ind = find(dist_um<=0.7*dist_um(1));
onset_ind = onset_ind(1);
end_ind = find(dist_um<=0.2*dist_um(1));
end_ind = end_ind(1);

% scatter(ring_time,dist_um,[],"black")
% hold on
% scatter(ring_time(onset_ind:end_ind),dist_um(onset_ind:end_ind),[],"blue")

p = polyfit(ring_time(onset_ind:end_ind), dist_um(onset_ind:end_ind), 1);   % 1 = linear fit
m = p(1);               % slope
b = p(2);               % intercept
x = ring_time(onset_ind:end_ind);
y=(x.*m)+b;
%plot(x,y,'r')

mean_peri_initial = mean(dist_um(1:3)); % get mean ring peri prior to ring ingression, in order 
t0 = (mean_peri_initial-b)/m;
%xline(t0)
intercep_y = -b/m;
%xline(t_ck)
t_ck = intercep_y-t0;

% compute normalized time
res = {[(ring_time-t0)./t_ck];t0;t_ck};
end