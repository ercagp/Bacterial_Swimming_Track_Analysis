%Crop the immotile fraction of the population (based on median speed) 
%and compute avgV 
%by Ercag Pince
%October 2019 
clearvars;
close all; 

%% Define the parameters below which the population will be discarded
threshSpeedArray = [2 5 10]; % um/s
%Define figure parameters
Edges = 0:2:100;

%% Define the path and load data
MainPath = 'Z:\Data\3D_Tracking_Data_Analysis'; 
VideoDate = '20191018';
%KMTLabel = 'KMT9_1'; %only for KMT9
MainPath = fullfile(MainPath,VideoDate);%fullfile(MainPath,VideoDate,KMTLabel)
%Define Strain Keywords
%StrainLabels = {'KMT10_Sample1','KMT10_Sample2','KMT12_Sample1','KMT12_Sample2'};

%Define export path
ExportPath = MainPath;
ExportFileName = ['[' VideoDate ']avgVThreshold.mat']; 
ExportFileName = fullfile(ExportPath,ExportFileName);

%Call up the file list
Files = getallfilenames(MainPath,'off');

%Select the combined data from different ROIs 
ROI_Keyword = 'CombinedBugStruct';
Files = Files(contains(Files,ROI_Keyword));

for j = 1:length(threshSpeedArray)
    for KMT_i = 1:length(Files)
    load(Files{KMT_i});
    
    %Extract the strain name from the full file name 
    [In,Out] = regexp(Files{KMT_i},['(?<=' VideoDate '\\)\w*']);
    StrainLabels{j,KMT_i} = Files{KMT_i}(In:Out); 
    
    
    % Create the structure containing speed info 
    S.Speeds = CB.Speeds;%B_Smooth.Speeds;
    S.Parameters = CB.Parameters;%B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S);
    
    % Select the bugs slower than threshSpeed
    B_Subset = CB;
    % Prepare logical mask to eliminate the tracks with speed lower than
    % the threshhold defined in threshSpeedArray
    ThreshMask = threshSpeedArray(j)<SpeedStats.medV;
    
    %Create the subset 
    B_Subset.Speeds = CB.Speeds(ThreshMask);
    B_Subset.Bugs = CB.Bugs(ThreshMask);
    SpeedStatsSubset = SpeedStatistics(B_Subset);
    
    %All V of the subset 
    allVSubset = cell2mat(SpeedStatsSubset.allV);
    
    %Plot the Subset
    %All speed
    hf_1 = figure; 
    histogram(allVSubset,Edges,'Normalization','pdf'); 
    title({StrainLabels{KMT_i},'Speed Distribution', [num2str(threshSpeedArray(j)) ' um/sec medV threshold']}); 
    ax_h1 = gca;
    ax_h1.XLabel.String = 'Speed(\mum/s)';
    ax_h1.YLabel.String = 'PDF';
    ax_h1.Title.Interpreter = 'none';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h1)
    
    %Median Speed
    hf_2 = figure; 
    histogram(SpeedStatsSubset.medV,Edges,'Normalization','pdf'); 
    title({StrainLabels{KMT_i},'Median Speed Distribution ', [num2str(threshSpeedArray(j)) ' um/s medV threshold']}); 
    ax_h2 = gca;
    ax_h2.XLabel.String = 'Speed(\mum/s)';
    ax_h2.YLabel.String = 'PDF';
    ax_h2.Title.Interpreter = 'none';
    %Adjust style 
    ErcagGraphics
    settightplot(ax_h2)
    
    %Calculate the average speed and standard error of the subset 
    avgVSubset(j,KMT_i) = mean(allVSubset); 
    %Standard error of the mean 
    semVSubset(j,KMT_i) = SEMV(B_Subset);%std(allVSubset)./sqrt(length(SpeedStatsSubset.allV));    
    end
end

save(ExportFileName,'avgVSubset','semVSubset','threshSpeedArray','StrainLabels');