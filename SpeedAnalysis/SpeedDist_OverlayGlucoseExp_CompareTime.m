%% Speed distributions at different time points, 
% KMT9 & KMT9F (Experiment date: 20190920 & 20190924) 
% October 2019 
clearvars
close all; 
%% Define Data Path and Gather Files List 
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20191011';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT9_Glu_30mM';
Strain_Label = 'KMT9 - 30mM';
%Keyword to find the folder associated with the strain label
BugStruct_Keyword = 'CombinedBugStruct';
%% Load files and overlay speed distributions 
%Retrieve the file list  
Files = getallfilenames(Main_Path,'off');
%Eliminate the files that are not labelled as the indicated strain name
%Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 
Files = Files(contains(Files,Strain_Keyword));
%Find the combined Bugstruct
Files = Files(cellfun(@(x) contains(x,BugStruct_Keyword),Files));

%Define the main export path 
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';

%Define plotting parameters
Edges = 0:5:200;
t = [0 60]; %mins. 
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
    %% Point(Instantaneous) speed distribution
    hf_1 = figure(1);
    hh_allV{i} = histogram(allV,Edges,'Normalization','pdf');
    hold on
    %% Median Speed 
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
    %% Mean Speed 
    %Mean speed distribution 
    hf_4 = figure(4);
    hh_meanV{i} = histogram(SpeedStats.meanV,Edges,'Normalization','pdf'); 
    hold on 
    
    %Weighted mean speed dist. 
    hf_5 = figure(5); 
    [NMean,Edges,binMean] = histcounts(SpeedStats.meanV,Edges);
    Weight_vec = SpeedStats.TrajDur;
        for k = 1:length(Edges)
            new_countsMeanV(k) = sum(Weight_vec(binMean == k));
        end
    histogram('BinEdges',Edges,'BinCounts',new_countsMeanV(1:end-1),'Normalization','PDF');
    hold on 
    
end
%% Plot parameters 
% All Speeds
figure(1)
title({[Strain_Label ' (' Video_Date ')'] ,'All Speeds'},'Interpreter','none')
ax_hf1 = gca;
%Set Axes Titles
ax_hf1.XLabel.String = 'Speed(\mum/s)';
ax_hf1.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf1)

%Median Speeds
figure(2)
title({[Strain_Label ' (' Video_Date ')'],'Median Speeds'},'Interpreter','none')
ax_hf2 = gca; 
%Set Axes Titles
ax_hf2.XLabel.String = 'Median Speed(\mum/s)';
ax_hf2.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf2)

%Weighted Median Speeds
figure(3)
title({[Strain_Label ' (' Video_Date ')'],'Weighted Median Speeds'},'Interpreter','none')
ax_hf3 = gca;
%Set Axes Titles
ax_hf3.XLabel.String = 'Median Speed(\mum/s)';
ax_hf3.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf3)

%Mean Speeds 
figure(4)
title({[Strain_Label ' (' Video_Date ')'],'Mean Speeds'},'Interpreter','none')
ax_hf4 = gca; 
%Set Axes Titles
ax_hf4.XLabel.String = 'Mean Speed(\mum/s)';
ax_hf4.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf4)

%Weighted Mean Speeds 
figure(5)
title({[Strain_Label ' (' Video_Date ')'],'Weighted Mean Speeds'},'Interpreter','none')
ax_hf5 = gca;
%Set Axes Titles
ax_hf5.XLabel.String = 'Mean Speed(\mum/s)';
ax_hf5.YLabel.String = 'PDF';
legend(legend_t,'Location','Best')
ErcagGraphics
settightplot(ax_hf5)

%% Export Figures 

printfig(hf_1,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_allV' ]),'-dpng')
printfig(hf_1,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_allV' ]),'-dpdf')

printfig(hf_2,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_medV' ]),'-dpng')
printfig(hf_2,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_medV' ]),'-dpdf')

printfig(hf_3,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_WmedV' ]),'-dpng')
printfig(hf_3,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_WmedV' ]),'-dpdf')

printfig(hf_4,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_meanV' ]),'-dpng')
printfig(hf_4,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_meanV' ]),'-dpdf')

printfig(hf_5,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_WmeanV' ]),'-dpng')
printfig(hf_5,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', [Strain_Keyword 'TimeSeriesDist_WmeanV' ]),'-dpdf')


