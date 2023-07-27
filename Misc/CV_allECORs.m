%% Computing Coefficient of Variation for all ECORs
% by Ercag
% April 2019 
clearvars;
close all; 

%% Define Loading Parameters 
%Define Export Folder 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\COV';
Export_Label = 'Coefficient_Var_allECORs';
%Define the loading path
Load_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Combined';

%Load mean swimming speed data
Folder_List = removedots_folderlisting(Load_Path);
number_ECOR = length(Folder_List);


%% Load each dataset and calculate coefficient of variation

%Preallocation 
axis_text = cell(number_ECOR); 
avgV = zeros(1,number_ECOR); 
std_allV = zeros(1,number_ECOR);
sem_avgV = zeros(1,number_ECOR);
COV = zeros(1,number_ECOR); 

for i = 1:number_ECOR
   Full_Path = fullfile(Folder_List(i).folder,Folder_List(i).name);
   MAT_label = dir([Full_Path filesep '*.mat']);
   load(fullfile(MAT_label.folder,MAT_label.name)); 
    
   %Get the ECOR number in string format 
   axis_text{i} = Folder_List(i).name;
    
   %Get the speed statistics 
   S = SpeedStatistics(CB); 
    
   %Retrieve all V 
   allV = cell2mat(S.allV);
   
   %Take the mean of all velocities for all bugs in all acq. 
   avgV(i) = mean(allV); 
   
   %Get the standard deviation of the speed set 
   std_allV(i) = std(allV);
   
   %Calculate coefficient of variation 
   COV(i) = std_allV(i)./avgV(i); 
   
   %Get the standard error 
   %sem_avgV(i) = std_allV(i)./length(S.allV);
end

%the order of ECOR list 
%1-) ECOR18
%2-) ECOR19
%3-) ECOR20
%4-) ECOR21
%5-) ECOR3
%6-) ECOR32 
%7-) ECOR34 
%8-) ECOR36
%9-) ECOR68
%10-) ECOR8 

ECOR_List = {'ECOR18','ECOR19','ECOR20','ECOR21','ECOR3','ECOR32','ECOR34','ECOR36','ECOR68','ECOR8'};

%% Plotting 
hf = figure; 
p_1 = plot(COV,'.'); 
p_1.MarkerSize = 20;
p_1.Color = [1 0 0]; 

ax = gca; 
ax.XTickLabel = ECOR_List;
ax.YLabel.String = 'Coefficient of Variation';
grid on 
%ax.XLim = [-1 11];

