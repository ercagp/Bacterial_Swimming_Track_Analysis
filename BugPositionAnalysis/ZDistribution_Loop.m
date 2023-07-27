%Deduce Z-Distribution from trajectories
%by Ercag Pince
%October 2019 
clearvars;
close all; 

%% Define Data Path and Gather Files List 
MainPath = 'Z:\Data\3D_Tracking_Data';
VideoDate = '20191003';
MainPath = fullfile(MainPath,VideoDate); 
%Define calling parameters for the strain
StrainKeyword = 'KMT12_Sample1';
StrainFolderKeyword = 'KMT12_Sample+\d';
ROIKeyword = '\\+ROI+\w+\w+\\';
TrackLabelKeyword = '\\+\w+_Tracking+\\';

%Include only final subfolders? 
TargetFlag = 'off';
Files = getallfilenames(MainPath,TargetFlag);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(contains(Files,StrainKeyword)); 

%Define export path
MainExportPath = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
lambda = 1;
LambdaLabel = ['lambda_' num2str(lambda)];

%Define the histogram's bin edge limits
Edges = -150:5:150; 

for i = 1:length(Files)
    [in_Label, out_Label]= regexp(Files{i},StrainFolderKeyword);
    StrainLabel = Files{i}(in_Label:out_Label); 
    [in_ROI, out_ROI] = regexp(Files{i},ROIKeyword);
    ROI = Files{i}(in_ROI+1:out_ROI-1);
    [in_TrackLabel, out_TrackLabel] = regexp(Files{i}, TrackLabelKeyword);
    TrackLabel = Files{i}(in_TrackLabel+1:out_TrackLabel-1);
    ExportFolder = fullfile(MainExportPath,VideoDate,StrainLabel,...
          ROI,TrackLabel,LambdaLabel);
    %Create the export folder at the path
    mkdir(ExportFolder);
    %Load the file 
    load(Files{i})
    %Extract the number of tracked bugs 
    TotalNumber = length(B_Smooth.Bugs);
    %Extract scaling parameters and rough focus value 
    ScaleZ = B_Smooth.Parameters.Refstack.ScaleZ;
    RoughFocus = B_Smooth.Parameters.Refstack.RoughFocus;
    %Extract Z-information
    Z = cellfun(@(x) (x(:,4)-RoughFocus)*ScaleZ,B_Smooth.Bugs,'UniformOutput',0);
    %Break down the cell into a large array 
    ZVec = cell2mat(Z); 
    %Plot the histogram 
    hf_1 = figure;
    histogram(ZVec,Edges,'Normalization','pdf'); 
    %Set Title
    title({[StrainLabel ' - ' ROI],[num2str(TotalNumber) ' cells']},'interpreter','none')
    
    %Set axis properties 
    ax = gca;
    %Set Axes Titles
    ax.XLabel.String = 'Z Position(\mum)';
    ax.YLabel.String = 'PDF';
    
    %Adjust style 
    ErcagGraphics
    settightplot(ax)
    %Save figure
    printfig(hf_1,fullfile(MainExportPath,VideoDate,StrainLabel,ROI,TrackLabel,LambdaLabel,[StrainLabel '_ZDist']),'-dpdf')
    printfig(hf_1,fullfile(MainExportPath,VideoDate,StrainLabel,ROI,TrackLabel,LambdaLabel,[StrainLabel '_ZDist']),'-dpng')
end

