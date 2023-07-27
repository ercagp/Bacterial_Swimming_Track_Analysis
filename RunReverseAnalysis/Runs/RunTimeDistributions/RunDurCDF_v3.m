%% 1-CDF of Run Durations 
%May 2020
%by Ercag
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/TimeAnalysis/Distributions/1_CDF';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT43','KMT47','KMT48','KMT53'}; 
%ADMM parameter
Lambda = 0.5; 

%Plot parameters 
fps = 30; %Hz 
Lab{1}.XAx = 'Run Duration (sec)';
Lab{1}.YAx = 'Fraction of run events longer than a given duration'; 
Lab{2}.XAx = 'Run Duration (sec)';
Lab{2}.YAx = 'Fraction of run events longer than a given duration'; 

minBin = 3/fps;
MaxBin = 3;
Bins = minBin:1/fps:MaxBin; %sec.
Lim.X = [minBin MaxBin]; 
plt = false;


%Selected [IPTG]
IPTGSel = 25; %uM


for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunDur = cell(length(Files),1);
    RunCell = cell(length(Files),1); 
    TurnDur = cell(length(Files),1); 
    Temp = []; 
    for i = 1:length(Files) 
        load(Files{i})
        %Filter parameters
        minV = Results.minV;
        minT = Results.minT;
        %T matrix
        T = Results.T; 
        
        IPTG(i) = RunReverse.Info.IPTG; 
        RunCell{i} = RunBreakDown(Speeds,T,minV,minT,fps);
        %Run duration vector
        Temp = cell2mat(RunCell{i}); 
        RunDur{i} = Temp(:,1);
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
    printfig(hf{j},fullfile(ExpPath,['[20200609]CDF_' StrainLabels{j} '.pdf']),'-dpdf')
end

figure(hf_select)
PlotSty(hf_select,Lab{2},Lim)
legend([hist_select{1:end}],StrainLabels,'Location','NorthEast')
printfig(hf_select,fullfile(ExpPath,['[20200609]CDF_AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
    
    
    
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

