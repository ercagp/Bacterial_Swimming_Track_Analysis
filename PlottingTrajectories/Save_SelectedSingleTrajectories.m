close all;
clearvars; 
%Generate spaghetti plot with speed colormap 

%Define Export Path
% File = 'KMT47_25uM';
% Export_Path = 'F:\Dropbox\Conferences\GRC_SignalTransduction_2020';
% Export_Title = fullfile(Export_Path,File);
% 

%Load the mat file
Load_Path = 'Z:\Data\3D_Tracking_Data\20191204\KMT47_25uM\ROI_1\20191205_Tracking\Bugs_20191205T200121_ADMM_Lambda_10.mat';
load(Load_Path)

V_max = 150; %max

% %Spaghetti plot
% s_speeds = size(B_Smooth.Speeds,1);
% PlotAllTracksSpeedColored_ForStruct(B_Smooth,1:s_speeds,V_max,'labeloff')


%Select trajectories 
SpeedStats = SpeedStatistics(B_Smooth);
pltparameters.minDur = 5; % Seconds
pltparameters.maxSpeed = 200; % um/s
pltparameters.minSpeed = 10; % um/s
[k, kind] = MotileLongTrajectorySubset(SpeedStats,pltparameters.minSpeed,pltparameters.minDur);

%Individual plot 
hf = figure(1); 
PlotColouredSpeedTrajectory_ForStruct(B_Smooth,kind(13),V_max) 

%Adjust aspect ratioclse all 
aspect = 0.75;

%Set the figure size 
hf.Position = [hf.Position(1) hf.Position(2)-100 750 aspect*750];

%Adjust the angle 
view(252.1618,21.4832)
%Remove the title 
ax = gca; 
ax.Title.String = ''; 
%Set the axes colors to black (for post-processing)
ax.XColor = [0 0 0]; 
ax.YColor = [0 0 0];
ax.ZColor = [0 0 0];
ax.MinorGridColor = [0 0 0]; 
ax.GridColor= [0 0 0]; 
ax.FontName = 'Arial';
%ax.TickLabelInterpreter = 'none';
ax.XLabel.String = '{\itx} (µm)';
ax.YLabel.String = '{\ity} (µm)';
ax.ZLabel.String = '{\itz} (µm)';
ax.BoxStyle = 'full';
%ax.YLabel.Position = [ -10.9822 135.7163  -167.7438];

c = colorbar; 
c.Title.String = 'Speed (µm/s)';
c.Color = [0 0 0];
c.Label.Color = [0 0 0];

%Export figure as PNG and PDF 
%export_fig KMT47_25uM_Longerthan5Sec_Bug168 -pdf -r650 -transparent 



