% Looped version of Plot_AllTracks.m
% Ercag Pince
% June 2019
clearvars;
close all; 
%% Define the path and load the data 
MainPath = 'Z:\Data\3D_Tracking_Data';
VideoDate = '20191206';
MainPath = fullfile(MainPath,VideoDate); 
%Include only final subfolders? 
Target_Flag = 'off';
Files = getallfilenames(MainPath,Target_Flag);
%Select filtered trajectories with particular lambda value 
LambdaFiltr = 10; 
Files = Files(contains(Files,['ADMM_Lambda_' num2str(LambdaFiltr)])); 
%Define Main Export Folder 
MainExportPath = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define regular expression key to search the strain label 
RegExp_StrainLabel = ['(?<=' VideoDate ')\\+\w*'];
%Define regular expression key to search ROI number
RegExp_ROI = '\\+ROI+[_]+\d\\'; 
%Define regular expression key to search for Lambda(smoothing parameter)
%number 
RegExp_Lambda = 'Lambda_\d';
%Define regular expression key to search for Tracking label(e.g.
%20190210_Tracking) 
RegExp_TrackLabel = '\d*\d_Tracking';

%Set maximum of the colorbar for the velocity map
V_max = 200; %m/sec 

for i = 1:length(Files)
    %Find Sample Label
    [inLabel, outLabel] = regexp(Files{i}, RegExp_StrainLabel);
    StrainLabel = Files{i}(inLabel+1:outLabel); 
    %Find ROI number 
    [inROI, outROI] = regexp(Files{i},RegExp_ROI);   
    ROI = Files{i}(inROI+1:outROI-1);
    %Find Track Label
    [inTrackLabel, outTrackLabel] = regexp(Files{i}, RegExp_TrackLabel);
    TrackLabel = Files{i}(inTrackLabel+1:outTrackLabel-1);
    %Find Lambda number
    [inLambda, outLambda] = regexp(Files{i}, RegExp_Lambda);
    LambdaLabel = Files{i}(inLambda:outLambda);
    
    %Any ExtraSubfolder?
    Extra_SubFolder = '';
    
    %Load the file 
    load(Files{i}) 
    %Plot it 
    hf_1 = figure(1);
    total_number = PlotAllTracks_ForStruct(B_Smooth); 
    %Make Title 
    title({StrainLabel,[num2str(total_number) ' cells']},'interpreter','none');
    %Export the plot 
    ExportFolder = fullfile(MainExportPath,VideoDate,StrainLabel,...
          ROI,TrackLabel,LambdaLabel);
    mkdir(ExportFolder); 
    %Save figure
    savefig(hf_1,fullfile(ExportFolder,[StrainLabel '_SpaghettiPlot.fig']))
    
    %% XZ and YZ Cross sections of the 3D spaghetti plot
    figure(1)
    ax = gca;
    ax.ZLim = [-150 150];
    %XZ Cross Section 
    view([0 90 0]); 
    printfig(hf_1,fullfile(ExportFolder,[StrainLabel '_SpaghettiPlot_XZCrossSection.png']),'-dpng')
    %YZ Cross Section 
    view([90 0 0]); 
    printfig(hf_1,fullfile(ExportFolder,[StrainLabel '_SpaghettiPlot_YZCrossSection.png']),'-dpng');
   
    %% Plot all tracks with velocity map 
    hf_2 = figure(2); 
    PlotColouredSpeedTrajectory2_ForStruct(B_Smooth,V_max);
    %"total_number" is the total number of cells which have non-zero track length 
    title({StrainLabel,[num2str(total_number) ' cells']},'interpreter','none');
    printfig(hf_2,fullfile(ExportFolder,[StrainLabel '_VelocitySpaghettiPlot.png']),'-dpng')
    printfig(hf_2,fullfile(ExportFolder,[StrainLabel '_VelocitySpaghettiPlot.pdf']),'-dpdf')
    savefig(hf_2,fullfile(ExportFolder,[StrainLabel '_VelocitySpaghettiPlot.fig']))
end

