%% 1-CDF of Run Durations 
%May 2020
%by Ercag
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/TurnRunDurations';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Plot parameters 
fps = 30; %Hz 
Lab{1}.XAx = 'Run Duration (sec)';
Lab{1}.YAx = 'Fraction of run events longer than a given duration'; 
Lab{2}.XAx = 'Run Duration (sec)';
Lab{2}.YAx = 'Fraction of run events longer than a given duration'; 

minBin = 0;
MaxBin = 4;
Bins = minBin:1/fps:MaxBin; %sec.
Lim.X = [minBin MaxBin]; 
plt = false;

%Selected [IPTG]
IPTGSel = 100; %uM


for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunDur = cell(length(Files),1);
    TurnDur = cell(length(Files),1); 
    for i = 1:length(Files) 
        load(Files{i})
        %Filter parameters
        minV = Results.minV;
        minT = Results.minT;
        %T matrix
        T = Results.T; 
        
        IPTG(i) = RunReverse.Info.IPTG; 
        RunDur{i} = AltRunLength(Speeds,T,minT,minV,fps);
    end

    RDur = matchrepeat(IPTG,RunDur);
    for k = 1:size(RDur,1)
        %Title for each figure 
        Lab{1}.Title  = StrainLabels{j};
        
        %-----Plot run durations for individual strain----%
        hf{j} = figure(j);
        CDFRun = histcounts(RDur{k,2},Bins, 'Normalization','CDF'); 
        hist{k,j} = histogram('BinEdges', Bins,'BinCounts',1-CDFRun,...
                            'DisplayStyle','Stairs','LineWidth',2);                
        hold on
        
        %-----Plot run durations at fixed [IPTG] ----%
        if RDur{k,1} == IPTGSel
           hf_select = figure(3*length(StrainLabels)+1); 
           CDFRun_select = histcounts(RDur{k,2},Bins,'Normalization','CDF');
           hist_select{j} = histogram('BinEdges',Bins,'BinCounts',1-CDFRun_select,'DisplayStyle','Stairs','Linewidth',2);
           hold on
           Lab{2}.Title = ['[IPTG] = ', num2str(RDur{k,1}) '\muM']; 
        end
     end
    figure(hf{j})
    PlotSty(hf{j},Lab{1},Lim) 
    %Insert legend 
    legLabels = cellfun(@num2str,RDur(:,1),'UniformOutput',0);
    legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
    NewOrder = [2 3 4 1];
    legend([hist{NewOrder,j}],legLabels(NewOrder),'Location','NorthEast')
    %Export figure 
    printfig(hf{j},fullfile(ExpPath,['[20200522]CDF_' StrainLabels{j} '.pdf']),'-dpdf')
end

figure(hf_select)
PlotSty(hf_select,Lab{2},Lim)
legend([hist_select{1:end}],StrainLabels,'Location','NorthEast')
printfig(hf_select,fullfile(ExpPath,['[20200522]CDF_AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
    
    
    
%% Functions     
function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             R{i,2} = cell2mat(Y(Mask)); 
         end
end

function PlotSty(hFig,Lab,Lim)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         ax.YScale = 'log';
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         settightplot(ax); 
end

% function RunL = RunLength(S,T,minT,minV,fps)
%          %Filter out trajectories
%          TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
%          medV = cellfun(@(x) medianN(x(:,9)), S);
%         
%          MaskTraj = medV > minV & TotalTime > minT;
%          SSubset = S(MaskTraj); 
%          TSubset = T(MaskTraj,:); 
%          RunL = []; 
%          for i  = 1:size(TSubset,1)
%              RunStart = TSubset{i,2};
%              RunEnd = TSubset{i,3};
%              if isempty(RunStart) && isempty(RunEnd)
%                  %Take the whole trajectory as a single run
%                  RL = length(SSubset{i}(:,1));
%              else
%                  RL = RunEnd(2:length(RunStart))-RunStart(1:(end-1))+1;
%              end   
%              RunL = [RunL; RL']; 
%          end
%          RunL = RunL./fps;
% end
%Alternative version of Run length function 
function RunL = AltRunLength(S,T,minT,minV,fps)
         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         MaskTraj = medV > minV & TotalTime > minT;
         TSubset = T(MaskTraj,:);
         %Exclude trajectories without turn events 
         TSubset = TSubset(~cellfun(@isempty,TSubset(:,2)),:);
                  
         RunL = []; 
         for i  = 1:size(TSubset,1)
             R = TSubset{i,1}; %Run matrix
             %Empty RL before loop
             RL = [];
             for j = 1:size(R,2)
                 if j == 1
                    RL(j) = sum(R(3:end,j))+1;
                 else
                    RL(j) = sum(R(1:end,j))+1;
                 end  
             end
                    
            RunL = [RunL; RL']; 
         end
         RunL = RunL./fps;
end
