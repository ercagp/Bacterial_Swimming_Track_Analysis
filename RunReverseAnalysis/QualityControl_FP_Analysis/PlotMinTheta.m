%% Plot minimum threshold angle vs. FP & FN
clearvars;
close all; 
clc; 

ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl/MinThetaThreshold_Space'; 
%% Data
Lambda = 0.5; 
minThres = [30 35 40 45 50 55];
% [20191014]KMT9_5mM_Glu_1_ROI_1
KMT9_FP = [13.37209302, 10.11904762,7.878787879,3.797468354,4.430379747,0.684931507 ]; % percentage, (in order with minThres)
KMT9_FN = [0.581395349, 0, 1.818181818, 1.898734177, 1.265822785, 0.684931507]; 

%[20191204]KMT47_50uM_ROI_1
KMT47_FP =[19.90049751, 16.32653061, 16.14583333, 7.182320442, 11.36363636, 11.11111111]; 
KMT47_FN = [0.995024876, 2.040816327, 0.520833333,2.762430939, 1.704545455, 1.754385965]; 

%% Plotting 

%False positives 
h_fp = figure(1); 
plot(minThres,KMT9_FP,'.-b','MarkerSize',15);
hold on 
plot(minThres,KMT47_FP,'.-r','MarkerSize',15);
legend({'KMT9','KMT47'}); 
ax = gca;
ax.XLabel.String = 'Minimum Absolute Angle (degrees)';
ax.YLabel.String = 'False Positives (%)';
ErcagGraphics 


printfig(h_fp,fullfile(ExpPath,'[MinThetaThreshold_Space]FalsePositive'),'-dpdf'); 

%False negatives 
h_fn = figure(2); 
plot(minThres,KMT9_FN,'.-b','MarkerSize',15);
hold on 
plot(minThres,KMT47_FN,'.-r','MarkerSize',15);
legend({'KMT9','KMT47'}); 
ax_2 = gca;
ax_2.XLabel.String = 'Minimum Absolute Angle (degrees)';
ax_2.YLabel.String = 'False Negatives (%)';
ErcagGraphics 

printfig(h_fn,fullfile(ExpPath,'[MinThetaThreshold_Space]FalseNegative'),'-dpdf'); 


