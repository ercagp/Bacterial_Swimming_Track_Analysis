%% Method 1 
% 1-) Weight the average speeds with their total trajectory durations
% 2-) Calculate the weighted mean of average speeds 

%Nature Rebuttal
%March 2019 
%Ercag 
clearvars;
close all; 


%% Define Loading Parameters 
%Define Export Folder 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Average_MeanSpeeds';
Export_Label = 'Weight_Avg_MeanSpeed_allECORs';
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

%% OD Data for ECOR (Figure 2b)
%Growth propensity Values for ECORs 
%ECOR3 
ECOR3 =  [0.431 0.515];
%OD value 
OD_ECOR3 = mean(ECOR3);
%Standard deviation 
std_ECOR3 = std(ECOR3);
%Standard error of the mean 
sem_ECOR3 = std(ECOR3)/sqrt(length(ECOR3));

%ECOR8 
ECOR8 = [0.214 0.222];
%OD value 
OD_ECOR8 = mean(ECOR8);
%Standard deviation of ECOR8
std_ECOR8 = std(ECOR8); 
%Standard error of the mean of ECOR8
sem_ECOR8 = std_ECOR8/sqrt(length(ECOR8));

%ECOR18 & ECOR19 
ECOR18 = [0.357   0.328]; 
OD_ECOR18 = mean(ECOR18); 
std_ECOR18 = std(ECOR18); 
sem_ECOR18 = std_ECOR18/sqrt(length(ECOR18));
ECOR19 = [0.225  0.242];
OD_ECOR19 = mean(ECOR19); 
std_ECOR19 = std(ECOR19); 
sem_ECOR19 = std_ECOR19/sqrt(length(ECOR19));

%ECOR20 & ECOR21
%OD data 
ECOR20 = [0.272 0.277];
OD_ECOR20 = mean(ECOR20); 
std_ECOR20 = std(ECOR20);
sem_ECOR20 = std_ECOR20/sqrt(length(ECOR20));
ECOR21 = [0.112  0.157];
OD_ECOR21 = mean(ECOR21); 
std_ECOR21 = std(ECOR21); 
sem_ECOR21 = std_ECOR21/sqrt(length(ECOR21));

%ECOR32 vs. ECOR68 
%OD data of ECOR32
ECOR32 = [0.258  0.237];
%OD value of ECOR32
OD_ECOR32 = mean(ECOR32); 
%Standard deviation 
std_ECOR32 = std(ECOR32);
%Standard error of the mean 
sem_ECOR32 = std_ECOR32/sqrt(length(ECOR32));
%OD data of ECOR68
ECOR68 = [0.091  0.094];
%OD value of ECOR68
OD_ECOR68 = mean(ECOR68);
%Standard deviation
std_ECOR68 = std(ECOR68); 
%Standard error of the mean 
sem_ECOR68 = std_ECOR68/sqrt(length(ECOR68));

%Put the OD data in correct order 
OD_data = [OD_ECOR18 OD_ECOR19 OD_ECOR20 OD_ECOR21,...
    OD_ECOR3 OD_ECOR68 OD_ECOR8];
std_OD_data = [std_ECOR18 std_ECOR19 std_ECOR20,std_ECOR21,...
    std_ECOR3 std_ECOR68 std_ECOR8];

%% Plot weighted average of mean speeds versus growth propensity 
hf_2 = figure(2);
err_1 = errorbarxy(W_avg,OD_data,std_avg,std_OD_data,{'ob', 'b', 'b'});

%Define colormap 
color_map = linspecer(5); 
color3_34 = color_map(1,:);
color8_36 = color_map(2,:);
color18_19 = color_map(3,:);
color20_21 = color_map(4,:);
color32_68 = color_map(5,:);

FontSize = 11; 
%Add Annotations 
ECOR18 = text(W_avg(1)-2.5,OD_data(1)+0.035,'ECOR18');
ECOR18.Color = color18_19;
ECOR18.FontSize = FontSize;

ECOR19 = text(W_avg(2)-2.5,OD_data(2)+0.025,'ECOR19');
ECOR19.Color = color18_19;
ECOR19.FontSize = FontSize;

ECOR20 = text(W_avg(3)-2.5,OD_data(3)+0.025,'ECOR20');
ECOR20.Color = color20_21;
ECOR20.FontSize = FontSize;

ECOR21 = text(W_avg(4)-2.5,OD_data(4)+0.045,'ECOR21');
ECOR21.Color = color20_21;
ECOR21.FontSize = FontSize;

ECOR3 = text(W_avg(5)-4.5,OD_data(5)+0.015,'ECOR3');
ECOR3.Color = color3_34;
ECOR3.FontSize = FontSize;

ECOR68 = text(W_avg(6)-2.5,OD_data(6)+0.025,'ECOR68');
ECOR68.Color = color32_68;
ECOR68.FontSize = FontSize;

ECOR8 = text(W_avg(7)-2.0,OD_data(7)+0.025,'ECOR8');
ECOR8.Color = color8_36;	
ECOR8.FontSize = FontSize;

ax = gca; 
ax.XAxis.Label.String = 'Speed (\mum/s)';
ax.YAxis.Label.String = 'Growth(OD_{600})';
ax.Title.String = 'Weighted average of mean speed';
ax.YLim = [0 0.60];
ax.XLim = [0 35]; 

ErcagGraphics
%settightplot(ax)

%Print the second figure 
printfig(hf_2,[Export_Folder filesep Export_Label],'-dpdf')



