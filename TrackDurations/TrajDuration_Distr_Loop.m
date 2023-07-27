%% Plot Distribution Total Trajectory Durations

%June 2019
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20190701';
Main_Path = fullfile(Main_Path,Video_Date); 
%Strain keyword 
Strain_Keyword = '\\+KMT9+\w+\w+\\';
ROI_Keyword = '\\+Acq+\w+\w+\\';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';
%Retrieve the file list 
%Include only final subfolders? 
TargetFlag = 'on';
Files = getallfilenames(Main_Path,TargetFlag);
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
%Define export path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
lambda = 1;
Lambda_Label = ['lambda_' num2str(lambda)];
for i = 1:length(Files)
    [in_Label, out_Label]= regexp(Files{i},'\\+KMT9+\w+\w+\\');
    Sample_Label = Files{i}(in_Label+1:out_Label-1); 
    Extra_SubFolder = ''; 
    [in_ROI, out_ROI] = regexp(Files{i},'\\+ROI+\w+\w+\\');%Files{i}(48:52);
    ROI = Files{i}(in_ROI+1:out_ROI-1);
    [in_TrackLabel, out_TrackLabel] = regexp(Files{i}, '\\+\w+_Tracking+\\');%Files{i}(54:70); 
    Track_Label = Files{i}(in_TrackLabel+1:out_TrackLabel-1);
    Export_Folder = fullfile(Main_Export_Path, Video_Date,Sample_Label,Extra_SubFolder,ROI,...
    Track_Label,['lambda_' num2str(lambda)]);
    mkdir(Export_Folder)
    %Load the file 
    load(Files{i}) 
    %% Carry the speed statistics 
    %Create the structure containing speed info 
    S.Speeds = B_Smooth.Speeds;
    S.Parameters = B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S); 
    %Get the total trajectory duration for each bug and plot it
    hf_1 = figure;
    Edges = 0:50; %seconds
    histogram(SpeedStats.TrajDur,Edges,'Normalization','PDF');
    title({[Sample_Label ' - ' ROI],'Total Duration Distribution'},'interpreter','none')
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.XLabel.String = 'Total Duration (sec.)';
    ax_h1.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h1)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_1,fullfile(Export_Folder,[Sample_Label '_TotalDurationDist.pdf']),'-dpdf')
      
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