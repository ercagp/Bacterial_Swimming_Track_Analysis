%Analysis of ECOR data
%Plot longer trajectories than a duration threshold
%Nature Rebuttal 
%by Ercag
%February 2019
clearvars; 
close all;

%% Define the path and load data
Main_Folder =  'Z:\Data\3D_Tracking_Data\ECOR3_Specific';
Sample_Label = 'ECOR3';

%Get the list of all subfolders
list = getallsubdirectories(Main_Folder); 

%Define the lambda value of ADDM; 
lambda = 1;

Export_label = Sample_Label;
%Define Export Path 
Export_Folder = ['F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs',...
     filesep 'Combined' filesep Export_label filesep 'ECOR3'];

%Make Export Path 
mkdir(Export_Folder);

%% Take the list of the .mat files
file_list = findlist(Main_Folder,Sample_Label,lambda)';

string_list = {'20190208 - ROI_1',...
               '20190208 - ROI_2' ,...
               '20190213 - ECOR3_z200micron' ,...
               '20190227 - ECOR3_z200micron'};
           
%% Discard stationary bugs and combine the rest 
% Define the parameters of the subset 
minDur = 5; % Seconds
maxSpeed = 100; % um/s
minSpeed = 5; % um/s

% Define Export Path 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Combined\ECOR3\Motile_Subset';
%Make Export Path 
mkdir(Export_Folder);
%Make folder for spaghetti plots
Spaghetti_Folder = fullfile(Export_Folder,'Spaghetti_Plots');
mkdir(Spaghetti_Folder);
%Define cells for combination
BugPosition = {}; 
BugSpeeds = {}; 
%Preallocate others
ax = cell(1,length(file_list));

    for i = 1:length(file_list)
    %load the mat file
    load(file_list{i});
 
    %Speed Statistics
    %Calculate r vector at each position of time point 
    r = calculateR(B_Smooth);
     
    %Perform Speed Statistics 
    SpeedStats = SpeedStatistics(B_Smooth);
 
    %Retrieve a subset of trajectories which are longer than minDur seconds
    %with maximum and minimum speeds of maxSpeed and minSpeed
    [k, kind] = MotileLongTrajectorySubset(SpeedStats,minSpeed,minDur);
 
    %Plot the selected trajectories by "kind" index numbers
    figure 
    PlotColouredSpeedTrajectory_ForStruct(B_Smooth, kind, maxSpeed, 'label')
    %title(Sample_Label)
    ax{i} = gca; 
    ax{i}.Title.String = string_list{i}; 
    ax{i}.Title.Interpreter = 'none';
    %Print each figure
    figfile_label = fullfile(Spaghetti_Folder,['ECOR3_' string_list{i}]);
    printfig(gcf,figfile_label,'-dpdf')
    savefig(gcf,figfile_label)
    
    %Combine Bug Trajectories and Speeds 
    BugPosition = vertcat(BugPosition,B_Smooth.Bugs(kind));
    BugSpeeds = vertcat(BugSpeeds,B_Smooth.Speeds(kind));
    end

%Generate the structure 
CB.Parameters = B_Smooth.Parameters; 
CB.Bugs = BugPosition; 
CB.Speeds = BugSpeeds; 
%Save the structure
save(fullfile(Export_Folder,'ECOR3_CombinedBugStruct.mat'),'CB');

%% Figures
%SpeedStats for combined cell 
SpeedStats_Combined = SpeedStatistics(CB);
%Edge vector for all histograms 
Edges = 0:1:50; 

%All Speed Distribution 
hf_allspeed = figure;
all_V = cell2mat(SpeedStats_Combined.allV);
histogram(all_V,Edges,'Normalization','pdf'); 
%Set Title
title({'ECOR3 Motile Fraction', 'Speed Distribution'})
ax_allspeed = gca;
%Set Axes Titles
ax_allspeed.XLabel.String = 'Speed(\mum/s)';
ax_allspeed.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_allspeed)
%Save the figure to the target(i.e. export) folder 
printfig(hf_allspeed,[Export_Folder '_AllSpeedDist'],'-dpdf')


%Mean Speed Distribution 
hf_mean = figure; 
histogram(SpeedStats_Combined.meanV,Edges,'Normalization','pdf'); 
title({'ECOR3 Motile Fraction', 'Mean Speed Distribution'})
ax_mean = gca;
%Set Axes Titles
ax_mean.XLabel.String = 'Speed(\mum/s)';
ax_mean.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_mean)
%Save the figure to the target(i.e. export) folder 
printfig(hf_mean,[Export_Folder '_MeanSpeedDist'],'-dpdf')

%Weighted average of mean speeds 
%Define edges

[N,Edges_new,bin] = histcounts(SpeedStats.meanV,Edges);

Weight_vec=SpeedStats.TrajDur;

for i = 1:length(Edges_new)
new_counts(i) = sum(Weight_vec(bin == i));
end

%Weighted Mean Speed Distribution 
hf_weight = figure; 
histogram('BinEdges',Edges_new,'BinCounts',new_counts(1:end-1),'Normalization','PDF');
%Set Title
title({'ECOR3 Motile Fraction','Weighted Mean Speed Distribution'})
ax_weight = gca;
%Set Axes Titles
ax_weight.XLabel.String = 'Speed(\mum/s)';
ax_weight.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_weight)
%Save the figure to the target(i.e. export) folder 
printfig(hf_weight,[Export_Folder '_WeightedMeanSpeed_Combined'],'-dpdf')


%% Functions 
function target_list = findlist(Folder,Label,lambda)
list = getallsubdirectories(Folder);
sub_list = list(cellfun(@(x) ~isempty(regexp(x,Label)),list));
folder_list = sub_list(cellfun(@(x) ~isempty(regexp(x,'201903\d*_Tracking'))| ~isempty(regexp(x,'20190227_Tracking'))|~isempty(regexp(x,'20190228_Tracking')),sub_list));
    for i = 1:length(folder_list)
    mat_list = dir([folder_list{i} filesep '*.mat']); 
    %Find the mat file with particular "lambda" number 
    lambda_logic = cellfun(@(x) ~isempty(regexp(x,['Lambda_' num2str(lambda)], 'once')),{mat_list.name}');
    %Specific mat file list 
    target_list{i} = fullfile(mat_list(lambda_logic).folder,mat_list(lambda_logic).name);
    end
end

