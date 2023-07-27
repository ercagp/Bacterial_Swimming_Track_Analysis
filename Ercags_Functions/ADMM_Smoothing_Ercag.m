%The script that smoothens trajectories of bacteria 
%using alternating direction method of multipliers(ADMM) 
%Functions performing ADMM calculations were written by Katja Taute
%November 2018
clearvars; 
close all; 

%Define the path and load the data 
Path = 'Z:\Data';
Date_Exp = '3D_Tracking_Data\20190208\ECOR68_z_200micron';
Label_Exp = 'ROI_1';
File = 'Bugs_20190213T010203';

Full_Path = [Path filesep Date_Exp filesep Label_Exp];
load([Full_Path filesep File]);

%Define the lambda value 
lambda = 0.15; 

%ADMM smoothing 
B_Smooth = ADMMPositionSmoothing(B,lambda); 

%Save smoothened trajectories 
File_S = [File '_ADMM_Lambda_' num2str(lambda) '.mat'];
%save to the same directory as the initial file
save([Full_Path filesep File_S],'B_Smooth');
