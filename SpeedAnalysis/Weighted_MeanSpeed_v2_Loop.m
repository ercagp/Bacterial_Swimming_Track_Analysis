%Correct Distribution of Weighted Mean Velocities for Individual Acq.
%by Ercag
%February 2019 
clearvars; 
close all; 

%% Define Define Data Path and Gather Files List 
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20191003';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT12_Sample1';
%Keyword to find the folder associated with the strain label
Strain_Folder_Keyword = 'KMT12_Sample+\d';
ROI_Keyword = '\\+ROI+\w+\w+\\';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';
%Retrieve the file list 
Files = getallfilenames(Main_Path);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(contains(Files,Strain_Keyword)); 

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
          ROI,Track_Label,Lambda_Label)
    %Create the export folder at the path
    mkdir(Export_Folder);
    %Load the file 
    load(Files{i})
    %% Carry the speed statistics 
    %Create the structure containing speed info 
    S.Speeds = B_Smooth.Speeds;
    S.Parameters = B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S); 

    %Define edges
    Edge = 0:5:200; 
    [N,Edges,bin] = histcounts(SpeedStats.meanV,Edge);
    Weight_vec=SpeedStats.TrajDur;

    for i = 1:length(Edges)
    new_counts(i) = sum(Weight_vec(bin == i));
    end
    %% Figures
    hf_1 = figure;
    histogram('BinEdges',Edges,'BinCounts',new_counts(1:end-1),'Normalization','PDF');
    %Set Title
    title({[Strain_Label ' - ' ROI],'Weighted Mean Speed'},'interpreter','none')
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.XLabel.String = 'Speed(\mum/s)';
    ax_h1.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h1)
    %Save the figure to the target(i.e. export) folder 
    printfig(hf_1,[Export_Folder filesep Strain_Label '_WeightedMeanSpeed.pdf'],'-dpdf')
    printfig(hf_1,[Export_Folder filesep Strain_Label '_WeightedMeanSpeed.png'],'-dpng')

    
end


