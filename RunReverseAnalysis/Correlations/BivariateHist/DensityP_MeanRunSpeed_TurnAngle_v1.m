%% Mean speed vs. Turn angle correlation (density) plots 
%January 2021
%by Ercag 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\AngularAnalysis';
%% Call the run reverse analysis files 
MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT43','KMT47','KMT53'};

%% User query to select which type of observable to plot 
disp('Which quantities to plot?')
disp('1-)Mean Speed Before vs. After Turns')
disp('2-)Mean Speed Before Turn vs. Turn Angles')
disp('3-)Mean Speed After Turn vs. Turn Angles')
disp('4-)Mean Run Speed vs. Run Times')
prompt = 'Enter the number of the observable to plot:\n'; 
n_Query = input(prompt); 

if n_Query  == 1 
   observable = 'MeanVBAT';
elseif n_Query == 2 
    observable = 'MeanVBT_TurnA';
elseif n_Query == 3
    observable = 'MeanVAT_TurnA'; 
elseif n_Query == 4
    observable = 'MeanV_RunTime'; 
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

% Define Histogram Parameters
PltPara.Normalization = 'PDF';


%% Load files and start the analysis 

for j = 1:length(StrainLabels)
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);    
    %Find ROIs and Video dates
    VideoDates = regexp(Files,RegKeyVD,'match','once');
    ROI = regexp(Files,RegKeyROI,'match','once');
    
    %Preallocate
    IPTG = zeros(length(Files),1);
    BeforeAfter = cell(length(Files),1);
    Runs = cell(length(Files),1);
    T = cell(length(Files),1);
    
    for i = 1:length(Files) 
        load(Files{i})
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        %Tabulate the mean speed data before and after turns
        [BeforeAfter{i}, Runs{i}, T{i}] = MatchSpeedTurnA(Speeds,Results,fps);
    end
    
    %Match different acq. with the same [IPTG]
    BeforeAfterMatch = matchrepeat(IPTG,BeforeAfter,T,'BeforeAfterDouble'); 
    RunsMatch = matchrepeat(IPTG,Runs,T,'RunCell'); 
    
    %Plot's title
    hFig = figure(1);
    switch observable 
           case 'MeanVBAT'
                 for k = 1:size(BeforeAfterMatch,1)   
                     MeanVB = BeforeAfterMatch{k,2}(:,1);
                     MeanVA = BeforeAfterMatch{k,2}(:,2);
                     
                     IPTG_Match = BeforeAfterMatch{k,1};
        
                     MeanV.X = MeanVB; 
                     MeanV.Y = MeanVA; 
                     
                     PltPara.Label.Title = [StrainLabels{j} ' - ' num2str(IPTG_Match) ' \muM [IPTG]']; 
                     PltPara.Label.XAx = 'Mean Speed Before Turn (\mum/sec)'; 
                     PltPara.Label.YAx = 'Mean Speed After Turn (\mum/sec)'; 
                     PltPara.Edges.X = 0:10:200; 
                     PltPara.Edges.Y = 0:10:200; 
                  
                     DensityP(MeanV,PltPara,hFig);
                     drawnow();
                  
                     %Export the figure 
                     S.ExpPath = ExpPath;
                     S.SubDir = 'DensityPlotCombinedAcq'; 
                     S.Strain = StrainLabels{j}; 
                     S.Stamp = Stamp;
                     S.PlotY = 'MeanRunSpeed_BeforeAfterTurn'; 
                     S.IPTG = num2str(IPTG_Match); 
                     
                     ExportFig(hFig,S);
                 end
             case 'MeanVBT_TurnA'
                  for k = 1:size(BeforeAfterMatch,1)
                      MeanVB = BeforeAfterMatch{k,2}(:,1);
                      Ang = BeforeAfterMatch{k,2}(:,3);
                  
                      IPTG_Match = BeforeAfterMatch{k,1};
                      
                      MeanV.X = MeanVB;
                      MeanV.Y = Ang; 
                  
                      PltPara.Label.Title = [StrainLabels{j} ' - ' num2str(IPTG_Match) ' \muM [IPTG]']; 
                      PltPara.Label.XAx = 'Mean Speed Before Turn (\mum/sec)'; 
                      PltPara.Label.YAx = 'Turn Angles (degrees)'; 
                      PltPara.Edges.X = 0:10:200; 
                      PltPara.Edges.Y = 0:10:180; 
                  
                      DensityP(MeanV,PltPara,hFig);
                      drawnow();
                  
                      %Export the figure 
                      S.ExpPath = ExpPath;
                      S.SubDir = 'DensityPlotCombinedAcq'; 
                      S.Strain = StrainLabels{j}; 
                      S.Stamp = Stamp;
                      S.PlotY = 'MeanRunSpeedBefore_TurnAngle'; 
                      S.IPTG = num2str(IPTG_Match); 

                      ExportFig(hFig,S);
                  end
            case 'MeanVAT_TurnA'
                  for k = 1:size(BeforeAfterMatch,1)
                      MeanVA = BeforeAfterMatch{k,2}(:,2);
                      Ang = BeforeAfterMatch{k,2}(:,3);
                       
                      IPTG_Match = BeforeAfterMatch{k,1};
                      
                      MeanV.X = MeanVA;
                      MeanV.Y = Ang; 
                      
                      PltPara.Label.Title = [StrainLabels{j} ' - ' num2str(IPTG_Match) ' \muM [IPTG]']; 
                      PltPara.Label.XAx = 'Mean Speed After Turn (\mum/sec)'; 
                      PltPara.Label.YAx = 'Turn Angles (degrees)'; 
                      PltPara.Edges.X = 0:10:200; 
                      PltPara.Edges.Y = 0:10:180; 
                  
                      DensityP(MeanV,PltPara,hFig);
                      drawnow();
                  
                      %Export the figure 
                      S.ExpPath = ExpPath;
                      S.SubDir = 'DensityPlotCombinedAcq'; 
                      S.Strain = StrainLabels{j}; 
                      S.Stamp = Stamp;
                      S.PlotY = 'MeanRunSpeedAfter_TurnAngle'; 
                      S.IPTG = num2str(IPTG_Match); 
                                       
                      ExportFig(hFig,S);
                  end
           case 'MeanV_RunTime'
                 for k = 1:size(RunsMatch,1)
                     
                     Temp = cell2mat(RunsMatch{k,2}); 
                     RunDur = Temp(:,1); %RunsMatch{k,2}(:,1);
                     MeanV = Temp(:,2); %RunsMatch{k,2}(:,2);
                     
                     IPTG_Match = RunsMatch{k,1};
                     
                     Var.X = RunDur;
                     Var.Y = MeanV; 
                     
                     PltPara.Label.Title = [StrainLabels{j} ' - ' num2str(IPTG_Match) ' \muM [IPTG]']; 
                     PltPara.Label.XAx = 'Run Times (sec)'; 
                     PltPara.Label.YAx = 'Mean Run Speed (\mum/sec)'; 
                     PltPara.Edges.X = 1/fps*[2.5, 4.5,  6.5,  8.5, 10.5, 13.5,  18.5,  28.5,  45, 65]; 
                     PltPara.Edges.Y = [0 30 75 150 200];
                                     
                     DensityP(Var,PltPara,hFig);
                     ax = gca; 
                     ax.YTick = PltPara.Edges.Y;
                     drawnow();
                        
                     %Export the figure 
                     S.ExpPath = ExpPath;
                     S.SubDir = 'DensityPlotCombinedAcq'; 
                     S.Strain = StrainLabels{j}; 
                     S.Stamp = Stamp;
                     S.PlotY = 'MeanRunSpeed_RunTime'; 
                     S.IPTG = num2str(IPTG_Match); 
                                       
                     ExportFig(hFig,S);   
                      
                 end
               
    end
    
end


 %% Functions 
 function [BeforeAfter,RunSubset,TSubset] = MatchSpeedTurnA(Speeds,R,fps) 
          %R: Results structure
          Runs = RunBreakDownv6(Speeds,R.T,fps);
          Angles = R.Ang(:,3); 
          
          FltMask = filterout(Speeds,R.minT,R.minV,fps); 
          RunSubset = Runs(FltMask,:);
          AngSubset = Angles(FltMask);
          TSubset = R.T(FltMask,:);
          
          BeforeAfter = cell(size(RunSubset,1),3);
         
          for i = 1:size(RunSubset,1)
              MeanRunS = RunSubset{i,2}(:,2);              
              %Mean speed before turn - 1st Column             
              BeforeAfter{i,1} = MeanRunS(1:end-1);
              %Mean speed after turn - 2nd Column              
              BeforeAfter{i,2} = MeanRunS(2:end);            
          end
          %Turn angles - 3rd column 
          BeforeAfter(:,3) = AngSubset; 
         
          %rectify cell2mat error by transposing empty matrices 
          Mask = cellfun(@isempty,BeforeAfter(:,1:2));
          BeforeAfter(Mask) = cellfun(@transpose,BeforeAfter(Mask),'UniformOutput',0);          
 end
 
function [FilterMask] = filterout(S,minT,minV,fps)

         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         %SSubset = S(FilterMask); 
end

function BiVar = DensityP(X,PltPara,hFig)
            
         AxLabel = PltPara.Label;
         
         fields = fieldnames(PltPara,'-full');
         
         if any(contains(fields,'Edges'))
            Edge.X = PltPara.Edges.X;
            Edge.Y = PltPara.Edges.Y; 
            BiVar = histogram2(X.X,X.Y,Edge.X,Edge.Y,'DisplayStyle','tile',...
                      'ShowEmptyBins','on',...
                      'Normalization',PltPara.Normalization);
            colorbar
         else
            BiVar = histogram2(X.X,X.Y,'DisplayStyle','tile',...
                      'ShowEmptyBins','on',...
                      'Normalization',PltPara.Normalization);
         end
         PlotSty(hFig,AxLabel)
             
end

function ExportFig(hf,Strings)
                                                        
        FinalExpPath = fullfile(Strings.ExpPath,Strings.SubDir,Strings.PlotY,Strings.Strain,[Strings.IPTG 'uM']);
        if ~exist(FinalExpPath,'dir')
            mkdir(FinalExpPath)
        end      
        FullFileName = [Strings.Stamp Strings.Strain '_' Strings.PlotY '_IPTG_' Strings.IPTG 'uM'];
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpng');
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpdf');
end

 function R = matchrepeat(X,Y,TCell,Type)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             YSubset = Y(Mask);
             TSubset = TCell(Mask); 
             
             if strcmp(Type,'RunCell')
                 R{i,2} = [];
                 for j = 1:size(YSubset,1)
                     %Calculate the length of RunEnd and RunStart Vectors                      
                     L = cellfun(@length,TSubset{j}); 
                     
                     %MaskTwT = (L(:,2) ~= 0) & (L(:,3) ~= 0) & (L(:,2) < L(:,3));  
                     
                     %Match ONLY complete runs! 
                     %Mask for the trajectories ending with a run
                     MaskNoTurn = (L(:,2) > 1) & (L(:,3) > 1) & (L(:,2) >= L(:,3));
                     %Mask for the trajectories ending with a turn 
                     MaskTurn = (L(:,2) > 0) & (L(:,3) > 0) & (L(:,2) < L(:,3));
                     
                     %Runs of the trajectories ending with a run 
                     RunsComplete_NoTurn = cellfun(@(x) x(2:end-1,:),YSubset{j}(MaskNoTurn,2),'UniformOutput',false);

                     %Runs of the trajectories ending with a turn
                     RunsComplete_Turn = cellfun(@(x) x(2:end,:),YSubset{j}(MaskTurn,2),'UniformOutput',false);
                     
                     R{i,2} = [R{i,2}; RunsComplete_NoTurn; RunsComplete_Turn]; 
                     %R{i,2} = cellfun(@(x) cell2mat(x(:,2)), YSubset, 'UniformOutput', false);
                 end
             else 
                 R{i,2} = cell2mat(cellfun(@(x) cell2mat(x), YSubset, 'UniformOutput', false));
             end
         end
end

function PlotSty(hFig,Lab)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         %ax.XLim = Lim.X;
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end




