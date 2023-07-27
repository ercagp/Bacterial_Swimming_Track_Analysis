%% Mean run speed distribution and other related plots
%December 2020 
%by Ercag
%v3 - This version includes "RunBreakDownv4" function. See the function for
%the details.  
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/SpeedAnalysis/Distributions/MeanRunSpeed';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Selected IPTG for the plot 
IPTGSel = 25; %uM 
fps = 30; %Hz
Lambda = 0.5; 
%% Define Plot parameters 
PltPara.Normalization = 'PDF';
PltPara.NormSwitch = '';
PltPara.DispStyle = 'stairs';
PltPara.FaceColor = 'none'; 
PltPara.LineWidth = 2; 
PltPara.Edges = 0:2:180; 
PltPara.Lim.X = [0 180]; 

if strcmp(PltPara.Normalization,'PDF')
    PltPara.Label.YAx = 'PDF'; 
else
    PltPara.Label.YAx = 'Counts'; 
end

PltParaSelect.Normalization = 'PDF';
PltParaSelect.LineWidth = 2; 
PltParaSelect.Bins = 0:2:150; 
PltParaSelect.Lim.X = [0 150]; 
PltParaSelect.DispStyle = 'Stairs'; 
PltParaSelect.FaceColor = 'none'; 
PltParaSelect.Label.XAx = '<V>_{Run} (\mum/sec)';
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
    RunDurCell =  cell(length(Files),1);
    RunCell_Flt = cell(length(Files),1);
    InstRunSpeed = cell(length(Files),1);
    MeanRunSpeed = cell(length(Files),1);
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
        [RunCell{i}, RunDurCell{i}] = RunBreakDownv4(Speeds,T,fps);  %RunBreakDownv4(S,T,fps) --> The order
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        RunCell_Flt{i} = RunCell{i}(FilterMask,:); 
        
        InstRunSpeed{i} = cell2mat(RunCell_Flt{i}(:,1)); 
        Temp = cell2mat(RunCell_Flt{i}(:,2)); 
        %Mean speed of runs 
        MeanRunSpeed{i} = Temp(:,1);  
        %Median speed of runs 
        %MedRunSpeed{i} = Temp(:,2);
        
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
    %RunDurRS = matchrepeat(IPTG,RunDur); 
    
    ColorMap_Edges = linspecer(size(InstRS,1),'qualitative');
    
    for k = 1:size(InstRS,1)
             IPTGLabel{k} = [num2str(MeanRS{k,1}) '\muM'];
             MRS.X = MeanRS{k,2}; %Mean Run Speeds
             MRS.RunDur = [];%RunDurRS{k,2};
             
             %IRS.X = InstRS{k,2}; %Instantaneous run speeds 
             %IRS.RunDur = []; %RunDurRS{k,2};
             
             %Colormap for different [IPTG]
             PltPara.EdgeColor = ColorMap_Edges(k,:);
             
             hf = figure(j);
             %Mean run speed distribution 
             if strcmp(PltPara.NormSwitch,'weighted')
                PltPara.Label.Title  = {StrainLabels{j}, 'Weighted Mean Run Speed'};
             else
                PltPara.Label.Title  = {StrainLabels{j}, 'Mean Run Speed'};
             end
             PltPara.Label.XAx = '<V>_{Run} (\mum/sec)';
             MRS_RH{k} = RunDist(MRS, PltPara, hf); 
             hold on 
             
             %Instantaneous run speed distribution 
             %PltPara.Label.Title  = {StrainLabels{j}, 'Instantaneous Run Speed'};
             %PltPara.Label.XAx = 'V_{Run} (\mum/sec)';
             %InstRH{k} = RunDist(IRS, PltPara, hf);
             %hold on 
                    
%             if IPTGLabel == IPTGSel
%                 hf_select = figure(40);
%                 PltParaSelect.EdgeColor = ColorMap{j};
%                 PltParaSelect.Label.Title = ['[IPTG] = ' num2str(IPTGLabel) ' \muM']; 
%                 HistSelect{j} =  RunDist(MeanRunSpeed,PltParaSelect,hf_select);
%                 hold on 
%             end
    end
    figure(hf)
    %SortandPutLeg(InstRS,InstRH,IPTGLabel)
    SortandPutLeg(MeanRS,MRS_RH,IPTGLabel)
    drawnow();
   
    printfig(hf,fullfile(ExpPath,['[20201201][MeanRunSpeed]' StrainLabels{j}...
                '.pdf']),'-dpdf');
             
    printfig(hf,fullfile(ExpPath,['[20201201][MeanRunSpeed]' StrainLabels{j}...
                '.png']),'-dpng');
    
end

% figure(hf_select)
% legend([HistSelect{1:end}],StrainLabels,'Location','NorthEast')

%printfig(hf_select,fullfile(ExpPath,['[20201109][MeanRunSpeed]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
%printfig(hf_select,fullfile(ExpPath,['[20201109][MeanRunSpeed]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.png']),'-dpng')




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
                NW(i) = sum(RunDur(i == Bins)); %Weighted counts 
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
    