% Backup .mat files of the bug trajectories to Dropbox folder 
% by Ercag 
% December 2019 
clearvars;
close all; 

%% Load the files list 
FilePath = 'Y:\Data\3DTracking_Data';

FilesList = getallfilenames(FilePath); 
 