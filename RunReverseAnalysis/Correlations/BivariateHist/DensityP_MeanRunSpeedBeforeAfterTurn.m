%% Plot bivariate histogram of mean run speeds before and turn
%note that ALL turning angles are included! 
%by Ercag
%May 2020 
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\RunAnalysis\SpeedAnalysis\Correlations\DensityPlot';
%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

Lab.XAx = '<V_{Run}>_{BeforeTurn} (\mum/sec)';
Lab.YAx = '<V_{Run}>_{AfterTurn} (\mum/sec)';
fps = 30;%Hz
Lambda = 0.5;

j = 3;
%Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
    RunSpeed = cell(length(Files),1);
    
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
        %Compute the cell containing run infomation 
        RunCell{i} = RunBreakDown(Speeds,T,minV,minT,fps);
        Temp = cell2mat(RunCell{i}); 
        %Mean speed of runs 
        RunSpeed{i} = Temp(:,2);
    end
    RS = matchrepeat(IPTG,RunSpeed);
    
    YEdge = 0:10:150;
    XEdge = 0:10:150;    
    
    for k = 1:size(RS,1)
        RunBeforeT = RS{k,2}(1:end-1);
        RunAfterT = RS{k,2}(2:end); 
        
        %Discard values larger than 170 um/sec;
%         RunBeforeT = RunBeforeT(RunBeforeT < 170); 
%         RunAfterT = RunAfterT(RunAfterT < 170); 
    
        IPTGLab = RS{k,1}; 
        
        hf = figure(k);
       
       histogram2(RunBeforeT,RunAfterT,XEdge,YEdge,'DisplayStyle','tile',...
            'ShowEmptyBins','on','Normalization','PDF'); 
       colorbar
         
        Lab.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLab) ' \muM']};
        PlotSty(hf,Lab);
        
        printfig(hf,fullfile(ExpPath,['[20201121][DensityPlot]' StrainLabels{j} '_MeanSpeedBeforeAfterTurn_[IPTG]_' num2str(IPTGLab) '_uM.pdf']),'-dpdf')
        printfig(hf,fullfile(ExpPath,['[20201121][DensityPlot]' StrainLabels{j} '_MeanSpeedBeforeAfterTurn_[IPTG]_' num2str(IPTGLab) '_uM']),'-dpng')

    end
        
  
%% Functions     
function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             R{i,2} = cell2mat(Y(Mask)); 
         end
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

