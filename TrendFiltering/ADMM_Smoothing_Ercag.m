%The script that smoothens trajectories of bacteria 
%using alternating direction method of multipliers(ADMM) 
%Functions performing ADMM calculations were written by Katja Taute
%November 2018
clearvars; 
close all; 

%Define the path and load the data 
Main_Path = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\3D_Tracking_Data\20190604';
Label_Exp = 'KMT9_OD_0.19\ROI_1';
Date_Track = '20190605_Tracking';
Files = dir([Main_Path filesep Label_Exp filesep Date_Track filesep '*.mat']);
Files = Files(~contains({Files.name},'ADMM'));

Final_String = [Files.folder filesep Files.name];

load(Final_String);

%Define the lambda value 
lambda = 0.5;

%Switch plot option on/off
plot_switch = 'plotoff';

%ADMM smoothing 
B_Smooth = ADMMPositionSmoothing(B,lambda,plot_switch); 

%Save smoothened trajectories 
File_Smooth = [Files.name(1:end-4) '_ADMM_Lambda_' num2str(lambda) '.mat'];
%save to the same directory as the initial file
save([Files.folder filesep File_Smooth],'B_Smooth');
