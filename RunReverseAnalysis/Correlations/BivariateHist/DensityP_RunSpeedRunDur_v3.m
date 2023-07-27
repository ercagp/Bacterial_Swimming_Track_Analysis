%% Run-time vs. Turn Angle 
%v3.0: The incomplete runs are included in the analysis (RunBreakDownv6)
%November 2021
%by Ercag
clearvars;
close all; 

%% Define Export Path for figures
ExpPath{1} = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverseAnalysis\RunAnalysis\SpeedAnalysis\Correlations';
ExpPath{2} = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\AngularAnalysis\Correlations';

%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
StrainLabels = {'KMT47'};
Lambda = 0.5;


%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz

%% Plot 2D-histogram of Run-time vs. Average Run-Speed

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Runs = cell(length(Files),2); 
    RunTimeSpeed = cell(length(Files),2); 
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
        RunTimeSpeed{i,1} = IPTG(i); 
        %Breakdown Run matrix into "Runs" 
        Runs{i,2} = RunBreakDownv6(Speeds,Results.T,fps); %!!! Complete + Incomplete Runs!!!

        %Isolate the AvMat
        AvMat = cell2mat(Runs{i,2}(:,2)); 
        RunTimeSpeed{i,2} = AvMat(:,1:2); %1st column: Run-times, 2nd column:Mean run-speeds                
    end
    RTS_Cmb = matchrepeat(RunTimeSpeed(:,1),RunTimeSpeed(:,2)); %Combined RunTimeSpeed matrices 
    
    for k = 1:size(RTS_Cmb,1)
        
        hf{k} = figure(k);
        Plot.X = RTS_Cmb{k,2}(:,1); %Run-times 
        Plot.Y = RTS_Cmb{k,2}(:,2); %Mean Run-Speeds
        Plot.XTitle = 'Run-Times (sec.)'; 
        Plot.YTitle = 'Mean Run Speeds (\mu{}m/sec)'; 
        Plot.Title = [StrainLabels{j} ' @ ' num2str(RTS_Cmb{k,1}) '\mu{}M']; 
        
        %Define X- and Y-Edges
        Plot.XEdges =  1/fps * [ 2.5,  4.5,  6.5,  8.5, 10.5, 13.5,  18.5,  28.5,  45] ; % Run-times
        Plot.YEdges = 0:5:180; % Mean Run-Speeds
        hist_RTS{k} = plotHist(hf{k},Plot);
        
        ExpFile.Strain = StrainLabels{j};
        ExpFile.PlotLabel = 'RunTimes_MeanRunSpeeds';
        ExpFile.IPTG = num2str(RTS_Cmb{k,1});
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