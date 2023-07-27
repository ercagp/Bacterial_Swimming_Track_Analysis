%Analysis of V.Fischeri Data
%by Ercag
%November 2018 
clear all; close all;
Folder = 'Z:\Data\20181107\'; 
Folder_analysis = 'Z:\Track_Analysis_Data\20181107'; 
files = getallfilenames(Folder);
%% Combine a number of experimental data 
%Vibrio_Fish_Test_1,
%Vibrio_Fish_Test_3,
%Vibrio_Fish_Test_4,
%Vibrio_Fish_Test_5,

%Non_filtered_Trajectories
%Indices of each trajectory file 
j = 1; 
k_traj = [1 5 6 7]; 
for i = k_traj
    load(files{i,1})
    VFT(j) = {B};
    j = j +1;
end
save([Folder_analysis filesep 'VFT_1345_merged_nonfiltered.mat'],'VFT')
    
%% Statistical Analysis
for i = 1:length(VFT)
    S(i)={BugsToSpeeds_ForStruct(VFT{i})};
    %Perform Speed Statistics 
    SpeedStats{i} = SpeedStatistics(S{i});
end
save([Folder_analysis filesep 'S_1345_merged_nonfiltered.mat'],'S')
save([Folder_analysis filesep 'Stats_1345_merged_nonfiltered.mat'],'SpeedStats')

%Overlay swimming speed histograms of different experiments 

edgesV=0:2:150;
for i = 1:length(SpeedStats)
    allV{i} = cell2mat(SpeedStats{i}.allV);
    ht(i) = histogram(allV{i}, edgesV,'Normalization','pdf','DisplayStyle','stairs');
    hold on 
end
hold off 
KatjasGraphics
xlabel('swimming speed v (\mu{}m/s)');
ylabel('pdf')
%legend(h, ConditionDescription{1:2}, 'Location', 'SouthWest')
title('swimming speed distribution')

%Trajectory durations 
figure 
hT=[];
edgesT=0:0.6:300;
for i=1:length(SpeedStats)
    hT(i)=histogram(SpeedStats{i}.TrajDur,edgesT, 'Normalization','cdf', 'DisplayStyle','stairs');
    hold on
end
hold off
KatjasGraphics
xlabel('trajectory duration (s)')
ylabel('cdf')
%legend(hT, ConditionDescription,'Location', 'SouthEast')

%1-time(CDF) (trajectory durations) 
figure;
CDF_TrajDurTime=NaN(length(edgesT),length(SpeedStats));
for i=1:length(SpeedStats)
    t=SpeedStats{i}.TrajDur;
    for j=1:length(edgesT)
        ll=t>edgesT(j);
        CDF_TrajDurTime(j,i)=sum(t(ll));
    end
    CDF_TrajDurTime(:,i)=CDF_TrajDurTime(:,i)./sum(t(~isnan(t)));    
end
hTt=stairs(edgesT, CDF_TrajDurTime);
KatjasGraphics
xlabel('trajectory duration (s)')
ylabel('1- time cdf')
set(gca,'XScale', 'log', 'XLim', [1 300]);

%% Motility Analysis
%Retrieve a subset of trajectories which are longer than minDur seconds
%with maximum and minimum speeds of maxSpeed and minSpeed
minDur = 10; % Seconds
maxSpeed = 100; % um/s
minSpeed = 15; % um/s

%Determine Long Trajectories for each field of view
hfST = cell(1,length(SpeedStats));
for i = 1:length(SpeedStats)
[k, kind] = MotileLongTrajectorySubset(SpeedStats{i},minSpeed,minDur);

%Plot the selected trajectories by "kind" index numbers
hfST{i} = figure;
PlotColouredSpeedTrajectory_ForStruct(S{i}, kind, maxSpeed, 'label');
title(['Field of View #' num2str(i)])
savefig(hfST{i},[Folder_analysis filesep 'SpeedTrajFig_minDur' num2str(minDur) '_minSpeed' num2str(maxSpeed) '_' num2str(i)])
end

%% Check the distance proximity in trajectories
%Check the proximity of the selected subset of trajectories 
% C=FindCoexistingTrajectories(BugStruct, 10); 
% I=find(C);
% [ind1, ind2]=ind2sub(size(C), I);
% 
% minD=sparse(size(C,1), size(C,2));
% for i=1:length(ind1)
%     [~,d]=FindTrajectoryDistances(BugStruct, ind1(i),ind2(i));
%     minD(ind1(i),ind2(i))=min(d);
% end

%kind(2)
%Find coexisting trajectories 
%Coex = FindCoexistingTrajectories(S{1}, 10)

%% Histograms and distribution 
%Check the speed distribution of the subset 
% allV_subset = SpeedStats.allV(kind);
% h = zeros(1,length(kind));
% edgesV = 0:2:150;
% 
% for i = 1:length(kind) 
%     figure(i+1)
%     h(i)=histogram(allV_subset{i}, edgesV,'Normalization','pdf','DisplayStyle','stairs');
%     drawnow()
% end




