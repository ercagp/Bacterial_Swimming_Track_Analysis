%% PDF estimates for Run speed distributions per bug with each run highlighted
%Each run has a separate color in the distribution 
%January 2021
%by Ercag
%from the v5 - Release notes:  "switch" mode was added to select mean, median or
%inst. speed distributions
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\RunAnalysis\SpeedAnalysis\Distributions\';
%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\Data';
StrainLabels = {'KMT43','KMT47','KMT53'}; 
%% User query to select which type of observable to plot 
disp('Which observable to plot?')
disp('1-)Instantaneous Speed')
disp('2-)Mean Speed')
disp('3-)Median Speed')
prompt = 'Enter the number of the observable to plot:\n'; 
n_Query = input(prompt); 

if n_Query  == 1 
   observable = 'instV';
elseif n_Query == 2 
    observable = 'meanV';
elseif n_Query == 3
    observable = 'medV'; 
end

prompt_BugNum = 'Enter the number of bugs to analyze \n';
nBug = input(prompt_BugNum);

%% Parameters
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5;

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

%RegExp Keys
RegKeyROI = 'ROI[_]\d'; 
RegKeyVD = ['(?<=Data' filesep filesep ')\d*']; %Video date

%Define Plot parameters 
PltPara.Normalization = 'count';
PltPara.DispStyle = 'stairs';
PltPara.FaceColor = 'none'; 
PltPara.LineWidth = 2; 
PltPara.Edges = 0:5:200; 
PltPara.Lim.X = [0 200]; 

%Define colormaps
ColorMap_Edges = linspecer(size(StrainLabels,2),'qualitative');

if strcmp(PltPara.Normalization,'PDF')
    PltPara.Label.YAx = 'PDF'; 
else
    PltPara.Label.YAx = 'Estimated Density'; 
end


for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Speeds_Flt = cell(length(Files),1);
    RunCell = cell(length(Files),1);
    RunCell_Flt = cell(length(Files),1);
    RunDur = cell(length(Files),1); 
    Temp = [];
    
    
    for i = 1:length(Files) 
        load(Files{i}) 
        
        minT = 3; %Results.minT; %Sample longer trajectories 
        minV = Results.minV; 
        
        fprintf(['minimum T =' num2str(minT) 'sec \n'])
        fprintf(['minimum V =' num2str(minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG;
        %Find ROIs and Video dates
        VideoDates = regexp(Files,RegKeyVD,'match','once');
        ROI = regexp(Files,RegKeyROI,'match','once');
        

        T = Results.T; 
        %Compute the cell containing run infomation 
        RunCell{i} = RunBreakDownv6(Speeds,T,fps);  %RunBreakDownv4(S,T,fps) --> The order
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        RunCell_Flt{i} = RunCell{i}(FilterMask,:); 
        
        switch observable 
               case 'instV'
                     %Select random "nBug" number of bugs 
                     BugRow = randi(size(RunCell_Flt{i},1),[1 nBug]); 
                     for k = 1:length(BugRow)
                         
                         InstV = RunCell_Flt{i}{BugRow(k),1};
                         BugNo = RunCell_Flt{i}{BugRow(k),3}; 
                         
                                                 
                         PltPara.Label.Title  = {[StrainLabels{j} ' @ ' num2str(IPTG(i)) '\muM [IPTG] - ' VideoDates{i}], [ROI{i} '- Bug #' num2str(BugNo)]};
                         PltPara.Label.XAx = 'V_{Run} (\mum/sec)';
                         
                         hFig = figure(k); 
                         X.X = InstV;
                         RunDist(X,PltPara,hFig);
                         drawnow();
                         
                         S.ExpPath = ExpPath; 
                         S.Strain = StrainLabels{j}; 
                         S.Stamp = Stamp;
                         S.PlotY = 'InstRunV'; 
                         S.IPTG = num2str(IPTG(i)); 
                         S.VD = VideoDates{i};
                         S.ROI = ROI{i};
                         S.BugNo = num2str(BugNo); 
            
                         ExportFig(hFig,S);
                     end
               case 'meanV'
                     BugRow = randi(size(RunCell_Flt{i},1),[1 nBug]); 
                     for k = 1:length(BugRow)
                         Temp = RunCell_Flt{i}{BugRow(k),2};
                         RunDur = Temp(:,1); 
                         MeanV = Temp(:,2);
                         
                         BugNo = RunCell_Flt{i}{BugRow(k),3}; 
                         
                         PltPara.NormSwitch = ''; 
                         PltPara.EdgeColor = ColorMap_Edges(j,:);
                         PltPara.Label.Title  = {[StrainLabels{j} ' @ ' num2str(IPTG(i)) '\muM [IPTG] - ' VideoDates{i}], [ROI{i} '- Bug #' num2str(BugNo)]};
                         PltPara.Label.XAx = '<V_{Run}> (\mum/sec)';
                         
                         hFig = figure(k); 
                         X.X = MeanV;
                         X.RunDur = RunDur; 
                         RunDist(X,PltPara,hFig);
                         drawnow();
                         
                                                  
                         S.ExpPath = ExpPath; 
                         S.Strain = StrainLabels{j}; 
                         S.Stamp = Stamp;
                         S.PlotY = 'MeanRunV'; 
                         S.IPTG = num2str(IPTG(i)); 
                         S.VD = VideoDates{i};
                         S.ROI = ROI{i};
                         S.BugNo = num2str(BugNo); 
                         
                         ExportFig(hFig,S);
                     end

               case 'medV'
                    continue
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

function ExportFig(hf,Strings)
                                                        
        FinalExpPath = fullfile(Strings.ExpPath,'RunSpeedsPerBug_HighlightedRuns',Strings.PlotY,Strings.Strain,[Strings.IPTG 'uM']);
        if ~exist(FinalExpPath,'dir')
            mkdir(FinalExpPath)
        end      
        FullFileName = [Strings.Stamp Strings.Strain '_' Strings.PlotY '_' Strings.VD '_IPTG_' Strings.IPTG 'uM_' Strings.ROI '_Bug#' Strings.BugNo];
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpng');
        printfig(hf,fullfile(FinalExpPath,FullFileName),'-dpdf');
end
function RunDenseH = RunDist(X,PltPara,hFig)
%         The input has now two components  
          XValues = X.X;   
          
          Edge = PltPara.Edges;
          DispStyle = PltPara.DispStyle;
          LineW = PltPara.LineWidth;
          FaceColor = PltPara.FaceColor;
          Norm = PltPara.Normalization; 
          %SelectedIPTG = PltPara.IPTGSel;
          AxLabel = PltPara.Label; 
          Lim = PltPara.Lim;
                  
          ColorMap_Runs = linspecer(length(XValues),'qualitative');
          for i = 1:length(XValues)
              [f,xi] = ksdensity(XValues{i});
              RunDenseH{i} = plot(xi,f,'Color',ColorMap_Runs(i,:),'LineWidth',1.5);
%               RunDistH{i} = histogram(XValues{i},Edge,'Normalization',Norm,'LineWidth',LineW,...
%                         'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',ColorMap_Runs(i,:));
              hold on            
          end
          hold off 
          PlotSty(hFig,AxLabel,Lim);
end


function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             if iscell(Y)
                %check what's inside Y 
                if iscell(Y{1})
                   R{i,2} = cell2mat(cellfun(@(x) cell2mat(x),Y(Mask),'UniformOutput',0));
                else
                   R{i,2} = cell2mat(Y(Mask)); 
                end
             else
                R{i,2} = Y(Mask); 
             end
         end
end

function PlotSty(hFig,Lab,Lim)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end

function SortandPutLeg(P,Handles,Labels)
         [~,LegendOrder] = sort(cell2mat(P(:,1)));
         legend([Handles{LegendOrder}],Labels{LegendOrder},'Location','NorthEast')
end
    