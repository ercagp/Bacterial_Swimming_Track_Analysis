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

%% Expansion Data for ECOR (Figure 2b)
%Scale
scale = 1/16.56; %mm/pixels %1/16.244; %mm/pixels;
min_hr = 1/60; %hours

%Expansion data of ECOR3
Exp_ECOR3_px = [1.1911 1.2396] ; %Pixels/min. !
%Expansion data in mm/hr
Exp_ECOR3_mm = Exp_ECOR3_px.*scale*(1/min_hr); %mm/hr.
%Expansion rate in radius(not Diameter!)
Exp_ECOR3_mm = Exp_ECOR3_mm/2;

%Average Expansion rate of ECOR3
avg_Exp_ECOR3_mm = mean(Exp_ECOR3_mm);
%Standard deviation of ECOR3
std_Exp_ECOR3_mm = std(Exp_ECOR3_mm);
%Standard error of the mean of ECOR3
sem_Exp_ECOR3_mm = std_Exp_ECOR3_mm/sqrt(length(Exp_ECOR3_mm));


%Expansion data of ECOR8 
Exp_ECOR8_px = [1.5698 1.4726]; %Pixels/min. !
Exp_ECOR8_mm = Exp_ECOR8_px.*scale*(1/min_hr); %mm/hr.
%Expansion rate in radius(not Diameter!)
Exp_ECOR8_mm = Exp_ECOR8_mm/2;

avg_Exp_ECOR8_mm = mean(Exp_ECOR8_mm);
std_Exp_ECOR8_mm = std(Exp_ECOR8_mm);
sem_Exp_ECOR8_mm = std_Exp_ECOR8_mm/sqrt(length(Exp_ECOR8_mm));

%Expansion data of ECOR18 & 19 
Exp_ECOR18_mm = [0.557 0.998];%Exp_ECOR18_px.*scale*(1/min_hr); %mm/hr.
Exp_ECOR19_mm = [1.035 1.589];%Exp_ECOR19_px.*scale*(1/min_hr); %mm/hr.
avg_Exp_ECOR18_mm = mean(Exp_ECOR18_mm);
std_Exp_ECOR18_mm = std(Exp_ECOR18_mm);
sem_Exp_ECOR18_mm = std_Exp_ECOR18_mm/sqrt(length(Exp_ECOR18_mm));
avg_Exp_ECOR19_mm = mean(Exp_ECOR19_mm); 
std_Exp_ECOR19_mm = std(Exp_ECOR19_mm); 
sem_Exp_ECOR19_mm = std_Exp_ECOR19_mm/sqrt(length(Exp_ECOR19_mm));

%Expansion data of ECOR20 & 21 
Exp_ECOR20_mm = [2.058 2.489]; %Exp_ECOR20_px.*scale*(1/min_hr); %mm/hr.
Exp_ECOR21_mm = [2.849 2.324];%Exp_ECOR21_px.*scale*(1/min_hr); %mm/hr.
avg_Exp_ECOR20_mm = mean(Exp_ECOR20_mm);
std_Exp_ECOR20_mm = std(Exp_ECOR20_mm);
sem_Exp_ECOR20_mm = std_Exp_ECOR20_mm/sqrt(length(Exp_ECOR20_mm));
avg_Exp_ECOR21_mm = mean(Exp_ECOR21_mm); 
std_Exp_ECOR21_mm = std(Exp_ECOR21_mm);
sem_Exp_ECOR21_mm = std_Exp_ECOR21_mm/sqrt(length(Exp_ECOR21_mm));

%Expansion data of ECOR32 
%Expansion data of ECOR32 in px/mins
%Exp_ECOR32_px = 0; %Pixels/min. !
%Exp_ECOR68_px = [0.3509	0.4412]; %Pixels/min. !
%Expansion data in mm/hr 
Exp_ECOR68_mm = [0.923 1.305];%Exp_ECOR68_px.*scale*(1/min_hr); %mm/hr.
%Average Expansion value of ECOR68
avg_Exp_ECOR68_mm = mean(Exp_ECOR68_mm);
%Standard deviation 
std_Exp_ECOR68_mm = std(Exp_ECOR68_mm);
%Standard error of the mean 


%Put the Expansion data in correct order 
Exp_data = [avg_Exp_ECOR18_mm  avg_Exp_ECOR19_mm avg_Exp_ECOR20_mm avg_Exp_ECOR21_mm,...
    avg_Exp_ECOR3_mm avg_Exp_ECOR68_mm avg_Exp_ECOR8_mm];
std_Exp_data = [std_Exp_ECOR18_mm std_Exp_ECOR19_mm std_Exp_ECOR20_mm std_Exp_ECOR21_mm,...
    std_Exp_ECOR3_mm std_Exp_ECOR68_mm std_Exp_ECOR8_mm];
%% Plot weighted average of mean speeds versus migration rates
hf_2 = figure(2);
err_1 = errorbarxy(W_avg,Exp_data,std_avg,std_Exp_data,{'ob', 'b', 'b'});

%Define colormap 
color_map = linspecer(5); 
color3_34 = color_map(1,:);
color8_36 = color_map(2,:);
color18_19 = color_map(3,:);
color20_21 = color_map(4,:);
color32_68 = color_map(5,:);

FontSize = 11; 
%Add Annotations 
ECOR18 = text(W_avg(1)-5.5,Exp_data(1)-0.1,'ECOR18');
ECOR18.Color = color18_19;
ECOR18.FontSize = FontSize;

ECOR19 = text(W_avg(2)-5.5,Exp_data(2)+0.1,'ECOR19');
ECOR19.Color = color18_19;
ECOR19.FontSize = FontSize;

ECOR20 = text(W_avg(3)-5.5,Exp_data(3),'ECOR20');
ECOR20.Color = color20_21;
ECOR20.FontSize = FontSize;

ECOR21 = text(W_avg(4)-2.5,Exp_data(4)+0.5,'ECOR21');
ECOR21.Color = color20_21;
ECOR21.FontSize = FontSize;

ECOR3 = text(W_avg(5)-1.5,Exp_data(5)+0.2,'ECOR3');
ECOR3.Color = color3_34;
ECOR3.FontSize = FontSize;

ECOR68 = text(W_avg(6)-4.85,Exp_data(6)+0.15,'ECOR68');
ECOR68.Color = color32_68;
ECOR68.FontSize = FontSize;

ECOR8 = text(W_avg(7)-1.5,Exp_data(7)+0.25,'ECOR8');
ECOR8.Color = color8_36;	
ECOR8.FontSize = FontSize;

ax = gca; 
ax.XAxis.Label.String = 'Speed (\mum/s)';
ax.YAxis.Label.String = 'Migration Rate(mm/hr)';
ax.Title.String = 'Weighted Mean Speed - Method 1';
ax.XLim = [0 35];
ax.YLim = [0 4]; 

ErcagGraphics
%Print the second figure 
printfig(hf_2,[Export_Folder filesep Export_Label],'-dpdf')


