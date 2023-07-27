%% Combine trajectories of the bugs which were acquired at different 
% region of interest and deduce the speed distribution
% v3 
%by Erçag Pinçe
%October 2019 
clearvars;
close all; 

%% Define path and other parameters
%-------Loading Path Parameters---------
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20191018';
%Define full main load path
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT9_MMVFv3_2';

%------Exporting Path Parameters--------
%Keyword to find the folder associated with the strain label
Strain_Folder_Keyword = Strain_Keyword;%'KMT9_Glu_30mM';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';
ROI_Keyword = 'ROI_+\w';
%Retrieve the file list 
Files = getallfilenames(Main_Path);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 

%Define export path
Main_Export_Path = '/Users/ercagpince/Dropbox/Research/3DTrackingAnalysisData';

%% Load each file and combine Bugstructs of different ROIs 

%Create the final (combined) structure with corresponding fields
CB.Bugs = {};
CB.Birthdays = {};
CB.LossCauses = {}; 
CB.Parameters = {};
CB.BugAmplitude = {}; 
CB.ImgPath = {}; 
CB.lambda = {};
CB.Speeds = {};


for i =1:length(Files)
     %% Create export paths and load the data 
    [in_Label, out_Label]= regexp(Files{i},Strain_Folder_Keyword);
    Strain_Label = Files{i}(in_Label:out_Label); 
    Extra_SubFolder = ''; 
    [in_ROI, out_ROI] = regexp(Files{i},ROI_Keyword);
    ROI = Files{i}(in_ROI+1:out_ROI-1);
    [in_TrackLabel, out_TrackLabel] = regexp(Files{i}, TrackLabel_Keyword);
    Track_Label = Files{i}(in_TrackLabel+1:out_TrackLabel-1);
    Export_Folder = fullfile(Main_Export_Path,Video_Date,Strain_Label,...
                   'CombinedTrajectories');
    %Create the export folder at the path
    mkdir(Export_Folder);
    %Load the file 
    load(Files{i});

    %Concatanate trajectories and speeds 
    CB.Bugs = vertcat(CB.Bugs,B_Smooth.Bugs);
    CB.Speeds = vertcat(CB.Speeds,B_Smooth.Speeds); 
    
    %Concatanate the rest
    CB.Birthdays = vertcat(CB.Birthdays,B_Smooth.Birthdays); 
    CB.LossCauses = vertcat(CB.LossCauses,B_Smooth.LossCauses); 
    CB.ParametersCell{i} = B_Smooth.Parameters;
    CB.BugAmplitude = vertcat(CB.BugAmplitude,B_Smooth.BugAmplitude);
    CB.ImgPath{i} = B_Smooth.ImgPath;
    CB.lambda{i} = B_Smooth.lambda;
    
end
CB.Parameters =  CB.ParametersCell{1}; 

%% Save the combined structure 
save(fullfile(Export_Folder,[Strain_Label '_CombinedBugStruct.mat']),'CB');

%% Retrieve speed statistics and define plot parameters 
SpeedStats = SpeedStatistics(CB);

%% Calculate weighted mean speed 
%Define edges of the histograms 
Edge = 0:5:200;
%Calculate weight of each bin as duration of trajectories 
[N,Edges,bin] = histcounts(SpeedStats.meanV,Edge);
Weight_vec=SpeedStats.TrajDur;

for i = 1:length(Edges)
new_counts(i) = sum(Weight_vec(bin == i));
end

%% Calculate weighted median speed 
%Calculate weight of each bin as duration of trajectories 
[NMed,Edges,binMed] = histcounts(SpeedStats.medV,Edge);
Weight_vec=SpeedStats.TrajDur;

for i = 1:length(Edges)
new_countsMedV(i) = sum(Weight_vec(binMed == i));
end

%% Plot the figures 
%% Mean Speed 
%Mean Speed Distribution 
hf_1 = figure; 
histogram(SpeedStats.meanV,Edges,'Normalization','pdf'); 
title({[Strain_Label ' - ' Video_Date],'Mean Speed'},'Interpreter','none')
ax_h1 = gca;
%Set Axes Titles
ax_h1.XLabel.String = 'Speed(\mum/s)';
ax_h1.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h1)
%Save the figure to the target(i.e. export) folder 
printfig(hf_1,fullfile(Export_Folder,[Strain_Label,'_MeanSpeedDist_Combined.pdf']),'-dpdf')

%Weighted Mean Speed Distribution 
%edgesV_weightedmean = 0:0.01:0.4;
hf_2 = figure; 
histogram('BinEdges',Edges,'BinCounts',new_counts(1:end-1),'Normalization','PDF');
%Set Title
title({[Strain_Label ' - ' Video_Date], 'Weighted Mean Speed'},'Interpreter','none')
ax_h2 = gca;
%Set Axes Titles
ax_h2.XLabel.String = 'Speed(\mum/s)';
ax_h2.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h2)
%Save the figure to the target(i.e. export) folder 
printfig(hf_2,fullfile(Export_Folder, [Strain_Label '_WeightedMeanSpeed_Combined.pdf']),'-dpdf')

%% Median Speed 
%Median Speed Distribution 

hf_3 = figure; 
histogram(SpeedStats.medV,Edges,'Normalization','pdf'); 
title({[Strain_Label ' - ' Video_Date],'Median Speed'},'Interpreter','none')
ax_h3 = gca;
%Set Axes Titles
ax_h3.XLabel.String = 'Speed(\mum/s)';
ax_h3.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h3)
%Save the figure to the target(i.e. export) folder 
printfig(hf_3,fullfile(Export_Folder,[Strain_Label,'_MedianSpeedDist_Combined.pdf']),'-dpdf')

%Weighted Median Speed Distribution

hf_4 = figure; 
histogram('BinEdges',Edges,'BinCounts',new_countsMedV(1:end-1),'Normalization','PDF');
title({[Strain_Label ' - ' Video_Date],'Weighted Median Speed'},'Interpreter','none')
ax_h4 = gca;
%Set Axes Titles
ax_h4.XLabel.String = 'Speed(\mum/s)';
ax_h4.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h4)
%Save the figure to the target(i.e. export) folder 
printfig(hf_4,fullfile(Export_Folder,[Strain_Label,'_WeightedMedianSpeed_Combined.pdf']),'-dpdf')

%% All Speed
hf_5 = figure; 
%Retrieve all speeds
allV = cell2mat(SpeedStats.allV);   
histogram(allV,Edges,'Normalization','pdf');
title({[Strain_Label ' - ' Video_Date],'All Inst. Speed'},'Interpreter','none')
ax_h5= gca;
%Set Axes Titles
ax_h5.XLabel.String = 'Speed(\mum/s)';
ax_h5.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h5)
%Save the figure to the target(i.e. export) folder 
printfig(hf_5,fullfile(Export_Folder,[Strain_Label,'_AllSpeed_Combined.pdf']),'-dpdf')








