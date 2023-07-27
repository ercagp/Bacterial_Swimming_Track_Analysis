%% Find the cross correlation between times series of speed and dAlpha3 
clearvars;
close all; 

MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_25uM/ROI_1/';
FileNameResults = '[20200403]Results_RunReverseAnalysis.mat';

%MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_50uM/ROI_1/[20200402]TurnEventAnalysis';
%FileNameResults = '[Results]RunReverseErcag_v2.mat';

%MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_75uM/ROI_1';
%FileNameResults = '[20200403]Results_RunReverseAnalysis.mat';

%MainPathResults = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/20191204/KMT47_100uM/ROI_1';
%FileNameResults = '[20200403]Results_RunReverseAnalysis.mat';

%MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_75uM/ROI_1/20191211_Tracking';
%FileNameTraj = 'Bugs_20191211T171007_ADMM_Lambda_0.5.mat';

%MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_100uM/ROI_1/20191206_Tracking';
%FileNameTraj = 'Bugs_20191206T200247_ADMM_Lambda_0.5.mat';

%MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_50uM/ROI_1/20191205_Tracking';
%FileNameTraj = 'Bugs_20191205T221226_ADMM_Lambda_0.5.mat';

MainPathTraj = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/20191204/KMT47_25uM/ROI_1/20191205_Tracking';
FileNameTraj = 'Bugs_20191205T200121_ADMM_Lambda_0.5.mat';


FullFileRes = fullfile(MainPathResults,FileNameResults);
FullFileTraj = fullfile(MainPathTraj,FileNameTraj); 
load(FullFileRes);
load(FullFileTraj);

%Scan the "T" matrix 
T = Results.T;
LT = length(T);

%Minimum Trajectory length & speed
minT = 2; %sec 
minV = 5; %um/sec

dAlpha3Cell = Results.dAlpha3;
dAlphaCell = cellfun(@(x) x(:,end), B_Smooth.Speeds,'UniformOutput',0);
SpeedCell = cellfun(@(x) x(:,9), B_Smooth.Speeds,'UniformOutput',0);

%Deduce the median speed and trajectory length of each bug 
medV=cell2mat(cellfun(@(x) (medianN(x(:,9))), B_Smooth.Speeds, 'UniformOutput', 0));
TrajDur=cell2mat(cellfun(@(x) (size(x,1)/B_Smooth.Parameters.fps), B_Smooth.Speeds, 'UniformOutput', 0));
%Determine the trajectories longer than minT with median speed larger than
%minV 
lTrajectory = medV > minV & TrajDur > minT; 

%Define max lag
maxLag = 10; 
NoTraj = 500; 

for i = 1:NoTraj%length(SpeedCell)
    if lTrajectory(i)
        logMaskCorr = (~isnan(dAlpha3Cell{i})) & (~isnan(SpeedCell{i})); 
        [SAlpCorr,Lag] = xcorr(dAlpha3Cell{i}(logMaskCorr),SpeedCell{i}(logMaskCorr),maxLag,'coeff');
        plot(Lag,SAlpCorr,'-b','LineWidth',1)
        hold on 
        plot(zeros(1,100),linspace(0,1,100),'--k','LineWidth',1)
    end
end

ax = gca; 
ax.XLabel.String = 'Lag (Frames)'; 
ax.YLabel.String = 'NCC (dAlpha3,Speed)'; 
ax.Title.String = {'KMT47 - 25\muM [IPTG]', [num2str(NoTraj) ' Trajectories']};
ErcagGraphics

hf_1 = figure(1); 
printfig(hf_1,fullfile(MainPathResults,'CrossCorr_dAlpha3_Speed.pdf'),'-dpdf')

