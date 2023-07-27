%% Combine PDFs using the script append_pdfs.m
clearvars;
close all; 
%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20191018';
StrainKeywords = {'KMT9_MMVFv3'};
Main_Path = fullfile(Main_Path,Video_Date); 
%Speed_Keyword = 'AllSpeedDist';
%TrajDur_Keyword = 'TotalDurationDist';
%MeanSpeed_Keyword = 'MeanSpeedDist';
%PlotKeyword = '_ZDist.pdf';
PlotKeyword = '_YZCrossSection.png';
%for KMT_i = 1:length(StrainKeywords)
    
%Include all subfolders
target_flag = 'off';
%Get the files
Files_Main = getallfilenames(Main_Path,target_flag);
%TargetFiles = Files_Main(contains(Files_Main,PlotKeyword) & (contains(Files_Main,StrainKeywords{1}) | contains(Files_Main,StrainKeywords{2})));
TargetFiles = Files_Main(contains(Files_Main,PlotKeyword) & contains(Files_Main,StrainKeywords{1}));
%Locate the ones with speed distribution on their label 
%Files_Speed = Files_Main(cellfun(@(x) contains(x,Speed_Keyword), Files_Main));
%Files_MeanSpeed = Files_Main(cellfun(@(x) contains(x,MeanSpeed_Keyword), Files_Main));
%Files_TrajDur = Files_Main(cellfun(@(x) contains(x,TrajDur_Keyword), Files_Main));

%end


%% Combine PDFs 
% for i = 1:length(Files_Speed)
% %append_pdfs(fullfile(Main_Path,[Video_Date '_KMT9_AllSpeedDist.pdf']),Files_Speed{i})
% %append_pdfs(fullfile(Main_Path,[Video_Date '_KMT9_AllMeanSpeedDist.pdf']),Files_MeanSpeed{i})
% %append_pdfs(fullfile(Main_Path,[Video_Date '_KMT9_AllTotalDurationDist.pdf']),Files_TrajDur{i})
% end
IM = []; 
for j = 1:length(TargetFiles)
    %append_pdfs(fullfile(Main_Path,[Video_Date '_' StrainKeywords{1}(1:end-2) '_all' PlotKeyword]),TargetFiles{j});
    IM = [IM imread(TargetFiles{j})];
    
end
imwrite(IM,fullfile(Main_Path,[Video_Date '_' StrainKeywords{1}(1:end) '_all' PlotKeyword]))