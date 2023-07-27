%% Method 1 
% 1-) Weight the average speeds with their total trajectory durations
% 2-) Calculate the mean of weighted average speeds 

%Nature Rebuttal
%March 2019 
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
%Define Export Folder 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Average_MeanSpeeds';
%Define the loading path
Folder = Export_Folder;  %Notice that the data is recalled from the export folder
File_List = dir([Folder filesep '*.mat']);

%% Calculate weighted average 
number_ECOR = length(File_List);%Number of ECORs 
W_avg = zeros(1,number_ECOR);
std_avg = zeros(1,number_ECOR);
axis_text = cell(1,number_ECOR);

for i = 1:number_ECOR
    load([File_List(i).folder filesep File_List(i).name])
    %Weigh average speed value 
     Weight = avg_V.*Total_TrajDur; 
     %Calculate weighted average 
     W_avg(i) = sum(Weight)./sum(Total_TrajDur);
     std_avg(i) = std(avg_V);
     axis_text{i} = File_List(i).name(1:6);
end

%Drop the hyphen on ECOR8_ and ECOR3_ 
axis_text{contains(axis_text,'ECOR8')}(end) = [];
axis_text{contains(axis_text,'ECOR3')}(end) = [];

%% Plot the weighted average mean speeds 
% Plot average mean speeds 
hf_1 = figure(1);
err_1 = errorbar(1:number_ECOR,W_avg, std_avg,'.');
err_1.LineWidth = 1.5;
err_1.MarkerSize = 11; 
err_1.Color = [0 0 1]; 

ax = gca;
ax.XLim = [0 8];
ax.XTick = 1:number_ECOR;
ax.XTickLabel = axis_text;
ax.YAxis.Label.String = 'Speed (\mum/s)';
ax.Title.String = 'Mean bug speeds';
%ErcagGraphics
ax.XAxis.Label.FontSize = 7;