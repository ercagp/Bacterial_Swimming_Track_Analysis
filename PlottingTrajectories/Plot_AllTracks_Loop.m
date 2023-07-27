% Looped version of Plot_AllTracks.m
% Ercag Pince
% June 2019
clearvars;
close all; 
%% Define the path and load the data 
Main_Path = 'Z:\Data\3D_Tracking_Data';
Video_Date = '20191014';
Main_Path = fullfile(Main_Path,Video_Date); 
%Include only final subfolders? 
Target_Flag = 'off';
Files = getallfilenames(Main_Path,Target_Flag);
Files = Files(contains(Files,'ADMM')); 
%Define Main Export Folder 
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
lambda = 1; 
%Flag for the decision if the file is raw or trend filtered
% raw_flag = ismember(0,lambda); 
%Set maximum of the colorbar for the velocity map
V_max = 200; %m/sec 

for i = 1:length(Files)
    [in_Label, out_Label] = regexp(Files{i},['(?<=' Video_Date ')\\+\w*[.]+\d*']);
    %[in_Label, out_Label]= regexp(Files{i},'\\+KMT9+\w+\w+\\');
    Sample_Label = Files{i}(in_Label+1:out_Label); 
    Extra_SubFolder = ''; 
    [in_ROI, out_ROI] = regexp(Files{i},'\\+ROI+\w+\w+\\');%Files{i}(48:52);
    ROI = Files{i}(in_ROI+1:out_ROI-1);
    [in_TrackLabel, out_TrackLabel] = regexp(Files{i}, '\\+\w+_Tracking+\\');%Files{i}(54:70); 
    Track_Label = Files{i}(in_TrackLabel+1:out_TrackLabel-1);
    %Load the file 
    load(Files{i}) 
    %Plot it 
    hf_1 = figure(1);
    total_number = PlotAllTracks_ForStruct(B_Smooth); 
    %Make Title 
    title({Sample_Label,[num2str(total_number) ' cells']},'interpreter','none');
    %Export the plot 
    Export_Folder = fullfile(Main_Export_Path, Video_Date,Sample_Label,Extra_SubFolder,ROI,...
    Track_Label,['lambda_' num2str(lambda)]);
    mkdir(Export_Folder); 
    %Save figure
    savefig(hf_1,fullfile(Export_Folder,[Sample_Label '_SpaghettiPlot.fig']))
    
    %% XZ and YZ Cross sections of the 3D spaghetti plot
    figure(1)
    ax = gca;
    ax.ZLim = [-150 150];
    %XZ Cross Section 
    view([0 90 0]); 
    printfig(hf_1,fullfile(Export_Folder,[Sample_Label '_SpaghettiPlot_XZCrossSection.png']),'-dpng')
    %YZ Cross Section 
    view([90 0 0]); 
    printfig(hf_1,fullfile(Export_Folder,[Sample_Label '_SpaghettiPlot_YZCrossSection.png']),'-dpng');
   
    %% Plot all tracks with velocity map 
    hf_2 = figure(2); 
    PlotColouredSpeedTrajectory2_ForStruct(B_Smooth,V_max);
    %"total_number" is the total number of cells which have non-zero track length 
    title({Sample_Label,[num2str(total_number) ' cells']},'interpreter','none');
    printfig(hf_2,fullfile(Export_Folder,[Sample_Label '_VelocitySpaghettiPlot.png']),'-dpng')
    savefig(hf_2,fullfile(Export_Folder,[Sample_Label '_VelocitySpaghettiPlot.fig']))
end

