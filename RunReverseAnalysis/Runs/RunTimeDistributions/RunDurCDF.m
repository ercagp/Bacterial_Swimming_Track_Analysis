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
Lab{1}.YAx = '1-CDF'; 
Lab{2}.XAx = 'Run Duration (sec)';
Lab{2}.YAx = '1-CDF'; 

Lim.X = [0 3]; 
plt = false;

%Selected [IPTG]
IPTGSel = 50; 

Bins = 0:1/fps:3; %sec.

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunDur = cell(length(Files),1);
    TurnDur = cell(length(Files),1); 
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        RunDur{i} = Results.RTStats.RunLengths';
        TurnDur{i} = Results.RTStats.TumbleLengths';
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
    
   
end

figure(hf_select)
PlotSty(hf_select,Lab{2},Lim)
legend([hist_select{1:end}],StrainLabels,'Location','NorthEast')
    
    
    
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
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         settightplot(ax); 
end
