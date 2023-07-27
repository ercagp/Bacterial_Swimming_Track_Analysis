%% Plot Distribution Total Trajectory Durations

%June 2019
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
MainPath = 'Z:\Data\3D_Tracking_Data'; 
VideoDate = '20191011';
%Define regular expression key to search the strain label 
RegExp_StrainLabel = ['(?<=' VideoDate ')\\+\w*'];
%Define regular expression key to search ROI number
RegExp_ROI = '\\+ROI+[_]+\d\\'; 
%Define regular expression key to search for Lambda(smoothing parameter)
%number 
RegExp_Lambda = 'Lambda_\d';
%Define regular expression key to search for Tracking label(e.g.
%20190210_Tracking) 
RegExp_TrackLabel = '\\+\d*+_Tracking+\\'; 

MainPath = fullfile(MainPath,VideoDate); 

%Include only final subfolders? 
Target_Flag = 'off';
%Retrieve the file list 
Files = getallfilenames(MainPath,Target_Flag);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 

%Define export path
MainExportPath = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
% lambda = 1;
% Lambda_Label = ['lambda_' num2str(lambda)];

%Define bin edges 
Edges = 0:1:20; %seconds

for i = 1:length(Files)
    %% Create export paths and load the data 
    [inLabel, outLabel] = regexp(Files{i}, RegExp_StrainLabel);
    StrainLabel = Files{i}(inLabel+1:outLabel); 
    [inROI, outROI] = regexp(Files{i},RegExp_ROI);
    ROI = Files{i}(inROI+1:outROI-1);
    [inTrackLabel, outTrackLabel] = regexp(Files{i}, RegExp_TrackLabel);
    TrackLabel = Files{i}(inTrackLabel+1:outTrackLabel-1);
    [inLambda, outLambda] = regexp(Files{i}, RegExp_Lambda);
    LambdaLabel = Files{i}(inLambda:outLambda);
   
    ExportFolder = fullfile(MainExportPath,VideoDate,StrainLabel,...
          ROI,TrackLabel,LambdaLabel);
    %Create the export folder at the path
    mkdir(ExportFolder);
    %Load the file 
    load(Files{i})
    %% Carry the speed statistics 
    %Create the structure containing speed info 
    S.Speeds = B_Smooth.Speeds;
    S.Parameters = B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S);
    %Deduce the vector for trajectory durations 
    TrajDur = SpeedStats.TrajDur;
    %Get the total trajectory duration for each bug and plot it
    hf_1 = figure;
    histogram(TrajDur,Edges,'Normalization','PDF');
    title({[StrainLabel ' - ' ROI],'Total Duration Distribution'},'interpreter','none')
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.XLabel.String = 'Total Duration (sec.)';
    ax_h1.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h1)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_1,fullfile(ExportFolder,[StrainLabel '_TotalDurationDist.pdf']),'-dpdf')
    printfig(hf_1,fullfile(ExportFolder,[StrainLabel '_TotalDurationDist.png']),'-dpng')
    %% Store density and trajectory durations
    Density = length(B_Smooth.Bugs); %Number of cells 
    save(fullfile(ExportFolder, [StrainLabel '_TrajDurandDensity_' ROI '.mat']),'Density','TrajDur','Edges'); 
end



%% Load Vector of Total Trajectory Duration 
% number_ECOR = length(File_List);%Number of ECORs 
% axis_text = cell(1,number_ECOR);
% Sum_TotalTrajDur = zeros(1,number_ECOR);
% 
% for i = 1:number_ECOR
%     load([File_List(i).folder filesep File_List(i).name])
%      Sum_TotalTrajDur(i) = sum(Total_TrajDur);
%      axis_text{i} = File_List(i).name(1:6);
% end
% 
% %Drop the hyphen on ECOR8_ and ECOR3_ 
% axis_text{contains(axis_text,'ECOR8')}(end) = [];
% axis_text{contains(axis_text,'ECOR3')}(end) = [];
% 
% %% Plot the weighted average mean speeds 
% % Plot average mean speeds 
% hf_1 = figure(1);
% p_1 = plot(1:number_ECOR,Sum_TotalTrajDur,'.');
% p_1.LineWidth = 1.5;
% p_1.MarkerSize = 12; 
% p_1.Color = [0 0 1]; 
% 
% ax = gca;
% ax.XLim = [0 8];
% ax.XTick = 1:number_ECOR;
% ax.XTickLabel = axis_text;
% ax.YAxis.Label.String = 'Time(s)';
% ax.Title.String = 'Total Trajectory Durations';
% %ErcagGraphics
% ax.XAxis.Label.FontSize = 7;
% 
% printfig(hf_1,[Export_Folder filesep Export_Label],'-dpdf')