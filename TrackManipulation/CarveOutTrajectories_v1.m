%Cutting out the trajectories that are closer to the chamber walls
%in Ibidi Chemotaxis Chambers 
%by Ercag
%June 2019 

clearvars;
close all; 

%% Load the trajectory 
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20190626';
Main_Path = fullfile(Main_Path,Video_Date); 

%Strain keyword 
Strain_Keyword = '\\+KMT9+\w+\w+\\';
ROI_Keyword = '\\+ROI+\w+\w+\\';
TrackLabel_Keyword = '\\+\w+_Tracking+\\';

Target_Flag = 'on';
Files = getallfilenames(Main_Path,Target_Flag);
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 

epsilon = 5; %microns

for i = 1:length(Files)
    load(Files{i})
    %Scale the bugs to the real distance values 
    B = ScaleTraj(B_Smooth);
    %Get the speed statistics 
    S = SpeedStatistics(B_Smooth);
    %Find maximum and minimum z values across all trajectories 
    Max_z = max(cellfun(@(x) max(x(:,4)),B)); 
    Min_z = min(cellfun(@(x) min(x(:,4)),B)); 
    %Find the points 10 microns smaller than maximum and 10 microns larger
    %than the minimum 
    ConditionCell = cellfun(@(x) x(:,4) <(Max_z - epsilon) & x(:,4) > (Min_z + epsilon), B,'UniformOutput',false);
    Mask = ~cellfun(@(x) ismember(false,x), ConditionCell); 
    %Plot all trajectories 
    PlotAllTracks_ScaledBugs(B)
    %Plot trajectories +-10microns away from the chamber walls    
    PlotAllTracks_ScaledBugs(B(Mask))
    %Calculate the drift velocity 
    VelSubset = S.allv(Mask); 
    Drift = sum(cell2mat(VelSubset),1);
end


 CB = combine_BugsV3(Main_Path)
