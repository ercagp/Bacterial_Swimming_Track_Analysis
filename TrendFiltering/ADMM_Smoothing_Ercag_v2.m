%The script that smoothens trajectories of bacteria 
%using alternating direction method of multipliers(ADMM) 
%Functions performing ADMM calculations were written by Katja Taute
%updated on November 2021
clearvars; 
close all; 

%Define the path and load the data 
MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\3D_Tracking_Data\20190604';
Label = 'KMT9_OD_0.19\ROI_2';
RegKey_TrackDate = ['(?<=ROI[_]\d*\' filesep ')'  '\d*[_]\w*'];
RegKey_FileName = 'Bugs[_]\d*\w\d*(?=[.]mat)'; 
%Date_Track = '20190605_Tracking';
Files = getallfilenames(fullfile(MainPath,Label)); 

Files_Smooth = Files(contains(Files,'ADMM')); 
Files = Files(~contains(Files,'ADMM'));

load(Files{1}); %single acquisition! 

%Define the lambda value 
lambda = 0.5;

%Switch plot option on/off
plot_switch = 'plotoff';

%ADMM smoothing 
B_Smooth = ADMMPositionSmoothing(B,lambda,plot_switch); 


%Save smoothened trajectories 
TrackDate = regexp(Files{1}, RegKey_TrackDate, 'match', 'once'); 
FileNameRaw = regexp(Files{1}, RegKey_FileName, 'match', 'once');
FinalFile = fullfile(MainPath,Label,TrackDate,[FileNameRaw '_ADMM_Lambda_' num2str(lambda) '.mat']);

%save to the same directory as the initial file
save(FinalFile);
