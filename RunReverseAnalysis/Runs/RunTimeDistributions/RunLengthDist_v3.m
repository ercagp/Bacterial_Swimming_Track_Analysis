%% Work out Run Length distributions v2
%by Ercag 
%May 2020 
clearvars;
close all;
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/TimeAnalysis/Distributions/RunTimes/CheckData';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT43','KMT47','KMT53'}; 
%ADMM parameter
Lambda = 0.5; 


%Filtering parameters
IPTGSel = 100; %uM 

%Plot parameters 
fps = 30; %Hz
NormType = 'PDF';

for in = 1:3
    Lab{in}.XAx = 'Run Duration (sec)';
    if strcmp(NormType,'PDF')
       Lab{in}.YAx = 'PDF'; 
    else
       Lab{in}.YAx = 'Counts'; 
    end
end

%Set bin arrays
minB = 3/fps;
maxB = 2.5; 
BinSize = 3/fps;

Bins{1} = minB:BinSize:maxB; %sec.

Lim.X = [minB maxB]; 
ColorMap = {[0 0.45 0.74],[0.85 0.33 0.10],[0.93 0.69 0.13]}; 


for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
    RunDur = cell(length(Files),1);
    Temp = [];
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;   
        minV = Results.minV; 
        T = Results.T; 
        %Compute the cell containing run infomation 
        RunCell{i} = RunBreakDown(Speeds,T,minV,minT,fps);
        Temp = cell2mat(RunCell{i}); 
        %Run duration vector
        RunDur{i} = Temp(:,1); 
        
        %Plot run durations for individual strains
        hf_IS = figure(i+(j-1)*length(Files));
        hist_IS = histogram(RunDur{i},Bins{1},'Normalization',NormType,...
            'FaceColor',ColorMap{j});
        Lab{1}.Title  = {StrainLabels{j},['[IPTG] = ' num2str(IPTG(i)) ' \muM']};
        PlotSty(hf_IS,Lab{1},Lim)
        printfig(hf_IS,fullfile(ExpPath,StrainLabels{j},['[20200609]' StrainLabels{j} '_[IPTG]_' num2str(IPTG(i)) 'uM_' num2str(i) '_RunDur_' NormType '.pdf']),'-dpdf');
    end
    continue 
    RDur = matchrepeat(IPTG,RunDur);
    for k = 1:size(RDur,1)
        IPTGMat(k) = RDur{k,1};
        %Title for each figure 
        Lab{1}.Title  = {StrainLabels{j},['[IPTG] = ' num2str(IPTGMat(k)) ' \muM']};
        Lab{2}.Title  = StrainLabels{j};

        %Run durations
        hf{k,j} = figure(k+4*(j-1));
        hist{k,j} = histogram(RDur{k,2},Bins{1},'Normalization',...
                    NormType);
        PlotSty(hf{k,j},Lab{1},Lim) 
        %hold on
         
        %Selected run durations 
        if RDur{k,1} == IPTGSel
           hf_select = figure(30); 
           hist_select{j} = histogram(RDur{k,2},Bins{1},'DisplayStyle','Stairs',...
               'Normalization',NormType,'Linewidth',2);
           hold on
           Lab{3}.Title = ['[IPTG] = ', num2str(RDur{k,1}) '\muM']; 
        end

    end
    %Insert legend 
    %legLabels = cellfun(@num2str,RDur(:,1),'UniformOutput',0);
    %legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
    %NewOrder = [2 3 4 1];
    %legend([hist{NewOrder,j}],legLabels(NewOrder),'Location','NorthEast')
    if strcmp(NormType,'PDF')
       %printfig(hf{j},fullfile(ExpPath,['[20200529]NPDF_' StrainLabels{j} '_RunDurations.pdf']),'-dpdf')
    else
       %printfig(hf{j},fullfile(ExpPath,['[20200529]' StrainLabels{j} '_RunDurations.pdf']),'-dpdf')
    end
    
    
%     figure(hf{length(StrainLabels)+j})
%     PlotSty(hf{length(StrainLabels)+j},Lab{2},Lim{2}) 
%     %Insert legend 
%     legLabels = cellfun(@num2str,TDur(:,1),'UniformOutput',0);
%     legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
%     NewOrder = [2 3 4 1];
%     legend([hist_TDur{NewOrder,j}],legLabels(NewOrder),'Location','NorthEast')
    %printfig(hf{length(StrainLabels)+j},fullfile(ExpPath,['[20200506]' StrainLabels{j} '_TurnDurations.pdf']),'-dpdf')
end
    figure(hf_select)
    PlotSty(hf_select,Lab{3},Lim)
    legend([hist_select{1:end}],StrainLabels,'Location','NorthEast')
    if strcmp(NormType,'PDF')
       %printfig(hf_select,fullfile(ExpPath,['[20200529]NPDF_RunDur_AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
    else
       %printfig(hf_select,fullfile(ExpPath,['[20200529]RunDur_AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
    end

    
    
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
         %settightplot(ax); 
end


