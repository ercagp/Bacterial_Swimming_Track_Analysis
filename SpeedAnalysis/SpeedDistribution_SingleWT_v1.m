%% Speed Distribution of other WT strains 
% November 2021 
% by Ercag Pince
clearvars;
close all;
clc; 

MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\3D_Tracking_Data';
VideoDate = '20190604';
StrainFolder = 'KMT9_OD_0.19'; 
Lambda = 0.5;

ExpPath = 'C:\Users\ercagp\Desktop';

Files = getallfilenames(fullfile(MainPath,VideoDate,StrainFolder)); 
TargetFiles = Files(~cellfun(@isempty, regexp(Files,['Lambda[_]' num2str(Lambda)],'match','once')));

PF.minT = 0; %sec
PF.minV = 20; %um/sec 
PF.fps = 30; %1/sec
PHist.YTitle = 'PDF'; 
ColorMap = linspecer(length(TargetFiles),'qualitative');

RegExp_ROI = 'ROI[_]\d'; 

ROI = cell(length(TargetFiles),1);
InstSpeed = cell(length(TargetFiles),1); 
MeanSpeed = cell(length(TargetFiles),1); 
MedSpeed = cell(length(TargetFiles),1); 
TrajDur = cell(length(TargetFiles),1); 

for i = 1:length(TargetFiles)
    load(TargetFiles{i});
    ROI{i} = regexp(TargetFiles{i},RegExp_ROI,'match','once'); 
        
    [Speeds, ~] = filterout(B_Smooth.Speeds,PF);
    InstSpeed{i} = cell2mat(cellfun(@(x) x(:,9), Speeds,'UniformOutput',0)); 
    MeanSpeed{i} = cellfun(@(x) nanmean(x(:,9)), Speeds, 'UniformOutput',1);
    MedSpeed{i} = cellfun(@(x) nanmedian(x(:,9)), Speeds, 'UniformOutput',1);
    TrajDur{i} = cellfun(@(x) length(x(:,1))/PF.fps, Speeds, 'UniformOutput',1); 
    
    PHist.Title = ['WT - ' ROI{i}]; 
    PHist.EdgeColor = ColorMap(i,:);
%   PHist.X = MeanSpeed{i}; 
    PHist.X = InstSpeed{i}; 
    PHist.TrajDur = TrajDur{i}; 
    PHist.Edges = 0:10:180; %mum/sec
    PHist.YTitle = 'PDF'; 
    PHist.XTitle = 'Instantaneous Speeds (\mu{}m/sec)'; 
    PHist.YLim = [0 0.012];

    hf{i} = figure(i); 
    PlotHist(hf{i},PHist); 
%    PlotWeight_Hist(hf{i}, PHist); 
end

ColorMap_Cmb = linspecer(2);

PCmb.Title = 'WT (KMT9)';
PCmb.XTitle = 'Speeds (\mu{}m/sec)';
PCmb.YTitle = 'PDF';
PCmb.EdgeColor = lines(1);%[0 0 1];%ColorMap(length(TargetFiles)+1,:); 
PCmb.X = cell2mat(InstSpeed); 
PCmb.Edges = 0:7:180; 
PCmb.YLim = [0, 0.020]; 

hf{end+1} = figure(length(TargetFiles)+1); 
Hist_Cmb{1} = PlotHist(hf{end}, PCmb); 
hold on 

PMean.Title = PCmb.Title;
PMean.XTitle = PCmb.XTitle;
PMean.YTitle = PCmb.YTitle; 
PMean.EdgeColor = PCmb.EdgeColor;%[52, 123, 190]./255;% ColorMap_Cmb(2,:); 
PMean.EdgeAlpha = 0.50; 
PMean.X = cell2mat(MeanSpeed);
PMean.TrajDur = cell2mat(TrajDur); 
PMean.Edges = PCmb.Edges;
PMean.YLim = [0, 0.020]; 
figure(hf{end}) 
%Hist_Cmb{2} = PlotHist(hf{end}, PMean); 
Hist_Cmb{2} = PlotWeight_Hist(hf{end}, PMean); 

legend([Hist_Cmb{1:end}],{'Inst. Speed','W. Mean Speed'},'Location','NorthWest')

hf{end}.Position = [925, 486, 738, 600]; 
ax = gca; 

Exp.Main = ExpPath; 
Exp.Filename = 'KMT9_Mean_InstSpeed_Overlay';
ExpFig(hf{end},Exp)

%% Functions 
function [SSubset, FilterMask] = filterout(S,ParaFilter)
          minT = ParaFilter.minT;
          minV = ParaFilter.minV; 
          fps = ParaFilter.fps; 

          %Filter out trajectories
          TotalTime = cellfun(@(x) length(x(:,1))/fps,S); 
          medV = cellfun(@(x) nanmedian(x(:,9)), S);
        
          FilterMask = medV > minV & TotalTime > minT;
          SSubset = S(FilterMask);
end


function Hist = PlotHist(hFig, HistPara)
         XValues = HistPara.X; 
         Edge = HistPara.Edges; 
         EdgeColor = HistPara.EdgeColor;
         
         if isfield(HistPara,'EdgeAlpha')
            EdgeAlpha = HistPara.EdgeAlpha;
         else
            EdgeAlpha = 1; 
         end
        
         Norm = 'PDF';
         LineW = 2; 
         DispStyle = 'stairs'; 
             
         Hist = histogram(XValues,Edge,'Normalization',Norm,'LineWidth',LineW,...
                          'DisplayStyle',DispStyle,'EdgeColor',EdgeColor,'EdgeAlpha',EdgeAlpha);                              
         PlotSty(hFig,HistPara)
end

function Hist = PlotWeight_Hist(hFig, HistPara)
         XValues = HistPara.X; 
         TrajDur = HistPara.TrajDur; 
         Edge = HistPara.Edges; 
         EdgeColor = HistPara.EdgeColor; 
         
         if isfield(HistPara,'EdgeAlpha')
            EdgeAlpha = HistPara.EdgeAlpha;
         else
            EdgeAlpha = 1; 
         end
        
        
         Norm = 'PDF';
         LineW = 2; 
         DispStyle = 'stairs'; 
             
         [~,Edges,Bins] = histcounts(XValues,Edge);
         for i = 1:length(Edges)-1
                NW(i) = sum(TrajDur(i == Bins)); %Weighted counts 
         end
         Hist = histogram('BinEdges',Edges,'BinCounts',NW,'Normalization',Norm,'LineWidth',LineW,...
                         'DisplayStyle',DispStyle,'EdgeColor',EdgeColor,'EdgeAlpha',EdgeAlpha);
         PlotSty(hFig,HistPara)
end


function PlotSty(hFig,Lab)
         figure(hFig);
         ax = gca; 
         ax.Title.String = Lab.Title;
         ax.Title.Interpreter = 'none'; 
         ax.XLabel.String = Lab.XTitle; 
         ax.YLabel.String = Lab.YTitle;
         %ax.XLim = Lim.X;
         ax.YLim = Lab.YLim; 
         ErcagGraphics
         %settightplot(ax); 
end

function ExpFig(hFig,Strings)
Main = Strings.Main; 
Filename = Strings.Filename;
%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];
Total = fullfile(Main,[Stamp Filename]); 


printfig(hFig,Total,'-dpng')
printfig(hFig,Total,'-dpdf')
end