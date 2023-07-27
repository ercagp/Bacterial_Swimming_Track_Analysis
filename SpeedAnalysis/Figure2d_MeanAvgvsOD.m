% Figure 2b in Mean Average Speed vs. OD
clearvars;
close all; 

%% ECOR3 & ECOR34
%OD data of ECOR3 
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

%% ECOR8 & ECOR36
%OD data of ECOR8
ECOR8 = [0.214 0.222];
%OD value 
OD_ECOR8 = mean(ECOR8);
%Standard deviation of ECOR8
std_ECOR8 = std(ECOR8); 
%Standard error of the mean of ECOR8
sem_ECOR8 = std_ECOR8/sqrt(length(ECOR8));
ECOR36 = [0.324  0.327];
OD_ECOR36 = mean(ECOR36); 
std_ECOR36 = std(ECOR36); 
sem_ECOR36 = std_ECOR36/sqrt(length(ECOR36));

%% ECOR18 & ECOR19 
%OD data
ECOR18 = [0.357   0.328]; 
OD_ECOR18 = mean(ECOR18); 
std_ECOR18 = std(ECOR18); 
sem_ECOR18 = std_ECOR18/sqrt(length(ECOR18));
ECOR19 = [0.225  0.242];
OD_ECOR19 = mean(ECOR19); 
std_ECOR19 = std(ECOR19); 
sem_ECOR19 = std_ECOR19/sqrt(length(ECOR19));
%% ECOR20 & ECOR21
%OD data 
ECOR20 = [0.272 0.277];
OD_ECOR20 = mean(ECOR20); 
std_ECOR20 = std(ECOR20);
sem_ECOR20 = std_ECOR20/sqrt(length(ECOR20));
ECOR21 = [0.112  0.157];
OD_ECOR21 = mean(ECOR21); 
std_ECOR21 = std(ECOR21); 
sem_ECOR21 = std_ECOR21/sqrt(length(ECOR21));
%% ECOR32 vs. ECOR68 
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

%% 
