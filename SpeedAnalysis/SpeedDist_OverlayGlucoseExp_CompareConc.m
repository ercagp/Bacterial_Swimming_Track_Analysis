%% Speed distributions at different time points, 
% KMT9 & KMT9F (Experiment date: 20190920 & 20190924) 
% October 2019 
clearvars
close all; 
%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20191011';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = {'KMT9_Glu_5mM_1','KMT9_Glu_30mM_1','KMT9_Glu_5mM_2','KMT9_Glu_30mM_2'};
%Keyword to find the folder associated with the strain label
BugStruct_Keyword = 'CombinedBugStruct';
%% Load files and overlay speed distributions 

%Retrieve the file list  
Files = getallfilenames(Main_Path,'off');
%Eliminate the files that are not labelled as the set of indicated strain
%name
%Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 
Files = Files(contains(Files,Strain_Keyword{3}) | contains(Files,Strain_Keyword{4}));
%Find the combined Bugstruct
Files = Files(contains(Files,BugStruct_Keyword));

%Define the main export path 
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';

%Define plotting parameters
Edges = 0:5:200;
t = 0; %[0 60]; %mins. 
% legend_t = strsplit(num2str(t));
% legend_t = cellfun(@(x) [x ' mins'],legend_t,'UniformOutput',0); % add units next to each label 


for i =1:2
    %Identify the label of the recalled data 
    [match, ~] = regexp(Files{i},Strain_Keyword,'match','split'); 
    StrainLabel = cell2mat(match{~cellfun(@isempty,match)})
    legend_c{i} = StrainLabel;
    %Create export paths and load the data 
    %Load the file
    Files{i} 
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

%Legend 
legend_c = cellfun(@(x) [x(1:end-2) ' @60 mins'],legend_c,'UniformOutput',0); % add units next to each label 
% All Speeds
figure(1)
title(['All Speeds (' Video_Date ')'],'Interpreter','none')
ax_hf1 = gca;
%Set Axes Titles
ax_hf1.XLabel.String = 'Speed(\mum/s)';
ax_hf1.YLabel.String = 'PDF';
lh_1 = legend(legend_c,'Location','NorthEast','Interpreter','none');
lh_1.FontSize = 10;
ErcagGraphics
settightplot(ax_hf1)

%Median Speeds
figure(2)
title(['Median Speeds (' Video_Date ')'],'Interpreter','none')
ax_hf2 = gca; 
%Set Axes Titles
ax_hf2.XLabel.String = 'Median Speed(\mum/s)';
ax_hf2.YLabel.String = 'PDF';
lh_2 = legend(legend_c,'Location','NorthEast','Interpreter','none');
lh_2.FontSize = 10; 
ErcagGraphics
settightplot(ax_hf2)

%Weighted Median Speeds
figure(3)
title(['Weighted Median Speeds (' Video_Date ')'],'Interpreter','none')
ax_hf3 = gca;
%Set Axes Titles
ax_hf3.XLabel.String = 'Median Speed(\mum/s)';
ax_hf3.YLabel.String = 'PDF';
lh_3 = legend(legend_c,'Location','NorthEast','Interpreter','none');
lh_3.FontSize = 10;
ErcagGraphics
settightplot(ax_hf3)

%Mean Speeds 
figure(4)
title(['Mean Speeds (' Video_Date ')'],'Interpreter','none')
ax_hf4 = gca; 
%Set Axes Titles
ax_hf4.XLabel.String = 'Mean Speed(\mum/s)';
ax_hf4.YLabel.String = 'PDF';
lh_4 = legend(legend_c,'Location','NorthEast','Interpreter','none');
lh_4.FontSize = 10;
ErcagGraphics
settightplot(ax_hf4)

%Weighted Mean Speeds 
figure(5)
title(['Weighted Mean Speeds (' Video_Date ')'],'Interpreter','none')
ax_hf5 = gca;
%Set Axes Titles
ax_hf5.XLabel.String = 'Mean Speed(\mum/s)';
ax_hf5.YLabel.String = 'PDF';
lh_5 = legend(legend_c,'Location','NorthEast','Interpreter','none');
lh_5.FontSize = 10;
ErcagGraphics
settightplot(ax_hf5)

%% Export Figures 

printfig(hf_1,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_allV_2' ),'-dpng')
printfig(hf_1,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_allV_2'),'-dpdf')

printfig(hf_2,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_medV_2'),'-dpng')
printfig(hf_2,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_medV_2'),'-dpdf')

printfig(hf_3,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_WmedV_2'),'-dpng')
printfig(hf_3,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_WmedV_2'),'-dpdf')

printfig(hf_4,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_meanV_2'),'-dpng')
printfig(hf_4,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_meanV_2'),'-dpdf')

printfig(hf_5,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_WmeanV_2'),'-dpng')
printfig(hf_5,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', 'KMT9_GluConctrDist_WmeanV_2'),'-dpdf')


