%% 
% - Take the average speed for each acquisition 
% - Weight the average speed with total trajectory time 
% - Take the weighted average of average speeds for a single ECOR

%Nature Rebuttal
%March 2019
%by Ercag Pince

clearvars; 
close all; 

%% Define the path and load data
FileStruct.Main_Folder = 'Z:\Data\3D_Tracking_Data';
FileStruct.VideoDate = {'20190213','20190227'};
FileStruct.SampleLabel = {'ECOR3','ECOR3'};
FileStruct.Extensions = {'_z200micron','_z100micron'};
FileStruct.ROI = {'ROI_1','ROI_1'}; %Region of Interest 
FileStruct.TrackingLabel = {'20190309_Tracking','20190307_Tracking'};
FileStruct.alpha = 0.25;
%Define the alpha value of ADDM; 
% alpha = 0.25;

%Define Export Path 
Export_Folder = ['F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs',...
     filesep 'Average_MeanSpeeds' filesep];
ECOR_number = FileStruct.SampleLabel{1};
%Make Export Path 
mkdir(Export_Folder);
% BugSpeeds = {};

%% Call each data one by one 

%load all data together
BSmooth_Acq_All = load_AllAcqData(FileStruct);

Total_TrajDur = zeros(1,length(BSmooth_Acq_All));
avg_V = zeros(1,length(BSmooth_Acq_All)); 
for i = 1:length(BSmooth_Acq_All)
    Single_Acq = BSmooth_Acq_All(i); 
    
    %Get the speed statistics 
    S = SpeedStatistics(Single_Acq);
    
    %Combine all speeds for a single acquisition data
    All_V = cell2mat(S.allV);
    
    %Take the mean of all instantenous speeds for all bugs (for single
    %acq.)
    avg_V(i) = mean(All_V);
    
    Total_TrajDur(i) = nansum(S.TrajDur);
end

%% Save the information of total durations and mean velocity 

save([Export_Folder ECOR_number '_AverageMeanSpeed.mat'],'avg_V','Total_TrajDur') 

