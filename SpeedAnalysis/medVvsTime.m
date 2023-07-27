%% Overlay average speed vs. time plots
% for the time experiment on motility of KMT9 & KMT9F 
% 1-) Recall the combined data and take the average of all bugs in all
% acquisitions
% 2-) Calculate the standard error of the mean by standard deviation of the
% speed dist / sqrt(number of trajectories) 
clearvars;
close all;

%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20190920';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = {'KMT9_','KMT9F_'};
Strain_Labels = {Strain_Keyword{1}(1:end-1),Strain_Keyword{2}(1:end-1)};
%Keyword to find the folder associated with the strain label
%Strain_Folder_Keyword = {'KMT9_+\w','KMT9F_+\w'};
BugStruct_Keyword = 'CombinedBugStruct';

for KMT_i = 1:length(Strain_Keyword)
%Retrieve the file list  
Files = getallfilenames(Main_Path,'off');
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(contains(Files,Strain_Keyword{KMT_i})); 
%Find the combined Bugstruct
Files = Files(contains(Files,BugStruct_Keyword)); 

%Create export paths and load the data 
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';

i_max = length(Files);
%Preallocation 
axisText = cell(i_max); 
medV = zeros(1,i_max); 
stdAllV = zeros(1,i_max);
semedV = zeros(1,i_max);
 for i = 1:i_max
     load(Files{i});
     %Get the speed statistics
     SpeedStats = SpeedStatistics(CB);
     %Retrieve all V 
     allV = cell2mat(SpeedStats.allV);
     %Take the mean of all velocities for all bugs in all acq. 
     medV(i) = median(allV); 
     %Get the standard deviation of the speed set 
     stdAllV(i) = std(allV);
     %Get the standard error of the median 
     semedV(i) = 1.253*stdAllV(i)./sqrt(length(SpeedStats.allV));
 end

timeVec = [0 15 30 60 120]; %mins. 
%% Plotting average speed vs. time 
hf_1 = figure(1);

err{KMT_i} = errorbar(timeVec, medV, semedV,'.');
hold on 
%pl{KMT_i} = plot(timeVec, avgV,'-');

%Save variables 
%medV - Standard error of the median(semedV) 
save(fullfile(Main_Export_Path,Video_Date,['medV_' Strain_Labels{KMT_i}]),'medV','semedV');

end

%Error bar Style 
err{1}.LineWidth = 1.5;
err{2}.LineWidth = 1.5;
err{1}.MarkerSize = 15; 
err{2}.MarkerSize = 15; 
% err_1.Color = [0 0 1]; 


ax = gca; 
ax.XLim = [-5 130]; 
ax.YLim = [20 90];
ax.XAxis.Label.String = 'Time (mins)';
ax.YAxis.Label.String = 'Median V (\mum/s)';
ax.Title.String = {'KMT9 (09/24/2019)', 'Whole Population'};
ax.Title.Interpreter = 'none'; 

%Legend 
lg_1 = legend(Strain_Labels,'Location','Best');
lg_1.Interpreter = 'none';

%General Style 
ErcagGraphics
settightplot(ax)

%% Save figures in PDF, FIG and PNG formats
printfig(hf_1,fullfile(Main_Export_Path,Video_Date, 'KMT9_MedianSpeedvsTime'),'-dpng')
printfig(hf_1,fullfile(Main_Export_Path,Video_Date, 'KMT9_MedianSpeedvsTime'),'-dpdf')
savefig(hf_1,fullfile(Main_Export_Path,Video_Date, 'KMT9_MedianSpeedvsTime'))


   