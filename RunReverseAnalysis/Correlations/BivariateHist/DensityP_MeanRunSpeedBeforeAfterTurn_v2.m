%% Plot bivariate histogram of mean run speeds before and turn
% v2: Includes complete and incomplete runs but removes no-turn
% trajectories

% November 2021 
% by Ercag 
clearvars;
close all; 

%% Define Export Path for figures
ExpPath{1} = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverseAnalysis\RunAnalysis\SpeedAnalysis\Correlations';

%% Call the run reverse analysis files
MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
StrainLabels = {'KMT53'};
Lambda = 0.5;
%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz
%% Plot 2D-histogram of mean run-speed before turn vs. mean run-speed after turn
for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Runs = cell(length(Files),2); 
    MeanRunSpeed = cell(length(Files),2); 
    BeforeAfter = cell(length(Files),2); 
    
    for i = 1:length(Files) 
        %Call the run-reverse file 
        load(Files{i}); 

        %Correct the wrong IPTG label 
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        %Store IPTG value
        Runs{i,1} = IPTG(i); 
        MeanRunSpeed{i,1} = IPTG(i);
        BeforeAfter{i,1} = IPTG(i);
        
        %Breakdown Run matrix into "Runs" 
        Runs{i,2} = RunBreakDownv6(Speeds,Results.T,fps); %!!! Incomplete + Complete Runs!!!         
                
        %Remove single run trajectories
        Runs{i,2} = Runs{i,2}(cellfun(@(x) size(x,1) > 1, Runs{i,2}(:,2)),:); 
        
        %Isolate the AvMat
        AvMat = cell2mat(Runs{i,2}(:,2));
        
        %Mean Run Speeds 
        MeanRunSpeed{i,2} = AvMat(:,2);
        
        %Mean run speeds before & after a turn
        BeforeAfter{i,2}(:,1) = MeanRunSpeed{i,2}(1:end-1); %Before
        BeforeAfter{i,2}(:,2) = MeanRunSpeed{i,2}(2:end); %After                                
    end
    
    BA_Cmb = matchrepeat(BeforeAfter(:,1),BeforeAfter(:,2));
    
    for k = 1:size(BA_Cmb,1)
        
        hf{k} = figure(k);
        Plot.X = BA_Cmb{k,2}(:,1); %Mean Run-Speeds Before a Turn
        Plot.Y = BA_Cmb{k,2}(:,2); %Mean Run-Speeds After a Turn
        
        Plot.XTitle = 'Mean Run Speed Before Turn (\mu{}m/sec)'; 
        Plot.YTitle = 'Mean Run Speed After Turn(\mu{}m/sec)'; 
        Plot.Title = [StrainLabels{j} ' @ ' num2str(BA_Cmb{k,1}) '\mu{}M']; 
        
        Plot.XEdges = 0:5:180; % Mean Run-Speeds
        Plot.YEdges = 0:5:180; % Mean Run-Speeds
        
        %Plot the 2D histogram 
        hist_RTS{k} = plotHist(hf{k},Plot);
        
        ExpFile.Strain = StrainLabels{j};
        ExpFile.PlotLabel = 'RunSpeed_BeforeAfter_Turn';
        ExpFile.IPTG = num2str(BA_Cmb{k,1});
        ExpFig(hf{k},ExpFile,ExpPath{1})                
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