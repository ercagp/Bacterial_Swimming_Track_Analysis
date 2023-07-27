%% Speed distributions at different time points, 
% KMT9 & KMT9F (Experiment date: 20190920 & 20190924) 
% October 2019 
clearvars
close all; 
%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20191018';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label


%% Load files and overlay speed distributions 
%Find combined trajectories 
BugStruct_Keyword = 'CombinedBugStruct';
%Define regular expression key to search the strain label 
RegExp_SubStrainLabel = ['(?<=' Video_Date ')\\+\w*'];
%Retrieve the file list  
Files = getallfilenames(Main_Path,'off');
%Find the combined Bugstruct
Files = Files(contains(Files,BugStruct_Keyword));

%Define the main export path 
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';

%Define plotting parameters
Edges = 0:5:100;
t = 0; %mins. 

if t == 0
    RegExp_StrainLabel = ['(?<=' Video_Date ')\\+\w*_1'];
    ExportLabel = '_1';
else
    RegExp_StrainLabel = ['(?<=' Video_Date ')\\+\w*_2'];
    ExportLabel = '_2';
end
   
MatchIndex = regexp(Files,RegExp_StrainLabel);
FilesMask = cellfun(@(x) ~isempty(x), MatchIndex);
SubFiles = Files(FilesMask); 
for j = 1:length(SubFiles)
        [inLabel, outLabel] = regexp(SubFiles{j}, RegExp_SubStrainLabel);
        StrainLabel = SubFiles{j}(inLabel+1:outLabel); 
        
        %legend
        if j < 3
        [InLeg, OutLeg] = regexp(StrainLabel,'(?<=KMT9_GLu_)\w*(?=_)');
        leg{j} = StrainLabel(InLeg:OutLeg);
        else
        leg{j} = 'MMVF_v3';
        end
        
        
        load(SubFiles{j});
       
        %Retrieve speed statistics 
        SpeedStats = SpeedStatistics(CB);
        %Retrieve all velocities 
        allV = cell2mat(SpeedStats.allV);   
        
        % Point(Instantaneous) speed distribution
        hf_1 = figure(1);
        if j == 3
        hh_allV{j} = histogram(allV,Edges,'Normalization','pdf','FaceAlpha',0.3,'EdgeAlpha',0.3);
        else
        hh_allV{j} = histogram(allV,Edges,'Normalization','pdf');
        end
        hold on
    
        %Median speed distribution 
        hf_2 = figure(2); 
        hh_medV{j} = histogram(SpeedStats.medV,Edges,'Normalization','pdf'); 
        hold on
        
        %Mean speed distribution 
        hf_3 = figure(3);
        hh_meanV{j} = histogram(SpeedStats.meanV,Edges,'Normalization','pdf'); 
        hold on 
    
        %Weighted median distributions
        hf_4 = figure(4); 
        [N,Edges,bin] = histcounts(SpeedStats.medV,Edges);
        Weight_vec = SpeedStats.TrajDur;
        for k = 1:length(Edges)
            new_counts(k) = sum(Weight_vec(bin == k));
        end
        histogram('BinEdges',Edges,'BinCounts',new_counts(1:end-1),'Normalization','PDF');
        hold on        
        
        %Weighted mean distributions
        hf_5 = figure(5); 
        [NMean,Edges,binMean] = histcounts(SpeedStats.meanV,Edges);
        Weight_vec_Mean = SpeedStats.TrajDur;
        for l = 1:length(Edges)
            new_counts_Mean(l) = sum(Weight_vec_Mean(binMean == l));
        end
        if j == 3 
        histogram('BinEdges',Edges,'BinCounts',new_counts_Mean(1:end-1),'Normalization','PDF','FaceAlpha',0.3,'EdgeAlpha',0.3);
        else
        histogram('BinEdges',Edges,'BinCounts',new_counts_Mean(1:end-1),'Normalization','PDF');    
        end
        hold on     
end
hold off
%% Plot parameters

%Legend 
leg = cellfun(@(x) strcat(x,' @',num2str(t),'mins'),leg,'UniformOutput',0); % add units next to each label 
% All Speeds
figure(1)
title(['All Point Speed (' Video_Date ')'],'Interpreter','none')
ax_hf1 = gca;
%Set Axes Titles
ax_hf1.XLabel.String = 'Speed(\mum/s)';
ax_hf1.YLabel.String = 'PDF';
lh_1 = legend(leg,'Location','NorthEast','Interpreter','none');
lh_1.FontSize = 10;
ErcagGraphics
settightplot(ax_hf1)

%Median Speeds
figure(2)
title(['Median Speed (' Video_Date ')'],'Interpreter','none')
ax_hf2 = gca; 
%Set Axes Titles
ax_hf2.XLabel.String = 'Median Speed(\mum/s)';
ax_hf2.YLabel.String = 'PDF';
lh_2 = legend(leg,'Location','NorthEast','Interpreter','none');
lh_2.FontSize = 10; 
ErcagGraphics
settightplot(ax_hf2)

%Mean Speeds 
figure(3)
title(['Mean Speed (' Video_Date ')'],'Interpreter','none')
ax_hf3 = gca; 
%Set Axes Titles
ax_hf3.XLabel.String = 'Mean Speed(\mum/s)';
ax_hf3.YLabel.String = 'PDF';
lh_3 = legend(leg,'Location','NorthEast','Interpreter','none');
lh_3.FontSize = 10;
ErcagGraphics
settightplot(ax_hf3)

%Weighted Median Speeds
figure(4)
title(['Weighted Median Speed (' Video_Date ')'],'Interpreter','none')
ax_hf4 = gca;
%Set Axes Titles
ax_hf4.XLabel.String = 'Median Speed(\mum/s)';
ax_hf4.YLabel.String = 'PDF';
lh_4 = legend(leg,'Location','NorthEast','Interpreter','none');
lh_4.FontSize = 10;
ErcagGraphics
settightplot(ax_hf4)

% %Weighted Mean Speeds 
figure(5)
title(['Weighted Mean Speed (' Video_Date ')'],'Interpreter','none')
ax_hf5 = gca;
%Set Axes Titles
ax_hf5.XLabel.String = 'Mean Speed(\mum/s)';
ax_hf5.YLabel.String = 'PDF';
lh_5 = legend(leg,'Location','NorthEast','Interpreter','none');
lh_5.FontSize = 10;
ErcagGraphics
settightplot(ax_hf5)

%% Export Figures 

printfig(hf_1,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_allV' ExportLabel] ),'-dpng')
printfig(hf_1,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_allV' ExportLabel] ),'-dpdf')

printfig(hf_2,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_medV' ExportLabel]),'-dpng')
printfig(hf_2,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_medV' ExportLabel]),'-dpdf')

printfig(hf_3,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_meanV' ExportLabel]),'-dpng')
printfig(hf_3,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_meanV' ExportLabel]),'-dpdf')

printfig(hf_4,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_WmedV' ExportLabel]),'-dpng')
printfig(hf_4,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_WmedV' ExportLabel]),'-dpdf')

printfig(hf_5,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_WmeanV' ExportLabel]),'-dpng')
printfig(hf_5,fullfile(Main_Export_Path,Video_Date,'SpeedAnalysis', ['KMT9_GluConctrDist_WmeanV' ExportLabel]),'-dpdf')


