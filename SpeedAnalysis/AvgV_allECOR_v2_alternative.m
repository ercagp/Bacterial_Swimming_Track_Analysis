%% Alternative meanV
clearvars;
close all; 
%% List file and load them. 
ECOR.Files{1} = 'Z:\Data\3D_Tracking_Data\20190315\ECOR36_z100micron_Obj\ROI_1\20190319_Tracking\Bugs_20190319T115900_ADMM_Lambda_1.mat';
ECOR.Files{2} = 'Z:\Data\3D_Tracking_Data\20190315\ECOR36_z100micron_Obj\ROI_2\20190326_Tracking\Bugs_20190326T195130_ADMM_Lambda_1.mat';
ECOR.Files{3} = 'Z:\Data\3D_Tracking_Data\20190319\ECOR36_z100micron_Obj\ROI_1\20190326_Tracking\Bugs_20190326T192454_ADMM_Lambda_1.mat';
ECOR.Files{4} = 'Z:\Data\3D_Tracking_Data\20190319\ECOR36_z100micron_Obj\ROI_2\20190326_Tracking\Bugs_20190326T110148_ADMM_Lambda_1.mat';
%ECOR.Files{5} = '.mat';
%ECOR.Files{6} = '';
%ECOR.Files{7} = '';

ECOR.StrainLabel = 'ECOR36';

ExportPath = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Round_one\3DTracking_ECORpairs\Average_MeanSpeeds';

for i = 1:length(ECOR.Files)
    load(ECOR.Files{i}); 
    
    S = SpeedStatistics(B_Smooth);
    allV{i} = cell2mat(S.allV);
    meanV(i) = mean(allV{i});
    N(i) = length(B_Smooth.Bugs);
    
    std_allV(i) = std(allV{i}); 
    err_allV(i) = SEMV(B_Smooth);
end

    %Find weighted average of mean speeds and standard error corrected for
    %overdispersion
    [avgW, errW] = weightedAv(meanV,err_allV);
    SaveLabel = ECOR.StrainLabel; 
    Files = ECOR.Files;
    save(fullfile(ExportPath,[SaveLabel '_WeightedAv']),'Files','meanV','N','err_allV','avgW','errW','SaveLabel');


