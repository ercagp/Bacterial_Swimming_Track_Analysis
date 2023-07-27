%% Speed distributions from single acquisitions and combined data
% November 2020 
% by Ercag 
clearvars;
clc; close all; 
%% Define Export Path for figures
ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\SpeedAnalysis';
%% Call the run reverse analysis files 
MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverse_Data'; %Call the "Speeds" matrix from the run-reverse data
StrainLabels = {'KMT43','KMT47'}; 

%% User query to select which type of observable to plot 
disp('Which observable to plot?')
disp('1-)Instantaneous Speed')
disp('2-)Mean Speed')
disp('3-)Median Speed')
prompt = 'Enter the number of the observable to plot:\n'; 
n_Query = input(prompt); 

prompt_IPTG = 'Select the [IPTG] to compare different strains \n';
disp('Which observable to plot?')
disp('1-)0 uM')
disp('2-)25 uM')
disp('3-)35 uM')
disp('4-)50 uM')
disp('5-)60 uM')
disp('6-)75 uM')
disp('7-)100 uM')
disp('8-)1 mM')

IPTG_Query = input(prompt_IPTG);
IPTG_All = [0 25 35 50 60 75 100 1000];
IPTG_Subset = [0 60 100 1000]; 
log_IPTGSel = false(1,length(IPTG_All));
log_IPTGSel(IPTG_Query) = true; 

if n_Query  == 1 
   observable = 'instV';
elseif n_Query == 2 
    observable = 'meanV';
elseif n_Query == 3
    observable = 'medianV'; 
end

%% Parameters
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5;

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

% Define Histogram Parameters
PltPara.Normalization = 'PDF';
PltPara.NormSwitch = '';
PltPara.DispStyle = 'stairs';
PltPara.FaceColor = 'none'; 
PltPara.LineWidth = 2.5; 
PltPara.Edges = 0:5:180; 
PltPara.Lim.X = [0 180]; 

if strcmp(PltPara.Normalization,'PDF')
    PltPara.Label.YAx = 'PDF'; 
else
    PltPara.Label.YAx = 'Counts'; 
end

% Define parameters for selected [IPTG] plot
PltParaSelect.Normalization = PltPara.Normalization;
PltParaSelect.NormSwitch = PltPara.NormSwitch;
PltParaSelect.DispStyle = PltPara.DispStyle; 
PltParaSelect.FaceColor = PltPara.FaceColor; 
PltParaSelect.LineWidth = PltPara.LineWidth; 
PltParaSelect.Edges = PltPara.Edges; 
PltParaSelect.Lim.X = PltPara.Lim.X; 
PltParaSelect.Label.YAx = PltPara.Label.YAx; 

%Selected [IPTG] value and preallocation 
IPTG_Sel = IPTG_All(log_IPTGSel); %uM 
SelInd = 1; %Selected plot counter
InstV_Sel_Handle = cell(size(StrainLabels,2),1); 
MeanV_Sel_Handle = cell(size(StrainLabels,2),1);
MedV_Sel_Handle = cell(size(StrainLabels,2),1);


%% Analysis
for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Speeds_Flt = cell(length(Files),1);
    InstSpeed = cell(length(Files),1);
    MeanSpeed = cell(length(Files),1);
    MedSpeed = cell(length(Files),1); %Median Speed
    TrajDur = cell(length(Files),1); 
    Temp = [];        
    
    for i = 1:length(Files) 
        load(Files{i})
        
        IPTG(i) = RunReverse.Info.IPTG;                   
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(IPTG(i)) 'uM \n \n'])                
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 
        %Filter out speeds 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps); 
        InstSpeed{i} = cell2mat(cellfun(@(x) x(:,9), Speeds_Flt{i},'UniformOutput',0)); 
        MeanSpeed{i} = cellfun(@(x) nanmean(x(:,9)), Speeds_Flt{i}, 'UniformOutput',1);
        MedSpeed{i} = cellfun(@(x) nanmedian(x(:,9)), Speeds_Flt{i}, 'UniformOutput',1);
        TrajDur{i} = cellfun(@(x) length(x(:,1))/fps, Speeds_Flt{i}, 'UniformOutput',1); 
    end
    
    InstV = matchrepeat(IPTG,InstSpeed);
    MeanV = matchrepeat(IPTG,MeanSpeed); 
    MedV = matchrepeat(IPTG,MedSpeed); 
    TrajDurV = matchrepeat(IPTG,TrajDur); 
    
    
    %Define colormaps for different & selected [IPTG] values 
    ColorMap_Edges = linspecer(length(IPTG_Subset),'qualitative');
    ColorMap_Sel = linspecer(size(StrainLabels,2),'qualitative'); 
    
    IPTGLabel = cell(size(InstV,1),1);
    
    switch observable 
        case 'instV'
              InstV_Handle = cell(size(InstV,1),1); 
                           
            for k = 1:length(IPTG_Subset)
                IPTGLabel{k} = [num2str(InstV{k,1}) '\muM'];
                
                %Select the IPTG values from the vector IPTG_Subset
                k_new = [InstV{:,1}] == IPTG_Subset(k); 
         
                IS.X = InstV{k_new,2}; %Instantaneous Speeds
                IS.TrajDur = TrajDurV{k_new,2};
        
                %Impose the colormap 
                PltPara.EdgeColor = ColorMap_Edges(k,:);
       
                hf{j} = figure(j);
                %Instantaneous speed distribution 
                PltPara.Label.Title  = {StrainLabels{j}, 'Instantaneous Speed'};
                PltPara.Label.XAx = 'V (\mum/sec)';
                                
                InstV_Handle{k} = SpeedDist(IS, PltPara, hf{j});
                hold on 
        
%                 if InstV{k,1} == IPTG_Sel
%                    hf_Sel = figure(20);
%                    PltParaSelect.EdgeColor = ColorMap_Sel(SelInd,:);
%                    PltParaSelect.Label.XAx = 'V (\mum/sec)';
%                    PltParaSelect.Label.Title  = ['Instantaneous Speed @ ' IPTGLabel{k} ' [IPTG]'] ;
%                    InstV_Sel_Handle{SelInd} = SpeedDist(IS, PltParaSelect, hf_Sel);
%                    hold on 
%                    SelInd = SelInd + 1;    
%                 end
        
             end
             figure(hf{j})
             hf{j}.Position = [905   689   757   602]; 
             drawnow();
             Leg_Cell = arrayfun(@num2str,IPTG_Subset,'UniformOutput',false); 
             Leg_Cell = cellfun(@(x) [x ' \mu{}M'], Leg_Cell ,'UniformOutput',false); 
             
             legend([InstV_Handle{1:end}], Leg_Cell, 'Location','NorthEast') 
             
             FinalExpPath = fullfile(ExpPath,'InstantaneousSpeed'); 
             if ~exist(FinalExpPath,'dir')
                 mkdir(FinalExpPath)
             end
             printfig(hf{j},fullfile(FinalExpPath,[Stamp '[InstantaneousSpeed]' StrainLabels{j} '.pdf']),'-dpdf');
             printfig(hf{j},fullfile(FinalExpPath,[Stamp '[InstantaneousSpeed]' StrainLabels{j} '.png']),'-dpng');
        case 'meanV'
              MeanV_Handle = cell(size(MeanV,1),1);
              for k = 1:length(IPTG_Subset)
                  IPTGLabel{k} = [num2str(MeanV{k,1}) '\muM'];
                  
                  %Select the IPTG values from the vector IPTG_Subset
                  k_new = [MeanV{:,1}] == IPTG_Subset(k); 
        
                  MS.X = MeanV{k_new,2}; %Mean Speeds
                  MS.TrajDur = TrajDurV{k_new,2}; 
        
                  %Impose the colormap 
                  PltPara.EdgeColor = ColorMap_Edges(k,:);
       
                  hf{j} = figure(j);
                  %Mean speed distribution 
                  if strcmp(PltPara.NormSwitch,'weighted')
                     PltPara.Label.Title  = {StrainLabels{j}, 'Weighted Mean Speed'}; 
                     PltParaSelect.Label.Title  = ['Weighted Mean Speed @ ' IPTGLabel{k} ' [IPTG]'] ;
                     FinalExpPath = fullfile(ExpPath,'WeightedMeanSpeed');
                     StampMeanV = [Stamp '[WeightedMeanSpeed]'];
                  else
                     PltPara.Label.Title  = {StrainLabels{j}, 'Mean Speed'};
                     PltParaSelect.Label.Title  = ['Mean Speed @ ' IPTGLabel{k} ' [IPTG]'] ;
                     FinalExpPath = fullfile(ExpPath,'MeanSpeed');
                     StampMeanV = [Stamp '[MeanSpeed]'];
                  end
                  PltPara.Label.XAx = '<V> (\mum/sec)';
                  MeanV_Handle{k} = SpeedDist(MS, PltPara, hf{j});
                  hold on 

                 if MeanV{k,1} == IPTG_Sel
                    hf_Sel = figure(20);
                    PltParaSelect.EdgeColor = ColorMap_Sel(SelInd,:);
                    PltParaSelect.Label.XAx = '<V> (\mum/sec)';
                    MeanV_Sel_Handle{SelInd} = SpeedDist(MS, PltParaSelect, hf_Sel);
                    hold on 
                   SelInd = SelInd + 1; 
                 end
              end 
              figure(hf{j})
              hf{j}.Position = [905   689   757   602]; 
              drawnow();
                           
              Leg_Cell = arrayfun(@num2str,IPTG_Subset,'UniformOutput',false); 
              Leg_Cell = cellfun(@(x) [x ' \mu{}M'], Leg_Cell ,'UniformOutput',false); 
             
              legend([MeanV_Handle{1:end}], Leg_Cell, 'Location','NorthEast') 
              
              if ~exist(FinalExpPath,'dir')
                 mkdir(FinalExpPath)
              end
              printfig(hf{j},fullfile(FinalExpPath,[StampMeanV StrainLabels{j} '.pdf']),'-dpdf');
              printfig(hf{j},fullfile(FinalExpPath,[StampMeanV StrainLabels{j} '.png']),'-dpng');
        case 'medianV'
              MedV_Handle = cell(size(MedV,1),1);
              for k = 1:size(MedV,1)
                  IPTGLabel{k} = [num2str(MedV{k,1}) '\muM'];
        
                  MS.X = MedV{k,2}; %Median Speeds
                  MS.TrajDur = TrajDurV{k,2}; 
        
                  %Impose the colormap 
                  PltPara.EdgeColor = ColorMap_Edges(k,:);
       
                  hf = figure(j);
                  %Mean speed distribution 
                  if strcmp(PltPara.NormSwitch,'weighted')
                     PltPara.Label.Title  = {StrainLabels{j}, 'Weighted Median Speed'}; 
                     PltParaSelect.Label.Title  = ['Weighted Median Speed @ ' IPTGLabel{k} ' [IPTG]'] ;
                     FinalExpPath = fullfile(ExpPath,'WeightedMedianSpeed');
                     StampMedV = [Stamp '[WeightedMedianSpeed]'];
                  else
                     PltPara.Label.Title  = {StrainLabels{j}, 'Median Speed'};
                     PltParaSelect.Label.Title  = ['Median Speed @ ' IPTGLabel{k} ' [IPTG]'] ;
                     FinalExpPath = fullfile(ExpPath,'MedianSpeed');
                     StampMedV = [Stamp '[MedianSpeed]'];
                  end
                  PltPara.Label.XAx = 'V_{Median} (\mum/sec)';
                  MedV_Handle{k} = SpeedDist(MS, PltPara, hf);
                  hold on 

                 if MedV{k,1} == IPTG_Sel
                    hf_Sel = figure(20);
                    PltParaSelect.EdgeColor = ColorMap_Sel(SelInd,:);
                    PltParaSelect.Label.XAx = 'V_{Median} (\mum/sec)';
                    MedV_Sel_Handle{SelInd} = SpeedDist(MS, PltParaSelect, hf_Sel);
                    hold on 
                   SelInd = SelInd + 1; 
                 end
              end 
              figure(hf)
              SortandPutLeg(MedV,MedV_Handle,IPTGLabel); 
              drawnow();
              if ~exist(FinalExpPath,'dir')
                 mkdir(FinalExpPath)
              end
              printfig(hf,fullfile(FinalExpPath,[StampMedV StrainLabels{j} '.pdf']),'-dpdf');
              printfig(hf,fullfile(FinalExpPath,[StampMedV StrainLabels{j} '.png']),'-dpng');
            
        otherwise 
            disp('none of the observables was selected')
    end
                 
end
% if n_Query == 1
%    legend([InstV_Sel_Handle{1:end}],StrainLabels,'Location','NorthEast')
%    printfig(hf_Sel,fullfile(FinalExpPath,[Stamp '[SelectedInstantaneousSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.pdf']),'-dpdf');
%    printfig(hf_Sel,fullfile(FinalExpPath,[Stamp '[SelectedInstantaneousSpeed]' '[IPTG]_' num2str(IPTG_Sel) '.png']),'-dpng');
% elseif n_Query == 2
%        legend([MeanV_Sel_Handle{1:end}],StrainLabels,'Location','NorthWest')
%        printfig(hf_Sel,fullfile(FinalExpPath,[Stamp '[Selected]' StampMeanV  '[IPTG]_' num2str(IPTG_Sel) '.pdf']),'-dpdf');
%        printfig(hf_Sel,fullfile(FinalExpPath,[Stamp '[Selected]' StampMeanV  '[IPTG]_' num2str(IPTG_Sel) '.png']),'-dpng');
% elseif n_Query == 3
%        legend([MedV_Sel_Handle{1:end}],StrainLabels,'Location','NorthEast');
%        printfig(hf_Sel,fullfile(FinalExpPath,['[Selected]' StampMedV  '[IPTG]_' num2str(IPTG_Sel) '.pdf']),'-dpdf');
%        printfig(hf_Sel,fullfile(FinalExpPath,['[Selected]' StampMedV  '[IPTG]_' num2str(IPTG_Sel) '.png']),'-dpng');
% end

%% Functions     
function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1))/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask);
end

function DistH = SpeedDist(X,PltPara,hFig)

%         The input has now two components  
          TrajDur = X.TrajDur; %for weighing mean speeds
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
                NW(i) = sum(TrajDur(i == Bins)); %Weighted counts 
             end
       
              DistH = histogram('BinEdges',Edges,'BinCounts',NW,'Normalization',Norm,'LineWidth',LineW,...
                         'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
          else
              DistH = histogram(XValues,Edge,'Normalization',Norm,'LineWidth',LineW,...
                        'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
          end
          PlotSty(hFig,AxLabel,Lim);
          
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

