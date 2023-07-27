%% Plot angular distributions
% May 2020 by Ercag
% 
% Revised on October 2021 by Ercag

clear all;
close all;
%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\AngularAnalysis';
%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
StrainLabels = {'KMT47'};
Lambda = 0.5;
%% Define Histogram Parameters

%Define bins
HistPara.Edges = 0:4:180; 
HistPara.LineWidth = 2.0; 
HistPara.DisplayStyle = 'stairs'; 
HistPara.XLabel = 'Turn Angle (degrees)';
HistPara.YLabel = 'Counts/sec.';
HistPara.XLim = [0, 180];

IPTG_X = [0, 60, 100, 1000]; 
%% Plot the normalized turn angle counts

fps = 30; %Hz
ColorMap_IPTG = linspecer(length(IPTG_X),'qualitative');

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),2);
    TurnDur = cell(length(Files),2);

    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        
        TurnAngle{i,1} = IPTG(i);
        TurnAngle{i,2} = Results.Ang(:,3); %note: all turn angles are already filtered
        TurnDur{i,1} = IPTG(i); 
        TurnDur{i,2} = TurnBreakDown(Speeds,Results.T,Results.minV,Results.minT,fps);                      
    end
    
    hFig = figure(j)
    for k = 1:length(IPTG_X)
        Mask = [TurnAngle{:,1}] == IPTG_X(k);
       
        TurnAngle_Subset = TurnAngle(Mask,:); 
        TurnDur_Subset = TurnDur(Mask,:); 
        
        %Normalization factor
        HistPara.Norm_Fac = sum(cell2mat(cellfun(@cell2mat ,TurnDur_Subset(:,2) ,'UniformOutput' ,false))); 
        HistPara.Title = StrainLabels{j};
        
        %Set the color
        HistPara.Color = ColorMap_IPTG(k,:); 
        
        All_TurnAngle = cell2mat(cellfun(@cell2mat ,TurnAngle_Subset(:,2) ,'UniformOutput' ,false));
        IPTG_X(k)
        hist_H{k} = AngleDist(All_TurnAngle,HistPara,hFig);
        hold on                
    end
    hold off 
    IPTG_Str = cellfun(@(x) [x ' \mu{}M'],cellfun(@num2str,arrayfun(@num2cell,IPTG_X),'UniformOutput',false),'UniformOutput',false);
    pLeg = legend([hist_H{1:end}],IPTG_Str,'Location','NorthWest'); 
    pLeg.FontSize = 11; 
    pLeg.FontName = 'Arial';
    
    ExpFig(hFig,StrainLabels{j},ExpPath)
    
    
end
%% Functions

function AnglePlotH = AngleDist(X,PltPara,hFig)
         
         Edges = PltPara.Edges;
         DisplayStyle = PltPara.DisplayStyle;
         LineWidth = PltPara.LineWidth;
         NormFac = PltPara.Norm_Fac;
         Color = PltPara.Color;
         
         [N,~,~] = histcounts(X,Edges);
                 
         NewCount = N./NormFac; 
         
         AnglePlotH = histogram('BinEdges',Edges,'BinCounts',NewCount,'DisplayStyle',DisplayStyle,...
                               'LineWidth',LineWidth,'EdgeColor',Color);
         
         figure(hFig);
         ax = gca; 
         ax.Title.String = PltPara.Title;
         ax.XLabel.String = PltPara.XLabel; 
         ax.YLabel.String = PltPara.YLabel;
         ax.XLim = PltPara.XLim;
         %ax.YLim = PltPara.YLim; 
         ErcagGraphics
         %settightplot(ax); 
         
         hFig.Position = [1000 797 683 541]; 
         
         
end

function ExpFig(hf,StrainLab,ExpPath)
         %Time stamp for the PNG/PDF files
         Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];
                        
         FullFileName = [Stamp num2str(StrainLab) '_TurnAngles_Combined'];
             
         if ~exist(ExpPath,'dir')
            mkdir(ExpPath)
         end   
         
         printfig(hf,fullfile(ExpPath,FullFileName),'-dpng');
         printfig(hf,fullfile(ExpPath,FullFileName),'-dpdf');
         savefig(hf,fullfile(ExpPath,FullFileName));
end