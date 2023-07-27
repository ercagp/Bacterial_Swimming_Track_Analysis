%% Run speed distributions and other related plots
%January 2021
%by Ercag
%v5 - Release notes:  "switch" mode was added to select mean, median or
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

prompt_IPTG = 'Select the [IPTG] to compare different strains \n';
disp('Which observable to plot?')
disp('1-)0 uM')
disp('2-)25 uM')
disp('3-)35 uM')
disp('4-)50 uM')
disp('5-)60 uM')
disp('6-)75 uM')
disp('7-)100 uM')
disp('8-)1000 uM')

IPTG_Query = input(prompt_IPTG);
IPTG_All = [0 25 35 50 60 75 100 1];
log_IPTGSel = false(1,length(IPTG_All));
log_IPTGSel(IPTG_Query) = true; 

%Selected [IPTG] value and preallocation 
IPTG_Sel = IPTG_All(log_IPTGSel); %uM 
SelInd = 1; %Selected plot counter
InstRS_Sel_Handle = cell(size(StrainLabels,2),1); 
MeanRS_Sel_Handle = cell(size(StrainLabels,2),1);
MedRS_Sel_Handle = cell(size(StrainLabels,2),1);

%% Parameters
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5;

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

%Define Plot parameters 
PltPara.Normalization = 'PDF';
PltPara.DispStyle = 'stairs';
PltPara.FaceColor = 'none'; 
PltPara.LineWidth = 2; 
PltPara.Edges = 0:5:200; 
PltPara.Lim.X = [0 200]; 

if strcmp(PltPara.Normalization,'PDF')
    PltPara.Label.YAx = 'PDF'; 
else
    PltPara.Label.YAx = 'Counts'; 
end

PltParaSelect.Normalization = 'PDF';
PltParaSelect.LineWidth = 2; 
PltParaSelect.Edges = 0:5:200; 
PltParaSelect.Lim.X = [0 200]; 
PltParaSelect.DispStyle = 'stairs'; 
PltParaSelect.FaceColor = 'none'; 
if strcmp(PltParaSelect.Normalization,'PDF')
    PltParaSelect.Label.YAx = 'PDF'; 
else
    PltParaSelect.Label.YAx = 'Counts'; 
end

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Speeds_Flt = cell(length(Files),1);
    RunCell = cell(length(Files),1);
    RunCell_Flt = cell(length(Files),1);
    InstRunSpeed = cell(length(Files),1);
    MeanRunSpeed = cell(length(Files),1);
    RunDur = cell(length(Files),1); 
    Temp = [];
    
    
    for i = 1:length(Files) 
        load(Files{i}) 
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 
        %Compute the cell containing run infomation 
        RunCell{i} = RunBreakDownv5(Speeds,T,fps);  %RunBreakDownv4(S,T,fps) --> The order
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        RunCell_Flt{i} = RunCell{i}(FilterMask,:); 
        
        InstRunSpeed{i} = cell2mat(RunCell_Flt{i}(:,1)); 
        Temp = cell2mat(RunCell_Flt{i}(:,2)); 
        %Duration of each run 
        RunDur{i} = Temp(:,1);
        %Mean speeds of runs 
        MeanRunSpeed{i} = Temp(:,2); 
        
        %hf = figure(i);
        %PltPara.Label.Title  = {[StrainLabels{j} '@' num2str(IPTG(i)) '\muM [IPTG]'], 'Instantaneous Run Speed'};
        %PltPara.Label.XAx = 'V_{Run} (\mum/sec)';
        %PltPara.EdgeColor = ColorMap_Edges(j,:);        
        %IS.X = InstRunSpeed{i};
        %IS.RunDur = [];
        %InstRH{i} = RunDist(IS, PltPara, hf);
        
    end
    InstRS = matchrepeat(IPTG,InstRunSpeed);
    MeanRS = matchrepeat(IPTG,MeanRunSpeed); 
    RunDurRS = matchrepeat(IPTG,RunDur); 
    
    %Define colormaps for different & selected [IPTG] values 
    ColorMap_Edges = linspecer(size(InstRS,1),'qualitative');
    ColorMap_Sel = linspecer(size(StrainLabels,2),'qualitative'); 
    
    IPTGLabel = cell(size(InstRS,1),1);

    

            switch observable 
                case 'instV'
                      InstRS_Handle = cell(size(InstRS,1),1); 
                      for k = 1:size(InstRS,1)
                          IPTG_Num(k) = InstRS{k,1};
                          IPTGLabel{k} = [num2str(IPTG_Num(k)) '\muM'];
                          IRS.X = InstRS{k,2}; %Instantaneous run speeds 
                          IRS.RunDur = [];
                          
                          hf = figure(j);
                          %Impose the colormap 
                          PltPara.EdgeColor = ColorMap_Edges(k,:);
                          PltPara.Label.Title  = {StrainLabels{j}, 'Instantaneous Run Speed'};
                          PltPara.Label.XAx = 'V_{Run} (\mum/sec)';
                          %Weighted or not? 
                          PltPara.NormSwitch = '';
                          
                          InstRS_Handle{k} = RunDist(IRS, PltPara, hf);
                          hold on 
                          drawnow();
                      
                          %Compare strains fixed [IPTG]
                          if IPTG_Num(k) == IPTG_Sel
                             hf_select = figure(40);
                             PltParaSelect.EdgeColor = ColorMap_Sel(SelInd,:);
                             PltParaSelect.Label.XAx = 'V_{Run} (\mum/sec)';
                             PltParaSelect.Label.Title = ['Instantaneous Run Speed @ ' IPTGLabel{k} ' [IPTG]']; 
                             %Weighted or not? 
                             PltParaSelect.NormSwitch = ''; 
                             InstRS_Sel_Handle{SelInd} =  RunDist(IRS,PltParaSelect,hf_select);
                             hold on 
                             SelInd = SelInd + 1; 
                          end
                      end
                      figure(hf)
                      %Create export folder 
                      FinalExpPath = fullfile(ExpPath,'InstantaneousRunSpeed',StrainLabels{j}); 
                      if ~exist(FinalExpPath,'dir')
                         mkdir(FinalExpPath)
                      end
       
                      SortandPutLeg(InstRS,InstRS_Handle,IPTGLabel)
                      %Print instantaneous speed plot
                      printfig(hf,fullfile(FinalExpPath,[Stamp '[InstRunSpeed]' StrainLabels{j}...
                               '.pdf']),'-dpdf');
             
                      printfig(hf,fullfile(FinalExpPath,[Stamp '[InstRunSpeed]' StrainLabels{j}...
                               '.png']),'-dpng');
                          
                case 'meanV'
                      MeanRS_Handle = cell(size(MeanRS,1),1);
                      for k = 1:size(MeanRS,1)
                          
                          IPTG_Num(k) = MeanRS{k,1};
                          IPTGLabel{k} = [num2str(IPTG_Num(k)) '\muM'];

                          MRS.X = MeanRS{k,2}; %Mean Run Speeds
                          MRS.RunDur = RunDurRS{k,2};
                     
                          hf = figure(j);
                          %Impose the colormap 
                          PltPara.EdgeColor = ColorMap_Edges(k,:);
                          PltPara.Label.Title  = {StrainLabels{j}, 'Mean Run Speed'};
                          PltPara.Label.XAx = '<V>_{Run} (\mum/sec)';
                          
                          %Weighted or not? 
                          PltPara.NormSwitch = '';                      
                          
                          if strcmp(PltPara.NormSwitch,'weighted')
                             PltPara.Label.Title  = {StrainLabels{j}, 'Weighted Mean Run Speed'};
                          else
                             PltPara.Label.Title  = {StrainLabels{j}, 'Mean Run Speed'};
                          end
                    
                          MeanRS_Handle{k} = RunDist(MRS, PltPara, hf); 
                          hold on
                          drawnow();
                     
                         %Compare strains fixed [IPTG]
                         if IPTG_Num(k) == IPTG_Sel
                            hf_select = figure(40);
                            PltParaSelect.EdgeColor = ColorMap_Sel(SelInd,:);
                            %Weighted or not? 
                            PltParaSelect.NormSwitch = PltPara.NormSwitch; 
                            
                            if strcmp(PltParaSelect.NormSwitch,'weighted')
                               PltParaSelect.Label.Title =  ['Weighted Mean Run Speed @ ' IPTGLabel{k} ' [IPTG]'];
                               PltParaSelect.Label.XAx = 'Weighted Mean Run Speed (\mum/sec)';
                            else
                               PltParaSelect.Label.Title =  ['Mean Run Speed @ ' IPTGLabel{k} ' [IPTG]'];
                               PltParaSelect.Label.XAx = '<V>_{Run} (\mum/sec)';

                            end
                            
                            MeanRS_Sel_Handle{SelInd} =  RunDist(MRS,PltParaSelect,hf_select);
                            hold on 
                            SelInd = SelInd + 1; 
                         end
                         
                      end
                      figure(hf)
                      %Create export folder 
                      FinalExpPath = fullfile(ExpPath,'MeanRunSpeed',StrainLabels{j}); 
                      if ~exist(FinalExpPath,'dir')
                         mkdir(FinalExpPath)
                      end
                      %Print mean speed plot
                      SortandPutLeg(MeanRS,MeanRS_Handle,IPTGLabel)
       
                      %Print mean run speed plot
                      printfig(hf,fullfile(FinalExpPath,[Stamp '[MeanRunSpeed]' StrainLabels{j}...
                            '.pdf']),'-dpdf');
             
                      printfig(hf,fullfile(FinalExpPath,[Stamp '[MeanRunSpeed]' StrainLabels{j}...
                               '.png']),'-dpng');
                case 'medV'
                    continue

            end
    
   
end

figure(hf_select)
if n_Query == 1
   legend([InstRS_Sel_Handle{1:end}],StrainLabels,'Location','NorthEast')
   printfig(hf_select,fullfile(ExpPath,'InstantaneousRunSpeed',[Stamp '[SelectedInstRunSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.pdf']),'-dpdf');
   printfig(hf_select,fullfile(ExpPath,'InstantaneousRunSpeed',[Stamp '[SelectedInstRunSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.png']),'-dpng');
elseif n_Query == 2
       legend([MeanRS_Sel_Handle{1:end}],StrainLabels,'Location','NorthEast')
       printfig(hf_select,fullfile(ExpPath,'MeanRunSpeed',[Stamp '[SelectedMeanRunSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.pdf']),'-dpdf');
       printfig(hf_select,fullfile(ExpPath,'MeanRunSpeed',[Stamp '[SelectedMeanRunSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.png']),'-dpng');
elseif n_Query == 3
%        legend([MedV_Sel_Handle{1:end}],StrainLabels,'Location','NorthEast');
%        printfig(hf_select,fullfile(ExpPath,'MedianRunSpeed',[Stamp '[SelectedMedianRunSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.pdf']),'-dpdf');
%        printfig(hf_select,fullfile(ExpPath,'MedianRunSpeed',[Stamp '[SelectedMedianRunSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.png']),'-dpng');
end




%% Functions     

function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
end

function RunDistH = RunDist(X,PltPara,hFig)
%         The input has now two components  
          RunDur = X.RunDur; %for weighing mean run speeds
          XValues = X.X;   
          
          Edge = PltPara.Edges;
          DispStyle = PltPara.DispStyle;
          LineW = PltPara.LineWidth;
          FaceColor = PltPara.FaceColor;
          EdgeColor = PltPara.EdgeColor; 
          Norm = PltPara.Normalization; 
          NormSwitch = PltPara.NormSwitch;
          %SelectedIPTG = PltPara.IPTGSel;
          AxLabel = PltPara.Label; 
          Lim = PltPara.Lim;
                   
          if strcmp(NormSwitch,'weighted')
             
             [~,Edges,Bins] = histcounts(XValues,Edge);
             for i = 1:length(Edges)-1
                NW(i) = sum(RunDur(Bins == i)); %Weighted counts 
             end
       
              RunDistH = histogram('BinEdges',Edges,'BinCounts',NW,'Normalization',Norm,'LineWidth',LineW,...
                         'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
          else
              RunDistH = histogram(XValues,Edge,'Normalization',Norm,'LineWidth',LineW,...
                        'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
          end
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
    