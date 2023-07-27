%Calculate mean and weighted mean of the mean speeds
%of ECORs (combined data) 
%Nature Rebuttal
%February 2019 
%Ercag 
clearvars;
close all; 

%Define Export Folder 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Average_MeanSpeeds';
mkdir(Export_Folder)

Folder = 'Z:\Data\3D_Tracking_Data';
Main_List = dir([Folder filesep '**']);
ECORList_index = contains({Main_List.folder},'ECOR');
ECOR_List = {Main_List(ECORList_index).folder}';
%Keyword
Keyword = 'ECOR19';
SubList = ECOR_List(contains(ECOR_List,Keyword));
SubList = unique(SubList);
SubSubList = SubList(contains(SubList,'ROI'));

%Exclude certain folders
Pattern = ["Erroneous_Tracking","Old_ECOR_Data"];
SubSubList(contains(SubSubList,Pattern)) = [];


%Define the alpha number
alph = 0.25; 
%Find the mat file

for i  = 1:length(SubSubList)
    MAT_List = dir([SubSubList{i} filesep '*.mat']);
    MAT_List_cell = {MAT_List.name};
    The_file = MAT_List_cell{contains(MAT_List_cell, num2str(alph))}; 
    load([SubSubList{i} filesep The_file]);
    %Get the speed statistics
    SpeedStats = SpeedStatistics(B_Smooth); 
    avgV_allBugs(i) = mean(cell2mat(SpeedStats.allV)); 
end

save([Export_Folder filesep Keyword '_AverageMeanSpeed.mat'],'avgV_allBugs') 

% %Plot average mean
% plot(1:length(ECOR_list),avg_meanV,'.r','MarkerSize',7);
% 
% 
% figure(1)
% plot(1:length(ECOR_list),weighted_avg,'.b','MarkerSize',7);
% ax = gca;
% ax.XLim = [0 7];
% ax.XTick = 1:length(ECOR_list);
% ax.XTickLabel = ECOR_list;
% 
% figure(2)
% plot(1:length(ECOR_list),avg_meanV,'.r','MarkerSize',7);
% ax_2 = gca; 
% ax_2.XLim = [0 7];
% ax_2.XTick = 1:length(ECOR_list);
% ax_2.XTickLabel = ECOR_list;
