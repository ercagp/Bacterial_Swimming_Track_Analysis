%% Average Population Velocity vs. Turning Frequency 
% by Ercag 
% June 2021 
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT53'};

%% User query to select which type of observable to plot 
disp('Which quantities to plot?')
disp('1-)Mean Population Speed vs. Turn Frequency')
disp('2-)Mean Population Speed vs. [IPTG]')
disp('3-)Median Population Speed vs. Turn Frequency')
disp('4-)Top Population Speed vs. Turn Frequency')
prompt = 'Enter the number of the observable to plot:\n'; 
n_Query = input(prompt); 


if n_Query  == 1 
   observable = 'MeanV_TurnFreq';
elseif n_Query == 2 
    observable = 'MeanV_IPTG';
elseif n_Query == 3
    observable = 'MedV_TurnFreq'; 
elseif n_Query == 4
    observable = 'TopSpeed_TurnFreq'; 
end

%% Input parameters 
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5; 

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

%RegExp Keys
RegKeyROI = 'ROI[_]\d';
RegKeyVD = ['(?<=Data' filesep ')\d*'];


%IPTG vector for the plot 
IPTG_X = [0, 25, 35, 50, 60, 75, 100,1000]; 

%Plot parameters 
PP.Lab.XAx = 'Mean Speed per Acq.(\mum/sec)'; 
PP.Lab.YAx = 'Turn Frequency (sec^{-1})';
PP.Lim.X  = [40 120]; 
PP.Lim.Y  = [0 2.55]; 
ColorMap = linspecer(length(StrainLabels),'qualitative'); 
ColorMap_IPTG = linspecer(length(IPTG_X),'qualitative'); 

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
    TurnFreq = zeros(length(Files),1);
    AllSpeeds = cell(length(Files),1);
    MeanSpeeds_perAcq = zeros(length(Files),1);
    pH = cell(length(IPTG_X),1); 
    
    
for i = 1:length(Files) 
        load(Files{i})
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        TurnSum(i) = RunReverse.TotalTurns;
        %Plot title
        PP.Lab.Title = StrainLabels{j}; 

        switch observable 
            case 'MeanV_TurnFreq'
                  hFig = figure(j);
                  FltMask =  filterout(Speeds,Results.minT,Results.minV,fps);
                  SpeedSubset = Speeds(FltMask); 
                                                                      
                  TrajDur(i) = sum(cellfun(@(x) size(x(:,1),1)./fps,SpeedSubset)); 
                  AllSpeeds{i} = cell2mat(cellfun(@(x) x(:,9), SpeedSubset, 'UniformOutput', false));
                  MeanSpeeds_perAcq(i) = mean(AllSpeeds{i},'omitnan'); 
                  TurnFreq(i) = TurnSum(i)/TrajDur(i);
                  
                  
                 
                  
                  if strcmp(VideoDates{i},'20210624')
                        Purple = [0.29,0.078,0.52]; 
                        plot(MeanSpeeds_perAcq(i),TurnFreq(i),'x','MarkerSize',12,'Color',Purple,'LineWidth',2.5);
                   
                  else
                     %unique [IPTG] index
                     if IPTG(i) == 1
                         IP = find(1000 == IPTG_X);
                     else
                         IP = find(IPTG(i) == IPTG_X);
                     end
                     pH{IP} = plot(MeanSpeeds_perAcq(i),TurnFreq(i),'o','MarkerSize',9,'Color',ColorMap_IPTG(IP,:),'LineWidth',1.5);
                     
                  end
                  

                  PlotSty(hFig,PP.Lab,PP.Lim)
                  hold on 
                  
                  if i == length(Files)
                       R = matchrepeat(IPTG,TurnFreq);
                       RSpeeds = matchrepeat(IPTG,AllSpeeds); 
                       RMeanSpeeds = [[RSpeeds{:,1}]', cellfun(@(x) mean(cell2mat(x),'omitnan'), RSpeeds(:,2), 'UniformOutput', true)]; 
                       RMeanTF = cellfun(@mean,R); 
                       RStd = cellfun(@std,R); 
                       RMean(RMean(:,1) == 1,1) = RMean(RMean(:,1) == 1,1).*1000;
                      
                       pH_mean{j} = plot(RMean(:,1),RMean(:,2),'.','MarkerSize',30,'Color',ColorMap(j,:)); 
                       pH_std{j} = errorbar(RMean(:,1),RMean(:,2),RStd(:,2),'both','o','Color',ColorMap(j,:),...
                                           'LineWidth',1.25);
                       plot(RMeanSpeeds(:,2)',RMeanTF(:,2)','.','MarkerSize',30,'Color',ColorMap_IPTG); 
                       ax = gca; 
                       ax.XTick = IPTG_X; 
                       grid on;
                       legend([pH{1:end}],num2str(IPTG_X'),'Location','NorthEast');
                       %Export the figure 
%                         S.ExpPath = ExpPath;
%                         S.SubDir = 'TurnFrequency_[IPTG]'; 
%                         S.Stamp = Stamp;
%                         S.PlotY = 'TurnFreq[IPTG]'; 
%                         S.ExpType = 'Combined'; 
%                    
%                         ExportFig(hFig,S)
%                      
                   end
        end
end
end
%% Functions 
function [FilterMask] = filterout(S,minT,minV,fps)

         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         %SSubset = S(FilterMask); 
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

 function R = matchrepeat(X,Y)
          UX = unique(X,'stable');
          R = cell(length(UX),2);
          for i = 1:length(UX)
              Mask = X == UX(i);
              R{i,1} = unique(X(Mask));
              R{i,2} = Y(Mask);             
          end         
 end


 function [TF_MeanV, MeanV, X] = TurnFreq_MeanV(S,T,Edges,fps)
          %Find mean speed per bug 
          V = cellfun(@(x) nanmean(x(:,9)), S); 
          [N,Edge,Bins] = histcounts(V,Edges);
          for i = 1:length(Edge)-1
              Mask = Bins == i; 
              TSubset = T(Mask,:);             
              TrajDur(i) = sum(cellfun(@(x) size(x,1)./fps, TSubset(:,1))); 
              TurnSum(i) = sum(cellfun(@(x) length(x), TSubset(:,3))); 
              
              TF_MeanV(i) = TurnSum(i)/TrajDur(i); 
          end
          MeanV = Edge;
          k = 1; 
          for j = 1:length(Edge)-1
              X(k) = mean([Edge(j), Edge(j+1)]); 
              k = k + 1; 
          end
 
 end
 
 function pHand = PlotTFV(hf,X,Para)
          
          Clr = Para.Color;  
          pHand = plot(X.X,X.Y,'o','MarkerSize',8,'Color',Clr,'LineWidth',1.5); 
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
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         ax.YLim = Lim.Y; 
         ax.XScale = 'lin';
         ErcagGraphics
         %settightplot(ax); 
end

