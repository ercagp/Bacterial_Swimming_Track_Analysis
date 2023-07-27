%% Determine Average Velocity of all the bugs at
% a given time point for KMT9 & KMT9F samples 
% September 2019 
% Ercag Pince
clearvars;
close all; 
%% Define the path 
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20190920';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT9F_';
%Keyword to find the folder associated with the strain label
Strain_Folder_Keyword = 'KMT9_+\w';
ROI_Keyword = '\\+ROI+\w+\w+\\';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';
%Retrieve the file list 
Files = getallfilenames(Main_Path);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 
%Take only one ROI
Files = Files(cellfun(@(x) contains(x,'ROI_1'),Files)); 

%Define Export Folder 
MainExportFolder = 'Z:\Data\3D_Tracking_Data_Analysis\';
ExportLabel = Strain_Keyword(1:end-1);

%% Load the data 
i_max = length(Files);
   for i = 1:i_max
       %Load the file 
       load(Files{i}); 
       %% Create the structure containing speed info 
       S.Speeds = B_Smooth.Speeds;
       S.Parameters = B_Smooth.Parameters;
       %Get the speed statistics
       SpeedStats = SpeedStatistics(S);
       %Retrieve all V 
       allV = cell2mat(SpeedStats.allV);
       %Take the mean of all velocities for all bugs in all acq. 
       avgV(i) = mean(allV); 
   end