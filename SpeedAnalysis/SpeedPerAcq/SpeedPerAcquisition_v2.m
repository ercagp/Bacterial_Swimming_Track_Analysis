%% Speed distributions per acquisition 
% v2 by Ercag 
% Release notes: "switch" mode was added to select mean, median or inst.
% speed distributions 
% January 2021 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/SpeedAnalysis/SpeedPerAcquisition'; %'F:\Dropbox\Research\NikauBackup\Data\SpeedAnalysis\SpeedPerAcquisition';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data/'; %'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\'; %Call the "Speeds" matrix from the run-reverse data
StrainLabels = {'KMT53'}; 

%% User query to select which type of observable to plot 
disp('Which observable to plot?')
disp('1-)Instantaneous Speed')
disp('2-)Mean Speed')
disp('3-)Median Speed')
prompt = 'Enter the number of the observable to plot:\n'; 
n_Query = input(prompt); 

if n_Query  == 1 
   observable = 'instV';
elseif n_Query == 2 
    observable = 'meanV';
elseif n_Query == 3
    observable = 'medianV'; 
end
%% Parameters
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5;

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

%RegExp Keys
RegKeyROI = 'ROI[_]\d';
RegKeyVD = ['(?<=Data' filesep ')\d*'];

%Define Colormap 
ColorMap = linspecer(2,'Sequential');

% Define Histogram Parameters
PltPara.Normalization = 'PDF';
PltPara.FaceColor = ColorMap(2,:); 
PltPara.EdgeColor = ColorMap(1,:) ; 
PltPara.Edges = 0:5:200; 
PltPara.Lim.X = [0 200]; 
if strcmp(PltPara.Normalization,'count')
    PltPara.Label.YAx = 'counts';
else 
    PltPara.Label.YAx = 'PDF';
end

%% Load files and start the analysis 
for j = 1:length(StrainLabels)
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
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
        %Trajectory durations 
        TrajDur = cellfun(@(x) length(x(:,1))./fps,Speeds_Flt{i}); 
        %Plot's title
        PltPara.Label.Title = {[StrainLabels{j} ' - ' VideoDates{i}], [num2str(IPTG(i)) ' \muM [IPTG] - ' ROI{i}]}; 
        hFig = figure(i);
   
        switch observable 
            case 'instV'
                  instV = cell2mat(cellfun(@(x) x(:,9), Speeds_Flt{i}, 'UniformOutput', false)); 
                  %Plot histogram
                  histogram(instV,PltPara.Edges,'Normalization',PltPara.Normalization,... 
                        'DisplayStyle','stairs','EdgeColor',PltPara.EdgeColor,'LineWidth',1.5);
                  %X-axis label 
                  PltPara.Label.XAx = 'Instantaneous Speed (\mum/sec)'; 
                
                  PlotSty(hFig,PltPara.Label,PltPara.Lim);
                  %Define export path 
                  FinalExpPath = fullfile(ExpPath,'InstSpeedPerAcq',StrainLabels{j}); 
                  if ~exist(FinalExpPath,'dir')
                    mkdir(FinalExpPath)
                  end
                  
                  FileLabel = 'InstV';
          
            case 'meanV'
                  meanV = cellfun(@(x) nanmean(x(:,9)),Speeds_Flt{i});
                  X.X = meanV; 
                  X.TrajDur = TrajDur;
                  PltPara.Label.XAx = 'Mean Speed (\mum/sec)';
                  Hist = SpeedDist(X,PltPara,hFig); 
                  %Define export path 
                  FinalExpPath = fullfile(ExpPath,'MeanSpeedPerAcq',StrainLabels{j}); 
                  if ~exist(FinalExpPath,'dir')
                    mkdir(FinalExpPath)
                  end
                  
                  FileLabel = 'MeanV';
                  legend([Hist{1:end}],{'Weighted','Native'},'FontSize',10);
            case 'medianV'
                  medV = cellfun(@(x) nanmedian(x(:,9)),Speeds_Flt{i});
                  X.X = medV; 
                  X.TrajDur = TrajDur;
                  PltPara.Label.XAx = 'Median Speed (\mum/sec)';
                  Hist = SpeedDist(X,PltPara,hFig); 
                  %Define export path 
                  FinalExpPath = fullfile(ExpPath,'MedianSpeedPerAcq',StrainLabels{j}); 
                  if ~exist(FinalExpPath,'dir')
                      mkdir(FinalExpPath)
                  end
                  FileLabel = 'MedV';
                  legend([Hist{1:end}],{'Weighted','Native'},'FontSize',10);
        end
        printfig(hFig,fullfile(FinalExpPath,... 
             [Stamp StrainLabels{j} '_' FileLabel '_PerAcq_' VideoDates{i} '_VideoDate_' 'IPTG_' num2str(IPTG(i)) 'uM_' ROI{i}]),...
             '-dpng')
        printfig(hFig,fullfile(FinalExpPath,... 
             [Stamp StrainLabels{j} '_' FileLabel '_PerAcq_' VideoDates{i} '_VideoDate_' 'IPTG_' num2str(IPTG(i)) 'uM_' ROI{i}]),...
             '-dpdf') 
    end
    close all; 
end

%% Functions

function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
end

function DistH = SpeedDist(X,PltPara,hFig)
          TrajDur = X.TrajDur; %for weighing mean/median speeds
          XValues = X.X;   
           
          Edge = PltPara.Edges;
          FaceColor = PltPara.FaceColor;
          EdgeColor = PltPara.EdgeColor; 
          Norm = PltPara.Normalization; 
          AxLabel = PltPara.Label; 
          Lim = PltPara.Lim;
                  
         [~,EdgeOut,Bins] = histcounts(XValues,Edge);
         for k = 1:length(EdgeOut)-1 
             NewCount(k) = sum(TrajDur(Bins == k)); 
         end
            
     
          %Weighted values 
          DistH{1} = histogram('BinEdges',Edge,'BinCounts',NewCount,'Normalization',Norm,'LineWidth',2.5,...
                           'DisplayStyle','stairs','EdgeColor',EdgeColor);
          hold on              
          %Native values 
          DistH{2} = histogram(XValues,Edge,'Normalization',Norm,... 
                        'DisplayStyle','bar','FaceColor',FaceColor);
          
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



