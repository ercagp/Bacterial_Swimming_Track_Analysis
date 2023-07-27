%% Run-time distribution of fast and slow runs 
%by Ercag 
%May 2020 
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
NormType = 'PDF';
Lab{1}.XAx = 't_{slow runs} (sec)';
Lab{2}.XAx = 't_{fast runs} (sec)'; 

if strcmp(NormType,'PDF')
    Lab{1}.YAx = 'PDF';
    Lab{2}.YAx = 'PDF';
else
    Lab{1}.YAx = 'Counts';
    Lab{2}.YAx = 'Counts'; 
end

%For different strains
ColorMap{1} = [0 0.45 0.74]; %KMT43
ColorMap{2} = [0.85 0.33 0.10]; %KMT47
ColorMap{3} = [0.93 0.69 0.13]; %KMT53

%Set bin arrays 
minB = 0;
maxB = 2.5; 
BinSize = 1/fps;

Bins = minB:BinSize:maxB; %sec.

Lim{1}.X = [minB maxB]; 
Lim{2}.X = [minB maxB]; 

%Set velocity threshold for fast bugs
Fast_Th = 100; %um/sec
Slow_Th = 40; %um/sec 

j = 3; 
%for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
    RunSpeed = cell(length(Files),1);
    RunDur = cell(length(Files),1);
    TSlowRuns = cell(length(Files),1);
    TFastRuns = cell(length(Files),1);
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
        RunDur{i} = Temp(:,1); 
        TSlowRuns{i} = RunDur{i}(RunSpeed{i} < Slow_Th); 
        TFastRuns{i} = RunDur{i}(RunSpeed{i} > Fast_Th); 
    end
    TSlow = matchrepeat(IPTG,TSlowRuns);
    TFast = matchrepeat(IPTG,TFastRuns);
    %Plot distributions 
    for k = 1:size(TSlow,1)
        %Title for each figure
        IPTGLab = TSlow{k,1}; 
        Lab{1}.Title  = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLab) '\muM']};

        %Run-time distribution for slow runs 
        hf{k} = figure(k);
        subplot(2,1,1)
        histFast{k} = histogram(TSlow{k,2},Bins,'EdgeColor',ColorMap{j},...
                'DisplayStyle','Stairs','Normalization',NormType,'LineWidth',2);
        PlotSty(hf{k},Lab{1},Lim{1});
        title(Lab{1}.Title);
        
        %Run-time distribution for fast runs 
%       hf_Slow{k} = figure(2*k); 
        subplot(2,1,2)
        histSlow{k} = histogram(TFast{k,2},Bins,'EdgeColor',ColorMap{j},...
                'DisplayStyle','Stairs','Normalization',NormType,'LineWidth',2);
        PlotSty(hf{k},Lab{2},Lim{2});

        %Export the figure
        printfig(hf{k},fullfile(ExpPath,['[20200529]' StrainLabels{j} '_RunTimeDistFastSlowRuns_[IPTG]_' num2str(IPTGLab) '_uM.pdf']),'-dpdf');
    end
%end


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
         %ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end
