close all;
clearvars; 
%Generate spaghetti plot with speed colormap 

%Define Export Path
File = 'ECOR18_ExFig_SpaghettiPlot_2';
Export_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Extended_Fig';
Export_Title = fullfile(Export_Path,File);


%Load the mat file
Load_Path = 'Z:\Data\3D_Tracking_Data\20190208\ECOR18_z_200micron_NewSample\ROI_1\20190310_Tracking\Bugs_20190310T081032_ADMM_Lambda_1.mat';
load(Load_Path)

V_max = 50; %max

%Spaghetti plot
s_speeds = size(B_Smooth.Speeds,1);
PlotAllTracksSpeedColored_ForStruct(B_Smooth,1:s_speeds,V_max,'labeloff')

%Adjust aspect ratioclse all 

aspect = 0.75;

%Set the figure size 
hf = figure(1); 
hf.Position = [hf.Position(1) hf.Position(2)-100 750 aspect*750];

%Adjust the angle 
view(-7,18)
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
ax.YLabel.Position = [ -10.9822 135.7163  -167.7438];

c = colorbar; 
c.Title.String = 'Speed (µm/s)';
c.Color = [0 0 0];
c.Label.Color = [0 0 0];

%Export figure as PNG and PDF 
export_fig ECOR18_ExFig_SpaghettiPlot_2 -png -r650 -transparent 



