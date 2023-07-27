%Analysis of V.Fischeri Data
%by Ercag
%November 2018 
clear all; close all;
Folder = 'Z:\Data\20181107\Vibrio_Fish_Test_1'; 
FileName = 'Bugs_20181119T064747.mat';
load([Folder filesep FileName])

%% Speed Statistics
%Calculate the speed vector 
S=BugsToSpeeds_ForStruct(BugStruct);
%Perform Speed Statistics 
SpeedStats = SpeedStatistics(S);

%Retrieve a subset of trajectories which are longer than minDur seconds
%with maximum and minimum speeds of maxSpeed and minSpeed
minDur = 10; % Seconds
maxSpeed = 100; % um/s
minSpeed = 15; % um/s
[k, kind] = MotileLongTrajectorySubset(SpeedStats,minSpeed,minDur);

%Plot the selected trajectories by "kind" index numbers
PlotColouredSpeedTrajectory_ForStruct(S, kind, maxSpeed, 'label')

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
allV_subset = SpeedStats.allV(kind);
h = zeros(1,length(kind));
edgesV = 0:2:150;

for i = 1:length(kind) 
    figure(i+1)
    h(i)=histogram(allV_subset{i}, edgesV,'Normalization','pdf','DisplayStyle','stairs');
    drawnow()
end




