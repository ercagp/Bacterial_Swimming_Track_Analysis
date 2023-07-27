%% Density plot for correlation between run-time before turn & after turn

%June 2020
%October 2021 
%by Ercag
clearvars;
close all;
%% Define Export Path for figures

% Mac: 
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data'; 
% Windows: ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunAnalysis\'
%% Call the run reverse analysis files

MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT43','KMT47','KMT53'}; 
Lambda = 0.5; 
%% Define Histogram Parameters

%Frames per second 
fps = 30; %Hz

%Plot parameters 
Lab.XAx = 't_{before turn} (sec)';
Lab.YAx = 't_{after turn} (sec)'; 

%Histogram parameters
YEdge = 1/fps * [ 2.5,  4.5,  6.5,  8.5, 10.5, 13.5,  18.5,  28.5,  45] ;
XEdge = 1/fps * [ 2.5,  4.5,  6.5,  8.5, 10.5, 13.5,  18.5,  28.5,  45] ;  

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
    RunDur = cell(length(Files),1);
    Temp = [];
    for i = 1:length(Files) 
        
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
              
        %Compute the cell containing run information 
        RunCell{i} = RunBreakDown(Speeds,Results,fps);
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
        X = [tRunBfr,tRunAfter]; 
        %plot
        hf = figure(k);
        hist = histogram2(tRunBfr,tRunAfter,XEdge,YEdge,'DisplayStyle','tile',...
            'ShowEmptyBins','on','Normalization','PDF'); 
        colorbar
        
        %Title of each plot
        Lab.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLabel) ' \muM']};
        %Impose style
        PlotSty(hf,Lab);
        %printfig(hf,fullfile(ExpPath,['[20201109]' StrainLabels{j} '_RuntimeBeforeAfterTurnCorr_[IPTG]_' num2str(IPTGLabel) '_uM.pdf']),'-dpdf')
        %printfig(hf,fullfile(ExpPath,['[20201109]' StrainLabels{j} '_RuntimeBeforeAfterTurnCorr_[IPTG]_' num2str(IPTGLabel) '_uM.png']),'-dpng')

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

function PlotSty(hFig,Lab)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
%          ax.XLim = Lim.X;
%          ax.YLim = Lim.Y; 
         ErcagGraphics
         ax.YTick = ax.XTick;  
         %settightplot(ax); 
end