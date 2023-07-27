%% Speed distributions per acquisition 
% v1 by Ercag 
% December 2020 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/SpeedAnalysis/SpeedPerAcquisition/MeanSpeedPerAcq';
%% Call the run reverse analysis files (Note that they also contain 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT43'}; 

%% Parameters
%Input
XEdge = 20:10:160; 
PltLabel.XAx =  'Mean Speed (\mum/s)'; 
PltLabel.YAx = 'Counts'; 
PltLim.X = [XEdge(1) XEdge(end)]; 

%RegExp Keys
RegKeyROI = 'ROI[_]\d';
RegKeyVD = '(?<=Data/)\d*';

%Imaging and ADMM Parameters
fps = 30; %Hz
Lambda = 0.5;

%Define Color map 
ColorMap = linspecer(2,'qualitative');

%% Load files and start the analysis 
Files = callResultsv2(MainPath, StrainLabels{1},Lambda);
%Find ROIs and Video dates
VideoDates = regexp(Files,RegKeyVD,'match','once');
ROI = regexp(Files,RegKeyROI,'match','once');

%Preallocate
IPTG = zeros(length(Files),1);
Speeds_Flt = cell(length(Files),1);

for i = 1:length(Files) 
        load(Files{i}) 
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        
        meanV = cellfun(@(x) nanmean(x(:,9)),Speeds_Flt{i});
        TrajDur = cellfun(@(x) length(x(:,1))./fps,Speeds_Flt{i}); 
        
        [N,Edge,Bins] = histcounts(meanV,XEdge);
        for k = 1:length(XEdge)-1 
            NewCount(k) = sum(TrajDur(Bins == k)); 
        end
        hf = figure(i);
        hist_w = histogram('BinEdges',XEdge,'BinCounts',NewCount,'DisplayStyle','stairs','EdgeColor',ColorMap(1,:),'LineWidth',1.5);
        drawnow()
        hold on 
        hist = histogram(meanV,XEdge,'DisplayStyle','bar','EdgeColor',ColorMap(2,:));
        PltLabel.Title = {[StrainLabels{1} ' - ' VideoDates{i}], [num2str(IPTG(i)) ' \muM [IPTG], ' ROI{i}]}; 
        legend([hist_w, hist],{'Weighted','Native'});
        
        PlotSty(hf,PltLabel,PltLim);
        
        printfig(hf,fullfile(ExpPath,...
           ['[20201217]' StrainLabels{1} '_MeanV_PerAcq_' VideoDates{i} '_VideoDate_' 'IPTG_' num2str(IPTG(i)) 'uM_' ROI{i}]),...
           '-dpng')

end


%% Functions

function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
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



