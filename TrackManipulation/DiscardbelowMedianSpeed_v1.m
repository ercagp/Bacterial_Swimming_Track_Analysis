%% Thresholding bug speeds (all acquisitions are combined)  
% Choose the median speed and discard the values below that
% for each strain 
clearvars;
close all; 
%% Load combined files 
% Define path 
Main_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Combined';
% Define ECOR strains of which data will be loaded
ECOR_label = {'ECOR21'};
%Define the export folder
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Discard_Speed';
mkdir(Export_Folder); 
%Get the list of all subdirectories in the main path
mat_list = cell(1,length(ECOR_label));
for mat_i = 1:length(ECOR_label)
mat_list{mat_i} = findmat(Main_Path,ECOR_label{mat_i}); 
end


%% Parameters
%Edge of the histograms 
Edges = 0:1:50; 
%Threshold value for the median speed
V_threshold = 3.0; %microns/sec 
%Plotting parameters 
X_Label = 'V(\mum/s)';
Y_Label = 'PDF'; 
Plot_Title = 'Instantaneous Velocities';

%% Perform thresholding(i.e. discard speeds below median) 
for i = 1:length(mat_list)
    load(mat_list{i})
    %Perform speed statistics 
    S = SpeedStatistics(CB);
    %Construct the matrix for all velocity values
    allV = cell2mat(S.allV); 
    %Select median speed and discard the values below
    %Select the bugs with median speed larger than V_threshold
    allV_subset = cell2mat(S.allV(S.medV>=V_threshold));
    %Compare the thresholded distribution to the old one 
     hf = figure(i);
     hst{1} = histogram(allV,Edges,'Normalization','pdf');
     hold on 
     hst{2} = histogram(allV_subset,Edges,'Normalization','pdf');
    %Assign colors 
     hst{1}.FaceColor = [0 0 1];
     hst{2}.FaceColor = [1 0 0];
     %Assign axis labels  
     ax = gca; 
     ax.XLabel.String = X_Label; 
     ax.YLabel.String = Y_Label; 
     %Assign the title 
     ax.Title.String = Plot_Title; 
     %Assign legend 
     leg = legend([hst{1} hst{2}],{[ECOR_label{i} ' Original'],[ECOR_label{i} ' Cutoff']}); 
     leg.FontSize = 10;
     leg.Location = 'NorthWest';
     %Other features to be implemented
     ErcagGraphics 
     %Save the thresholded value 
     save(fullfile(Export_Folder,[ECOR_label{i} 'AllSpeed_MedianThresholdedBugs.mat']),'allV_subset')
     %Save figures 
     printfig(hf, fullfile(Export_Folder,[ECOR_label{i} '_AllSpeed_MedianThresholdedBugs']),'-dpdf')
     savefig(hf, fullfile(Export_Folder,[ECOR_label{i} '_AllSpeed_MedianThresholdedBugs']))
end

%% Extra Functions 
function mat_files = findmat(Path,Label)
list = getallsubdirectories(Path);
target_path = list(cellfun(@(x) ~isempty(regexp(x,Label, 'once')),list));
    if strcmp(Label,'ECOR3')
       %Create a logical mask to find the pattern 'R3' at the last two
       %characters, which is present only in 'ECOR3' (the others are
       %either two numbers or two strings 
       logical_mask = cellfun(@(X) strcmp(X,'R3'),cellfun(@(x) x(end-1:end), target_path,'UniformOutput',0));
       mat_list = dir(fullfile(cell2mat(target_path(logical_mask)),'*.mat')); 
       mat_files = fullfile(mat_list.folder,mat_list.name);
    else
       mat_list = dir(fullfile(cell2mat(target_path),'*.mat')); 
       mat_files = fullfile(mat_list.folder,mat_list.name);
    end
end


