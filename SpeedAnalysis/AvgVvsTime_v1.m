%% Determine average speed vs. time 
% for the time experiment on motility of KMT9 
% 1-) Recall the combined data and take the average of all bugs in all
% acquisitions
% 2-) Calculate the standard error of the mean by standard deviation of the
% speed dist / sqrt(number of trajectories) 
clearvars;
close all;

%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20190924';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT9_';
%Keyword to find the folder associated with the strain label
Strain_Folder_Keyword = 'KMT9_+\w';
BugStruct_Keyword = 'CombinedBugStruct';
%Retrieve the file list 
Files = getallfilenames(Main_Path,'off');
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 
%Find the combined Bugstruct
Files = Files(cellfun(@(x) contains(x,BugStruct_Keyword),Files)); 

%% Create export paths and load the data 
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';

i_max = length(Files);
%Preallocation 
axisText = cell(i_max); 
avgV = zeros(1,i_max); 
stdAllV = zeros(1,i_max);
semAvgV = zeros(1,i_max);
 for i = 1:i_max
     load(Files{i});
     %Get the speed statistics
     SpeedStats = SpeedStatistics(CB);
     %Retrieve all V 
     allV = cell2mat(SpeedStats.allV);
     %Take the mean of all velocities for all bugs in all acq. 
     avgV(i) = mean(allV); 
     %Get the standard deviation of the speed set 
     stdAllV(i) = std(allV);
     %Get the standard error 
     semAvgV(i) = stdAllV(i)./sqrt(length(SpeedStats.allV));
 end

timeVec = [0 15 30 60 120]; %mins. 
%% Plotting average speed vs. time 
hf_1 = figure;

err_1 = errorbar(timeVec, avgV, semAvgV,'.'); 

%Error bar Style 
err_1.LineWidth = 1.5;
err_1.MarkerSize = 15; 
err_1.Color = [0 0 1]; 

%Strain label 
Strain_Label = Strain_Keyword(1:end-1);

ax = gca; 
ax.XAxis.Label.String = 'Time (mins)';
ax.YAxis.Label.String = '<V> (\mum/s)';
ax.Title.String = {Strain_Label, 'Whole Population'};
ax.Title.Interpreter = 'none'; 

%General Style 
ErcagGraphics
settightplot(ax)

%Export figure
printfig(hf_1,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'AverageSpeedvsTime' ]),'-dpng')
printfig(hf_1,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'AverageSpeedvsTime' ]),'-dpdf')
savefig(hf_1,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'AverageSpeedvsTime' ]))

   