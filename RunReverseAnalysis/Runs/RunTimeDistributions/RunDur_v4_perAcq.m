%% Plot Run Duration(aka Times) Distributions (1-CDF & PDFs)
% January 2021
%by Ercag 
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\RunAnalysis\TimeAnalysis\Distributions';
%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT43','KMT47','KMT53'};
%% User query to select which type of observable to plot 
disp('Which quantities to plot?')
disp('1-)Run Duration distributions (PDFs) ')
disp('2-)Fraction of run times longer than a given time (1-CDF)')
disp('3-)')
disp('4-)')
prompt = 'Enter the number of the observable to plot:\n'; 
n_Query = input(prompt); 

if n_Query  == 1 
   observable = 'RunDurPDF';
elseif n_Query == 2 
    observable = '1_CDF';
elseif n_Query == 3
    observable = ''; 
elseif n_Query == 4
    observable = ''; 
end

%% Input parameters 
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5; 

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

%RegExp Keys
RegKeyROI = 'ROI[_]\d';
RegKeyVD = ['(?<=Data' filesep filesep ')\d*'];

%Plot parameters 
PP.Lim.X  = [0, 1.5]; 
PP.Edges = 1/fps*[2.5, 4.5,  6.5,  8.5, 10.5, 13.5,  18.5,  28.5,  45]; 
PP.Norm = 'PDF'; 
PP.LineWidth = 1.75; 
ColorMap = linspecer(length(StrainLabels),'qualitative'); 
%% Calculate Run Durations
for j = 1:length(StrainLabels)
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);    
    %Find ROIs and Video dates
    VideoDates = regexp(Files,RegKeyVD,'match','once');
    ROI = regexp(Files,RegKeyROI,'match','once');
   
    %Preallocate
    IPTG = zeros(length(Files),1);
    TSubset = cell(length(Files),1);
    RunDur =  cell(length(Files),1);
    for i = 1:length(Files)
        load(Files{i}) 
        
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        %Filter out run-reverse cell 
        [~,FltMask] = filterout(Speeds,Results.minT,Results.minV,fps); 
        TSubset{i} = Results.T(FltMask,:); 
                
        %Plot's title 
        PP.Label.Title = {[StrainLabels{j} ' - ' VideoDates{i}], [num2str(IPTG(i)) ' \muM [IPTG] - ' ROI{i}]}; 
        hFig = figure(1);
        switch observable 
            case 'RunDurPDF'
                  %Get run duration vector 
                  RunDur{i} = cell2mat(GetRunDur(TSubset{i},fps));
                  
                  PP.Label.XAx = 'Run Duration (sec.)'; 
                  PP.EdgeColor = ColorMap(j,:); 
                  if strcmp(PP.Norm,'PDF')                 
                     PP.Label.YAx = 'PDF'; 
                  else
                     PP.Label.YAx = 'Counts'; 
                  end
                 
                  h_Hist = HistRunDur(RunDur{i},PP,hFig);
                  PlotSty(hFig,PP);
                  
                  %Export the figure 
                  S.ExpPath = ExpPath;
                  S.SubDir = 'RunTimes_PerAcq'; 
                  S.Strain = StrainLabels{j}; 
                  S.Stamp = Stamp;
                  S.PlotY = 'RunTimesPerAcq'; 
                  S.IPTG = num2str(IPTG(i)); 
                  S.VD = VideoDates{i};
                  S.ROI = ROI{i};
                  S.ExpType = 'PerAcq';
                      
                  ExportFig(hFig,S);
                  
            case '1_CDF' 
                  %Get run duration vector 
                  RunDur{i} = cell2mat(GetRunDur(TSubset{i},fps));
                   
                  PP.Label.XAx = 'Run Duration (sec.)'; 
                  PP.Label.YAx = '1-CDF'; 
                  PP.EdgeColor = ColorMap(j,:); 
                  PP.Norm = 'count';
                  
                  [CDF,~] = histcounts(RunDur{i},PP.Edges,'Normalization','cdf');
                  
                  h_CDF = HistRunDur(1-CDF,PP,hFig);
                  PlotSty(hFig,PP);
                  ax = gca;
                  ax.YScale = 'log'; 
                  

                  %Export the figure 
                  S.ExpPath = ExpPath;
                  S.SubDir = '1_CDF_PerAcq'; 
                  S.Strain = StrainLabels{j}; 
                  S.Stamp = Stamp;
                  S.PlotY = '1_CDF_PerAcq'; 
                  S.IPTG = num2str(IPTG(i)); 
                  S.VD = VideoDates{i};
                  S.ROI = ROI{i};
                  S.ExpType = 'PerAcq';
                      
                  ExportFig(hFig,S);
        end

        
    end
    
    
end


%% Functions 
function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
end

function Hist = HistRunDur(X,PltPara,hFig)
         
         figure(hFig); 
         
         XValues = X; %Run durations                 
         Edges = PltPara.Edges; 
         Norm = PltPara.Norm; 
         LineWidth = PltPara.LineWidth; 
         EdgeColor = PltPara.EdgeColor;
         
         if strcmp(Norm,'PDF')
            Hist = histogram(XValues,Edges,...
                            'EdgeColor',EdgeColor,...
                            'Normalization',Norm,...
                            'DisplayStyle','Stairs',...
                            'LineWidth',LineWidth); 
         else
           Hist = histogram('BinEdges',Edges,'BinCounts',XValues,...
                            'EdgeColor',EdgeColor,...
                            'Normalization',Norm,...
                            'DisplayStyle','Stairs',...
                            'LineWidth',LineWidth); 
         end
         drawnow();             
         
end

function ExportFig(hf,Strings)
                                                                  
        if strcmp(Strings.ExpType,'PerAcq')
           FinalExpPath = fullfile(Strings.ExpPath,Strings.SubDir,Strings.PlotY,Strings.Strain,[Strings.IPTG 'uM']);
           FullFileName = [Strings.Stamp Strings.Strain '_' Strings.PlotY '_' Strings.VD '_IPTG_' Strings.IPTG 'uM_' Strings.ROI];
        else
           FinalExpPath = fullfile(Strings.ExpPath,Strings.SubDir);
           FullFileName = [Strings.Stamp Strings.PlotY];
        end
        
        if ~exist(FinalExpPath,'dir')
            mkdir(FinalExpPath)
        end   
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpng');
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpdf');
        savefig(hf,fullfile(FinalExpPath,FullFileName));
end


function PlotSty(hFig,PlotPara)
         figure(hFig);
         ax = gca; 
         ax.Title.String = PlotPara.Label.Title;
         ax.XLabel.String = PlotPara.Label.XAx; 
         ax.YLabel.String = PlotPara.Label.YAx;
         ax.XLim = PlotPara.Lim.X;
%         ax.YLim = PlotPara.Lim.Y;
         ErcagGraphics
%        settightplot(ax); 
end

function SortandPutLeg(P,Handles,Labels)
         [~,LegendOrder] = sort(cell2mat(P(:,1)));
         legend([Handles{LegendOrder}],Labels{LegendOrder},'Location','NorthEast')
end
    