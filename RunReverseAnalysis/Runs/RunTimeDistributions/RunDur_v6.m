%% Plot Run-Time Distributions (PDFs)
% v6.0: this version separates run-time distributions in four different mean
% speed binning [0-35],[35-75],[75-150] & [150-200] um/sec. 
% Also, it uses RunBreakDownv3 to include only complete runs. 

% November 2021 
%by Ercag Pince 
clearvars;
close all; 
%% Define Export Path for figures

ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/TimeAnalysis/Distributions/RunTimes';
%% Call the run reverse analysis files

MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT47'};
Lambda = 0.5;

%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz

%% Plot Run-Time Distributions in three different subset of bins 
for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Runs = cell(length(Files),2); 
    RunDur = cell(length(Files),2); 
    
    for i = 1:length(Files)
        load(Files{i})
        %Correct the wrong IPTG label 
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        
        %Store IPTG value
        Runs{i,1} = IPTG(i);
        RunDur{i,1} = IPTG(i);
        
        Runs{i,2} = RunBreakDownv3(Speeds,Results.T,fps); %Only Complete Runs!
        AvMat = cell2mat(Runs{i,2}(:,2)); 
        
        %Select run durations by their mean speed
        V = [0,35,75,150,200];
        ColorMap = linspecer(length(V)-1,'qualitative');

        
        RunDur{i,2} = AvMat(AvMat(:,2) > V(1) & AvMat(:,2) < V(2),1); 
        RunDur{i,3} = AvMat(AvMat(:,2) > V(2) & AvMat(:,2) < V(3),1);
        RunDur{i,4} = AvMat(AvMat(:,2) > V(3) & AvMat(:,2) < V(4),1);
        RunDur{i,5} = AvMat(AvMat(:,2) > V(4) & AvMat(:,2) <= V(5),1);
    end
    
    RD_0 = matchrepeat(RunDur(:,1),RunDur(:,2));
    RD_1 = matchrepeat(RunDur(:,1),RunDur(:,3));
    RD_2 = matchrepeat(RunDur(:,1),RunDur(:,4));
    RD_3 = matchrepeat(RunDur(:,1),RunDur(:,5));
    
    RD_Cmb = [RD_0(:,1), RD_0(:,2), RD_1(:,2), RD_2(:,2), RD_3(:,2)]; 
    
    for k = 1:size(RD_Cmb,1) 
        for l = 1:length(V)-1
            ind = k + (l-1)*10; 
            hf{ind} = figure(ind);

            Plot.X =  RD_Cmb{k,l+1};
            Plot.Edges = 1/fps.*[(2.5:2:45), 46.5];
            Plot.Color = ColorMap(l,:);
            Plot.Title = {[StrainLabels{j} ' @ ' num2str(RD_Cmb{k,1}) '\mu{}M'],...
                          [num2str(V(l)) '-' num2str(V(l+1)) '\mu{}m/sec']};
            Plot.XTitle = 'Run Duration (sec.)';
            Plot.YTitle = 'PDF'; 
        
            plotHist(hf{ind},Plot)
            %Export Figure 
            ExpFile.Strain = StrainLabels{j};
            ExpFile.PlotLabel = [num2str(V(l)) '-' num2str(V(l+1)) '_MeanSpeedBinned_RunDurations'];
            ExpFile.IPTG = num2str(RD_Cmb{k,1});
            ExpFig(hf{ind},ExpFile,ExpPath)
        end 
    end
end


%% Functions 
function Hist = plotHist(h_Fig,P)
         figure(h_Fig)
         X = P.X; 
         Edges = P.Edges;
         XTitle = P.XTitle;
         YTitle = P.YTitle; 
         Title = P.Title; 
         Color = P.Color; 
    
         Hist = histogram(X,Edges,'DisplayStyle','stairs','Normalization','PDF','EdgeColor',Color,...
                         'LineWidth',2.0);        
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