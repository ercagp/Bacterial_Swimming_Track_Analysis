%% Plot turning frequency vs. [IPTG] & Turning Freq. vs. Mean Population Speed 
% January 2021
%by Ercag 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverseAnalysis\EventRates';
%% Call the run reverse analysis files 
MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT53'};

%% User query to select which type of observable to plot 
disp('Which quantities to plot?')
disp('1-)Turn Frequency vs [IPTG]')
disp('2-)Turn Frequency vs. Average Swimming Speed')
disp('3-)')
disp('4-)')
prompt = 'Enter the number of the observable to plot:\n'; 
n_Query = input(prompt); 

if n_Query  == 1 
   observable = 'TurnFreq_IPTG';
elseif n_Query == 2 
    observable = 'TurnFreq_meanV';
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
RegKeyVD = ['(?<=Data' filesep ')\d*'];

%IPTG vector for the plot 
IPTG_X = [0, 25, 35, 50, 75, 100]; 

%Plot parameters 
PP.Lab.XAx = '[IPTG] (\muM)'; 
PP.Lab.YAx = 'Turn Frequency (sec^{-1})';
PP.Lim.X  = [-5 105]; 
PP.Lim.Y  = [0 1.5]; 
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
                
    for i = 1:length(Files) 
        load(Files{i})
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        TurnSum(i) = RunReverse.TotalTurns;

                
        switch observable 
            case 'TurnFreq_IPTG'
                  hFig = figure(1);
                  FltMask =  filterout(Speeds,Results.minT,Results.minV,fps);
                  SpeedSubset = Speeds(FltMask); 
                                                                                         
                  TrajDur(i) = sum(cellfun(@(x) size(x(:,1),1)./fps,SpeedSubset));                                      
                  TurnFreq(i) = TurnSum(i)/TrajDur(i);
                   
                  %Turning Freq. vs. [IPTG]
                  if IPTG(i) == 1
                     IPTG_Plot(i) = IPTG(i)*1000;
                  else
                     IPTG_Plot(i) = IPTG(i);
                  end
                  
                  if strcmp(VideoDates{i},'20210624')
                        Purple = [0.29,0.078,0.52]; 
                        plot(IPTG_Plot(i),TurnFreq(i),'x','MarkerSize',12,'Color',Purple,'LineWidth',2.5);
                  else
                     pH{j} = plot(IPTG_Plot(i),TurnFreq(i),'o','MarkerSize',7,'Color',ColorMap(j,:));
                  end
                  
                  PlotSty(hFig,PP.Lab,PP.Lim)
                  hold on 
                  
                  if i == length(Files)
                     R = matchrepeat(IPTG,TurnFreq);
                     RMean = cellfun(@mean,R); 
                     RStd = cellfun(@std,R); 
                     RMean(RMean(:,1) == 1,1) = RMean(RMean(:,1) == 1,1).*1000;
                     
                     pH_mean{j} = plot(RMean(:,1),RMean(:,2),'.','MarkerSize',30,'Color',ColorMap(j,:)); 
                     pH_std{j} = errorbar(RMean(:,1),RMean(:,2),RStd(:,2),'both','o','Color',ColorMap(j,:),...
                                          'LineWidth',1.25);
                     ax = gca; 
                     ax.XTick = IPTG_X; 
                     grid on;
                     if j == length(StrainLabels)
                        legend([pH{1:end}],StrainLabels,'Location','NorthWest')
                        %Export the figure 
                        S.ExpPath = ExpPath;
                        S.SubDir = 'TurnFrequency_[IPTG]'; 
                        S.Stamp = Stamp;
                        S.PlotY = 'TurnFreq[IPTG]'; 
                        S.ExpType = 'Combined'; 
                   
                        ExportFig(hFig,S)
                     end
                  end

                                                    
            case 'TurnFreq_meanV'
                hFig = figure(i);

                FltMask =  filterout(Speeds,Results.minT,Results.minV,fps);
                SpeedsFlt = Speeds(FltMask); 
                EdgeVec = 0:10:200; 
                [TurnFreq_Bin, MeanV, X] = TurnFreq_MeanV(SpeedsFlt,Results.T,EdgeVec,fps); 
                PltPara.XLim = [0,200];
                PltPara.YLim = [0,1.5]; 
                PltPara.Label.XAx = 'Mean Speed (\mum /sec)';
                PltPara.Label.YAx = 'Turning Frequency (sec^{-1})';
                PltPara.Label.Title = {[StrainLabels{j} ' - ' VideoDates{i}], [num2str(IPTG(i)) ' \muM [IPTG] - ' ROI{i}]}; 
                PltPara.Color = ColorMap(j,:); %Separate colors for each  
                
                PltPara.XTick = 0:20:200; 
                Plt.X = X;
                Plt.Y = TurnFreq_Bin;
                PlotTFV(hFig,Plt,PltPara);

                %Export the figure 
                S.ExpPath = ExpPath;
                S.SubDir = 'TurnFrequency_MeanRunSpeed'; 
                S.Strain = StrainLabels{j}; 
                S.Stamp = Stamp;
                S.PlotY = 'TurnFreq_MeanV_PerAcq'; 
                S.IPTG = num2str(IPTG(i)); 
                S.VD = VideoDates{i};
                S.ROI = ROI{i};
                S.ExpType = 'PerAcq';
                
                ExportFig(hFig,S);

            %case ''

            %case ''

        end
    end
    %close all; 
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
         %ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         ax.YLim = Lim.Y; 
         ax.XScale = 'lin';
         ErcagGraphics
         %settightplot(ax); 
end

