%% Plot Run Duration(aka Times) Distributions (1-CDF & PDFs)
% February 2021
%v5 - this version separates run-time distributions in four different mean
% speed binning [0-35],[35-75],[75-150] & [150-200] um/sec. 
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
PP.Lim.X  = [0, 2.5]; 
PP.Edges = 1/fps.*[(2.5:2:75), 76.5];
PP.Norm = 'PDF'; 
PP.LineWidth = 2.0;
PP.SpeedEdges = [0,35,75,200]; %um/sec 
%Which speed bin to plot? 
PP.SelectedBin = 1; %[75-200]; 



%Selected IPTG value
% IPTG_Sel = 100; %uM
% hand_Select = cell(length(StrainLabels),1); 
%% Calculate Run Durations
for j = 1:length(StrainLabels)
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);    
    %Find ROIs and Video dates
    VideoDates = regexp(Files,RegKeyVD,'match','once');
    ROI = regexp(Files,RegKeyROI,'match','once');
   
    %Preallocate
    IPTG = zeros(length(Files),1);
    TSub = cell(length(Files),1);
    RunSub =  cell(length(Files),1);
    for i = 1:length(Files)
        load(Files{i}) 
        
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        %Filter out run-reverse cell and yield subsets of the T-cell &
        %Run-cells 
        [~,RunSub{i},TSub{i}] = MakeSubsets(Speeds,Results,fps); 
    end
      

     %Match IPTG & Run Duration values
     RunCell_Combined = matchrepeat(IPTG,RunSub,TSub);
     %Define colormaps for different & selected [IPTG] values 
     ColorMap_Edges = linspecer(size(RunCell_Combined,1),'qualitative');
     ColorMap_Sel = linspecer(size(StrainLabels,2),'qualitative'); 
     %Preallocate 
     IPTG_S = cell(size(RunCell_Combined,1),1); 
     IPTG_Num = zeros(size(RunCell_Combined,1),1); 
     h_PDF = cell(size(RunCell_Combined,1),1); 
     h_CDF = cell(size(RunCell_Combined,1),1); 
        
     for k = 1:size(RunCell_Combined,1)    
         RunCellMat = cell2mat(RunCell_Combined{k,2});
         
         IPTG_Num(k) = RunCell_Combined{k,1}; 
         IPTG_S{k} = [num2str(IPTG_Num(k)) ' \muM'];
                 
         %Plot's title 
         PP.Label.Title = [StrainLabels{j} ' - [IPTG] = ' IPTG_S{k}];
         hFig = figure(j);
         switch observable 
                case 'RunDurPDF'

                  PP.Label.XAx = 'Run Duration (sec.)'; 
                  PP.EdgeColor = ColorMap_Sel(j,:); 
                  if strcmp(PP.Norm,'PDF')                 
                     PP.Label.YAx = 'PDF'; 
                  else
                     PP.Label.YAx = 'Counts'; 
                  end
                  
                  %Plot Run Duration Dist. 
                  h_PDF{k} = HistRunDur(RunCellMat,PP,hFig);
                  drawnow(); 
                  PlotSty(hFig,PP);
                  
                  %Export the figure 
                  S.ExpPath = ExpPath;
                  S.SubDir = ''; 
                  S.Strain = StrainLabels{j}; 
                  S.Stamp = Stamp;
                  S.PlotY = ['RunTimes_' num2str(PP.SpeedEdges(PP.SelectedBin)) ' - ' num2str(PP.SpeedEdges(PP.SelectedBin+1)) ' um_sec']; 
                  S.IPTG = num2str(IPTG_Num(k)); 
                  S.ExpType = '';
                      
                  ExportFig(hFig,S);
                  
                  
%                   if IPTG_Num(k) == IPTG_Sel
%                      hfSelect = figure(40); 
%                      PPSelect = PP; %Pass the properties pf PP to PPSelect; 
%                      PPSelect.EdgeColor = ColorMap_Sel(j,:);
%                      PPSelect.Label.Title = ['[IPTG] = ' num2str(IPTG_Sel) ' \muM']; 
%                       
%                      hand_Select{j} =  HistRunDur(RunCellMat,PPSelect,hfSelect);
%                      drawnow(); 
%                      PlotSty(hfSelect,PPSelect);
%                      hold on  
%                      
%                      FinalExpPath_Select = fullfile(ExpPath,S.PlotY);
%                      FullFileName_Select = [Stamp 'Selected_' S.PlotY '_IPTG_' num2str(IPTG_Sel) 'uM'];
%                   end                      
                      
                      
            case '1_CDF' 
                 PP.Label.XAx = 'Run Duration (sec.)'; 
                 PP.Label.YAx = '1-CDF'; 
                 PP.EdgeColor = ColorMap_Sel(j,:); 
                 PP.Norm = 'count';
                  
                 [CDF,~] = histcounts(RD,PP.Edges,'Normalization','cdf');
                
                 h_CDF{k} = HistRunDur(1-CDF,PP,hFig);
                 drawnow(); 
                 PlotSty(hFig,PP);
                 ax = gca;
                 ax.YScale = 'log'; 
                  

                  %Export the figure 
                  S.ExpPath = ExpPath;
                  S.SubDir = ''; 
                  S.Strain = StrainLabels{j}; 
                  S.Stamp = Stamp;
                  S.PlotY = '1_CDF'; 
                  S.IPTG = num2str(IPTG_Num(k)); 
                  S.ExpType = '';
                  
                  %ExportFig(hFig,S);
                  
%                   if IPTG_Num(k) == IPTG_Sel
%                      hfSelect = figure(40); 
%                      PPSelect = PP; %Pass the properties pf PP to PPSelect; 
%                      PPSelect.EdgeColor = ColorMap_Sel(j,:);
%                      PPSelect.Label.Title = ['[IPTG] = ' num2str(IPTG_Sel) ' \muM']; 
%                      PPSelect.Edges = PP.Edges; 
%                       
%                      [CDF_Select,~] = histcounts(RD,PPSelect.Edges,'Normalization','cdf');
%                 
%                      hand_Select{j} = HistRunDur(1-CDF_Select,PPSelect,hfSelect);
%                      drawnow(); 
%                      PlotSty(hfSelect,PPSelect);
%                      ax_S = gca;
%                      ax_S.YScale = 'log'; 
%                      
%                      hold on  
%                      
%                      FinalExpPath_Select = fullfile(ExpPath,S.PlotY);
%                      FullFileName_Select = [Stamp 'Selected_' S.PlotY '_IPTG_' num2str(IPTG_Sel) 'uM'];
%                   end                
          end

     end
% figure(hfSelect) 
% legend([hand_Select{1:end}], StrainLabels,'Location','NorthEast');
% %Export the figure of selected [IPTG] 
% printfig(hfSelect,fullfile(FinalExpPath_Select,FullFileName_Select),'-dpng');
% printfig(hfSelect,fullfile(FinalExpPath_Select,FullFileName_Select),'-dpdf');
% savefig(hfSelect,fullfile(FinalExpPath_Select,FullFileName_Select));
end


%% Functions 
function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
end

function [AngSubset,RunSubset,TSubset] = MakeSubsets(Speeds,R,fps) 
          %R: Results structure
          Runs = RunBreakDownv6(Speeds,R.T,fps);
          Angles = R.Ang(:,3); 
          
          [~,FltMask] = filterout(Speeds,R.minT,R.minV,fps); 
          RunSubset = Runs(FltMask,:);
          AngSubset = Angles(FltMask);
          TSubset = R.T(FltMask,:);          
 end


function Hist = HistRunDur(X,PltPara,hFig)
         
         figure(hFig);        
         %Edges for the run durations
         DurEdges = PltPara.Edges; 
         Norm = PltPara.Norm; 
         LineWidth = PltPara.LineWidth; 
         %Edges for speed binning
         SpeedEdges = PltPara.SpeedEdges; 
         %Which speed bin to plot? 
         SelectedBin = PltPara.SelectedBin; 
         
         ColorMapBins = linspecer(length(SpeedEdges)-1,'qualitative');
         
                          
         %Perform speed binning 
         [~,~,BinI] = histcounts(X(:,2),SpeedEdges);
         
         
         
         MaskSpeeds = BinI == SelectedBin;             
             
         %Isolate run durations in the i^th bin 
         RunDurBin = X(MaskSpeeds,1);
         
         [N_PDF,~] = histcounts(RunDurBin,DurEdges,'Normalization','PDF'); 
         
             
         %Gamma fit 
         GammaPD = fitdist(RunDurBin,'Gamma');
         XFit = linspace(PltPara.Lim.X(1),PltPara.Lim.X(2),1000); 
             
         %Exponential fit 
         %Find the peak of the dist. 
         Peak_Ind = N_PDF == max(N_PDF);
         PeakEdge = DurEdges(Peak_Ind); 
         
         
         %Fit exponential function starting from the peak value          
         ExpPD = fitdist(RunDurBin(RunDurBin >= PeakEdge),'Exponential');
         
         %Set the edge color 
         EdgeColor = ColorMapBins(SelectedBin,:); 
             
         if strcmp(Norm,'PDF')
            Hist = histogram(RunDurBin,DurEdges,...
                            'EdgeColor',EdgeColor,...
                            'Normalization',Norm,...
                            'DisplayStyle','Stairs',...
                            'LineWidth',LineWidth); 
             hold on 
             %Plot Gamma Fit              
             Y_Gamma = pdf(GammaPD,XFit);
             HandGamma = plot(XFit,Y_Gamma,'-','LineWidth',LineWidth,'Color',EdgeColor);
                     
             Y_Exp = pdf(ExpPD,XFit);
             HandExp = plot(XFit,Y_Exp,'--','LineWidth',LineWidth,'Color',EdgeColor);                                                                              
          else
          %The part for 1-CDF plot must be updated!!! 
          Hist = histogram('BinEdges',DurEdges,'BinCounts',RunDurBin,...
                            'EdgeColor',EdgeColor,...
                            'Normalization',Norm,...
                            'DisplayStyle','Stairs',...
                            'LineWidth',LineWidth); 
          %The part for 1-CDF plot must be updated!!!
          end
          
          SpeedEdgeStr = [num2str(SpeedEdges(SelectedBin)) ' - ' num2str(SpeedEdges(SelectedBin+1)) ' \mum/s'];
             
         
         
          legend([Hist, HandGamma, HandExp],{SpeedEdgeStr,'Gamma Fit','Exp. Fit'},'Location','NorthEast');
          hold off
end

function ExportFig(hf,Strings)
                                                                  
        if strcmp(Strings.ExpType,'PerAcq')
           FinalExpPath = fullfile(Strings.ExpPath,Strings.SubDir,Strings.PlotY,Strings.Strain,[Strings.IPTG 'uM']);
           FullFileName = [Strings.Stamp Strings.Strain '_' Strings.PlotY '_' Strings.VD '_IPTG_' Strings.IPTG 'uM_' Strings.ROI];
        else
           FinalExpPath = fullfile(Strings.ExpPath,Strings.SubDir,Strings.PlotY,Strings.Strain,[Strings.IPTG 'uM']);
           FullFileName = [Strings.Stamp Strings.Strain '_' Strings.PlotY '_IPTG_' Strings.IPTG 'uM'];
        end
        
        if ~exist(FinalExpPath,'dir')
            mkdir(FinalExpPath)
        end   
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpng');
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpdf');
        savefig(hf,fullfile(FinalExpPath,FullFileName));
end

function R = matchrepeat(X,Y,TCell)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             YSubset = Y(Mask);
             TSubset = TCell(Mask); 
             
             R{i,2} = [];
             for j = 1:size(YSubset,1)
                 %Calculate the length of RunEnd and RunStart Vectors                      
                 L = cellfun(@length,TSubset{j}); 
                                        
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
              end
         end
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