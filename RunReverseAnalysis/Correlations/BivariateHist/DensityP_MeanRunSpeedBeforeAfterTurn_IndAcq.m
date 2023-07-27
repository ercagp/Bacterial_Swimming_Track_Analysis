%% Plot bivariate histogram of mean run speeds before and turn for single acquisition 
%note that ALL turning angles are included! 
%by Ercag
%May 2020 
clearvars;
close all; 

%% Define Export Path for figures
GenExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabel = 'KMT43';
VideoDate = '20200803'; 
%Set label head for PDF & PNG files 
Date = datetime; 
LHead = ['[' num2str(year(Date)) num2str(month(Date)) sprintf('%02d',day(Date)) ']'];
FigFormat = '-dpng'; 

Lab.XAx = '<V_{Run}>_{BeforeTurn} (\mum/sec)';
Lab.YAx = '<V_{Run}>_{AfterTurn} (\mum/sec)';
YEdge = 0:5:150;
XEdge = 0:5:150;  
BinArray = 30;
fps = 30;%Hz

RegKey= [ '\[' VideoDate '\]' StrainLabel];
RegKeyROI = 'ROI[_]\d'; 

%Call all the .mat files of the run-reverse analysis results
Files = callResults(MainPath, StrainLabel);
%Find files of the target strain and videodate 
SubFiles = Files(~cellfun(@isempty,regexp(Files,RegKey,'once'))); 

    
for i = 1:length(SubFiles)
    %Find IPTG and ROI labels of the target file 
    ROI = regexp(SubFiles{i},RegKeyROI,'match','once');   
    
    load(SubFiles{i})
    IPTG = RunReverse.Info.IPTG; 

    MeanRunSpeeds = GetRuns(Results,Speeds,fps); 
    RunBeforeTurn = MeanRunSpeeds(1:end-1);
    RunAfterTurn = MeanRunSpeeds(2:end);
    
    hf = figure(i);
       
    histogram2(RunBeforeTurn,RunAfterTurn,XEdge,YEdge,'DisplayStyle','tile',...
            'ShowEmptyBins','on','Normalization','PDF'); 
    colorbar
         
    Lab.Title = {StrainLabel,['[IPTG] = ' num2str(IPTG) ' \muM']};
    PlotSty(hf,Lab);
    
    %Define Target Export Path 
    ExpPath = fullfile(GenExpPath,VideoDate,[StrainLabel '_' num2str(IPTG) 'uM'],ROI,'Correlations','MeanRunSpeedBeforeAfterTurn');
    if ~exist(ExpPath,'dir')
       mkdir(ExpPath)
    end
        
    printfig(hf,fullfile(ExpPath,[LHead '[DensityPlot]' StrainLabel '_MeanSpeedBeforeAfterTurn_[IPTG]_' num2str(IPTG) '_uM_' ROI]),FigFormat)
end
  
%% Functions     

function MeanRunSpeeds = GetRuns(Results,Speeds,fps)
         minT = Results.minT;
         minV = Results.minV; 
         T = Results.T; 

         RunCell = RunBreakDown(Speeds,T,minV,minT,fps);
         RunMat = cell2mat(RunCell); 
         %Mean speed of runs 
         MeanRunSpeeds = RunMat(:,2);
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

