%% Speed distributions at different time points, 
% KMT9 & KMT9F (Experiment date: 20190920 & 20190924) 
% October 2019 
clearvars
close all; 
%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20190924';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT9_';
Strain_Label = Strain_Keyword(1:end-1);
%Keyword to find the folder associated with the strain label
BugStruct_Keyword = 'CombinedBugStruct';
%% Load files and overlay speed distributions 

%Retrieve the file list  
Files = getallfilenames(Main_Path,'off');
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 
%Find the combined Bugstruct
Files = Files(cellfun(@(x) contains(x,BugStruct_Keyword),Files));

%Define the main export path 
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';

%Define plotting parameters
Edges = 0:5:180;
t = [0 15 30 60 120]; %mins. 
legend_t = strsplit(num2str(t));
legend_t = cellfun(@(x) [x ' mins'],legend_t,'UniformOutput',0); % add units next to each label 


for i =1:length(Files)
    %Create export paths and load the data 
    %Load the file 
    load(Files{i});
    %Retrieve speed statistics 
    SpeedStats = SpeedStatistics(CB);
    %Retrieve all velocities 
    allV = cell2mat(SpeedStats.allV);   
    %All speed distribution
    hf_1 = figure(1);
    hh_allV{i} = histogram(allV,Edges,'Normalization','pdf');
    hold on
    %Median speed distribution 
    hf_2 = figure(2); 
    hh_medV{i} = histogram(SpeedStats.medV,Edges,'Normalization','pdf'); 
    hold on
    %Weighted median distributions
    hf_3 = figure(3); 
    [N,Edges,bin] = histcounts(SpeedStats.medV,Edges);
    Weight_vec = SpeedStats.TrajDur;
        for j = 1:length(Edges)
        new_counts(j) = sum(Weight_vec(bin == j));
        end
    histogram('BinEdges',Edges,'BinCounts',new_counts(1:end-1),'Normalization','PDF');
    hold on 
end
%% Plot parameters 
% All Speeds
figure(1)
title({Strain_Label,'All Speeds'},'Interpreter','none')
ax_hf1 = gca;
%Set Axes Titles
ax_hf1.XLabel.String = 'Speed(\mum/s)';
ax_hf1.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf1)

%Median Speeds
figure(2)
title({Strain_Label,'Median Speeds'},'Interpreter','none')
ax_hf2 = gca; 
%Set Axes Titles
ax_hf2.XLabel.String = 'Median Speed(\mum/s)';
ax_hf2.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf2)

%Weighted Median Speeds
figure(3)
title({Strain_Label,'Weighted Median Speeds'},'Interpreter','none')
ax_hf3 = gca;
%Set Axes Titles
ax_hf3.XLabel.String = 'Median Speed(\mum/s)';
ax_hf3.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf3)
%Export Figures 

printfig(hf_1,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'TimeSeriesDist_allV' ]),'-dpng')
printfig(hf_1,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'TimeSeriesDist_allV' ]),'-dpdf')

printfig(hf_2,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'TimeSeriesDist_medV' ]),'-dpng')
printfig(hf_2,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'TimeSeriesDist_medV' ]),'-dpdf')

printfig(hf_3,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'TimeSeriesDist_WmedV' ]),'-dpng')
printfig(hf_3,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'TimeSeriesDist_WmedV' ]),'-dpdf')




