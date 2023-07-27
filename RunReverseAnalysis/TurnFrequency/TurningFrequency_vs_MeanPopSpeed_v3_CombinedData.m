%% Plot turning frequency vs. mean population speed
% January 2021

%by Ercag 
clearvars;
close all;
%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverseAnalysis\EventRates';
mkdir(ExpPath);
%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverse_Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT53'};
%% Input parameters

%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5; 

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

%RegExp Keys
RegKeyROI = 'ROI[_]\d';
RegKeyVD = ['(?<=Data' filesep filesep ')\d*'];

%IPTG vector for the plot 
IPTG_X = [0, 25, 50, 60, 75, 100, 1000]; 

%Plot parameters 
ColorMap = linspecer(length(StrainLabels),'qualitative'); 
%ColorMap_IPTG = linspecer(length(IPTG_X),'sequential'); 
ColorMap_IPTG = lines(length(IPTG_X));
PP.Label.XAx = 'Mean Speed (\mum/sec)';
PP.Label.YAx = 'Turn Frequency (sec^{-1})'; 
PP.XTick = 0:20:200; 
PP.XLim = [0,200];
PP.YLim = [0,3.5]; 

%Edge vectors 
Edge = 0:10:200; %um/sec
%% Calculate Turn Frequency & Mean Speed

for j = 1:length(StrainLabels)
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);    
    %Find ROIs and Video dates
    VideoDates = regexp(Files,RegKeyVD,'match','once');
    ROI = regexp(Files,RegKeyROI,'match','once');
    
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnSum = zeros(length(Files),1);
    TrajDur = zeros(length(Files),1);
    TurnFreq_Bin = cell(length(Files),2);%Second column is for IPTG
    MeanV = cell(length(Files),2); %Second column is for IPTG
                
    for i = 1:length(Files) 
        load(Files{i})
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000; %1000uM
        end
      
        
        APara.minT = Results.minT;
        APara.minV = Results.minV;
        APara.fps = fps; 
       
        TotalN_Bugs{i,1} = IPTG(i);
        MeanV_AllBugs{i,1} = IPTG(i);
        MeanV{i,1} = IPTG(i); %IPTG     
        TurnFreq_Bin{i,1} = IPTG(i);
        %Calculate turn frequency per bin 
        [TurnFreq_Bin{i,2}, MeanV{i,2}, MeanV_AllBugs{i,2},TotalN_Bugs{i,2}] = TurnFreq_MeanV(Speeds,Results.T,Edge,APara);     
    end
    %TurnFB_Matched = matchrepeat(IPTG,TurnFreq_Bin);
    
    for k = 1:size(IPTG_X,2)
        
        %Find the meanV vectors matches with IPTG value
        MeanV_AllBugs_Matched = MeanV_AllBugs([MeanV_AllBugs{:,1}] == IPTG_X(k),2);
        MeanV_Matched = MeanV([MeanV{:,1}] == IPTG_X(k),2); 
        TurnFB_Matched = TurnFreq_Bin([TurnFreq_Bin{:,1}] == IPTG_X(k),2);   
        TotalN_Bugs_Matched = TotalN_Bugs([TotalN_Bugs{:,1}] == IPTG_X(k),2);   
        
        hFig = figure(k);          
        
        TurnFBM_Plot.NBugs = TotalN_Bugs_Matched; 
        TurnFBM_Plot.XMean = MeanV_AllBugs_Matched; %to take the population mean of all speeds of all bugs        
        TurnFBM_Plot.X = MeanV_Matched;
        TurnFBM_Plot.Y = TurnFB_Matched;  %Turn Frequency per bin 
        PP.Color = ColorMap_IPTG(k,:); 
        PP.Label.Title = [StrainLabels{j} ' - [IPTG] @' num2str(IPTG_X(k)) ' \muM']; 

        PlotTFV(hFig,TurnFBM_Plot,PP);
        
        %Export the figure 
        S.ExpPath = ExpPath;
        S.SubDir = 'TurnFrequency_MeanRunSpeed'; 
        S.Strain = StrainLabels{j}; 
        S.Stamp = Stamp;
        S.PlotY = 'TurnFreq_MeanV_Combined'; 
        S.IPTG = num2str(IPTG_X(k)); 
             
        ExportFig(hFig,S);
    end

  

    close all 
end
%% Functions

 function [FilterMask] = filterout(S,minT,minV,fps)

         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         %SSubset = S(FilterMask); 
 end
 
 
 function [TurnFreq, MeanV_perAcq,MeanV_perAcq_AllBugs,N_Bugs] = TurnFreq_MeanV(S,T,Edges,AllPara)
              
          
          %Filter out the speeds matrices
          FltMask =  filterout(S,AllPara.minT,AllPara.minV,AllPara.fps);
          SFlt = S(FltMask);
          TFlt = T(FltMask,:);
          
          %Find mean speed per bug 
          V = cellfun(@(x) mean(x(:,9),'omitnan'), SFlt); 
          [N,Edge,Bins] = histcounts(V,Edges);
                   
          %Preallocate 
          TrajDur = zeros(length(Edge)-1,1);
          TurnSum = zeros(length(Edge)-1,1);
          TurnFreq = zeros(length(Edge)-1,1);
          
          for i = 1:length(Edge)-1
              Mask = Bins == i; 
              TSubset = TFlt(Mask,:);
              
              %Check the subset of Speeds matrices
              SSubset = SFlt(Mask);
              %CMP = [cellfun(@(x) size(x,1),SSubset(:,1)), cellfun(@(x) size(x,1), TSubset(:,1))]
              
              %Discard the empty matrix entries 
              TurnMask = ~cellfun(@(x) isempty(x), TSubset(:,3));
              %Filter "T" matrix to get rid of trajectories with no turns 
              TSubset_NoTurn = TSubset(TurnMask,:); 
              SSubset_NoTurn = SSubset(TurnMask);                         
              
              MeanV_perAcq_AllBugs{i} = cell2mat(cellfun(@(x) x(:,9),SSubset_NoTurn,'UniformOutput',false));
              MeanV_perAcq(i) = mean(cell2mat(cellfun(@(x) x(:,9),SSubset_NoTurn,'UniformOutput',false)),'omitnan');
              %Number of bugs 
              N_Bugs(i) = size(SSubset_NoTurn,1);
              
              %MeanV(i) = MeanAll(:,9);
               
              TrajDur(i) = sum(cellfun(@(x) size(x,1)./AllPara.fps, TSubset_NoTurn(:,1))); 
              TurnSum(i) = sum(cellfun(@(x) length(x), TSubset_NoTurn(:,3))); 
              
              TurnFreq(i) = TurnSum(i)/TrajDur(i); 
          end
          TurnFreq = TurnFreq';
 end
 
 function R = matchrepeat(X,Y)
          UX = unique(X,'stable');
          R = cell(length(UX),2);
          for i = 1:length(UX)
              Mask = X == UX(i);
              R{i,1} = unique(X(Mask));
              YSubset = Y(Mask);
              R{i,2} = []; 
              for j = 1:size(YSubset,1)
                  R{i,2} = [R{i,2}, YSubset{j}];
             end                 
          end
 end

function pHand = PlotTFV(hf,X,Para)
          
          Clr = Para.Color;
          for i = 1:size(X.X,1)
              pHand = plot(X.X{i},X.Y{i},'o','MarkerSize',7,'Color',Clr,'LineWidth',1.5); 
              hold on             
              Test(i,:) = X.XMean{i};
              Test_N(i,:) = X.NBugs{i};
          end
          
          
          for j = 1:size(Test,2)
               meanV(j) = mean(cell2mat(Test(:,j)),'omitnan');
               std_X(j) = std(cell2mat(Test(:,j)),'omitnan');
          end
          %Standard error of the mean 
          sem_X = std_X./sqrt(sum(Test_N,1));
         
          meanTF = mean(cell2mat(X.Y),1,'omitnan');
          %std_X = std(cell2mat(X.X),0,1,'omitnan'); 
          std_Y = std(cell2mat(X.Y),0,1,'omitnan'); 
          errorbar(meanV,meanTF,std_Y,std_Y,sem_X,sem_X,'.','MarkerSize',32,...
                   'LineWidth',2.0,'Color',Clr); 
               
          drawnow(); 
          %Impose style
          ax = gca; 
          ax.XTick = Para.XTick; 
          ax.YAxis.Label.String = Para.Label.YAx;
          ax.XAxis.Label.String = Para.Label.XAx;
          ax.Title.String = Para.Label.Title;
          ax.XLim = Para.XLim; 
          ax.YLim = Para.YLim;
          ax.FontSize = 18;
          ax.FontName =  'Helvetica';
          ax.LineWidth = 2.0; 
          ax.Box = 'on';
          
          grid on 
          
          SetFigLarge(hf,ax); 
          hold off
          
 end


 function SetFigLarge(hFig,ax)
          hFig.Color = [1 1 1];
          hFig.InnerPosition = [328,741,1472,427];
          hFig.OuterPosition = [320,733,1488,520];
          settightplot(ax); 
          hFig.PaperUnits = 'centimeters';
          hFig.PaperPosition = [1 2.0 28 16.8];
 end
 
  
function PlotSty(hFig,Lab,Lim)
         figure(hFig);
         ax = gca; 
         %ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end

function ExportFig(hf,Strings)
                                                        
          
        FinalExpPath = fullfile(Strings.ExpPath,Strings.SubDir,Strings.PlotY,Strings.Strain,[Strings.IPTG 'uM']);
        FullFileName = [Strings.Stamp Strings.Strain '_' Strings.PlotY '_IPTG_' Strings.IPTG 'uM'];
        
        
        if ~exist(FinalExpPath,'dir')
            mkdir(FinalExpPath)
        end   
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpng');
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpdf');
        savefig(hf,fullfile(FinalExpPath,FullFileName));
end