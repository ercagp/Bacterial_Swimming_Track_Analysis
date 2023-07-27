%Combine trajectories of the same ECOR taken at either different days
%or instances 
%and show speed distributions 
%Nature Rebuttal
%February 2019
%by Ercag Pince

clearvars; 
close all; 

%% Define the path and load data
Main_Folder =  'Z:\Data\3D_Tracking_Data';
Acq_Date = '20190604'; 
Full_Path = fullfile(Main_Folder,Acq_Date); 
Sample_Label = 'KMT9_OD_0.60';

%Get the list of all subfolders
list = getallsubdirectories(Full_Path); 

%Define the lambda value of ADDM; 
lambda = 1;

Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
Export_label = Sample_Label;
Extra_SubFolder = '';
%Define Export Path 
Export_Folder = fullfile(Export_Path,'Combined',Acq_Date,Export_label,Extra_SubFolder);

%Make Export Path 
mkdir(Export_Folder);

%% Carry the speed statistics 
%Assign expression to search in the folder list
Exp = [Sample_Label '\\' Extra_SubFolder];

%Assign date expressions to be searched 
Date_Exp{1} = '201905\d*_Tracking';
Date_Exp{2} = '201906\d*_Tracking';
Date_Exp{3} = '20190530_Tracking';

%Retrieve the final list 
final_list = findlist(Full_Path,Exp,Date_Exp);
%Load and combine(concatanate) speed vectors 
CB = combine_BugsV2(final_list,lambda);

%Get the speed statistics
SpeedStats = SpeedStatistics(CB); 

%Weighted average of mean speeds 
%Define edges
Edge = 0:5:200;

[N,Edges,bin] = histcounts(SpeedStats.meanV,Edge);

Weight_vec=SpeedStats.TrajDur;

for i = 1:length(Edges)
new_counts(i) = sum(Weight_vec(bin == i));
end


%% Save the Speeds cell 
save(fullfile(Export_Folder,[Sample_Label '_CombinedBugStruct.mat']),'CB');

%% Figures 
%Mean Speed Distribution 
hf_1 = figure; 
histogram(SpeedStats.meanV,Edges,'Normalization','pdf'); 
title({Export_label,'Mean Speed Distribution - Combined'},'Interpreter','none')
ax_h1 = gca;
%Set Axes Titles
ax_h1.XLabel.String = 'Speed(\mum/s)';
ax_h1.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h1)
%Save the figure to the target(i.e. export) folder 
printfig(hf_1,[Export_Folder filesep Export_label '_MeanSpeedDist_Combined.pdf'],'-dpdf')

%Weighted Mean Speed Distribution 
%edgesV_weightedmean = 0:0.01:0.4;
hf_2 = figure; 
histogram('BinEdges',Edges,'BinCounts',new_counts(1:end-1),'Normalization','PDF');
%Set Title
title({Export_label, 'Weighted Mean Speed - Combined'},'Interpreter','none')
ax_h2 = gca;
%Set Axes Titles
ax_h2.XLabel.String = 'Speed(\mum/s)';
ax_h2.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h2)
%Save the figure to the target(i.e. export) folder 
printfig(hf_2,[Export_Folder filesep Export_label '_WeightedMeanSpeed_Combined.pdf'],'-dpdf')


%All Speed Distribution 
hf_3 = figure;
all_V = cell2mat(SpeedStats.allV);
histogram(all_V,Edges,'Normalization','pdf'); 
%Set Title
title({Export_label,'Speed Distribution - Combined'},'Interpreter','none')
ax_h3 = gca;
%Set Axes Titles
ax_h3.XLabel.String = 'Speed(\mum/s)';
ax_h3.YLabel.String = 'PDF';
%Adjust style 
ErcagGraphics
settightplot(ax_h3)
%Save the figure to the target(i.e. export) folder 
printfig(hf_3,[Export_Folder filesep Export_label '_AllSpeedDist_Combined.pdf'],'-dpdf')


function target_list = findlist(Folder,Label,Date_Exp)
list = getallsubdirectories(Folder);
sub_list = list(cellfun(@(x) ~isempty(regexp(x,Label, 'once')),list));
target_list = sub_list(cellfun(@(x) ~isempty(regexp(x,Date_Exp{1}, 'once'))| ~isempty(regexp(x,Date_Exp{2}, 'once'))|~isempty(regexp(x,Date_Exp{3}, 'once')),sub_list));
end

function CB = combine_BugsV2(target_list,lambda)
    BugPosition = {}; 
    BugSpeeds = {}; 
    for i = 1:length(target_list)
    Folder = target_list{i};
    
    %Take the list 
    list_folder = dir(fullfile(Folder,'*.mat')); 
    %Find the mat file with particular "lambda" number 
    lambda_logic = cellfun(@(x) ~isempty(regexp(x,['Lambda_' num2str(lambda)], 'once')),{list_folder.name}');
    
    %Load the .mat file 
    mat_file = fullfile(list_folder(lambda_logic).folder,list_folder(lambda_logic).name);
    load(mat_file);
    
    %Concatanate Bug Structures
    BugPosition = vertcat(BugPosition,B_Smooth.Bugs);
    BugSpeeds = vertcat(BugSpeeds,B_Smooth.Speeds);
    end
    
    %Generate the structure 
    CB.Parameters = B_Smooth.Parameters; 
    CB.Bugs = BugPosition; 
    CB.Speeds = BugSpeeds; 
end