%Generate Spaghetti Plots of ECORs 
%Nature Rebuttal 
%by Ercag 
%February 2019 
close all; 
clearvars; 
%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20190522';
ECOR_Label = 'KMT9_OD_0.5';
Sample_Label = ECOR_Label;
Extra_SubFolder = '';
ROI = 'ROI_2'; %Region of Interest
Track_Label = '20190428_Tracking';
Folder =  fullfile(Main_Path,Video_Date,Sample_Label,...
         Extra_SubFolder,ROI,Track_Label);
lambda = 1; 

%Flag for the decision if the file is raw or trend filtered
raw_flag = ismember(0,lambda); 

list_mat = dir([Folder filesep '*.mat']); 
%Find the list of trend filtered files 
new_list_handle = cellfun(@(x) contains(x,'ADMM'),{list_mat.name});
list_mat_ADMM = list_mat(new_list_handle); 
%Find the list of raw files
list_mat_raw = list_mat(~new_list_handle); 

if raw_flag
    list_final = list_mat_raw;
else
    %Find the file having a specific lambda number
    final_handle = cellfun(@(x) contains(x,['Lambda_' num2str(lambda)]),{list_mat_ADMM.name});
    list_final = list_mat_ADMM(final_handle);
end


%Define Export Path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
Export_Folder = fullfile(Main_Export_Path, Video_Date,Sample_Label,Extra_SubFolder,ROI,...
    Track_Label,['lambda_' num2str(lambda)]);
mkdir(Export_Folder);

%List the smoothed trajectory file with a specific lambda value
FileName = list_final.name; 
load(fullfile(Folder,FileName))

%% Plot all tracks(i.e. spaghetti plot) 
if raw_flag 
    BugStruct = B; 
else
    BugStruct = B_Smooth;
end 

total_number = PlotAllTracks_ForStruct(BugStruct);
%"total_number" is the total number of cells which have non-zero track length 
title({ECOR_Label,[num2str(total_number) ' cells']});

hf_1 = gcf;
printfig(hf_1,[Export_Folder filesep Sample_Label '_SpaghettiPlot' ],'-dpdf')
savefig(hf_1,[Export_Folder filesep Sample_Label '_SpaghettiPlot' ])



