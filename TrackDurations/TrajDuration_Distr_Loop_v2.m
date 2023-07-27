%% Plot Distribution Total Trajectory Durations

%June 2019
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20191003';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT12_Sample2';
%Keyword to find the folder associated with the strain label
Strain_Folder_Keyword = 'KMT12_Sample+\d';
ROI_Keyword = '\\+ROI+\w+\w+\\';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';
%Retrieve the file list 
Files = getallfilenames(Main_Path);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 

%Define export path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
lambda = 1;
Lambda_Label = ['lambda_' num2str(lambda)];

%Define bin edges 
Edges = 0:1:20; %seconds


for i = 1:length(Files)
    %% Create export paths and load the data 
    [in_Label, out_Label] = regexp(Files{i},['(?<=' Video_Date ')\\+\w*[.]+\d*']);
    Strain_Label = Files{i}(in_Label+1:out_Label); 
    Extra_SubFolder = ''; 
    [in_ROI, out_ROI] = regexp(Files{i},ROI_Keyword);
    ROI = Files{i}(in_ROI+1:out_ROI-1);
    [in_TrackLabel, out_TrackLabel] = regexp(Files{i}, TrackLabel_Keyword);
    Track_Label = Files{i}(in_TrackLabel+1:out_TrackLabel-1);
    Export_Folder = fullfile(Main_Export_Path,Video_Date,Strain_Label,...
          ROI,Track_Label,Lambda_Label)
    %Create the export folder at the path
    mkdir(Export_Folder);
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
    histogram(SpeedStats.TrajDur,Edges,'Normalization','PDF');
    title({[Strain_Label ' - ' ROI],'Total Duration Distribution'},'interpreter','none')
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.XLabel.String = 'Total Duration (sec.)';
    ax_h1.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h1)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_1,fullfile(Export_Folder,[Strain_Label '_TotalDurationDist.pdf']),'-dpdf')
      
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