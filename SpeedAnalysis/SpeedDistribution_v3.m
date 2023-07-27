%% Speed distributions from single acquisitions and combined data
% November 2020 
% by Ercag 
clearvars;
clc; close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/SpeedAnalysis';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/'; %Call the "Speeds" matrix from the run-reverse data
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Selected IPTG for the plot 
IPTG_Sel = 100; %uM 
SelInd = 1; 
InstS_Sel_Handle = cell(size(StrainLabels,2),1); 
MeanS_Sel_Handle = cell(size(StrainLabels,2),1); 
fps = 30; %Hz
Lambda = 0.5;

%% Define Histogram Parameters
PltPara.Normalization = 'PDF';
PltPara.NormSwitch = '';
PltPara.DispStyle = 'stairs';
PltPara.FaceColor = 'none'; 
PltPara.LineWidth = 2; 
PltPara.Edges = 0:5:160; 
PltPara.Lim.X = [0 180]; 

if strcmp(PltPara.Normalization,'PDF')
    PltPara.Label.YAx = 'PDF'; 
else
    PltPara.Label.YAx = 'Counts'; 
end

PltParaSelect.Normalization = 'PDF';
PltParaSelect.LineWidth = 2; 
PltParaSelect.Bins = 0:10:160; 
PltParaSelect.Lim.X = [0 160]; 
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
    InstSpeed = cell(length(Files),1);
    MeanSpeed = cell(length(Files),1);
    MedSpeed = cell(length(Files),1); %Median Speed
    TrajDur = cell(length(Files),1); 
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
        %Filter out speeds 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps); 
        InstSpeed{i} = cell2mat(cellfun(@(x) x(:,9), Speeds_Flt{i},'UniformOutput',0)); 
        MeanSpeed{i} = cellfun(@(x) nanmean(x(:,9)), Speeds_Flt{i}, 'UniformOutput',1);
        MedSpeed{i} = cellfun(@(x) nanmedian(x(:,9)), Speeds_Flt{i}, 'UniformOutput',1);
        TrajDur{i} = cellfun(@(x) length(x(:,1))/fps, Speeds_Flt{i}, 'UniformOutput',1); 
    end
    
    InstS = matchrepeat(IPTG,InstSpeed);
    MeanS = matchrepeat(IPTG,MeanSpeed); 
    MedS = matchrepeat(IPTG,MedSpeed); 
    TrajDurS = matchrepeat(IPTG,TrajDur); 
    %Define colormaps for different [IPTG] values
    ColorMap_Edges = linspecer(size(InstS,1),'qualitative');
    %ColorMap_Sel = linspecer(size(StrainLabels,2),'qualitative'); 
    
    IPTGLabel = cell(size(InstS,1),1);
    InstS_Handle = cell(size(InstS,1),1); 
    MeanS_Handle = cell(size(InstS,1),1);
    
    for k = 1:size(InstS,1)
        IPTGLabel{k} = [num2str(InstS{k,1}) '\muM'];
         
        IS.X = InstS{k,2}; %Instantaneous Speeds
        IS.TrajDur = TrajDurS{k,2};
        
%         MS.X = MeanS{k,2}; %Mean Speeds
%         MS.TrajDur = TrajDurS{k,2}; 
        
        %Impose the colormap 
        PltPara.EdgeColor = ColorMap_Edges(k,:);
       
        hf = figure(j);
        %Instantaneous speed distribution 
        PltPara.Label.Title  = {StrainLabels{j}, 'Instantaneous Speed'};
        PltPara.Label.XAx = 'V (\mum/sec)';
        InstS_Handle{k} = SpeedDist(IS, PltPara, hf);
        hold on 
        
%         if InstS{k,1} == IPTG_Sel
%            hf_Sel = figure(1);
%            PltPara.EdgeColor = ColorMap_Sel(SelInd,:);
%            PltPara.Label.Title  = ['Instantaneous Speed @ ' IPTGLabel{k} ' [IPTG]'] ;
%            PltPara.Label.XAx = 'V (\mum/sec)';
%            InstS_Sel_Handle{SelInd} = SpeedDist(IS, PltPara, hf_Sel);
%            hold on 
%            SelInd = SelInd + 1; 
%         end
        
%         if MeanS{k,1} == IPTG_Sel
%            hf_Sel = figure(1);
%            PltPara.EdgeColor = ColorMap_Sel(SelInd,:);
%            PltPara.Label.Title  = ['Weighted Mean Speed @ ' IPTGLabel{k} ' [IPTG]'] ;
%            PltPara.Label.XAx = 'V (\mum/sec)';
%            MeanS_Sel_Handle{SelInd} = SpeedDist(MS, PltPara, hf_Sel);
%            hold on 
%            SelInd = SelInd + 1; 
%         end
        
        %Mean speed distribution
        %if strcmp(PltPara.NormSwitch,'weighted')
        %   PltPara.Label.Title  = {StrainLabels{j}, 'Weighted Mean Speed'}; 
        %else
        %    PltPara.Label.Title  = {StrainLabels{j}, 'Mean Speed'};
        %end
        %PltPara.Label.XAx = '<V> (\mum/sec)';
        %MeanS_Handle{k} = SpeedDist(MS, PltPara, hf);
        %hold on 

    end
    figure(hf)
    
    SortandPutLeg(InstS,InstS_Handle,IPTGLabel); 
    drawnow(); 
    %printfig(hf,fullfile(ExpPath,['[20201129][InstantaneousSpeed]' StrainLabels{j} '.pdf']),'-dpdf');
    %printfig(hf,fullfile(ExpPath,['[20201129][InstantaneousSpeed]' StrainLabels{j} '.png']),'-dpng');

    %SortandPutLeg(MeanS,MeanS_Handle,IPTGLabel); 
    %drawnow(); 
    %printfig(hf,fullfile(ExpPath,['[20201129][WeightedPopulationMeanSpeed]' StrainLabels{j} '.pdf']),'-dpdf');
    %printfig(hf,fullfile(ExpPath,['[20201129][WeightedPopulationMeanSpeed]' StrainLabels{j} '.png']),'-dpng');                     
end
%legend([InstS_Sel_Handle{1:end}],StrainLabels,'Location','NorthEast')
%printfig(hf_Sel,fullfile(ExpPath,['[20201129][SelectedInstSpeed][IPTG]_' num2str(IPTG_Sel) 'uM.pdf']),'-dpdf');
%printfig(hf_Sel,fullfile(ExpPath,['[20201129][SelectedInstSpeed][IPTG]_' num2str(IPTG_Sel) 'uM.png']),'-dpng');

legend([MeanS_Sel_Handle{1:end}],StrainLabels,'Location','NorthEast')
printfig(hf_Sel,fullfile(ExpPath,['[20201129][SelectedWeightedMeanSpeed][IPTG]_' num2str(IPTG_Sel) 'uM.pdf']),'-dpdf');
printfig(hf_Sel,fullfile(ExpPath,['[20201129][SelectedWeightedMeanSpeed][IPTG]_' num2str(IPTG_Sel) 'uM.png']),'-dpng');

%% Functions     
function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1))/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask);
end

function DistH = SpeedDist(X,PltPara,hFig)

%         The input has now two components  
          TrajDur = X.TrajDur; %for weighing mean speeds
          XValues = X.X;   
           
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
                NW(i) = sum(TrajDur(i == Bins)); %Weighted counts 
             end
       
              DistH = histogram('BinEdges',Edges,'BinCounts',NW,'Normalization',Norm,'LineWidth',LineW,...
                         'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
          else
              DistH = histogram(XValues,Edge,'Normalization',Norm,'LineWidth',LineW,...
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