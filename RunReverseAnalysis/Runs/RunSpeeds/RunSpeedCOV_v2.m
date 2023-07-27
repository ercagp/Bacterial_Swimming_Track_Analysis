%% Find the coefficient of variation in run speeds (dispersion of run speeds)
% as function of average speeds
% v2 by Ercag (Binned version) 
% December 2020
clearvars;
close all;
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/SpeedAnalysis/StatisticalCheck/RunSpeedCOV';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT53'}; 
SInd = 3; 

%% Parameters
%Input
XEdge = 20:10:150; 
%Plot parameters
PltPara.DispStyle = 'stairs';
PltPara.FaceColor = 'none';
ColorMap = linspecer(3,'qualitative');
PltPara.LineWidth = 2; 
PltPara.Edges = XEdge; 
PltPara.Lim.X = [XEdge(1) XEdge(end)]; 
PltPara.Label.YAx = '\sigma(V/<V>)'; 
PltPara.Label.XAx = 'Mean Speed (\mum/s)'; 

%RegExp Keys
RegKeyROI = 'ROI[_]\d';
RegKeyVD = '(?<=Data/)\d*';

%Imaging and ADMM Parameters
fps = 30; %Hz
Lambda = 0.5; 
%% Load files and start the analysis 
Files = callResultsv2(MainPath, StrainLabels{1},Lambda);
%Find ROIs and Video dates
VideoDates = regexp(Files,RegKeyVD,'match','once');
ROI = regexp(Files,RegKeyROI,'match','once');

%Preallocate
IPTG = zeros(length(Files),1);
Speeds_Flt = cell(length(Files),1);
RunCell = cell(length(Files),1);
RunCell_Flt = cell(length(Files),1);
    
   
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
        RunCell{i} = RunBreakDownv6(Speeds,T,fps);
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        RunCell_Flt{i} = RunCell{i}(FilterMask,:); 
        
        
        
        InstV = RunCell_Flt{i}(:,1); 
        OnlyStatV = RunCell_Flt{i}(:,2);
        jEnd = length(XEdge)-1;
        
        for j = 1:jEnd
            if j == jEnd
                log_Stat = cellfun(@(X) (X >= XEdge(j)) & (X <= XEdge(j+1)) ,OnlyStatV,'UniformOutput',false);
            else
                log_Stat = cellfun(@(X) (X >= XEdge(j)) & (X < XEdge(j+1)) ,OnlyStatV,'UniformOutput',false);
            end
            
            for k = 1:size(InstV,1)
                logMat = log_Stat{k}(:,2);
                
                V = InstV{k}(logMat);
                meanV = OnlyStatV{k}(logMat,2);
                NormV = [];
                for l = 1:size(meanV,1)
                    NormV = [NormV; V{l}./meanV(l)];
                end
                
                NV{k,1} = NormV;
            end
            
            STD(j,1)= std(cell2mat(NV),'omitnan');
        end
        
%         if sum(isnan(STD)) > 0
%            
%            NaNInd = find(isnan(STD));
%            XEdge(NaNInd + 1) = []; 
%            
%            STD = STD(~isnan(STD)); 
%         end
        
       hFig = figure(i);
       PltPara.EdgeColor = ColorMap(SInd,:);
       PltPara.Label.Title = {[StrainLabels{1} ' - ' VideoDates{i}], [num2str(IPTG(i)) ' \muM [IPTG], ' ROI{i}]}; 
       STDDist(XEdge,STD,PltPara,hFig)
       printfig(hFig,fullfile(ExpPath,...
           ['[20201217]' StrainLabels{1} '_COV_v2_' VideoDates{i} '_VideoDate_' 'IPTG_' num2str(IPTG(i)) 'uM_' ROI{i}]),...
           '-dpng')
       
       printfig(hFig,fullfile(ExpPath,...
           ['[20201217]' StrainLabels{1} '_COV_v2_' VideoDates{i} '_VideoDate_' 'IPTG_' num2str(IPTG(i)) 'uM_' ROI{i}]),...
           '-dpdf')
end  

%% Functions     

function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
end


function STDDistH = STDDist(X,Y,PltPara,hFig)

          XValues = X;   
          YValues = Y; 
          
          DispStyle = PltPara.DispStyle;
          LineW = PltPara.LineWidth;
          FaceColor = PltPara.FaceColor;
          EdgeColor = PltPara.EdgeColor; 
          %SelectedIPTG = PltPara.IPTGSel;
          AxLabel = PltPara.Label; 
          Lim = PltPara.Lim;
                   

          STDDistH = histogram('BinEdges',XValues,'BinCounts',YValues,'LineWidth',LineW,...
                              'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
         
          PlotSty(hFig,AxLabel,Lim);
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