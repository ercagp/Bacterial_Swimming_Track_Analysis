%% Mean run speed before a run and after a run (i.e. run vs. next run) 
%May 2020
%by Ercag 
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunSpeeds';

%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Frames per second 
fps = 30; %Hz

%Plot parameters 
Lab.XAx = '<V>_{BeforeTurn} (\mum/sec)';
Lab.YAx = '<V>_{AfterTurn} (\mum/sec)'; 
minB = 0;
maxB = 160; 
Lim.X = [minB maxB]; 
Lim.Y = [minB maxB];




for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
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
        %Mean speed of runs 
        RunSpeed{i} = Temp(:,2); 
    end
    RS = matchrepeat(IPTG,RunSpeed);
    
    for k = 1:size(RS,1)
        %<V>_beforeturn & <V>_afterturn
        hf = figure(k+(4*(j-1)));
        RunBeforeT = RS{k,2}(1:end-1);
        RunAfterT = RS{k,2}(2:end); 
        IPTGLabel = RS{k,1};
        %Plot it
        plot(RunBeforeT,RunAfterT,'.');
        hold on 
        %Diagonal line 
        plot(Lim.X,Lim.Y,'--k','LineWidth',1.5)
        %Title of each plot
        Lab.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLabel) ' \muM']};
        %Impose style
        PlotSty(hf,Lab,Lim);
        printfig(hf,fullfile(ExpPath,['[20200529]' StrainLabels{j} '_MeanSpeedBeforeAfterTurn_[IPTG]_' num2str(IPTGLabel) '_uM.pdf']),'-dpdf');
    end
end

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

