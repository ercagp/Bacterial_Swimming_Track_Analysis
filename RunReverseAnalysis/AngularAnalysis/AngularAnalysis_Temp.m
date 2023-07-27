%% Plot angular distributions 
% May 2020 by Ercag
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\AngularAnalysis\Distributions';
%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%% Define Histogram Parameters  
%Define bins
HistPara.Bins = 0:2:180; 
HistPara.LineWidth = 1.5; 
%Selected IPTG value
%HistPara.IPTGSel = 25; %[uM]
kSelect = 1; %Selected index for a particular [IPTG] 
HistPara.Normalization = 'count';
HistPara.NormSwitch = 'NormalizeCounts'; 
HistPara.DisplayStyle = 'Stairs'; 
HistPara.Label.XAx = 'Turn Angle (degrees)';
if strcmp(HistPara.NormSwitch,'PDF')
   HistPara.Label.YAx = 'PDF'; 
else
   HistPara.Label.YAx = 'Counts/sec';
end
HistPara.Lim.X = [0, 180]; 

%% Define Density Plot Parameters
DensityPlotPara.XEdge = 0:2:180;
DensityPlotPara.YEdge = 0:2:180;
DensityPlotPara.DisplayStyle = 'tile';
DensityPlotPara.Normalization = 'PDF'; 

fps = 30; %Hz
Lambda = 0.5; 

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),1);
    AngleBefore = cell(length(Files),1);
    AngleAfter = cell(length(Files),1);
    EventRate = cell(length(Files),1);
    TrajTime = cell(length(Files),1);

    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG;
        TurnAngle{i} = cell2mat(Results.Ang(:,3));
        AngleBefore{i} = TurnAngle{i}(1:end-1); 
        AngleAfter{i} = TurnAngle{i}(2:end); 
        EventRate{i} = RunReverse.EventRate;
        
        SpeedsFlt = filterout(Speeds,Results.minT,Results.minV,fps);
        
        TrajTime{i} = sum(cellfun(@(x) length(x(:,1))./fps,SpeedsFlt)); 
    end
    
    TurnA = matchrepeat(IPTG,TurnAngle);
    AngleBR = matchrepeat(IPTG,AngleBefore); 
    AngleAR = matchrepeat(IPTG,AngleAfter); 
    EventRt = matchrepeat(IPTG,EventRate);
    TrajT = matchrepeat(IPTG,TrajTime); 
    
    ERavg = cellfun(@mean,EventRt(:,2));
    %Create a cell to store IPTG values for the figure's legend 
    IPTG_TurnAngle = cell(1,size(TurnA,1)); 
    %Label for the figure's title
    HistPara.Label.Title = StrainLabels{j}; 
    DensityPlotPara.StrainLabel = StrainLabels{j}; 

    %Create a cell to store histogram obj
    TurnAngleHist = cell(1,size(TurnA,1));
    
    for k = 1:size(TurnA,1)

        IPTG_TurnAngle{k} = strcat(num2str(TurnA{k,1}),' \muM'); 
        %TurnAngle = TurnA{k,2}; 
        %TrajTime = TrajT{k,2}; 
        
        %Angle.BeforeR = AngleBR{k,2};
        %Angle.AfterR = AngleAR{k,2}; 
        %IPTG_AngBA = AngleBR{k,1}; 

        %hf = figure(k);
        %TurnAngleHist{k} = AngleDist(TurnAngle,TrajTime,HistPara,hf);
        %hold on 
        
        %hfDensityPlt = figure(3*length(StrainLabels)+k+((j-1)*size(TurnA,1)));
        
        %AngleBeforeAfterRun(Angle,IPTG_AngBA,DensityPlotPara)
        %printfig(hfDensityPlt,fullfile(ExpPath,['[20201108]' StrainLabels{j} '_[IPTG]_' num2str(IPTG_AngBA) 'uM_AngleBeforeRunAfterRun.pdf']),'-dpdf')
    end
    hf_CmpStr = figure(1); 
    TurnAngleSelect = TurnA{kSelect,2};
    TrajTime = TrajT{kSelect,2};
    HistPara.Label.Title = IPTG_TurnAngle{kSelect}; 
    TAHist_CmpStr{j} = AngleDist(TurnAngleSelect,TrajTime,HistPara,hf_CmpStr); 
    hold on 
    
    
    %figure(hf)
    %settightplot(gca); 
    %[~,LegendOrder] = sort(cell2mat(TurnA(:,1)));
    %legend([TurnAngleHist{LegendOrder}],IPTG_TurnAngle(LegendOrder),'Location','NorthWest')
    %printfig(hf,fullfile(ExpPath,['[20201108]' StrainLabels{j} '_TurnAngles.pdf']),'-dpdf')

end

legend([TAHist_CmpStr{1:end}],StrainLabels{1:end},'Location','NorthWest')
printfig(hf_CmpStr,fullfile(ExpPath,['[20201120]StrainCmp_[IPTG]_' num2str(TurnA{kSelect,1}) 'uM_TestTurnAngles.pdf']),'-dpdf')
printfig(hf_CmpStr,fullfile(ExpPath,['[20201120]StrainCmp_[IPTG]_' num2str(TurnA{kSelect,1}) 'uM_TestTurnAngles.png']),'-dpng')


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


function AnglePlotH = AngleDist(X,TrajT,PltPara,hFig)
         
         Edge = PltPara.Bins;
         DisplayStyle = PltPara.DisplayStyle;
         LineWidth = PltPara.LineWidth;
         Normalization = PltPara.Normalization; 
         NormSwitch = PltPara.NormSwitch;
         %SelectedIPTG = PltPara.IPTGSel;
         AxLabel = PltPara.Label; 
         Lim = PltPara.Lim;
        
        if strcmp(NormSwitch,'NormalizeCounts')
           [histC, Edges]= histcounts(X,Edge,'Normalization','count');  
           newVals = histC./sum(TrajT); %Counts per total trajectory time / mean event rate
        
           AnglePlotH = histogram('BinEdges',Edges,'BinCounts',newVals,'DisplayStyle',DisplayStyle,...
                             'LineWidth',LineWidth);
        else

           AnglePlotH = histogram(X,Edge,'Normalization',Normalization,'DisplayStyle',DisplayStyle,...
                                 'LineWidth',LineWidth);
                             
        end
        PlotSty(hFig,AxLabel,Lim);
end


function SSubset = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         MaskTraj = medV > minV & TotalTime > minT;
         SSubset = S(MaskTraj); 
         
end
function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             if iscell(Y)
                R{i,2} = cell2mat(Y(Mask)); 
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



