%Select bugs from indices
%and plot their speed heatmapped trajectories 
%Ercag 
%February 2019
close all;

%Define the path to save the figures 
fig_path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs';

%Input the strain number
ECOR_num = 'ECOR68_z_200micron';
%Indicate the ROI number
ROI_num = 'ROI_1';

titre = [ECOR_num ' trajectories longer than ' num2str(minDur) ' sec.'];

%Select the excluded subset
ex_ind = [44,114,116,289,374,514,524,599,638,825,883];

new_kind = kind(~ismember(kind,ex_ind)); 
%Plot it
h_fig{1} = figure;
PlotColouredSpeedTrajectory_ForStruct(S, new_kind, maxSpeed, 'label');
title(titre)
%settightplot(gca);

%Save the trajectory plot 
total_path = [fig_path filesep ECOR_num filesep ROI_num];
mkdir(total_path)
fig_filename = [ECOR_num '_tlongerthan' num2str(minDur) 'sec'];
%printfig(h_fig{1},[total_path filesep fig_filename],'-dpdf')
%savefig(h_fig{1},[total_path filesep fig_filename]);

%% Histograms and distribution 
%Check the speed distribution of the subset 
allV_subset = SpeedStats.allV(new_kind);
h = zeros(1,length(new_kind));
edgesV = 0:2:150;

for i = 1:length(new_kind) 
    h_hist_fig{i} = figure(i+1);
    h(i)=histogram(allV_subset{i}, edgesV, 'Normalization','pdf','DisplayStyle','stairs');
    title(['Bug #' num2str(new_kind(i))])
    ax{i} = gca;
    ax{i}.XLabel.String = 'Velocity(\mum/s)';
    ErcagGraphics
    settightplot(ax{i})
    drawnow()
    %Print the plot to pdf 
    hist_filename = [ECOR_num '_BugNo_' num2str(new_kind(i))];
    %printfig(h_hist_fig{i},[total_path filesep hist_filename],'-dpdf')
end
