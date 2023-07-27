%% Plot run-time (i.e. run duration) vs. mean run speed
% Bi-variate histogram 
%June 2020
%by Ercag
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\RunAnalysis\SpeedAnalysis\Correlations\DensityPlot\MeanRunSpeed_BeforeAfterTurn';

%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\Data';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Frames per second 
fps = 30; %Hz
%Lambda value 
Lambda = 0.5; 

%Plot parameters 
Lab.XAx = '<V>_{Run} (\mum/sec)';
Lab.YAx = 't_{Run} (sec)'; 


%Histogram parameters
YEdge = 3/fps:3/fps:10/fps;%3/fps:1/fps:45/fps;
XEdge = 0:5:75;%0:10:150;


for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
    RunDur = cell(length(Files),1);
    RunSpeed = cell(length(Files),1);
    Temp = [];
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 
        %Compute the cell containing run infomation 
        RunCell{i} = RunBreakDown(Speeds,T,minV,minT,fps);
        Temp = cell2mat(RunCell{i}); 
        %Run-times 
        RunDur{i} = Temp(:,1); 
        %Mean speed of runs
        RunSpeed{i} = Temp(:,2);
        
    end
    RS = matchrepeat(IPTG,RunSpeed);
    RT = matchrepeat(IPTG,RunDur); 
    for k = 1:size(RS,1)
        IPTGLabel = RT{k,1};
        tRun = RT{k,2};
        VRun = RS{k,2}; 
        
        %plot 
        hf = figure(k+(4*(j-1)));
        %<V>_run vs. t_run
        
        histogram2(VRun,tRun,XEdge,YEdge,'DisplayStyle','tile',...
            'ShowEmptyBins','on','Normalization','PDF');
        colorbar
        %Title of each plot
        Lab.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLabel) ' \muM']};
        PlotSty(hf,Lab);
        printfig(hf,fullfile(ExpPath,['[20201122]Test_' StrainLabels{j} '_RunTimeSpeedCorr_[IPTG]_' num2str(IPTGLabel) '_uM.pdf']),'-dpdf')
        printfig(hf,fullfile(ExpPath,['[20201122]Test_' StrainLabels{j} '_RunTimeSpeedCorr_[IPTG]_' num2str(IPTGLabel) '_uM.png']),'-dpng')

%         R = corrcoef(VRun,tRun);
%         rho(k,j) = R(1,2); 
    end
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
%          ax.XLim = Lim.X;
%          ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end