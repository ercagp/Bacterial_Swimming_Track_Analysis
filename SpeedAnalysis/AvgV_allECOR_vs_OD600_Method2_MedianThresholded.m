%% Method 2 
% 1-) Recall the combined data and take the average of all bugs in all
% acquisitions
% 2-) Calculate the standard error of the mean by standard deviation of the
% speed dist / sqrt(number of trajectories) 

%Nature Rebuttal
%March 2019 
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
%Define Export Folder 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Average_MeanSpeeds';
Export_Label = 'Avg_MeanSpeed_allECORs_OD600_Method2_MedianThresholded';
%Define the loading path
Load_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Discard_Speed';
%Folder_List = removedots_folderlisting(Load_Path);
File_List = dir(fullfile(Load_Path,'*.mat'));
ECOR_List = retrieveList(File_List);
number_ECOR = length(ECOR_List);
%% Calculate mean and standard error of the speed vector
%Preallocation 
axis_text = cell(number_ECOR); 
avgV = zeros(1,number_ECOR); 
std_allV = zeros(1,number_ECOR);
sem_avgV = zeros(1,number_ECOR);

for i = 1:number_ECOR
   %Full_Path = [Folder_List(i).folder filesep Folder_List(i).name];
   %MAT_label = dir([Full_Path filesep '*.mat']);
   %load([MAT_label.folder filesep MAT_label.name]);
   load(fullfile(File_List(i).folder,File_List(i).name));

   %Get the ECOR number in string format 
   axis_text{i} = ECOR_List{i};
    
   %Get the speed statisics 
   %S = SpeedStatistics(CB); 
    
   %Retrieve all V 
   %allV = cell2mat(S.allV);
   
   %Take the mean of all velocities for all bugs in all acq. 
   avgV(i) = mean(allV_subset); 
   
   %Get the standard deviation of the speed set 
   std_allV(i) = std(allV_subset);
   
   %Get the standard error 
   sem_avgV(i) = std_allV(i)./length(allV_subset);
end


%% Plot mean speed 
hf_1 = figure(1);
err_1 = errorbar(1:number_ECOR,avgV, sem_avgV,'.');
err_1.LineWidth = 1.5;
err_1.MarkerSize = 11; 
err_1.Color = [0 0 1]; 

ax = gca;
ax.XLim = [0 8];
ax.XTick = 1:number_ECOR;
ax.XTickLabel = axis_text;
ax.YAxis.Label.String = 'Speed (\mum/s)';
ax.Title.String = 'Mean bug speeds - Method 2';
%ErcagGraphics
ax.XAxis.Label.FontSize = 7;

%% OD Data for ECOR (Figure 2b)
%Growth propensity Values for ECORs 
%ECOR3 & ECOR34  
ECOR3 =  [0.431 0.515];
%OD value 
OD_ECOR3 = mean(ECOR3);
%Standard deviation 
std_ECOR3 = std(ECOR3);
%Standard error of the mean 
sem_ECOR3 = std(ECOR3)/sqrt(length(ECOR3));
%OD data of ECOR34
ECOR34 = [0.297 0.315];
%OD value 
OD_ECOR34 = mean(ECOR34); 
%Standard deviation 
std_ECOR34 = std(ECOR34);
%Standard error of the mean 
sem_ECOR34 = std(ECOR34)/sqrt(length(ECOR34)); 

%ECOR8 & ECOR36 
ECOR8 = [0.214 0.222];
%OD value 
OD_ECOR8 = mean(ECOR8);
%Standard deviation of ECOR8
std_ECOR8 = std(ECOR8); 
%Standard error of the mean of ECOR8
sem_ECOR8 = std_ECOR8/sqrt(length(ECOR8));
%OD value of ECOR36 
ECOR36 = [0.324  0.327];
OD_ECOR36 = mean(ECOR36);
%Standard deviation of ECOR36
std_ECOR36 = std(ECOR36); 
%Standard error of the mean of ECOR36
sem_ECOR36 = std_ECOR36/sqrt(length(ECOR36));

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
OD_data = [OD_ECOR18...
          OD_ECOR19...
          OD_ECOR20...
          OD_ECOR21...
          OD_ECOR32...
          OD_ECOR34...
          OD_ECOR36...
          OD_ECOR3...
          OD_ECOR68...
          OD_ECOR8];

std_OD_data = [std_ECOR18... 
               std_ECOR19... 
               std_ECOR20... 
               std_ECOR21...
               std_ECOR32...
               std_ECOR34...
               std_ECOR36...
               std_ECOR3...
               std_ECOR68...
               std_ECOR8];

%% Plot average of mean speeds versus growth propensity 
hf_2 = figure(2);
err_1 = errorbarxy(avgV,OD_data,sem_avgV,std_OD_data,{'ob', 'b', 'b'});
hold on 

%Define colormap 
color_map = linspecer(5); 
color3_34 = color_map(1,:);
color8_36 = color_map(2,:);
color18_19 = color_map(3,:);
color20_21 = color_map(4,:);
color32_68 = color_map(5,:);

%Lines connecting ECOR pairs 
p_ECOR18_19 = plot([avgV(1) avgV(2)],[OD_data(1) OD_data(2)],'-');
p_ECOR20_21 = plot([avgV(3) avgV(4)],[OD_data(3) OD_data(4)],'-');
p_ECOR3_34 = plot([avgV(8) avgV(6)],[OD_data(8) OD_data(6)],'-');
p_ECOR8_36 = plot([avgV(10) avgV(7)],[OD_data(10) OD_data(7)],'-');
p_ECOR32_68 = plot([avgV(5) avgV(9)],[OD_data(5) OD_data(9)],'-');

%Colors of the lines 
p_ECOR18_19.Color = color18_19; 
p_ECOR20_21.Color = color20_21; 
p_ECOR3_34.Color = color3_34; 
p_ECOR8_36.Color = color8_36; 
p_ECOR32_68.Color = color32_68;

FontSize = 11; 
TD_Factor = 1.05;
%Add Annotations 
ECOR18 = text(TD_Factor*avgV(1),TD_Factor*OD_data(1),'ECOR18');
ECOR18.Color = color18_19;
ECOR18.FontSize = FontSize;

ECOR19 = text(TD_Factor*avgV(2),TD_Factor*OD_data(2),'ECOR19');
ECOR19.Color = color18_19;
ECOR19.FontSize = FontSize;

ECOR20 = text(TD_Factor*avgV(3),TD_Factor*OD_data(3),'ECOR20');
ECOR20.Color = color20_21;
ECOR20.FontSize = FontSize;

ECOR21 = text(TD_Factor*avgV(4),TD_Factor*OD_data(4),'ECOR21');
ECOR21.Color = color20_21;
ECOR21.FontSize = FontSize;

ECOR32 = text(TD_Factor*avgV(5),TD_Factor*OD_data(5),'ECOR32');
ECOR32.Color = color32_68;
ECOR32.FontSize = FontSize;

ECOR34 = text(TD_Factor*avgV(6),TD_Factor*OD_data(6),'ECOR34');
ECOR34.Color = color3_34;
ECOR34.FontSize = FontSize;

ECOR36 = text(TD_Factor*avgV(7),TD_Factor*OD_data(7),'ECOR36');
ECOR36.Color = color8_36;
ECOR36.FontSize = FontSize;

ECOR3 = text(TD_Factor*avgV(8),TD_Factor*OD_data(8),'ECOR3');
ECOR3.Color = color3_34;
ECOR3.FontSize = FontSize;

ECOR68 = text(TD_Factor*avgV(9),TD_Factor*OD_data(9),'ECOR68');
ECOR68.Color = color32_68;
ECOR68.FontSize = FontSize;

ECOR8 = text(TD_Factor*avgV(10),TD_Factor*OD_data(10),'ECOR8');
ECOR8.Color = color8_36;	
ECOR8.FontSize = FontSize;

ax = gca; 
ax.XAxis.Label.String = 'Avg. Swimming Speed (\mum/s)';
ax.YAxis.Label.String = 'Growth(OD_{600})';
ax.Title.String = 'Motile Population';
ax.YLim = [0 0.60];
ax.XLim = [-0.75 35]; 

ErcagGraphics
%Print the second figure 
printfig(hf_2,[Export_Folder filesep Export_Label],'-dpdf')

%% Functions 
function List = retrieveList(File_List)
names = {File_List(:).name}';
%Find the expression which has the pattern ECOR+number+number
%and find the starting(a) and ending indices(b) of that expression
%in the file list
[a,b] = cellfun(@(x) regexp(x,'ECOR\d\w'),names);
    for i =1:length(a) 
    List{i} = names{i}(a(i):b(i));
    end
%find the ECOR3 & ECOR8 and correct the string arrays
log_mask = cellfun(@(x) ~isempty(regexp(x,'[A-Z]\>', 'once')),List); 
List(log_mask) = cellfun(@(X) erase(X,'A') , List(log_mask),'UniformOutput',0); %Find a more elegant way to implement the idea of removing last character for this line 
List = List'; 
end
