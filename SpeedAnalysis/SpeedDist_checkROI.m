%% Check the difference in speed distributions between different acquisitions(ie ROIs)
%by Erça? 
%October 2019 

clearvars;
close all; 

%% Define Data Path and Gather Files List 
%-------Loading Path Parameters---------
Main_Path = 'Z:\Data\3D_Tracking_Data\'; 
Video_Date = '20191011';
%Define full main load path
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT9_Glu_30mM_1';

%------Exporting Path Parameters--------
%Keyword to find the folder associated with the strain label
Strain_Folder_Keyword = 'KMT9_Glu_30mM_1';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';
ROI_Keyword = 'ROI_+\w';
%Retrieve the file list 
Files = getallfilenames(Main_Path);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 

%Define export path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis\';
%Define Smoothing Parameter Lambda
lambda = 1;
Lambda_Label = ['lambda_' num2str(lambda)];

%% Load each file and plot the distribution on a single figure
% Create figure and its handle 
hf_1 = figure;
hold all 

for i =1:length(Files)
    %Create export paths and load the data
    [in_Label, out_Label]= regexp(Files{i},Strain_Folder_Keyword);
    Strain_Label = Files{i}(in_Label:out_Label); 
    Extra_SubFolder = ''; 
    [in_TrackLabel, out_TrackLabel] = regexp(Files{i}, TrackLabel_Keyword);
    Track_Label = Files{i}(in_TrackLabel+1:out_TrackLabel-1);
    [in_ROI, out_ROI] = regexp(Files{i},ROI_Keyword);
    ROI = Files{i}(in_ROI:out_ROI); %Just for the plot legend
    Export_Folder = fullfile(Main_Export_Path,Video_Date,Strain_Label,...
          Track_Label,Lambda_Label);
    %Create the export folder at the path
    mkdir(Export_Folder);
    %Load the file 
    load(Files{i});
    
    %Create the structure containing speed info 
    S.Speeds = B_Smooth.Speeds;
    S.Parameters = B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S); 
    
    %Edge vector for all histograms 
    Edges = 0:5:150; %um/sec
    % All Speed Distribution for a single acquisition
    all_V = cell2mat(SpeedStats.allV);
    hist{i} = histogram(all_V,Edges,'Normalization','pdf');
    %Tag the histogram
    hist{i}.DisplayName = ROI;
    %Set Title
    title({Strain_Label,'Speed Distribution of Different Acquisition'},'interpreter','none')
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.XLabel.String = 'Speed(\mum/s)';
    ax_h1.YLabel.String = 'PDF';
    %Adjust style 
    ErcagGraphics
    %Add legend 
    l_1 = legend;

end

l_1.Interpreter = 'none';
