%% Mean run speed distribution and other related plots
%% Compare Weighted distributions 
%December 2020 
%by Ercag
%v3 - It uses RunBreakDownv5 function 
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/SpeedAnalysis/Distributions/MeanRunSpeed/Cmp_MeanRunSpeeds/IndividualAcq';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT53'}; 

%Selected IPTG for the plot 
IPTGSel = 25; %uM 
fps = 30; %Hz
Lambda = 0.5; 

%% Define Plot parameters
iFig = 1; 
PltPara.Normalization = 'PDF';
PltPara.NormSwitch = '';
PltPara.DispStyle = 'stairs';
PltPara.FaceColor = 'none'; 
PltPara.LineWidth = 2; 
PltPara.Edges = 0:2:180; 
PltPara.Lim.X = [0 180]; 

if strcmp(PltPara.Normalization,'PDF')
    PltPara.Label.YAx = 'PDF'; 
else
    PltPara.Label.YAx = 'Counts'; 
end

%ColorMap_Edges = linspecer(size(InstRS,1),'qualitative');
ColorMap_Edges = linspecer(2,'qualitative');

PltParaSelect.Normalization = 'PDF';
PltParaSelect.LineWidth = 2; 
PltParaSelect.Bins = 0:2:180; 
PltParaSelect.Lim.X = [0 180]; 
PltParaSelect.DispStyle = 'Stairs'; 
PltParaSelect.FaceColor = 'none'; 
PltParaSelect.Label.XAx = '<V>_{Run} (\mum/sec)';
if strcmp(PltParaSelect.Normalization,'PDF')
    PltParaSelect.Label.YAx = 'PDF'; 
else
    PltParaSelect.Label.YAx = 'Counts'; 
end

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Speeds_Flt = cell(length(Files),1);
    RunCell = cell(length(Files),1);
    RunCell_Flt = cell(length(Files),1);
    InstRunSpeed = cell(length(Files),1);
    MeanRunSpeed = cell(length(Files),1);
    RunDur = cell(length(Files),1); 
    Temp = [];
    
    for i = 1:length(Files) 
        load(Files{i}) 
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 
        %Compute the cell containing run infomation 
        RunCell{i} = RunBreakDownv5(Speeds,T,fps);  %RunBreakDownv3(S,T,fps) --> The order
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        RunCell_Flt{i} = RunCell{i}(FilterMask,:); 
        
        InstRunSpeed{i} = cell2mat(RunCell_Flt{i}(:,1)); 
        Temp = cell2mat(RunCell_Flt{i}(:,2)); 
        %Run durations
        RunDur{i} = Temp(:,1); 
        %Mean speed of runs 
        MeanRunSpeed{i} = Temp(:,2);
        
        MeanRunPlot.X = MeanRunSpeed{i}; 
        MeanRunPlot.RunDur = RunDur{i}; 
        
        %Compare weighted and native mean speed of runs
        hf = figure(i);
        PltPara.Label.Title  = {[StrainLabels{j} ' - ' num2str(IPTG(i)) ' \muM [IPTG]'], 'Compare Mean Run Speeds'};
        PltPara.Label.XAx = '<V>_{Run} (\mum/sec)';
        PltPara.EdgeColor = ColorMap_Edges(1,:);
        PltPara.NormSwitch = '';             
        MeanRun_RH{1} = RunDist(MeanRunPlot, PltPara, hf);
        hold on 
        PltPara.EdgeColor = ColorMap_Edges(2,:);
        PltPara.NormSwitch = 'weighted';
        MeanRun_RH{2} = RunDist(MeanRunPlot, PltPara, hf);
        legend([MeanRun_RH{1} MeanRun_RH{2}],{'Native','Weighted'},'Location','NorthEast')  
        drawnow(); 
        
        printfig(hf,fullfile(ExpPath,['[20201202][MeanRunSpeedCMP]' StrainLabels{j} '_' num2str(IPTG(i)) '_uM[IPTG]' num2str(i) '.pdf'])...
                      ,'-dpdf');
        printfig(hf,fullfile(ExpPath,['[20201202][MeanRunSpeedCMP]' StrainLabels{j} '_' num2str(IPTG(i)) '_uM[IPTG]' num2str(i) '.png'])...
                      ,'-dpng');
        
        
    end
    InstRS = matchrepeat(IPTG,InstRunSpeed);
    MeanRS = matchrepeat(IPTG,MeanRunSpeed); 
    RunDurRS = matchrepeat(IPTG,RunDur); 
    

    
    for k = 1:size(InstRS,1)
             IPTGLabel{k} = [num2str(MeanRS{k,1}) '\muM'];
             MRS.X = MeanRS{k,2}; %Mean Run Speeds
             MRS.RunDur = RunDurRS{k,2};
             
%              hf = figure(iFig);
%              iFig = iFig + 1; 
             %Mean run speed distribution 
             
%              PltPara.Label.Title  = {[StrainLabels{j} ' - ' IPTGLabel{k} ' [IPTG]'], 'Compare Mean Run Speeds'};
%              PltPara.Label.XAx = '<V>_{Run} (\mum/sec)';
%              
             %Colormap for non-weighted dist.  
%              PltPara.EdgeColor = ColorMap_Edges(1,:);
%              
%              PltPara.NormSwitch = '';             
%              MRS_RH{k,1} = RunDist(MRS, PltPara, hf); 
%              hold on 
%              
%              %Colormap for weighted dist.  
%              PltPara.EdgeColor = ColorMap_Edges(2,:);
%              PltPara.NormSwitch = 'weighted';
%              MRS_RH{k,2} = RunDist(MRS, PltPara, hf); 
%              
%              legend([MRS_RH{k,1} MRS_RH{k,2}],{'Native','Weighted'},'Location','NorthEast')
%              drawnow(); 
%              
%              printfig(hf,fullfile(ExpPath,['[20201202][MeanRunSpeedCMP]' StrainLabels{j}...
%                       '_[IPTG]_' num2str(MeanRS{k,1}) '.pdf']),'-dpdf');
%              printfig(hf,fullfile(ExpPath,['[20201202][MeanRunSpeedCMP]' StrainLabels{j}...
%                       '_[IPTG]_' num2str(MeanRS{k,1}) '.png']),'-dpng');

                    
%             if IPTGLabel == IPTGSel
%                 hf_select = figure(40);
%                 PltParaSelect.EdgeColor = ColorMap{j};
%                 PltParaSelect.Label.Title = ['[IPTG] = ' num2str(IPTGLabel) ' \muM']; 
%                 HistSelect{j} =  RunDist(MeanRunSpeed,PltParaSelect,hf_select);
%                 hold on 
%             end
    end


end

% figure(hf_select)
% legend([HistSelect{1:end}],StrainLabels,'Location','NorthEast')

%printfig(hf_select,fullfile(ExpPath,['[20201109][MeanRunSpeed]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
%printfig(hf_select,fullfile(ExpPath,['[20201109][MeanRunSpeed]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.png']),'-dpng')




%% Functions     

function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
         
end

function RunDistH = RunDist(X,PltPara,hFig)

%         The input has now two components  
          RunDur = X.RunDur; %for weighing mean run speeds
          XValues = X.X;   
            
%          
          Edge = PltPara.Edges;
          DispStyle = PltPara.DispStyle;
          LineW = PltPara.LineWidth;
          FaceColor = PltPara.FaceColor;
          EdgeColor = PltPara.EdgeColor; 
          Norm = PltPara.Normalization; 
          NormSwitch = PltPara.NormSwitch;
          %SelectedIPTG = PltPara.IPTGSel;
          AxLabel = PltPara.Label; 
          Lim = PltPara.Lim;
                   
          if strcmp(NormSwitch,'weighted')
             
             [~,Edges,Bins] = histcounts(XValues,Edge);
             for i = 1:length(Edges)-1
                NW(i) = sum(RunDur(i == Bins)); %Weighted counts 
             end
       
              RunDistH = histogram('BinEdges',Edges,'BinCounts',NW,'Normalization',Norm,'LineWidth',LineW,...
                         'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
          else
              RunDistH = histogram(XValues,Edge,'Normalization',Norm,'LineWidth',LineW,...
                        'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
          end
          PlotSty(hFig,AxLabel,Lim);
          
end


function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             if iscell(Y)
                %check what's inside Y 
                if iscell(Y{1})
                   R{i,2} = cell2mat(cellfun(@(x) cell2mat(x),Y(Mask),'UniformOutput',0));
                else
                   R{i,2} = cell2mat(Y(Mask)); 
                end
             else
                R{i,2} = Y(Mask); 
             end
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

function SortandPutLeg(P,Handles,Labels)
         [~,LegendOrder] = sort(cell2mat(P(:,1)));
         legend([Handles{LegendOrder}],Labels{LegendOrder},'Location','NorthEast')
end
    