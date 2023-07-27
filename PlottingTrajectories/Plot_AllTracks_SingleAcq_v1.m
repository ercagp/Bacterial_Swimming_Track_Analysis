% Revamped version of Plot_AllTracks.m
% by Ercag Pince
% November 2021
clearvars;
close all; 
%% Define the path and load the data 
File = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\3D_Tracking_Data\20190604\KMT9_OD_0.19\ROI_1\20190605_Tracking\Bugs_20190605T185955_ADMM_Lambda_1.mat';
%Lambda value
Lambda = 1; 
%MainExportPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/TrajectoryAnalysis';
%Define regular expression key to search for the strain label,ROI & IPTG
RegExp_Strain = 'KMT[\d]'; 
RegExp_ROI = 'ROI[_]\d'; 
%Define regular expression key to search for Tracking label(e.g.20190210_Tracking) 
RegExp_TrackLabel = '\d*\d_Tracking';

%Set maximum of the colorbar for the velocity map
V_max = 200; %m/sec
%Find ROI number 
ROI = regexp(File,RegExp_ROI,'match','once');
StrainLabel = regexp(File,RegExp_Strain,'match','once'); 

%Find Track Label
%TrackLabel = regexp(Files{i},RegExp_TrackLabel,'match','once');

%Load the file 
load(File) 
%Plot it 
hf_1 = figure(1);
total_number = PlotAllTracks_ForStruct(B_Smooth); 
%Make Title 
title({StrainLabel,[num2str(total_number) ' cells']},'interpreter','none');
%Export the plot 
LambdaLabel = ['Lambda_' num2str(Lambda)]; 
    
%   ExportFolder = fullfile(MainExportPath,VideoDate,StrainLabel_IPTG,...
%          ROI,TrackLabel,LambdaLabel);
%    mkdir(ExportFolder);
    %Make an extra folder for individual trajectories 
%    mkdir(fullfile(ExportFolder,'IndividualTraj')); 
    %Save figure
%savefig(hf_1,fullfile(ExportFolder,[StrainLabel_IPTG '_' ROI '_SpaghettiPlot.fig']))
    
%% XZ and YZ Cross sections of the 3D spaghetti plot
figure(1)
ax = gca;
ax.ZLim = [-150 150];
%XZ Cross Section 
view([0 90 0]); 
%printfig(hf_1,fullfile(ExportFolder,[StrainLabel_IPTG '_' ROI '_SpaghettiPlot_XZCrossSection.png']),'-dpng')
%YZ Cross Section 
view([90 0 0]); 
%printfig(hf_1,fullfile(ExportFolder,[StrainLabel_IPTG '_' ROI '_SpaghettiPlot_YZCrossSection.png']),'-dpng');
   
%% Plot all tracks with velocity map 
hf_2 = figure(2); 
PlotColouredSpeedTrajectory2_ForStruct(B_Smooth,V_max);
%"total_number" is the total number of cells which have non-zero track length 
title({[StrainLabel ' - ' ROI],[num2str(total_number) ' cells']},'interpreter','none');
%     printfig(hf_2,fullfile(ExportFolder,[StrainLabel_IPTG '_' ROI '_VelocitySpaghettiPlot']),'-dpng')
%     printfig(hf_2,fullfile(ExportFolder,[StrainLabel_IPTG '_' ROI '_VelocitySpaghettiPlot.pdf']),'-dpdf')
%     savefig(hf_2,fullfile(ExportFolder,[StrainLabel_IPTG '_' ROI '_VelocitySpaghettiPlot.fig']))


