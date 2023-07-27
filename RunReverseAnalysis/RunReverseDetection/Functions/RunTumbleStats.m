%% Run-Tumble Statistics of the Vibrio Fischeri Trajectories
%by Erça?
%December 2019 
clearvars;
close all; 
%% Load Data
BugTraj = {'Z:\Data\3D_Tracking_Data\20191014\KMT9_5mM_Glu_1\ROI_1\20191017_Tracking\Bugs_20191017T032033_ADMM_Lambda_1.mat'};
load(BugTraj{1})

% Set parameters
SpeedThreshold = 10; %micron/sec
TimeThreshold = 10; %seconds 
ThreshFactorA = 10; 
%Set sharp turning angle event threshold
SharpTurnA = 90; 

%% Run BugTumble algorithm 
[RunCell,indVec] = BugTumbles(B_Smooth,SpeedThreshold,TimeThreshold,ThreshFactorA);
%Select the analyzed bugs from the ensemble 
RunCellSubset =  cell(length(indVec),4); 
RunCellSubset(:,1) =  num2cell(indVec);
RunCellSubset(:,2:end) = RunCell(indVec,:);

RatioSpeed = [];
%Run a loop over the index of the bug to investigate 
for iBug = 1:length(indVec)
%Isolate Trajectory and Angle&Speed Information 
BugSpeed = B_Smooth.Speeds{RunCellSubset{iBug,1}};
%Extract Angles
Ang = BugSpeed(:,end); 


%Isolate Run Matrix 
RunMat = RunCellSubset{iBug,2};

%Isolate run start and end positions 
%RunStart(1) = 1;
RunStart = RunCellSubset{iBug,3}; %[RunStart, RunCellSubset{iBug,3}];
RunEnd = RunCellSubset{iBug,4}; 

%Extract turn angles
TurnAng = []; 
IndTurnA = []; 
iMax = length(RunEnd);
for i = 1:iMax
    if i > length(RunStart)
       IndTurnA = [IndTurnA;(RunEnd(i): size(RunMat,1))'];
       TurnAng = [TurnAng;Ang(RunEnd(i):size(RunMat,1))]; 
    else
       IndTurnA = [IndTurnA;(RunEnd(i):(RunStart(i)-1))'];
       TurnAng = [TurnAng;Ang(RunEnd(i):(RunStart(i)-1))]; 
    end
end

%Turn angle histogram 
% figure
% histogram(TurnAng,'Normalization','PDF');
% drawnow()

%Sharp turn events 
MaskTurnA = TurnAng > SharpTurnA; 
IndTurnASharp = IndTurnA(MaskTurnA); 

%Number of sharp turning events 
TurnEvents(iBug) = sum(MaskTurnA);

[angleVel, sInd] = anglesurvey(BugSpeed,1:size(BugSpeed,1),120);
%reduce consecutive points 
% A = find([true ~(diff(sInd)==1)]); 
% for k = 1:length(A)-1
%     subset = sInd(A(k):A(k+1)-1);
%     sIndNew(k) = floor(median(subset));
% end

%Angle between velocity vectors
%Define lag 
% deltaL = 2; 
% InitI = 1; 
% InitJ = 1+deltaL; 
% 
% dotAB = dot(BugSpeed(InitI:end-deltaL,6:8),BugSpeed(InitJ:end,6:8),2); 
% normAB = vecnorm(BugSpeed(InitI:end-deltaL,6:8),2,2).*vecnorm(BugSpeed(InitJ:end,6:8),2,2); 
% angleVel = rad2deg(acos(dotAB./normAB)); 
% 
% maskAngleVel = angleVel > 150; 
% %shift the logical mask by one row 
% maskAngleVelNew = false(length(maskAngleVel)+1,1); 
% maskAngleVelNew(2:end) = maskAngleVel(1:end);
% maskAngleVelNew(end) = false; 
% % 
% IndAngleVel = 1:size(BugSpeed,1); 
% IndAngleVel = IndAngleVel(maskAngleVelNew);
% 
% 
% %Plot the trajectory and mark sharp turning angles
figure;
PlotTrajectory(BugSpeed,RunMat,IndTurnASharp)
%mark the turning events detected for second order dAlpha
plot3(BugSpeed(sInd,2),BugSpeed(sInd,3),BugSpeed(sInd,4),'ro','MarkerSize',8);


%Deduce bug speed before and after the sharp turning event 
SpeedSharpTurnBefore = []; 
SpeedSharpTurnAfter = []; 
deltaP = 5; %look deltaP away from sharp turns 
for iTurn = 1:length(IndTurnASharp)
   if IndTurnASharp(iTurn)- deltaP <= 0
       SpeedSharpTurnBefore = [ SpeedSharpTurnBefore; (BugSpeed((IndTurnASharp(iTurn)-1):(IndTurnASharp(iTurn)),9))];
       MeanBefore = mean(BugSpeed((IndTurnASharp(iTurn)-1):(IndTurnASharp(iTurn)),9));
   else
       SpeedSharpTurnBefore = [ SpeedSharpTurnBefore; (BugSpeed((IndTurnASharp(iTurn)-deltaP):(IndTurnASharp(iTurn)),9))];
       MeanBefore = mean(BugSpeed((IndTurnASharp(iTurn)-deltaP):(IndTurnASharp(iTurn)),9));
   end
       
   if IndTurnASharp(iTurn) + deltaP > size(BugSpeed,1)
      SpeedSharpTurnAfter = [ SpeedSharpTurnAfter; (BugSpeed((IndTurnASharp(iTurn)):(IndTurnASharp(iTurn)+1),9))];
      MeanAfter = mean(BugSpeed((IndTurnASharp(iTurn)):(IndTurnASharp(iTurn)+1),9)); 
   else
      SpeedSharpTurnAfter = [ SpeedSharpTurnAfter; (BugSpeed((IndTurnASharp(iTurn)):(IndTurnASharp(iTurn)+deltaP),9))]; 
      MeanAfter = mean(BugSpeed((IndTurnASharp(iTurn)):(IndTurnASharp(iTurn)+deltaP),9));
   end
   RatioSpeed = [RatioSpeed; (MeanBefore./MeanAfter)'];
end

% Edges = 0:5:200;

% figure
% hst{1} = histogram(SpeedSharpTurnBefore,Edges,'Normalization','pdf');
% hold on 
% hst{2} = histogram(SpeedSharpTurnAfter,Edges,'Normalization','pdf');
% legend([hst{1:end}],{'Before';'After'})
end

% figure
% histogram(RatioSpeed,0:0.1:10,'Normalization','pdf') 

% figure
% histogram(TurnEvents,'Normalization','pdf')

function [angleVel, sharpInd] = anglesurvey(B,Ind,SharpTurn) 
sharpInd = [];
for i = 1:length(Ind) 
    %Find the angle between the v. vector of Bug Ind(i) and 6 vectors around it 
    deltaL = 5; 
    angleVel{i} = []; 
    
    if Ind(i) <= deltaL || Ind(i)+deltaL > length(Ind)
        continue
    else
        for delta = deltaL:-1:1
        dotAB = dot(B(Ind(i)-delta,6:8), B(Ind(i),6:8),2);
        normAB = vecnorm(B(Ind(i)-delta,6:8),2,2).*vecnorm(B(Ind(i),6:8),2,2); 
        angleVel{i} = [angleVel{i}; rad2deg(acos(dotAB./normAB))]; 
        end

        for delta = 1:deltaL
        dotAB = dot(B(Ind(i)+delta,6:8), B(Ind(i),6:8),2);
        normAB = vecnorm(B(Ind(i)+delta,6:8),2,2).*vecnorm(B(Ind(i),6:8),2,2); 
        angleVel{i} = [angleVel{i}; rad2deg(acos(dotAB./normAB))]; 
        end
    end
    
    %check angleVel for sharp turns 
    if any(angleVel{i} > SharpTurn) 
       sharpInd = [sharpInd Ind(i)];
    else 
        continue
    end
end

end


function PlotTrajectory(S,R,i)
colourorder={ 'b', 'c'};
plot3(S(:,2), S(:,3), S(:,4), 'Color', [ 0.8 0.8 0.8],'LineWidth',3)
drawnow
hold on 
for k=1:size(R,2)
    j=mod(k,2)+1;    
    %plot runs
    plot3(S(R(:,k),2), S(R(:,k),3), S(R(:,k),4), 'Color', colourorder{j},'LineWidth',3);
    drawnow()
    %plot velocity vectors 
    %quiver3(S(R(:,k),2),S(R(:,k),3),S(R(:,k),4),S(R(:,k),6),S(R(:,k),7),S(R(:,k),8),'Color','r','LineWidth',2) 
end
%mark the sharp turning events
plot3(S(i,2),S(i,3),S(i,4),'bx','MarkerSize',8);
drawnow()

ax = gca;
ax.DataAspectRatio = [1 1 1];
ax.Clipping = 'off';
ErcagGraphics
ax.XLabel.String = 'x (\mu{}m)';
ax.YLabel.String = 'y (\mu{}m)';
ax.ZLabel.String = 'z (\mu{}m)';
end









