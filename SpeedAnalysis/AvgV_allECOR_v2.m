%1-) Calculate inverse variance weighted point speeds 
%2-) Calculate corrected error (overdispersion, using Katja's script)
clearvars; 
close all; 
%% Load Data 
ECOR.MainPath = '/Volumes/Pince/Data/3D_Tracking_Data/';
ECOR.VideoDates = {'20190215','20190318'};

ECOR.ROI{1,:} = {'ROI_1','ROI_2','ROI_1','ROI_2'};
ECOR.ROI{2,:} = {'ROI_1','ROI_2','ROI_3'};
ECOR.TrackingDates{1,:} = {'20190311','20190311','20190312','20190312'};
ECOR.TrackingDates{2,:} = {'20190323','20190321','20190328'};
ECOR.StrainLabels{1,:} = {'ECOR19_z175micron','ECOR19_z175micron','ECOR19_z175micron_NewSample','ECOR19_z175micron_NewSample'};
ECOR.StrainLabels{2,:} = {'ECOR19_z100micron_Obj','ECOR19_z100micron_Obj','ECOR19_z100micron_Obj'};
ECOR.Lambda = 1; 

%Define Export Path 
ExportPath = '/Users/ercagpince/Dropbox/Research/Paper_Revisions/Coexistence in bacterial populations/Round_one/3DTracking_ECORpairs/AverageMean_Speeds';

for i = 1:length(ECOR.VideoDates)
    for j = 1:length(ECOR.StrainLabels{i,:})
    FilePath = fullfile(ECOR.MainPath,ECOR.VideoDates{i},...
                       cell2mat(ECOR.StrainLabels{i}(j)),cell2mat(ECOR.ROI{i}(j)));
    Files = getallfilenames(FilePath,'off'); 
    Keyword = [cell2mat(ECOR.TrackingDates{i}(j)) '_Tracking'];
    Files = Files(contains(Files,Keyword) & contains(Files,['Lambda_',num2str(ECOR.Lambda)]));
    
    load(cell2mat(Files));
    
    %carry out speed statistics
    S = SpeedStatistics(B_Smooth);
    allV{i,j} = cell2mat(S.allV); 
    meanV = mean(allV{i,j});
    
    N(i,j) = length(B_Smooth.Bugs);
    
    std_allV(i,j) = std(allV{i,j}); 
    err_allV(i,j) = SEMV(B_Smooth);
    end
end

    meanV = reshape(meanV,[1 size(meanV,1)*size(meanV,2)]);
    err_allV = reshape(err_allV,[1 size(err_allV,1)*size(err_allV,2)]);
    %Find weighted average of mean speeds and standard error corrected for
    %overdispersion
    [avgW, errW] = weightedAv(meanV,err_allV);
    SaveLabel = regexp(ECOR.StrainLabels{j},'\w*(?=_z)','Match');
    save(fullfile(ExportPath,[cell2mat(SaveLabel{1}) '_WeightedAv']),'avgW','errW','SaveLabel');