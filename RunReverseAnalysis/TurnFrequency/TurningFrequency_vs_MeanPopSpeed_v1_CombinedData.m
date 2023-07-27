%% Plot turning frequency vs. mean population speed
% January 2021
%by Ercag 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis\EventRates';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT43','KMT47','KMT53'};
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
IPTG_X = [0, 25, 35, 50, 75, 100]; 

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
    TurnFreq_Bin = cell(length(Files),1);
                
    for i = 1:length(Files) 
        load(Files{i})
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        FltMask =  filterout(Speeds,Results.minT,Results.minV,fps);
        SpeedsFlt = Speeds(FltMask); 
       
        %Calculate turn frequency per bin 
        [TurnFreq_Bin{i}, MeanV, X] = TurnFreq_MeanV(SpeedsFlt,Results.T,Edge,fps);                
    end
    TurnFB_Cell = matchrepeat(IPTG,TurnFreq_Bin);
    
    for k = 1:size(TurnFB_Cell,1) 
        
        hFig = figure(k); 
        TurnFB.X = X; % X (Edges) 
        TurnFB.Y = TurnFB_Cell{k,2};  %Turn Frequency per bin 
        PP.Color = ColorMap_IPTG(TurnFB_Cell{k,1} == IPTG_X,:); 
        PP.Label.Title = [StrainLabels{j} ' - [IPTG] @' num2str(TurnFB_Cell{k,1}) ' \muM']; 
        
        PlotTFV(hFig,TurnFB,PP);
        
        %Export the figure 
        S.ExpPath = ExpPath;
        S.SubDir = 'TurnFrequency_MeanRunSpeed'; 
        S.Strain = StrainLabels{j}; 
        S.Stamp = Stamp;
        S.PlotY = 'TurnFreq_MeanV_Combined'; 
        S.IPTG = num2str(TurnFB_Cell{k,1}); 
        
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
 
 
 function [TF_MeanV, MeanV, X] = TurnFreq_MeanV(S,T,Edges,fps)
              
          %Find mean speed per bug 
          V = cellfun(@(x) nanmean(x(:,9)), S); 
          [N,Edge,Bins] = histcounts(V,Edges);
          
          %Preallocate 
          TrajDur = zeros(length(Edge)-1,1);
          TurnSum = zeros(length(Edge)-1,1);
          TF_MeanV = zeros(length(Edge)-1,1);
          
          for i = 1:length(Edge)-1
              Mask = Bins == i; 
              TSubset = T(Mask,:);
              
              %Discard the empty matrix entries 
              TurnMask = ~cellfun(@(x) isempty(x), TSubset(:,3));
              %Filter "T" matrix to get rid of trajectories with no turns 
              TSubsetFlt = TSubset(TurnMask,:); 
               
              TrajDur(i) = sum(cellfun(@(x) size(x,1)./fps, TSubsetFlt(:,1))); 
              TurnSum(i) = sum(cellfun(@(x) length(x), TSubsetFlt(:,3))); 
              
              TF_MeanV(i) = TurnSum(i)/TrajDur(i); 
          end
          MeanV = Edge;
          k = 1; 
          for j = 1:length(Edge)-1
              X(k) = mean([Edge(j), Edge(j+1)]); 
              k = k + 1; 
          end
 
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
          pHand = plot(X.X,X.Y,'o','MarkerSize',7,'Color',Clr,'LineWidth',1.5); 
          hold on 
          %Mean values
          meanTF = nanmean(X.Y,2); 
          stdTF = std(X.Y,0,2,'omitnan'); 
          errorbar(X.X,meanTF,stdTF,'.','MarkerSize',32,...
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


