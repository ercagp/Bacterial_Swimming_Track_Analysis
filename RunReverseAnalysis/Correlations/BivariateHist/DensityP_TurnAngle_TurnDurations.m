%% Turn Durations vs. Turn Angle 
% in the hunt for the false positives 
% November 2021
% by Ercag
clearvars;
close all; 

%% Define Export Path for figures
ExpPath{1} = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverseAnalysis\TurnAnalysis\Correlations';
ExpPath{2} = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\AngularAnalysis\Correlations';

%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
StrainLabels = {'KMT47'};
Lambda = 0.5;

%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz

%% Plot 2D-histogram of Turn Angles vs. Turn Durations
for j = 1:length(StrainLabels)
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAng = cell(length(Files),2); 
    TurnDur = cell(length(Files),2); 
    TurnDurAng = cell(length(Files),2);
    for i = 1:length(Files)
        %Call the run-reverse file 
        load(Files{i}); 
        %Correct the wrong IPTG label 
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        %Store IPTG value
        TurnDur{i,1} = IPTG(i);         
        TurnAng{i,1} = IPTG(i); 
        TurnDurAng{i,1} = IPTG(i);
        
        %Breakdown Run matrix into "Turns"        
        TurnDur{i,2} = TurnBreakDownv2(Results.T,fps); 
        TurnAng{i,2} = Results.Ang(:,3); %note: all turn angles are already filtered
        
        TurnDurAng{i,2} = [cell2mat(TurnDur{i,2}),cell2mat(TurnAng{i,2})]; 
    end
    
    TDA_Cmb = matchrepeat(TurnDurAng(:,1),TurnDurAng(:,2)); 
    
    for k = 1:size(TDA_Cmb,1)
        hf{k} = figure(k);
        Plot.X = TDA_Cmb{k,2}(:,1); %Turn durations 
        Plot.Y = TDA_Cmb{k,2}(:,2); %Turn angles 
        Plot.XTitle = 'Turn Durations (sec.)';
        Plot.YTitle = 'Turn Angles (degrees)';
        Plot.Title = [StrainLabels{j} ' @ ' num2str(TDA_Cmb{k,1}) '\mu{}M']; 

        
        %Define X- and Y-Edges
        Plot.XEdges =  1/fps * [2.5, 4.5,  6.5,  8.5, 10.5, 13.5,  18.5,  28.5,  45] ; % Run-times
        Plot.YEdges = 0:10:180; 
        %Plot Turn dur. vs. Turn angles 
        hist_RTS{k} = plotHist(hf{k},Plot);
        
        ExpFile.Strain = StrainLabels{j};
        ExpFile.PlotLabel = 'TurnDurations_TurnAngles';
        ExpFile.IPTG = num2str(TDA_Cmb{k,1});
        ExpFig(hf{k},ExpFile,ExpPath{1})        
        ExpFig(hf{k},ExpFile,ExpPath{2})        
    end
    
end


%% Functions 
function Hist = plotHist(h_Fig,P)
         figure(h_Fig)
         X = P.X; 
         Y = P.Y; 
         XEdges = P.XEdges;
         YEdges = P.YEdges;
         XTitle = P.XTitle;
         YTitle = P.YTitle; 
         Title = P.Title; 
        
         Hist = histogram2(X,Y,XEdges,YEdges,...
                          'DisplayStyle','tile','ShowEmptyBins','on','Normalization','PDF');        
         colorbar; 
         title(Title);
         xlabel(XTitle);
         ylabel(YTitle);
         ErcagGraphics
end

function ExpFig(h_Fig,S,ExpPath)
         %Time stamp for the PNG/PDF files
         Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];
                        
            
         if ~exist(ExpPath,'dir')
            mkdir(ExpPath)
         end   
         
         FullFileName = [Stamp S.Strain '_' S.PlotLabel '_IPTG_' S.IPTG 'uM'];
         
         printfig(h_Fig,fullfile(ExpPath,FullFileName),'-dpng');
         printfig(h_Fig,fullfile(ExpPath,FullFileName),'-dpdf');
         savefig(h_Fig,fullfile(ExpPath,FullFileName));
end

