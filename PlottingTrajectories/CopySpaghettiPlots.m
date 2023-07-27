%% Copy all spaghetti plots to a subfolder 

%Test 
clearvars;
close all; 
%% File Path
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20190616';
Main_Path = fullfile(Main_Path,Video_Date); 
Spaghetti_Keyword = 'SpaghettiPlot';
%Include all subfolders
target_flag = 'off';
%Get the files
Files_Main = getallfilenames(Main_Path,target_flag);
%Define the new path 
New_Folder = 'Z:\Data\3D_Tracking_Data_Analysis\20190616\All_SpaghettiPlots';
mkdir(New_Folder);
%% Find files and copy them 
Files_Spa = Files_Main(cellfun(@(x) contains(x,Spaghetti_Keyword), Files_Main));
for i = 1:length(Files_Spa)
    copyfile(Files_Spa{i},New_Folder)
end



