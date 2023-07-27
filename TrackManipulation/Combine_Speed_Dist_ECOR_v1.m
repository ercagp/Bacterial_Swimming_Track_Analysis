%Combine trajectories of the same ECOR taken at either different days
%or instances 
%and show speed distributions 
%Nature Rebuttal
%February 2019
%by Ercag Pince

clearvars; 
close all; 

%% Define the path and load data
FileStruct.Main_Folder = 'Z:\Data\3D_Tracking_Data';
FileStruct.VideoDate = {'20190208','20190208','20190213','20190227'};
FileStruct.SampleLabel = {'ECOR_3','ECOR_3','ECOR3','ECOR3'};
FileStruct.Extensions = {[],[],'_z200micron','_z100micron'};
FileStruct.ROI = {'ROI_1','ROI_2','ROI_1','ROI_1'}; %Region of Interest 
FileStruct.TrackingLabel = {'20190328_Tracking','20190328_Tracking','20190309_Tracking','20190307_Tracking'};
FileStruct.lambda = 1;
%Define the lambda value of ADDM; 
% lambda = 0.25;

Export_label = FileStruct.SampleLabel{1};
%Define Export Path 
Export_Folder = ['F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs',...
     filesep 'Combined' filesep Export_label filesep];
%Make Export Path 
mkdir(Export_Folder);
% BugSpeeds = {};

%% Carry the speed statistics 
CB = combine_Bugs(FileStruct);

%Generate the Speeds structure
% S.Speeds = CB.Speeds;
% S.Parameters = B_Smooth.Parameters;
%Get the speed statistics
SpeedStats = SpeedStatistics(CB); 

%Weighted average of mean speeds 
%Define edges
Edge = 0:1:50; 

[N,Edges,bin] = histcounts(SpeedStats.meanV,Edge);

Weight_vec=SpeedStats.TrajDur;

for i = 1:length(Edges)
new_counts(i) = sum(Weight_vec(bin == i));
end


%% Save the Speeds cell 
save([Export_Folder Export_label '_CombinedBugStruct.mat'],'CB');

%% Figures 
%Mean Speed Distribution 
hf_1 = figure; 
histogram(SpeedStats.meanV,Edges,'Normalization','pdf'); 
title({Export_label,'Mean Speed Distribution - Combined'})
ax_h1 = gca;
%Set Axes Titles
ax_h1.XLabel.String = 'Speed(\mum/s)';
ax_h1.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h1)
%Save the figure to the target(i.e. export) folder 
printfig(hf_1,[Export_Folder filesep Export_label '_MeanSpeedDist_Combined'],'-dpdf')

%Weighted Mean Speed Distribution 
%edgesV_weightedmean = 0:0.01:0.4;
hf_2 = figure; 
histogram('BinEdges',Edges,'BinCounts',new_counts(1:end-1),'Normalization','PDF');
%Set Title
title({Export_label, 'Weighted Mean Speed - Combined'})
ax_h2 = gca;
%Set Axes Titles
ax_h2.XLabel.String = 'Speed(\mum/s)';
ax_h2.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h2)
%Save the figure to the target(i.e. export) folder 
printfig(hf_2,[Export_Folder filesep Export_label '_WeightedMeanSpeed_Combined'],'-dpdf')


%All Speed Distribution 
hf_3 = figure;
all_V = cell2mat(SpeedStats.allV);
histogram(all_V,Edges,'Normalization','pdf'); 
%Set Title
title({Export_label,'Speed Distribution - Combined'})
ax_h3 = gca;
%Set Axes Titles
ax_h3.XLabel.String = 'Speed(\mum/s)';
ax_h3.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h3)
%Save the figure to the target(i.e. export) folder 
printfig(hf_3,[Export_Folder filesep Export_label '_AllSpeedDist_Combined'],'-dpdf')