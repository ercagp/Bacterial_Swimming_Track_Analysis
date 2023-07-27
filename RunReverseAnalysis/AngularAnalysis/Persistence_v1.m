%% Persistence 
%v1.0: To check the persistence <cos(\theta)> value being how close to -1 
%by Ercag
%November 2021 
clearvars;
close all; 
clc; 

%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Desktop';
%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverse_Data';
StrainLabels = {'KMT9'};
Lambda = 0.5;

%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz
%% Find persistence for each velocity bin ([0-35], [35-75], [75-150], [150-200]) before !!a turn!!. 
%Find .mat files
Files{1} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_1','[20190604]KMT9_OD_0.19_ROI_1_Lambda_0.5_Results.mat');
Files{2} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_2','[20190604]KMT9_OD_0.19_ROI_2_Lambda_0.5_Results.mat');

%Preallocate
TurnAngle = cell(length(Files),1); 
Runs = cell(length(Files),1); 
Before = cell(length(Files),1); 

for i = 1:length(Files)
    load(Files{i}) 
    
    TurnAngle{i,1} = Results.Ang(:,3); %note: all turn angles are already filtered
    Runs{i,1} = RunBreakDownv6(Speeds,Results.T,fps); %!!! Complete + Incomplete Runs!!! 
    
    [Before{i,1}, ~] = test_sep(Runs{i,1},TurnAngle{i,1}); 
    
    %Replace all empty ROW vectors by COLUMN vectors to 
    % be able to run CELL2MAT command
    Before_Clean{i,1} = replace_empty(Before{i,1});
    
    All = cell2mat(Before_Clean{i,1}); 
    
    %Select run durations by their mean speed
    V = [0,35,75,150,200];
    
    Binned_Speed_TurnAng{i,1} = All(All(:,2) > V(1) & All(:,2) <= V(2),:); 
    Binned_Speed_TurnAng{i,2} = All(All(:,2) > V(2) & All(:,2) <= V(3),:); 
    Binned_Speed_TurnAng{i,3} = All(All(:,2) > V(3) & All(:,2) <= V(4),:); 
    Binned_Speed_TurnAng{i,4} = All(All(:,2) > V(4) & All(:,2) <= V(5),:); 
    
    Persistence(i,1) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,1}(:,1)))); 
    Persistence(i,2) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,2}(:,1)))); 
    Persistence(i,3) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,3}(:,1)))); 
    Persistence(i,4) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,4}(:,1)))); 
    
end

BinnedSTA_Cmb{1} = [Binned_Speed_TurnAng{1,1};Binned_Speed_TurnAng{2,1}];
Pers_Cmb(1) = mean(cos(deg2rad(BinnedSTA_Cmb{1}(:,1)))); 

BinnedSTA_Cmb{2} = [Binned_Speed_TurnAng{1,2};Binned_Speed_TurnAng{2,2}];
Pers_Cmb(2) = mean(cos(deg2rad(BinnedSTA_Cmb{2}(:,1)))); 

BinnedSTA_Cmb{3} = [Binned_Speed_TurnAng{1,3};Binned_Speed_TurnAng{2,3}];
Pers_Cmb(3) = mean(cos(deg2rad(BinnedSTA_Cmb{3}(:,1)))); 

BinnedSTA_Cmb{4} = [Binned_Speed_TurnAng{1,4};Binned_Speed_TurnAng{2,4}];
Pers_Cmb(4) = mean(cos(deg2rad(BinnedSTA_Cmb{4}(:,1)))); 


Plot.X = {'0-35','35-75','75-150','150-200'}; 

hf = figure(1); 
plot(1:length(Pers_Cmb), Pers_Cmb,'.','MarkerSize',30)
ax = gca;
ax.XTick = 1:4;
ax.XLim = [0.5 4.5];
ax.YLim  = [-1 0];
ax.XTickLabel = Plot.X; 
grid on; 
ax.XLabel.String = '<V> (\mu{}m/sec)';
ax.YLabel.String = 'Persistence'; 
ax.Title.String = 'WT(KMT9) - Combined'; 
ErcagGraphics; 


%% Functions 

function [Bfr, Aft] = test_sep(Run,Ang) 
         Bfr = cell(size(Run,1),2);
         Aft = cell(size(Run,1),2);
         for i = 1:size(Run,1)
             if isempty(Run{i,2})
                MeanSpeeds = double.empty(0,1);
             else
                MeanSpeeds = [Run{i,2}(:,2)];
             end
                          
             TurnAngles = [Ang{i}]; 
             %1st column: Angles
             Bfr{i,1} = TurnAngles;
             Aft{i,1} = TurnAngles;
             %2nd column: Speeds
             Bfr{i,2} = MeanSpeeds(1:end-1);
             Aft{i,2} = MeanSpeeds(2:end);
         end
         
end

function x = replace_empty(x)
         I = cellfun(@isempty, x);
         %x(I(:,1),1) = cellfun(@rep,x(I(:,1)),'UniformOutput',0);
         x(I(:,2),2) = cellfun(@rep,x(I(:,2)),'UniformOutput',0);
         %I fucking hate this type of pointers!                  
    function  y = rep(~)
              y = double.empty(0,1);
    end
end