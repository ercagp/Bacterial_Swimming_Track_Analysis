%Analysis of V.Fischeri Data
%by Ercag
%November 2018 
clear all; close all;
Folder = 'Z:\Data\20181107\Vibrio_Fish_Test_1'; 
FileName = 'Bugs_20181119T064747.mat';
load([Folder filesep FileName])

%Calculate the speed vector 
S=BugsToSpeeds_ForStruct(BugStruct);
%Perform Speed Statistics 
SpeedStats = SpeedStatistics(S);

minDur = 5; %units?  probably seconds --> CHECK! 
maxSpeed = 100; %units? - probably um/s --> CHECK! 
minSpeed = 50; %units? - probably um/s --> CHECK! 
[k, kind] = MotileLongTrajectorySubset(SpeedStats,minSpeed,minDur);

%Plot the selected by "kind" index numbers
PlotColouredSpeedTrajectory_ForStruct(S, kind, maxSpeed, 'label')

%kind(2)
%Find coexisting trajectories 
%Coex = FindCoexistingTrajectories(S{1}, 10)