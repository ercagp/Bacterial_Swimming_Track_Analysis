%Determine the total number of cells in each acquisition
%and plot them as a function of time 
%by Ercag Pince
%October 2019 
clearvars;
close all; 

%% Define path and get the file list 
MainPath = 'Z:\Data\3D_Tracking_Data'; 
VideoDate = '20190920';
MainPath = fullfile(MainPath,VideoDate); 
%Keyword to find the files associated with the strain label
StrainKeyword = 'KMT9F_';
%Keyword to find the folder associated with the strain label
StrainFolderKeyword = [StrainKeyword '+\w'];
ROIKeyword = '\\+ROI+\w+\w+\\';
TrackLabelKeyword = '\\+\w+_Tracking+\\';
%Retrieve the file list 
Files = getallfilenames(MainPath);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(contains(Files,StrainKeyword)); 

%Define export path
MainExportPath = 'Z:\Data\3D_Tracking_Data_Analysis';
FullExportPath = fullfile(MainExportPath,VideoDate);

for KMT_i = 1:length(Files)
    %Load each .mat file contaning BugStruct
    load(Files{KMT_i});
    Files{KMT_i} 
    %Deduce the total number of bugs tracked 
    BugsTracked(KMT_i) = length(B_Smooth.Bugs); 
end

%Breakdown the matrix into 2 by 5 to bin the different ROIs of a same
%acquisition
NewBugsTracked = reshape(BugsTracked,[2,length(BugsTracked)/2]);
AvgBugsTracked = mean(NewBugsTracked,1); 
StdBugsTracked = std(NewBugsTracked,1); 
%% Plot the average number of bugs per acquisition 
%Define time vector
timeVec = [0 15 30 60 120]; %mins. 

hf_1 = figure(1);
%Plot the error bars
err = errorbar(timeVec,AvgBugsTracked,StdBugsTracked,'.'); 
%Error bar Style 
err.LineWidth = 1.5;
err.MarkerSize = 15; 
% err_1.Color = [0 0 1]; 

%Axis properties 
ax = gca; 
ax.XLim = [-5 130]; 
ax.YLim = [500 2000];
ax.XAxis.Label.String = 'Time (mins)';
ax.YAxis.Label.String = 'Average # of Bugs per Acq. (a.u.)';
ax.Title.String = StrainKeyword(1:end-1);
ax.Title.Interpreter = 'none'; 

%General Style 
ErcagGraphics
settightplot(ax)

%% Save figures in PDF, FIG and PNG formats
printfig(hf_1,fullfile(FullExportPath,[StrainKeyword(1:end-1) '_TotalNumberBugsvsTime']),'-dpng')
printfig(hf_1,fullfile(FullExportPath,[StrainKeyword(1:end-1) '_TotalNumberBugsvsTime']),'-dpdf')
savefig(hf_1,fullfile(FullExportPath,[StrainKeyword(1:end-1) '_TotalNumberBugsvsTime']))

%Save some variables for future use 
save(fullfile(FullExportPath,['avgBugsTracked_' StrainKeyword(1:end-1)]),'AvgBugsTracked','StdBugsTracked',...
    'timeVec');

