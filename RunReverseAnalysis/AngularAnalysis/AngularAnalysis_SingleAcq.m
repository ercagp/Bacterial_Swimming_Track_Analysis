%% Plot angular distributions 
% May 2020 by Ercag
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/AngularAnalysis/SingleAcquisitions/Distributions';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT47'};
Lambda = 0.5; 

%% ColorMap for different strains 
ColorMap{1} = [0 0.45 0.74]; %KMT43
ColorMap{2} = [0.85 0.33 0.10]; %KMT47
ColorMap{3} = [0.93 0.69 0.13]; %KMT53

%% Define Histogram Parameters  
%Define bins
HistPara.Bins = 0:2:180; 
HistPara.LineWidth = 1.5; 
%Selected IPTG value
HistPara.IPTGSel = 75; %[uM]
HistPara.Normalization = 'count';
HistPara.NormSwitch = 'Normalized'; 
HistPara.DisplayStyle = 'Stairs';
HistPara.LineColor = ColorMap{2}; 
HistPara.Label.XAx = 'Turn Angle (degrees)';
if strcmp(HistPara.NormSwitch,'PDF')
   HistPara.Label.YAx = 'PDF'; 
else
   HistPara.Label.YAx = 'Counts';
end
HistPara.Lim.X = [0, 180]; 

%% Define Density Plot Parameters
DensityPlotPara.XEdge = 0:2:180;
DensityPlotPara.YEdge = 0:2:180;
DensityPlotPara.DisplayStyle = 'tile';
DensityPlotPara.Normalization = 'PDF'; 

fps = 30; %Hz

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),1);
    AngleBefore = cell(length(Files),1);
    AngleAfter = cell(length(Files),1);
    TrajTime = cell(length(Files),1);
    TotalTrajTime = zeros(length(Files),1);
    IPTG_TurnAngle = cell(length(Files),1);
    
    VideoDates = regexp(Files,'(?<=Data/)\d*','Match','once');
    ROI = regexp(Files,'ROI[_]\d','Match','once');


        

    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG;
        TurnAngle{i} = Results.Ang(:,3); %note: all turn angles are already filtered
        AngleBefore{i} = TurnAngle{i}(1:end-1); 
        AngleAfter{i} = TurnAngle{i}(2:end); 
        TrajTime{i} = cellfun(@(x) length(x(:,1))./fps, Speeds);  
        
        [SpeedsFlt,FiltMask] = filterout(Speeds,Results.minT,Results.minV,fps);
        TotalTrajTime(i) = sum(TrajTime{i}(FiltMask)); 
        IPTG_TurnAngle{i} = strcat(num2str(IPTG(i)),' \muM'); 
        
        TotalDur = TotalTrajTime(i);
        TurnA = cell2mat(TurnAngle{i}); 
        
       
        hf = figure;
        HistPara.Label.Title = {VideoDates{i}, [StrainLabels{j} ' -- [IPTG] = '   IPTG_TurnAngle{i} ' -- ' ROI{i}]};
        AngleDist(TurnA,TotalDur,HistPara,hf)

        printfig(hf,fullfile(ExpPath,['[20201120]' VideoDates{i} '_' StrainLabels{j} '_' num2str(IPTG(i)) 'uM_' ROI{i} '_NormalizedTurnAngles.pdf']),'-dpdf')
        printfig(hf,fullfile(ExpPath,['[20201120]' VideoDates{i} '_' StrainLabels{j} '_' num2str(IPTG(i)) 'uM_' ROI{i} '_NormalizedTurnAngles.png']),'-dpng')
        
        

         if IPTG(i) == HistPara.IPTGSel
            HistPara.Label.Title = [StrainLabels{j} ' -- [IPTG] = '  IPTG_TurnAngle{i}];
            hfSel = figure(100);
            AngleDist(TurnA,TotalDur,HistPara,hfSel)
            hold on 
         end

        
    end

        
        %hfDensityPlt = figure(3*length(StrainLabels)+k+((j-1)*size(TurnA,1)));
        
        %AngleBeforeAfterRun(Angle,IPTG_AngBA,DensityPlotPara)
        %printfig(hfDensityPlt,fullfile(ExpPath,['[20201119]' StrainLabels{j} '_[IPTG]_' num2str(IPTG_AngBA) 'uM_AngleBeforeRunAfterRun.pdf']),'-dpdf')
    
    
    %figure(hf)
    %settightplot(gca); 
    %[~,LegendOrder] = sort(cell2mat(TurnA(:,1)));
    %legend([TurnAngleHist{LegendOrder}],IPTG_TurnAngle(LegendOrder),'Location','NorthWest')

    
end




%% Functions
function DensityPlotH = AngleBeforeAfterRun(Angle,IPTG,DensityPlotPara)
        XEdge = DensityPlotPara.XEdge;
        YEdge = DensityPlotPara.XEdge;
        DisplayStyle = DensityPlotPara.DisplayStyle;
        Normalization = DensityPlotPara.Normalization; 
        StrainLabel = DensityPlotPara.StrainLabel; 
        
        
        %Data
        AngleBeforeRun = Angle.BeforeR; 
        AngleAfterRun = Angle.AfterR; 
        AngleBeforeRunPlt = AngleBeforeRun(1:length(AngleAfterRun));
        
        DensityPlotH = histogram2(AngleBeforeRunPlt,AngleAfterRun,XEdge,YEdge,'DisplayStyle',DisplayStyle,...
            'ShowEmptyBins','on','Normalization',Normalization); 
        
        colorbar
        xlabel('Turn Angle Before Run')
        ylabel('Turn Angle After Run')
        title({StrainLabel,['[IPTG] = ' num2str(IPTG) '\muM']})
end


function AnglePlotH = AngleDist(X,TotalDur,PltPara,hFig)
         
         Edge = PltPara.Bins;
         DisplayStyle = PltPara.DisplayStyle;
         LineWidth = PltPara.LineWidth;
         EdgeColor = PltPara.LineColor;
         Normalization = PltPara.Normalization; 
         NormSwitch = PltPara.NormSwitch;
         SelectedIPTG = PltPara.IPTGSel;
         AxLabel = PltPara.Label; 
         Lim = PltPara.Lim;
        
        if strcmp(NormSwitch,'Normalized')
           [N,Edges] = histcounts(X,Edge);
           BinWidth = Edges(2) - Edges(1); %assuming uniform increase of edges

           N_Norm = N/(BinWidth*sum(TotalDur));
        
            
           AnglePlotH = histogram('BinEdges',Edges,'BinCounts',N_Norm,'DisplayStyle',DisplayStyle,...
                                 'EdgeColor',EdgeColor,'LineWidth',LineWidth);                  
           AxLabel.YAx = 'Counts / Seconds'; 
        else

           AnglePlotH = histogram(X,Bins,'Normalization',Normalization,'DisplayStyle',DisplayStyle,...
                                 'LineWidth',LineWidth);
                             
        end
        PlotSty(hFig,AxLabel,Lim);
end


function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
         
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



