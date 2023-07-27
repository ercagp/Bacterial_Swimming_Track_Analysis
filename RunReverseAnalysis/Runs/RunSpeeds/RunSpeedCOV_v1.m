%% Find the coefficient of variation in run speeds (dispersion of run speeds)
% as function of average speeds
% v1 by Ercag
% December 2020
clearvars;
close all;
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/SpeedAnalysis/StatisticalCheck/RunSpeedCOV';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT47'}; 

%% Parameters
%Input
XEdge = 20:10:150; 
YEdge = 0:0.05:1.2;
%Plot parameters
PltPara.DispStyle = 'tile';
PltPara.Norm = 'PDF'; 
PltPara.Label.YAx = '\sigma(V)/<V>'; 
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
% InstRunSpeed = cell(length(Files),1);
% MeanRunSpeed = cell(length(Files),1);
% RunDur = cell(length(Files),1); 
%Temp = [];

    
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
        RunCell{i} = RunBreakDownv5(Speeds,T,fps);  %RunBreakDownv4(S,T,fps) --> The order
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        RunCell_Flt{i} = RunCell{i}(FilterMask,:); 
        
        %STD of each run : the 4th column of RunCell{i}(:,2)
        %Mean V of each run: the 2nd column of RunCell{i}(:,2) 
        %COV: Coefficient of variation for each run (STD/<V>)
        RunMat = RunCell_Flt{i}(:,2);
        STD = cell2mat(cellfun(@(x) x(:,4), RunMat, 'UniformOutput', false));
        MeanV = cell2mat(cellfun(@(x) x(:,2), RunMat, 'UniformOutput', false));
        COV = STD./MeanV; 
        
        figure(i)
%       plot(MeanV,COV,'.','MarkerSize',6);         
        X.XEdge = XEdge;
        Y.YEdge = YEdge; 
        X.X = MeanV; 
        Y.Y = COV; 
        
        
        PltPara.Label.Title = {[StrainLabels{1} ' - ' VideoDates{i}], [num2str(IPTG(i)) ' \muM [IPTG], ' ROI{i}]}; 
        hFig = figure(i);
        DensityH = COVDensity(X,Y,PltPara,hFig); 
        drawnow()
        
        %Pearson correlation 
        rho(i) = corr(MeanV(~isnan(COV)),COV(~isnan(COV)));
        display(['rho = ' num2str(rho(i))]); 
        
        %Print out figures
        printfig(hFig,fullfile(ExpPath,...
           ['[20201217]' StrainLabels{1} '_COV_v1_' VideoDates{i} '_VideoDate_' 'IPTG_' num2str(IPTG(i)) 'uM_' ROI{i}]),...
           '-dpng')
       
        printfig(hFig,fullfile(ExpPath,...
           ['[20201217]' StrainLabels{1} '_COV_v1_' VideoDates{i} '_VideoDate_' 'IPTG_' num2str(IPTG(i)) 'uM_' ROI{i}]),...
           '-dpdf')
              
        
%         InstRunSpeed{i} = cell2mat(RunCell_Flt{i}(:,1)); 
%         Temp = cell2mat(RunCell_Flt{i}(:,2)); 
%         %Duration of each run 
%         RunDur{i} = Temp(:,1);
%         %Mean speeds of runs 
%         MeanRunSpeed{i} = Temp(:,2); 
end


%% Functions     

function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
end



function COVDensityH = COVDensity(X,Y,PltPara,hFig)

         XValues = X.X;   
         YValues = Y.Y;
         XEdge = X.XEdge; 
         YEdge = Y.YEdge; 
          
         DispStyle = PltPara.DispStyle;
         Norm = PltPara.Norm; 
         %SelectedIPTG = PltPara.IPTGSel;
         AxLabel = PltPara.Label;
          

         COVDensityH = histogram2(XValues,YValues,XEdge,YEdge,'Normalization',Norm,...
                              'ShowEmptyBins','on','DisplayStyle',DispStyle);
         colorbar;       
         PlotSty(hFig,AxLabel);
end


function PlotSty(hFig,Lab)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         %ax.XLim = Lim.X;
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end
