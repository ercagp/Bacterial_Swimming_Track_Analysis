%% Determine Average Velocity using Method 2 
% 1-) Recall the combined data and take the average of all bugs in all
% acquisitions
% 2-) Calculate the standard error of the mean by standard deviation of the
% speed dist / sqrt(number of trajectories) 

%March 2019 
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
%Define Export Folder 
Export_Folder = 'Z:\Data\3D_Tracking_Data_Analysis\Combined\KMT9_20190522_23';
Export_Label = 'AvgV_vs_OD600_KMT9_20190522_23';
%Define the loading path
Load_Path = 'Z:\Data\3D_Tracking_Data_Analysis\Combined\KMT9_20190522_23\';
% File_List = getallfilenames(Load_Path);
% File_List = File_List(cellfun(@(x) contains(x,'.mat'),File_List));
File_List = findlist(Load_Path);

number_data = length(File_List);
%% Calculate mean and standard error of the speed vector
%Preallocation 
axis_text = cell(number_data); 
avgV = zeros(1,number_data); 
std_allV = zeros(1,number_data);
sem_avgV = zeros(1,number_data);

%Define OD vector for the strain 
Strain_Label = 'KMT9';
OD_vec = [0.13 0.23 0.35 0.49 0.50 0.56]; 

for i = 1:number_data
    
   File_List{i}
   load(File_List{i})
    
   %Get the strain number in string format 
   %axis_text{i} = Folder_List(i).name;
    
   %Get the speed statisics 
   S = SpeedStatistics(CB); 
    
   %Retrieve all V 
   allV = cell2mat(S.allV);
   
   %Take the mean of all velocities for all bugs in all acq. 
   avgV(i) = mean(allV); 
   
   %Get the standard deviation of the speed set 
   std_allV(i) = std(allV);
   
   %Get the standard error 
   sem_avgV(i) = std_allV(i)./length(S.allV);
end


%% Plot mean speed 
%Pick a subset for different day data 
dd_mask = boolean([0 0 0 0 1 1]);

hf_1 = figure(1);
err_1 = errorbar(OD_vec(~dd_mask), avgV(~dd_mask), sem_avgV(~dd_mask),'.');
hold on 
err_2 = errorbar(OD_vec(dd_mask), avgV(dd_mask), sem_avgV(dd_mask),'.');

err_1.LineWidth = 1.5;
err_1.MarkerSize = 18; 
err_1.Color = [0 0 1]; 

err_2.LineWidth = 1.5;
err_2.MarkerSize = 18; 
err_2.Color = [1 0 0]; 

hold off 

% Plot average of mean speeds versus growth propensity 

ax = gca; 
ax.XAxis.Label.String = 'Growth (OD_{600})';
ax.YAxis.Label.String = '<V> (\mum/s)';
ax.Title.String = {Strain_Label, 'Whole Population'};
%ax.YLim = [0 0.60];
%ax.XLim = [0 0.70]; 
%ax.XTick = [0.10 0.20 0.30 0.40 0.50 0.60 0.70];

ErcagGraphics
%Print the second figure 
grid on 
printfig(hf_1,[Export_Folder filesep Export_Label],'-dpdf')

function list_cell = findlist(Folder) 
list_mat = dir([Folder filesep '*.mat']); 
list_cell = cellfun(@(x) strcat(Folder,x),{list_mat.name},'UniformOutput',0)';
end
