%% Differentiate turns from reversals
clearvars;
close all;
clc;

%% Define Path and call up trajectory files 
% Define the path for the results of the run-reverse analysis
MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_100uM/ROI_1';
FileNameResults = '[20200403]Results_RunReverseAnalysis.mat';

%MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_75uM/ROI_1';
%FileNameResults = '[20200403]Results_RunReverseAnalysis.mat';
%MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_25uM/ROI_1/';
%FileNameResults = '[20200403]Results_RunReverseAnalysis.mat';
%MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_50uM/ROI_1/[20200402]TurnEventAnalysis';
%FileNameResults = '[Results]RunReverseErcag_v2.mat';
%MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191014/[20200328]TurnEvent_Analysis/IndividualBugs'; 
%FileNameResults = 'TestRunReverseResults.mat';

MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_100uM/ROI_1/20191206_Tracking';
FileNameTraj = 'Bugs_20191206T200247_ADMM_Lambda_0.5.mat';

%MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_75uM/ROI_1/20191211_Tracking';
%FileNameTraj = 'Bugs_20191211T171007_ADMM_Lambda_0.5.mat';
%MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_25uM/ROI_1/20191205_Tracking';
%FileNameTraj = 'Bugs_20191205T200121_ADMM_Lambda_0.5.mat'; 
%MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_50uM/ROI_1/20191205_Tracking';
%FileNameTraj = 'Bugs_20191205T221226_ADMM_Lambda_0.5.mat';
%MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191014/KMT9_5mM_Glu_1/ROI_1/20191017_Tracking'; 
%FileNameTraj = 'Bugs_20191017T032033_ADMM_Lambda_0.5.mat';

FullFileRes = fullfile(MainPathResults,FileNameResults);
FullFileTraj = fullfile(MainPathTraj,FileNameTraj); 
load(FullFileRes);
load(FullFileTraj);

%Scan the "T" matrix 
T = Results.T;
LT = length(T);

dAlpha3Cell = Results.dAlpha3;
dAlphaCell = cellfun(@(x) x(:,end), B_Smooth.Speeds,'UniformOutput',0);
SpeedCell = cellfun(@(x) x(:,9), B_Smooth.Speeds,'UniformOutput',0);

%Minimum Trajectory length & speed
minT = 2; %sec 
minV = 5; %um/sec

%Deduce the median speed and trajectory length of each bug 
medV=cell2mat(cellfun(@(x) (medianN(x(:,9))), B_Smooth.Speeds, 'UniformOutput', 0));
TrajDur=cell2mat(cellfun(@(x) (size(x,1)/B_Smooth.Parameters.fps), B_Smooth.Speeds, 'UniformOutput', 0));
%Determine the trajectories longer than minT with median speed larger than
%minV 
lTrajectory = medV > minV & TrajDur > minT; 

dAlpha3_Turn = [];
dAlpha_Turn = []; 
Speed_Turn = []; 
Acc_Turn = []; 
for i = 1:length(B_Smooth.Speeds)
    if lTrajectory(i)
       Speed = SpeedCell{i};
       Acc = diff(Speed).*B_Smooth.Parameters.fps;
       RunStart = T{i,2};
       RunEnd =  T{i,3};
       dAlpha3 = dAlpha3Cell{i}; 
       dAlpha = dAlphaCell{i}; 
      

        for j = 1:length(RunEnd)
            dAlpha_Turn = [dAlpha_Turn ; dAlpha(RunEnd(j))];
            dAlpha3_Turn = [dAlpha3_Turn ; dAlpha3(RunEnd(j))];

            Speed_Turn = [Speed_Turn; Speed(RunEnd(j))];
            Acc_Turn = [Acc_Turn; Acc(RunEnd(j))]; 
        end
    end
end
        hf_1 = figure(1); 
        plot(dAlpha3_Turn,Speed_Turn,'.b','MarkerSize',10);
        ax{1} = gca; 
        ax{1}.XLabel.String = 'dAlpha3'; 
        ax{1}.YLabel.String = 'Speed(\mum/sec)';
        ax{1}.Title.String = {'KMT47','100\muM [IPTG]'};
        ErcagGraphics
        
        printfig(hf_1, fullfile(MainPathResults,'dAlpha3_vs_Speed.pdf'),'-dpdf')
        
       
        hf_2 = figure(2);
        plot(dAlpha3_Turn,Acc_Turn,'.b','MarkerSize',10);
        ax{2} = gca; 
        ax{2}.XLabel.String = 'dAlpha3'; 
        ax{2}.YLabel.String = 'Acceleration(\mum/sec^2)'; 
        ax{2}.Title.String = {'KMT47','100\muM [IPTG]'};
        ErcagGraphics
        printfig(hf_2, fullfile(MainPathResults,'dAlpha3_vs_Acc.pdf'),'-dpdf')

        
%         figure(3) 
%         plot(dAlpha_Turn,Speed_Turn,'.b','MarkerSize',10);
%         
%         figure(4)
%         plot(dAlpha_Turn,Acc_Turn,'.b','MarkerSize',10);






