%% Extension to BarPlotCriteria.m 
%by Ercag Pince
%April 2020 
clearvars;
clc;
close all; 

%ExpPathBoth = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl/1stConditionDropped_Space/BothConditions_MarkedPoints';
ExpPathOnlyTwo = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl/1stConditionDropped_Space/OnlySecondCondition_MarkedPoints';

%% Only the 2nd selection criteria (i.e. (LalphaT(i) && LalphaT3(i))) 
%Selected Trajectories - FP & FN percentages of points triggered by 1st or
%2nd condition (or both) 
KMT9_FP_1st = 30; %percentage
KMT9_FP_2nd = 100;  
KMT9_FP_Both = 30; 

KMT47_FP_1st = 11.1;
KMT47_FP_2nd = 83.3;
KMT47_FP_Both = 11.1; 