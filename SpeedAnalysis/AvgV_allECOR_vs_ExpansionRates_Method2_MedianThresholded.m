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
Export_Label = 'AvgV_vs_ExpRate_allECORs_Method2_MedianThresholded';

%Define the data path
Load_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Discard_Speed';
Load_Katja = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Katja_data\ExpansionVsSwimmingSpeedforErcag.mat'; 

%Load Katja's data 
load(Load_Katja)

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
    load(fullfile(File_List(i).folder,File_List(i).name));
    
   %Get the ECOR number in string format 
   axis_text{i} = ECOR_List{i};
    
   %Get the speed statistics 
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

%% Expansion Data for ECOR (Figure 2b)
%Scale
scale = 1/16.56; %mm/pixels %1/16.244; %mm/pixels;
min_hr = 1/60; %hours

%Expansion data of ECOR3 & ECOR34
Exp_ECOR3_px = [1.1911 1.2396] ; %Pixels/min. !
Exp_ECOR34_px = [0 0]; %Pixels/min. !
%Expansion data in mm/hr
Exp_ECOR3_mm = Exp_ECOR3_px.*scale*(1/min_hr); %mm/hr.
Exp_ECOR34_mm = Exp_ECOR34_px.*scale*(1/min_hr); %mm/hr.
%Expansion rate in radius(not Diameter!)
Exp_ECOR3_mm = Exp_ECOR3_mm/2;
Exp_ECOR34_mm = Exp_ECOR34_mm/2;

%Average Expansion rate of ECOR3
avg_Exp_ECOR3_mm = mean(Exp_ECOR3_mm);
%Standard deviation of ECOR3
std_Exp_ECOR3_mm = std(Exp_ECOR3_mm);
%Standard error of the mean of ECOR3
sem_Exp_ECOR3_mm = std_Exp_ECOR3_mm/sqrt(length(Exp_ECOR3_mm));
%Average Expansion rate of ECOR34
avg_Exp_ECOR34_mm = mean(Exp_ECOR34_mm);
%Standard deviation 
std_Exp_ECOR34_mm = std(Exp_ECOR34_mm); 
%Standard error of the mean  
sem_Exp_ECOR34_mm = std_Exp_ECOR34_mm/sqrt(length(Exp_ECOR34_mm));

%Expansion data of ECOR8 & ECOR36
Exp_ECOR8_px = [1.5698 1.4726]; %Pixels/min. !
Exp_ECOR36_px = 0; %Pixels/min. !
Exp_ECOR8_mm = Exp_ECOR8_px.*scale*(1/min_hr); %mm/hr.
Exp_ECOR36_mm = Exp_ECOR36_px.*scale*(1/min_hr); %mm/hr.
%Expansion rate in radius(not Diameter!)
Exp_ECOR8_mm = Exp_ECOR8_mm/2;
Exp_ECOR36_mm = Exp_ECOR36_mm/2;

avg_Exp_ECOR8_mm = mean(Exp_ECOR8_mm);
std_Exp_ECOR8_mm = std(Exp_ECOR8_mm);
sem_Exp_ECOR8_mm = std_Exp_ECOR8_mm/sqrt(length(Exp_ECOR8_mm));
avg_Exp_ECOR36_mm = mean(Exp_ECOR36_mm); 
std_Exp_ECOR36_mm = std(Exp_ECOR36_mm);
sem_Exp_ECOR36_mm = std_Exp_ECOR36_mm/sqrt(length(Exp_ECOR36_mm));

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
Exp_ECOR32_mm = [0.046 0.039];  %Exp_ECOR32_px.*scale*(1/min_hr); %mm/hr.
avg_Exp_ECOR32_mm = mean(Exp_ECOR32_mm);
std_Exp_ECOR32_mm = std(Exp_ECOR32_mm); 
% Exp_ECOR68_px = [0.3509	0.4412]; %Pixels/min. !
%Expansion data in mm/hr 
Exp_ECOR68_mm = [0.923 1.305];%Exp_ECOR68_px.*scale*(1/min_hr); %mm/hr.
%Average Expansion value of ECOR68
avg_Exp_ECOR68_mm = mean(Exp_ECOR68_mm);
%Standard deviation 
std_Exp_ECOR68_mm = std(Exp_ECOR68_mm);
%Standard error of the mean 

%Put the Expansion data in correct order 
Exp_data = [avg_Exp_ECOR18_mm...
            avg_Exp_ECOR19_mm...
            avg_Exp_ECOR20_mm...
            avg_Exp_ECOR21_mm...
            avg_Exp_ECOR32_mm...
            avg_Exp_ECOR34_mm...
            avg_Exp_ECOR36_mm...
            avg_Exp_ECOR3_mm...
            avg_Exp_ECOR68_mm... 
            avg_Exp_ECOR8_mm];

std_Exp_data = [std_Exp_ECOR18_mm...
               std_Exp_ECOR19_mm...
               std_Exp_ECOR20_mm...
               std_Exp_ECOR21_mm...
               std_Exp_ECOR32_mm...
               std_Exp_ECOR34_mm... 
               std_Exp_ECOR36_mm...
               std_Exp_ECOR3_mm...
               std_Exp_ECOR68_mm... 
               std_Exp_ECOR8_mm];

%% Pearson correlation coefficient between the set of Exp_data and avgV 
pearson = corr(avgV',Exp_data');
%Bootstrap the sampling set 
[bootstat,bootsam] = bootstrp(1000,@corr,avgV,Exp_data); 
%Plot the bootstrapped correlation coefficients 
hf_boot = figure(2);
histogram(bootstat,'Normalization','PDF');
ax_boot = gca;
ax_boot.XAxis.Label.String = '\rho';
ax_boot.YAxis.Label.String = 'PDF'; 
ax_boot.Title.String = 'Correlation Coefficient(Bootstrapped)';

ErcagGraphics
printfig(hf_boot,[Export_Folder filesep 'Bootstrapped_Pearson_Dist_MotileFraction'],'-dpdf')

%% Plot average of mean speeds versus growth propensity 
% Your data only 
hf_2 = figure(3);
err_1 = errorbarxy(avgV,Exp_data,sem_avgV,std_Exp_data,{'ob', 'b', 'b'});

%Define colormap 
color_map = linspecer(5); 
color3_34 = color_map(1,:);
color8_36 = color_map(2,:);
color18_19 = color_map(3,:);
color20_21 = color_map(4,:);
color32_68 = color_map(5,:);

FontSize = 11;
TD_Factor = 1.05; 
%Add Annotations 
ECOR18 = text(TD_Factor*avgV(1),TD_Factor*Exp_data(1),'ECOR18');
ECOR18.Color = color18_19;
ECOR18.FontSize = FontSize;

ECOR19 = text(TD_Factor*avgV(2),TD_Factor*Exp_data(2),'ECOR19');
ECOR19.Color = color18_19;
ECOR19.FontSize = FontSize;

ECOR20 = text(TD_Factor*avgV(3),TD_Factor*Exp_data(3),'ECOR20');
ECOR20.Color = color20_21;
ECOR20.FontSize = FontSize;

ECOR21 = text(TD_Factor*avgV(4),TD_Factor*Exp_data(4),'ECOR21');
ECOR21.Color = color20_21;
ECOR21.FontSize = FontSize;

ECOR32 = text(TD_Factor*avgV(5),TD_Factor*Exp_data(5),'ECOR32');
ECOR32.Color = color32_68;
ECOR32.FontSize = FontSize;

ECOR34 = text(TD_Factor*avgV(6),TD_Factor*Exp_data(6),'ECOR34');
ECOR34.Color = color3_34;
ECOR34.FontSize = FontSize;

ECOR36 = text(avgV(7),-0.2,'ECOR36');
ECOR36.Color = color8_36;
ECOR36.FontSize = FontSize;

ECOR3 = text(TD_Factor*avgV(8),TD_Factor*Exp_data(8),'ECOR3');
ECOR3.Color = color3_34;
ECOR3.FontSize = FontSize;

ECOR68 = text(TD_Factor*avgV(9),TD_Factor*Exp_data(9),'ECOR68');
ECOR68.Color = color32_68;
ECOR68.FontSize = FontSize;

ECOR8 = text(TD_Factor*avgV(10),TD_Factor*Exp_data(10),'ECOR8');
ECOR8.Color = color8_36;	
ECOR8.FontSize = FontSize;

Rho_text = text(29,3.75,['\rho = ' num2str(pearson,'%4.2f')]);
Rho_text.FontSize = FontSize+2; 

ax = gca; 
ax.YAxis.Label.String = 'Migration Rate(mm/hr)';
ax.XAxis.Label.String = 'Avg. Swimming Speed(\mum/s)';
ax.Title.String = 'Motile Population';
ax.XLim = [-1.75 35];
ax.YLim = [-0.55 4]; 

ErcagGraphics
%Print the second figure 
printfig(hf_2,[Export_Folder filesep Export_Label],'-dpdf')

%Your data + Katja's data
%Scale Katja's expansion rate data to mm/hr
Katja_Scale = 1e-3*(60*60);% um^2/sec --> mm/hr 
r_WT = r_WT * Katja_Scale; 
r_WT_err = r_WT_err * Katja_Scale; 
r_fla_0 = r_fla_0 * Katja_Scale; 
r_fla_err = r_fla_err * Katja_Scale; 

hf_3 = figure(4);
err_2 = errorbarxy(avgV,Exp_data,sem_avgV,std_Exp_data,{'ob', 'b', 'b'});
hold on 
%Plot trade-off on wild-type 
err_katja_1 = errorbarxy(vall_WT,r_WT,vall_WT_err,r_WT_err,{'ok','k','k'}); 
%Plot trade-off on inducible flagella 
err_katja_2 = errorbarxy(vall_fla,r_fla_0,vall_fla_err,r_fla_err,{'or','r','r'}); 
hold off 

%Define colormap 
color_map = linspecer(5); 
color3_34 = color_map(1,:);
color8_36 = color_map(2,:);
color18_19 = color_map(3,:);
color20_21 = color_map(4,:);
color32_68 = color_map(5,:);

FontSize = 11;
TD_Factor = 1.05; 
%Add Annotations 
ECOR18 = text(TD_Factor*avgV(1),TD_Factor*Exp_data(1),'ECOR18');
ECOR18.Color = color18_19;
ECOR18.FontSize = FontSize;

ECOR19 = text(TD_Factor*avgV(2),TD_Factor*Exp_data(2),'ECOR19');
ECOR19.Color = color18_19;
ECOR19.FontSize = FontSize;

ECOR20 = text(TD_Factor*avgV(3),TD_Factor*Exp_data(3),'ECOR20');
ECOR20.Color = color20_21;
ECOR20.FontSize = FontSize;

ECOR21 = text(TD_Factor*avgV(4),TD_Factor*Exp_data(4),'ECOR21');
ECOR21.Color = color20_21;
ECOR21.FontSize = FontSize;

ECOR32 = text(TD_Factor*avgV(5),TD_Factor*Exp_data(5),'ECOR32');
ECOR32.Color = color32_68;
ECOR32.FontSize = FontSize;

ECOR34 = text(TD_Factor*avgV(6),TD_Factor*Exp_data(6),'ECOR34');
ECOR34.Color = color3_34;
ECOR34.FontSize = FontSize;

ECOR36 = text(avgV(7),-0.2,'ECOR36');
ECOR36.Color = color8_36;
ECOR36.FontSize = FontSize;

ECOR3 = text(TD_Factor*avgV(8),TD_Factor*Exp_data(8),'ECOR3');
ECOR3.Color = color3_34;
ECOR3.FontSize = FontSize;

ECOR68 = text(TD_Factor*avgV(9),TD_Factor*Exp_data(9),'ECOR68');
ECOR68.Color = color32_68;
ECOR68.FontSize = FontSize;

ECOR8 = text(TD_Factor*avgV(10),TD_Factor*Exp_data(10),'ECOR8');
ECOR8.Color = color8_36;	
ECOR8.FontSize = FontSize;

%Text for Pearson correlation coefficient
% Rho_text = text(29,3.75,['\rho = ' num2str(pearson,'%4.2f')]);
% Rho_text.FontSize = FontSize+2; 

ax_2 = gca; 
ax_2.YAxis.Label.String = 'Migration Rate(mm/hr)';
ax_2.XAxis.Label.String = 'Avg. Swimming Speed(\mum/s)';
ax_2.Title.String = 'Motile Population';
ax_2.XLim = [-1.75 40];
ax_2.YLim = [-0.55 4]; 

ErcagGraphics
%Print legend
leg_1 = legend([err_katja_1.hMain err_katja_2.hMain],{'Wild-type','Inducible Flagella'});
leg_1.Box = 'off';
leg_1.FontSize = FontSize; 

%Print the second figure
printfig(hf_3,[Export_Folder filesep Export_Label '_overlayKatjasData'],'-dpdf')

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
