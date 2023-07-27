%% Turn events plot for KMT48 at diffrent lambda value
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT48'}; 
Lambda = [0.5, 5]; 

hf = figure(1); 


j = 1; 

    for s = 1:length(Lambda)
        %Find .mat files
        Files = callResultsv2(MainPath, StrainLabels{j},Lambda(s));
        IPTG = zeros(length(Files),1);
        TurnRate = zeros(length(Files),1); 

        for i = 1:length(Files) 
            %Load file and calculate turn event rates
            load(Files{i})    
            IPTG(i) = RunReverse.Info.IPTG;
            TurnRate(i) = RunReverse.EventRate;
        end
        R = matchrepeat(IPTG,TurnRate);
        N = cellfun(@(x) size(x,1), R); 
        
        IPTGMat = cellfun(@(x) x(1,1), R);
        AvgMat = cell2mat(cellfun(@mean,R,'UniformOutput',0));
        StdMat = cellfun(@(x) std(x(:,2)),R);
        StdError = StdMat./sqrt(N);
        
        figure(hf) 
        err{s} = errorbar(IPTGMat,AvgMat(:,2),StdError,'.');
        hold on 

        
    end
    
figure(hf);
legEntry = {['Lambda = ' num2str(Lambda(1))],['Lambda = ' num2str(Lambda(2))]};
legend([err{1:end}],legEntry,...
    'Location','NorthEast');
%Labels 
L.Title = {'minV = 10 \mum/sec','minT = 2 sec.'};
L.XAxL = '[IPTG] (\muM)';
L.YAxL = 'Event Rate (1/sec.)'; 
Lim.X = [20 105];
Lim.Y = [0 1]; 
XTick = [25 50 75 100]; 
%Adjust plot style
PlotSty(hf,L,Lim,XTick);
set([err{1:end}],'MarkerSize',20)
set([err{1:end}],'LineWidth',0.75)

%Export figure
%printfig(hf,fullfile(ExpPath,'[20200606]KMT48_TurnEventRates_DiffLambda_minV10_minT2'),'-dpdf')
%savefig(hf,fullfile(ExpPath,'[20200606]KMT48_TurnEventRates_DiffLambda_minV10_minT2'))

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
         ax.Title.String = Labels.Title;
         ax.XLabel.String = Labels.XAxL; 
         ax.YLabel.String = Labels.YAxL;
         ax.XLim = Lim.X;
         ax.YLim = Lim.Y;
         ax.XTick = XTick;
         ErcagGraphics
         settightplot(ax); 
end

