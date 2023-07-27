%% Work out Run Length and Turn Length distributions
%by Ercag 
%May 2020 
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
Lab{1}.YAx = 'PDF'; 
Lab{2}.XAx = 'Turn Duration (sec)';
Lab{2}.YAx = 'Counts'; 
Lab{3}.XAx = 'Run Duration (sec)';
Lab{3}.YAx = 'Counts'; 
plt = false;

Bins{1} = 0:1/fps:3; %sec.
Bins{2} = 0:1/fps:0.5; %sec

Lim{1}.X = [0 3]; 
Lim{2}.X = [0 0.5]; 


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
        
        %Plot run durations for individual strains
        if IPTG(i) == 25
        hf_ind = figure(10+j);
        hist_ind = histogram(RunDur{i},Bins{1},'DisplayStyle','Stairs',...
                                'Normalization','count','LineWidth',2);
        hold on
        Lab{1}.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTG(i)) ' \muM']};
        plt = true;
        end
    end
    if plt 
    PlotSty(hf_ind,Lab{1},Lim{1})
    end
    
    RDur = matchrepeat(IPTG,RunDur);
    TDur = matchrepeat(IPTG,TurnDur);
    %TA_TDur = [TA(:,2),TDur(:,2)]; %TurnAngles-TurnDurations
    for k = 1:size(RDur,1)
        %Title for each figure 
        Lab{1}.Title  = StrainLabels{j};
        Lab{2}.Title  = StrainLabels{j};

        %Run durations
        hf{j} = figure(j);
        hist{k,j} = histogram(RDur{k,2},Bins{1},'DisplayStyle','Stairs',...
                'Normalization','PDF','LineWidth',2);  
        hold on
        
        %Turn durations
        hf{length(StrainLabels)+j} = figure(length(StrainLabels)+j);
        hist_TDur{k,j} = histogram(TDur{k,2},Bins{2},'DisplayStyle','Stairs',...
                'Normalization','count','LineWidth',2); 
        hold on
         
        %Selected run durations 
        if RDur{k,1} == 50
           hf_select = figure(3*length(StrainLabels)+1); 
           hist_select{j} = histogram(RDur{k,2},Bins{1},'DisplayStyle','Stairs',...
               'Normalization','count','Linewidth',2);
           hold on
           Lab{3}.Title = ['[IPTG] = ', num2str(RDur{k,1}) '\muM']; 
           Lab{3}.YAx = 'PDF';
        end

    end
    figure(hf{j})
    PlotSty(hf{j},Lab{1},Lim{1}) 
    %Insert legend 
    legLabels = cellfun(@num2str,RDur(:,1),'UniformOutput',0);
    legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
    NewOrder = [2 3 4 1];
    legend([hist{NewOrder,j}],legLabels(NewOrder),'Location','NorthEast')
    printfig(hf{j},fullfile(ExpPath,['[20200512]NPDF_' StrainLabels{j} '_RunDurations.pdf']),'-dpdf')
    
    
    figure(hf{length(StrainLabels)+j})
    PlotSty(hf{length(StrainLabels)+j},Lab{2},Lim{2}) 
    %Insert legend 
    legLabels = cellfun(@num2str,TDur(:,1),'UniformOutput',0);
    legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
    NewOrder = [2 3 4 1];
    legend([hist_TDur{NewOrder,j}],legLabels(NewOrder),'Location','NorthEast')
    printfig(hf{length(StrainLabels)+j},fullfile(ExpPath,['[20200506]' StrainLabels{j} '_TurnDurations.pdf']),'-dpdf')
end
    figure(hf_select)
    PlotSty(hf_select,Lab{3},Lim{1})
    legend([hist_select{1:end}],StrainLabels,'Location','NorthEast')
    printfig(hf_select,fullfile(ExpPath,'[20200511]RunDur_AllStrains_IPTG_50uM.pdf'),'-dpdf')
    
    
    
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
