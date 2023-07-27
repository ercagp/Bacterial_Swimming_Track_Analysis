%% Calculate and Plot turn event rates (# of detected turns / # of traj time) 
% by Ercag
% May 2020 
clearvars;
close all;
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53','KMT48'}; 
Lambda = 0.5; 

hf = figure(1); 
hf_avg = figure(2); 
hf_48 = figure(3); 

k = 1; 
for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);

    IPTG = zeros(length(Files),1);
    TurnRate = zeros(length(Files),1); 

    for i = 1:length(Files) 
        %Load file and calculate turn event rates
        load(Files{i})    
        IPTG(i) = RunReverse.Info.IPTG;
        TurnRate(i) = RunReverse.EventRate;
    end
  
    %Convert 1mM to 1000uM 
    IPTG_Plot = IPTG; 
    IPTG_Plot(IPTG_Plot == 1) = IPTG_Plot(IPTG_Plot == 1).*1000;

    figure(hf);
    plot(IPTG_Plot,TurnRate,'.','MarkerSize',12);
    hold on 
    R = matchrepeat(IPTG,TurnRate);
    N = cellfun(@(x) size(x,1), R); 
    
    AvgMat = cell2mat(cellfun(@mean,R,'UniformOutput',0));
    StdMat = cellfun(@(x) std(x(:,2)),R);
    StdError = StdMat./sqrt(N);
    
    IPTGMat = cellfun(@(x) x(1,1), R);
    %Convert 1mM to 1000uM 
    IPTGMat(IPTGMat == 1) = IPTGMat(IPTGMat == 1)*1000; %uM
    
    %SumMat = cell2mat(cellfun(@(x) sum(x(:,2:3),1), R,'UniformOutput',0));
    %ER = SumMat(:,1)./SumMat(:,2); 
    
    if j == 1 || j == 2 || j == 3
       figure(hf_avg); 
       %p{j} = plot(IPTGMat,AvgMat(:,2),'.','MarkerSize',15);
        err{j} = errorbar(IPTGMat,AvgMat(:,2),StdError,'.');
        hold on 
    end
    
    if j == 3 || j == 4
       figure(hf_48)
       err_48{k} = errorbar(IPTGMat,AvgMat(:,2),StdError,'.');
       hold on
       k = k + 1; 
    end
end

%% Figure(1)

%% Figure(2) 
%Insert legends
figure(hf_avg);
legEntry = {'\DeltacheY(eCheY*)','\DeltacheY(eCheY)','WT(empty plasmid)'};
legend([err{1:end}],legEntry,...
    'Location','NorthWest');
%Labels 
L.Title = {'minV = 10\mum/sec','minT = 2 sec'};
L.XAxL = '[IPTG] (\muM)';
L.YAxL = 'Event Rate (1/sec.)'; 
Lim.X = [20 1200];
Lim.Y = [0 2.5]; 
XTick = [25 35 50 60 75 100 1000]; 
PlotSty(hf_avg,L,Lim,XTick); 
set([err{1:end}],'MarkerSize',35)
set([err{1:end}],'LineWidth',1.25)

%Export figure
printfig(hf_avg,fullfile(ExpPath,'[20210312]BBM_TurnEventRates_StdError_minV10_minT2'),'-dpdf')
%savefig(hf_avg,fullfile(ExpPath,'[20200606]TurnEventRates_StdError_minV10_minT2'))

%% Figure(3)
figure(hf_48);
legEntry_48 = {'WT (empty plasmid)','\DeltacheAY (eCheY)'};
legend([err_48{1:end}],legEntry_48,...
    'Location','NorthWest');
PlotSty(hf_48,L,Lim,XTick);
set([err_48{1:end}],'MarkerSize',35)
set([err_48{1:end}],'LineWidth',1.25)
%Same color for WT 
err_48{1}.Color = err{3}.Color;
err_48{2}.Color = rgb('Green'); 

%Export figure
%printfig(hf_48,fullfile(ExpPath,'[20210312]BBM_KMT48_TurnEventRates_StdError_minV10_minT2'),'-dpdf')
%savefig(hf_48,fullfile(ExpPath,'[20200606]KMT48_TurnEventRates_StdError_minV10_minT2'))

%% Functions
%X is an array!
function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),1);
         for i = 1:length(UX)
             Mask = X == UX(i); 
             R{i}(:,1) = X(Mask); 
             R{i}(:,2) = Y(Mask);
         end
end

function PlotSty(hFig,Labels,Lim,XTick)
         figure(hFig);
         ax = gca; 
         %ax.Title.String = Labels.Title;
         ax.XLabel.String = Labels.XAxL; 
         ax.YLabel.String = Labels.YAxL;
         ax.XLim = Lim.X;
         ax.YLim = Lim.Y;
         ax.XTick = XTick;
         ax.XScale = 'log'; 
         ErcagGraphics
         settightplot(ax); 
end
