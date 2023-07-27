%Cutting out the trajectories that are closer to the chamber walls
%in Ibidi Chemotaxis Chambers 
%by Ercag
%June 2019 

clearvars;
close all; 

%% Load the trajectory 
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20190701';
Sample_Label = 'KMT9_Chemotaxis_Control';
Main_Path = fullfile(Main_Path,Video_Date,Sample_Label); 

%Export Path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
lambda = 1; 

%Combine different acquisitions 
CB = combine_BugsV3(Main_Path);

epsilon = 10; %microns

%Scale the bugs to the real distance values 
B = ScaleTraj(CB);
%Get the speed statistics 
S = SpeedStatistics(CB);
%Find maximum and minimum z values across all trajectories 
Max_z = 65%max(cellfun(@(x) max(x(:,4)),B)); %microns
Min_z = -5%min(cellfun(@(x) min(x(:,4)),B)); %microns 
%Find the points 10 microns smaller than maximum and 10 microns larger
%than the minimum 
ConditionCell = cellfun(@(x) x(:,4) <(Max_z - epsilon) & x(:,4) > (Min_z + epsilon), B,'UniformOutput',false);

BReduced = cell(length(B),1); 
vReduced = cell(length(B),1); 
for i = 1:length(B)
    BReduced{i} = B{i}(ConditionCell{i},:);
    vReduced{i} = S.allv{i}(ConditionCell{i}(1:end-1),:); 
end
  
%Mask = ~cellfun(@(x) ismember(false,x), ConditionCell); 

%% Plotting 
%Label for all the plots 
%Sample_Label = 'KMT9_Chemotaxis_500uM';
total_number = length(CB.Bugs);
%Plot all trajectories 
PlotAllTracks_ScaledBugs(B)
hf_1 = figure(1);
title({Sample_Label,[num2str(total_number) ' cells']},'interpreter','none');
%Plot trajectories +-10microns away from the chamber walls    
PlotAllTracks_ScaledBugs(BReduced)
hf_2 = figure(2);
total_number_ex = length(BReduced);
title({Sample_Label,'Near Wall Traj. Excluded'},'interpreter','none')
%Export plots
%Make the target folder
TargetExportPath = fullfile(Main_Export_Path,'Combined',Video_Date,Sample_Label);
mkdir(TargetExportPath)
%Save figures to those folders 
savefig(hf_1, fullfile(TargetExportPath,[Sample_Label '_allTraj'])); 
savefig(hf_2, fullfile(TargetExportPath,[Sample_Label '_' num2str(epsilon) 'micron_excluded'])); 

%% Save combined files 
save(fullfile(TargetExportPath,[Sample_Label '_CombinedBugTraj']),'CB')

%% Calculate the drift velocity 
VelSubset = cell2mat(vReduced);%S.allv(Mask); 
Drift = mean(VelSubset,1); %mean(cell2mat(VelSubset),1);
DriftStd = std(VelSubset,1); 
%How many of the member of the cell "BReduced" entered into the calculation
%of mean velocity? 
NCountedBugs = sum(cellfun(@(x) ~isempty(x), BReduced)); 
%Calculate the standard e. of the mean by dividing the std by this sqrt 
%of this number
DriftSem = DriftStd./sqrt(NCountedBugs);
