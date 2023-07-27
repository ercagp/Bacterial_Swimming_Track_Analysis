%% Plot Total Trajectory Durations vs. ECOR number 

%Nature Rebuttal
%March 2019 
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
%Define Export Folder 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Average_MeanSpeeds';
Export_Label = 'TotalTrajDur_allECORs';
%Define the loading path
Folder = Export_Folder;  %Notice that the data is recalled from the export folder
File_List = dir([Folder filesep '*.mat']);

%% Load Vector of Total Trajectory Duration 
number_ECOR = length(File_List);%Number of ECORs 
axis_text = cell(1,number_ECOR);
Sum_TotalTrajDur = zeros(1,number_ECOR);

for i = 1:number_ECOR
    load([File_List(i).folder filesep File_List(i).name])
     Sum_TotalTrajDur(i) = sum(Total_TrajDur);
     axis_text{i} = File_List(i).name(1:6);
end

%Drop the hyphen on ECOR8_ and ECOR3_ 
axis_text{contains(axis_text,'ECOR8')}(end) = [];
axis_text{contains(axis_text,'ECOR3')}(end) = [];

%% Plot the weighted average mean speeds 
% Plot average mean speeds 
hf_1 = figure(1);
p_1 = plot(1:number_ECOR,Sum_TotalTrajDur,'.');
p_1.LineWidth = 1.5;
p_1.MarkerSize = 12; 
p_1.Color = [0 0 1]; 

ax = gca;
ax.XLim = [0 8];
ax.XTick = 1:number_ECOR;
ax.XTickLabel = axis_text;
ax.YAxis.Label.String = 'Time(s)';
ax.Title.String = 'Total Trajectory Durations';
%ErcagGraphics
ax.XAxis.Label.FontSize = 7;

printfig(hf_1,[Export_Folder filesep Export_Label],'-dpdf')