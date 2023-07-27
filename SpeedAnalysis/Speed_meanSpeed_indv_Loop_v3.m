%Weighted Mean for Individual Acquisitions
%by Ercag
%February 2019 
clearvars; 
close all; 
%% Define the path and load data
MainPath = 'Z:\Data\3D_Tracking_Data'; 
VideoDate = '20191211';
MainPath = fullfile(MainPath,VideoDate); 
%Define regular expression key to search the strain label 
RegExp_StrainLabel = ['(?<=' VideoDate ')\\+\w*'];
%Define regular expression key to search ROI number
RegExp_ROI = '\\+ROI+[_]+\d\\'; 
%Define regular expression key to search for Lambda(smoothing parameter)
%number 
RegExp_Lambda = 'Lambda_\d';
%Define regular expression key to search for Tracking label(e.g.
%20190210_Tracking) 
RegExp_TrackLabel = '\\+\d*+_Tracking+\\'; 

%Retrieve the file list 
Files = getallfilenames(MainPath);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
%Eliminate the files that are not labelled as the indicated strain name
%Files = Files(cellfun(@(x) contains(x,StrainKeyword),Files)); 

%Define export path
MainExportPath = 'Z:\Data\3D_Tracking_Data_Analysis';
% %Define Smoothing Parameter Lambda
% lambda = 1;
% Lambda_Label = ['lambda_' num2str(lambda)];

for i = 1:length(Files)
    %% Create export paths and load the data 
    %Find Sample Label
    [inLabel, outLabel] = regexp(Files{i}, RegExp_StrainLabel);
    StrainLabel = Files{i}(inLabel+1:outLabel); 
    %Find ROI number 
    [inROI, outROI] = regexp(Files{i},RegExp_ROI);   
    ROI = Files{i}(inROI+1:outROI-1);
    %Find Track Label
    [inTrackLabel, outTrackLabel] = regexp(Files{i}, RegExp_TrackLabel);
    TrackLabel = Files{i}(inTrackLabel+1:outTrackLabel-1);
    %Find Lambda number
    [inLambda, outLambda] = regexp(Files{i}, RegExp_Lambda);
    LambdaLabel = Files{i}(inLambda:outLambda);
    
    %Any ExtraSubfolder?
    Extra_SubFolder = '';
        
    %Define the export folder
    ExportFolder = fullfile(MainExportPath,VideoDate,StrainLabel,...
          ROI,TrackLabel,LambdaLabel);
    %Create the export folder at the path
    mkdir(ExportFolder);
    %Load the file 
    load(Files{i}); 
    
    %% Carry the speed statistics 
    %Create the structure containing speed info 
    S.Speeds = B_Smooth.Speeds;
    S.Parameters = B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S); 
    %% Figures
    %Define the edge vector for all histograms 
    Edges = 0:5:200; 
    
    %Mean Speed Distribution 
    hf_1 = figure; 
    histogram(SpeedStats.meanV,Edges,'Normalization','pdf'); 
    title({[StrainLabel ' - ' ROI],'Mean Speed Distribution'},'interpreter','none')
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.XLabel.String = '<V>(\mum/s)';
    ax_h1.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h1)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_1,fullfile(ExportFolder,[StrainLabel '_MeanSpeedDist.pdf']),'-dpdf')
    printfig(hf_1,fullfile(ExportFolder,[StrainLabel '_MeanSpeedDist.png']),'-dpng')
    
    %All Speed Distribution 
    hf_2 = figure;
    all_V = cell2mat(SpeedStats.allV);
    histogram(all_V,Edges,'Normalization','pdf'); 
    %Set Title
    title({[StrainLabel ' - ' ROI],'All Point Speed Distribution'},'interpreter','none')
    ax_h2 = gca;
    %Set Axes Titles
    ax_h2.XLabel.String = 'Speed(\mum/s)';
    ax_h2.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h2)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_2,fullfile(ExportFolder,[StrainLabel '_AllSpeedDist.pdf']),'-dpdf')
    printfig(hf_2,fullfile(ExportFolder,[StrainLabel '_AllSpeedDist.png']),'-dpng')
    
    %Median Speed Distribution 
    hf_3 = figure; 
    histogram(SpeedStats.medV,Edges,'Normalization','pdf'); 
    title({[StrainLabel ' - ' ROI],'Median Speed Distribution'},'interpreter','none')
    ax_h3 = gca;
    %Set Axes Titles
    ax_h3.XLabel.String = 'Median Speed(\mum/s)';
    ax_h3.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h3)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_3,fullfile(ExportFolder,[StrainLabel '_MedSpeedDist.pdf']),'-dpdf')
    printfig(hf_3,fullfile(ExportFolder,[StrainLabel '_MedSpeedDist.png']),'-dpng')
    
    %Weighted Mean Speed 
    hf_4 = figure;
    %Replace bins with trajectory duration values to weigh meanV with track times 
    [N,Edges,bin] = histcounts(SpeedStats.meanV,Edges);
    WeightVec = SpeedStats.TrajDur;
    NewCounts = zeros(1,length(Edges));
        for j = 1:length(Edges)
        NewCounts(j) = sum(WeightVec(bin == j));
        end
    histogram('BinEdges',Edges,'BinCounts',NewCounts(1:end-1),'Normalization','PDF');
    title({[StrainLabel ' - ' ROI],'Weighted Mean Speed Distribution'},'interpreter','none')
    ax_h4 = gca;
     %Set Axes Titles
    ax_h4.XLabel.String = '<V>(\mum/s)';
    ax_h4.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h4)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_4,fullfile(ExportFolder,[StrainLabel '_WeightedMeanSpeedDist.pdf']),'-dpdf')
    printfig(hf_4,fullfile(ExportFolder,[StrainLabel '_WeightedMeanSpeedDist.png']),'-dpng')

   %Weighted Median Speed
   hf_5 = figure; 
   %Replace bins with trajectory duration values to weigh medV with track times 
   [NMed,Edges,binMed] = histcounts(SpeedStats.medV,Edges);
   WeightVecMed = SpeedStats.TrajDur;
   NewCountsMed = zeros(1,length(Edges));
        for j = 1:length(Edges)
        NewCountsMed(j) = sum(WeightVecMed(binMed == j));
        end
   histogram('BinEdges',Edges,'BinCounts',NewCountsMed(1:end-1),'Normalization','PDF');
   title({[StrainLabel ' - ' ROI],'Weighted Median Speed Distribution'},'interpreter','none')
   ax_h5 = gca;
   ax_h5.XLabel.String = 'Median Speed (\mum/s)';
   ax_h5.YLabel.String = 'PDF';
   %Adjust style 
   ErcagGraphics
   settightplot(ax_h4)
   %Save the figure to the target(i.e. export) folder 
   printfig(hf_5,fullfile(ExportFolder,[StrainLabel '_WeightedMedianSpeedDist.pdf']),'-dpdf')
   printfig(hf_5,fullfile(ExportFolder,[StrainLabel '_WeightedMedianSpeedDist.png']),'-dpng')

end

