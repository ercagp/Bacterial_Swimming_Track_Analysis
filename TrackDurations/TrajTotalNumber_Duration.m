%% Number of trajectories and length of trajectories entering the run-reverse analysis
%May 2020
%by Ercag
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/TrajNumber_Durations';
mkdir(ExpPath)
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

LimP.X = [20 105]; %IPTG
LimP.Y = [500 5250];
LimTT.X = LimP.X;
LimTT.Y = [3e3 2.3e4]; %Seconds
Lab{1}.XAx = '[IPTG] (\mum)';
Lab{2}.XAx = '[IPTG] (\mum)';
Lab{1}.YAx = 'Total # of Analyzed Bugs';
Lab{2}.YAx = 'Total Traj. Duration (sec)';

fps = 30; %Hz 

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    TotalNumBug = zeros(length(Files),1);
    TotalTime = zeros(length(Files),1);
    %TotalTrajDur = cell(length(Files),2);

    for i = 1:length(Files)
        %Call data    
        load(Files{i})
        
        IPTG(i) = RunReverse.Info.IPTG;
        TotalNumBug(i) = Results.AnalysedTrajNum;
        %Filter out trajectories
        [~,TotalT] = filterout(Speeds,Results.minT,Results.minV,fps);
        TotalTime(i) = TotalT; 
    end
    newOrder = [2 3 4 1];
    TNB = matchrepeat(IPTG,TotalNumBug);
    TT = matchrepeat(IPTG,TotalTime);
    TNB = TNB(newOrder,:);
    TT = TT(newOrder,:);
 
    
    hf = figure(1);
    p{j} = plot(cell2mat(TNB(:,1)),cellfun(@sum,TNB(:,2)),'.-','MarkerSize',20,...
               'LineWidth',1.5);
    hold on 
    
    hf_TT = figure(2); 
    p_TT{j} = plot(cell2mat(TT(:,1)),cellfun(@sum,TT(:,2)),'.-','MarkerSize',20,...
              'LineWidth',1.5);
    hold on
end
Lab{1}.Title = ''; 
PlotSty(hf,Lab{1},LimP)
legend([p{1:end}],StrainLabels,'Location','NorthEast')
printfig(hf,fullfile(ExpPath,'[20200517]TotalBugNum_[IPTG]_AllStrains.pdf'),'-dpdf');

Lab{2}.Title = ''; 
PlotSty(hf_TT,Lab{2},LimTT)
legend([p_TT{1:end}],StrainLabels,'Location','NorthEast')
printfig(hf_TT,fullfile(ExpPath,'[20200517]TotalTrajDur_[IPTG]_AllStrains.pdf'),'-dpdf');



function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             R{i,2} = Y(Mask); 
         end
end

function PlotSty(hFig,Lab,Lim)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         ax.YLim = Lim.Y; 
         ErcagGraphics
         settightplot(ax); 
end

function [S,TotalT] = filterout(S,minT,minV,fps)
         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
         
         MaskTraj = medV > minV & TotalTime > minT;
         S = S(MaskTraj); 
         TotalT = sum(cellfun(@(x) length(x(:,1)).*1/fps,S)); 
end
