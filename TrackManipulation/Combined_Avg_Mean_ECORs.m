%Calculate mean and weighted mean of the mean speeds
%of ECORs (combined data) 
%Nature Rebuttal
%February 2019 
%Ercag 
clearvars;
close all; 

Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Combined';
ECOR_list = {'ECOR8',...
    'ECOR18',...
    'ECOR19',...
    'ECOR20',...
    'ECOR21',...
    'ECOR68'};

for i = 1:length(ECOR_list)
    load([Folder filesep ECOR_list{i} filesep ECOR_list{i} '_CombinedBugStruct.mat'])
    %Get the speed statistics
    SpeedStats = SpeedStatistics(CB); 
    Weight_vec = SpeedStats.meanV.*SpeedStats.TrajDur;
    %Weighted average 
    weighted_avg(i) = nansum(Weight_vec)/nansum(SpeedStats.TrajDur);
    avg_meanV(i) = nanmean(SpeedStats.meanV); 
end

figure(1)
plot(1:length(ECOR_list),weighted_avg,'.b','MarkerSize',7);
ax = gca;
ax.XLim = [0 7];
ax.XTick = 1:length(ECOR_list);
ax.XTickLabel = ECOR_list;

figure(2)
plot(1:length(ECOR_list),avg_meanV,'.r','MarkerSize',7);
ax_2 = gca; 
ax_2.XLim = [0 7];
ax_2.XTick = 1:length(ECOR_list);
ax_2.XTickLabel = ECOR_list;
