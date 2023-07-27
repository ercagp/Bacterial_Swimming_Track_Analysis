%Weighted Mean for Individual Acquisitions
%by Ercag
%February 2019 
clearvars; 
close all; 
%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20191003';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT12_Sample2';
%Keyword to find the folder associated with the strain label
Strain_Folder_Keyword = 'KMT12_Sample+\d';
ROI_Keyword = '\\+ROI+\w+\w+\\';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';
%Retrieve the file list 
Files = getallfilenames(Main_Path);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 

%Define export path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
lambda = 1;
Lambda_Label = ['lambda_' num2str(lambda)];

for i = 1:length(Files)
    %% Create export paths and load the data 
    [in_Label, out_Label]= regexp(Files{i},Strain_Folder_Keyword);
    Strain_Label = Files{i}(in_Label:out_Label); 
    Extra_SubFolder = ''; 
    [in_ROI, out_ROI] = regexp(Files{i},ROI_Keyword);
    ROI = Files{i}(in_ROI+1:out_ROI-1);
   [in_TrackLabel, out_TrackLabel] = regexp(Files{i}, TrackLabel_Keyword);
    Track_Label = Files{i}(in_TrackLabel+1:out_TrackLabel-1);
    Export_Folder = fullfile(Main_Export_Path,Video_Date,Strain_Label,...
          ROI,Track_Label,Lambda_Label);
    %Create the export folder at the path
    mkdir(Export_Folder);
    %Load the file 
    load(Files{i}); 
    
    %% Carry the speed statistics 
    %Create the structure containing speed info 
    S.Speeds = B_Smooth.Speeds;
    S.Parameters = B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S); 
    %% Figures
    %Edge vector for all histograms 
    Edges = 0:5:200; 
    %Mean Speed Distribution 
    hf_1 = figure; 
    histogram(SpeedStats.meanV,Edges,'Normalization','pdf'); 
    title({[Strain_Label ' - ' ROI],'Mean Speed Distribution'},'interpreter','none')
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.XLabel.String = 'Speed(\mum/s)';
    ax_h1.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h1)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_1,fullfile(Export_Folder,[Strain_Label '_MeanSpeedDist.pdf']),'-dpdf')
    printfig(hf_1,fullfile(Export_Folder,[Strain_Label '_MeanSpeedDist.png']),'-dpng')
    
    % %All Speed Distribution 
    hf_2 = figure;
    all_V = cell2mat(SpeedStats.allV);
    histogram(all_V,Edges,'Normalization','pdf'); 
    %Set Title
    title({[Strain_Label ' - ' ROI],'Speed Distribution'},'interpreter','none')
    ax_h2 = gca;
    %Set Axes Titles
    ax_h2.XLabel.String = 'Speed(\mum/s)';
    ax_h2.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h2)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_2,fullfile(Export_Folder,[Strain_Label '_AllSpeedDist.pdf']),'-dpdf')
    printfig(hf_2,fullfile(Export_Folder,[Strain_Label '_AllSpeedDist.png']),'-dpng')
end

