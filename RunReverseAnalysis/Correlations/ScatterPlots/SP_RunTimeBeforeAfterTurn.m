%% Plot run-time correlation between run-time before turn & after turn 
%May 2020
%by Ercag
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/TurnRunDurations';

%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Frames per second 
fps = 30; %Hz

%Plot parameters 
Lab.XAx = 't_{before turn} (sec)';
Lab.YAx = 't_{after turn} (sec)'; 

minT = 0;
maxT = 3.5;
Lim.X = [minT maxT];
Lim.Y = [minT maxT];

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
    RunDur = cell(length(Files),1);
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
    end
    RT = matchrepeat(IPTG,RunDur); 
    for k = 1:size(RT,1)
        %<V>_run vs. t_run
        IPTGLabel = RT{k,1};
        tRunBfr = RT{k,2}(1:end-1);
        tRunAfter = RT{k,2}(2:end); 
        %plot 
        hf = figure(k+(4*(j-1)));
        plot(tRunBfr,tRunAfter,'.b'); 
        %Title of each plot
        Lab.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLabel) ' \muM']};
        %Impose style
        PlotSty(hf,Lab,Lim);
        printfig(hf,fullfile(ExpPath,['[20200529]' StrainLabels{j} '_RuntimeBeforeAfterTurnCorr_[IPTG]_' num2str(IPTGLabel) '_uM.pdf']),'-dpdf')
        R = corrcoef(tRunBfr,tRunAfter);
        rho(k,j) = R(1,2); 
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

function PlotSty(hFig,Lab,Lim)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end
