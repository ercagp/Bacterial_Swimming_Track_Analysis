%% Density plot for correlation between run-time before turn & after turn for single acquisition 
%November 2020
%by Ercag
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
%Frames per second 
fps = 30; %Hz

%Histogram parameters
YEdge = 0:3/fps:2;
XEdge = 0:3/fps:2;  



%Plot parameters 
Lab.XAx = 't_{before turn} (sec)';
Lab.YAx = 't_{after turn} (sec)'; 

RegKey= [ '\[' VideoDate '\]' StrainLabel];
RegKeyROI = 'ROI[_]\d'; 

%Call all the .mat files of the run-reverse analysis results
Files = callResults(MainPath, StrainLabel);
%Find files of the target strain and videodate 
SubFiles = Files(~cellfun(@isempty,regexp(Files,RegKey,'once'))); 

for i = 1:length(SubFiles)
    
    load(SubFiles{i})
    
    %Find IPTG and ROI labels of the target file 
    ROI = regexp(SubFiles{i},RegKeyROI,'match','once');   
    IPTG = RunReverse.Info.IPTG; 
    
    RunDur = GetRunTimes(Results,Speeds,fps); 
    
    %<V>_run vs. t_run
    RunDurBefore = RunDur(1:end-1);
    RunDurAfter = RunDur(2:end); 

    %plot 
    hf = figure(i);
        
    histogram2(RunDurBefore,RunDurAfter,XEdge,YEdge,'DisplayStyle','tile',...
            'ShowEmptyBins','on','Normalization','PDF'); 
    colorbar
    %Title of each plot
    Lab.Title = {StrainLabel,['[IPTG] = ' num2str(IPTG) ' \muM']};
    %Impose style
    PlotSty(hf,Lab);
    %Define Target Export Path 
    ExpPath = fullfile(GenExpPath,VideoDate,[StrainLabel '_' num2str(IPTG) 'uM'],ROI,'Correlations','RunTimeBeforeAfterTurn');
    if ~exist(ExpPath,'dir')
       mkdir(ExpPath)
    end
    
    printfig(hf,fullfile(ExpPath,[LHead '[DensityPlot]' StrainLabel '_RunTimeBeforeAfterTurn_[IPTG]_' num2str(IPTG) '_uM_' ROI]),FigFormat)
end


%% Functions

function RunDur = GetRunTimes(Results,Speeds,fps)
         minT = Results.minT;
         minV = Results.minV; 
         T = Results.T; 

         RunCell = RunBreakDown(Speeds,T,minV,minT,fps);
         RunMat = cell2mat(RunCell); 
         %Run durations 
         RunDur = RunMat(:,1);
end
function PlotSty(hFig,Lab)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
%          ax.XLim = Lim.X;
%          ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end
