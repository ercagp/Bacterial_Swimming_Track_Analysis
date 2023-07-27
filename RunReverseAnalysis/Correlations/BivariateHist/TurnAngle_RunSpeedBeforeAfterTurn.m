%% Bivariate histogram for Turn Angle vs. Before Run/After
%December 2020 
%by Ercag
clearvars; close all;
clc;

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/AngularAnalysis/Correlations/DensityPlots/';

%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/'; %Call the "Speeds" matrix from the run-reverse data
StrainLabels = {'KMT53'}; 

%% Define Bivariate Histogram Parameters
PltPara.Normalization = 'PDF';
PltPara.Edges.X = 0:5:180; 
PltPara.Edges.Y = 0:5:180; 
IPTG_Sel = 100; 
i_Sel = 1; 


%Acquisition and post processing parameters 
fps = 30; %Hz
Lambda = 0.5;

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngCell_Flt = cell(length(Files),1);
    Speeds_Flt =  cell(length(Files),1);
    SpeedBeforeTurn_Flt = cell(length(Files),1);
    SpeedAfterTurn_Flt = cell(length(Files),1);
    MeanSpeedBeforeTurn_Flt = cell(length(Files),1);
    MeanSpeedAfterTurn_Flt = cell(length(Files),1);

    
    for i = 1:length(Files) 
        load(Files{i}) 
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 

        %Break down turn angles and add run-turn index info 
        TurnCell = TurnAngleBreakDown(T,Results.Ang);
        
        %Instantaneous run speeds before & after turns 
        [SpeedBeforeTurn,SpeedAfterTurn] = InstSpeed_Turn(TurnCell,Speeds);
        
        %Mean run speeds before & after turns
        [MeanSpeedBeforeTurn, MeanSpeedAfterTurn] = MeanSpeed_Turn(TurnCell,Speeds);     
        
        
        %Filter out bugs below the set threshold 
        [Speeds_Flt{i}, FilterMask] = filterout(Speeds,minT,minV,fps);
        TurnAngCell_Flt{i} = TurnCell(FilterMask,3); %3rd column
        SpeedBeforeTurn_Flt{i} = SpeedBeforeTurn(FilterMask);
        SpeedAfterTurn_Flt{i} = SpeedAfterTurn(FilterMask);
        MeanSpeedBeforeTurn_Flt{i} = MeanSpeedBeforeTurn(FilterMask); 
        MeanSpeedAfterTurn_Flt{i} = MeanSpeedAfterTurn(FilterMask); 
        
        
        %Plot Bivariate Histogram of SpeedBeforeTurn vs SpeedAfterTurn
        SBT_Single = cell2mat(SpeedBeforeTurn_Flt{i}); 
        SAT_Single = cell2mat(SpeedAfterTurn_Flt{i}); 
        MSBT_Single = MeanSpeedBeforeTurn_Flt{i};
        MSAT_Single = MeanSpeedAfterTurn_Flt{i};
        TA_Single = cell2mat(TurnAngCell_Flt{i}); 
        
        if IPTG(i) == IPTG_Sel
%            hf_BT = figure(i_Sel);
%            i_Sel = i_Sel + 1; 
%            PltPara.Label.Title = [StrainLabels{j} ' @ ' num2str(IPTG(i)) ' uM [IPTG] - Single Acq.']; 
%            PltPara.Label.XAx = 'Inst.Speed Before Turn (\mum/sec)';
%            PltPara.Label.YAx = 'Turn Angle (Degrees)'; 
%            HistH = DensityPlot(SBT_Single,TA_Single,PltPara,hf_BT);
%            printfig(hf_BT,fullfile(ExpPath,'TurnAngle_vs_SpeedBefore_AfterTurn',StrainLabels{j},'BeforeTurn','IndividualAcquisitions',['[20201202][TurnAngle_RunSpeedBeforeTurn]' StrainLabels{j} '_[IPTG]_' num2str(IPTG(i)) '_uM_' num2str(i) '.png']),'-dpng')
%            printfig(hf_BT,fullfile(ExpPath,'TurnAngle_vs_SpeedBefore_AfterTurn',StrainLabels{j},'BeforeTurn','IndividualAcquisitions',['[20201202][TurnAngle_RunSpeedBeforeTurn]' StrainLabels{j} '_[IPTG]_' num2str(IPTG(i)) '_uM_' num2str(i) '.pdf']),'-dpdf')
        end
    end
    
 
    
    SBT = matchrepeat(IPTG,SpeedBeforeTurn_Flt);
    SAT = matchrepeat(IPTG,SpeedAfterTurn_Flt);
    MSBT = matchrepeat(IPTG,MeanSpeedBeforeTurn_Flt); 
    MSAT = matchrepeat(IPTG,MeanSpeedAfterTurn_Flt);
    
    TurnAngC = matchrepeat(IPTG,TurnAngCell_Flt);
    for k = 1:size(MSBT,1)
        IPTGLabel{k} = [num2str(SBT{k,1}) '\muM'];
        
        MeanSpeedBeforeTurn_X = MSBT{k,2}; 
        MeanSpeedAfterTurn_Y = MSAT{k,2}; 
        MeanSpeedAfterTurn_X = MSAT{k,2}; 

%         SpeedBeforeTurn_X = SBT{k,2};
%         SpeedAfterTurn_Y = SAT{k,2};
%         SpeedAfterTurn_X = SAT{k,2}; 
        TurnAngle_Y = TurnAngC{k,2}; 
        
        PltPara.Label.Title = [StrainLabels{j} ' @ ' IPTGLabel{k} ' [IPTG]']; 
        PltPara.Label.XAx = 'Mean Run Speed Before Turn (\mum/sec)';
        PltPara.Label.YAx = 'Turn Angle (degrees)';
        %% Mean Run Speed Before vs. Turn Angle 
        hf = figure(k+(j-1)*6); 
        Hist_H = DensityPlot(MeanSpeedBeforeTurn_X,TurnAngle_Y,PltPara,hf);
        
        
        %% Instantaneous Run Speed Before vs. Turn Angle 
%          hf = figure(k+(j-1)*6);
%         Hist_H = DensityPlot(SpeedBeforeTurn_X,TurnAngle_Y,PltPara,hf);
%         FullExp = fullfile(ExpPath,'TurnAngle_vs_SpeedBefore_AfterTurn',StrainLabels{j},'BeforeTurn');
%         if ~exist(FullExp,'dir')
%             mkdir(FullExp);  
%         end
%         printfig(hf,fullfile(FullExp,['[20201203][TurnAngle_RunSpeedBeforeTurn]' StrainLabels{j} '_[IPTG]_' num2str(num2str(SBT{k,1})) '_uM.png']),'-dpng')
%         printfig(hf,fullfile(FullExp,['[20201203][TurnAngle_RunSpeedBeforeTurn]' StrainLabels{j} '_[IPTG]_' num2str(num2str(SBT{k,1})) '_uM.pdf']),'-dpdf')
        
        %% Instantaneous Run Speed After vs. Turn Angle
%         Hist_H = DensityPlot(SpeedAfterTurn_X,TurnAngle_Y,PltPara,hf);
%         FullExp = fullfile(ExpPath,'TurnAngle_vs_SpeedBefore_AfterTurn',StrainLabels{j},'AfterTurn');
%         if ~exist(FullExp,'dir')
%             mkdir(FullExp);  
%         end
%         printfig(hf,fullfile(FullExp,['[20201203][TurnAngle_RunSpeedAfterTurn]' StrainLabels{j} '_[IPTG]_' num2str(num2str(SBT{k,1})) '_uM.png']),'-dpng')
%         printfig(hf,fullfile(FullExp,['[20201203][TurnAngle_RunSpeedAfterTurn]' StrainLabels{j} '_[IPTG]_' num2str(num2str(SBT{k,1})) '_uM.pdf']),'-dpdf')
        
        %% Instantaneous Run Speed Before vs. After
%         Hist_H = DensityPlot(SpeedBeforeTurn_X,SpeedAfterTurn_Y,PltPara,hf);
%         
%         FullExp = fullfile(ExpPath,'RunSpeedBefore_AfterTurn',StrainLabels{j});
%         if ~exist(FullExp,'dir')
%             mkdir(FullExp);  
%         end
%         printfig(hf,fullfile(FullExp,['[20201202][RunSpeedBefore_AfterTurn]' StrainLabels{j} '_[IPTG]_' num2str(num2str(SBT{k,1})) '_uM.png']),'-dpng')
%         printfig(hf,fullfile(FullExp,['[20201202][RunSpeedBefore_AfterTurn]' StrainLabels{j} '_[IPTG]_' num2str(num2str(SBT{k,1})) '_uM.pdf']),'-dpdf')
        
    end

end

%% Functions
function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

 %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1))/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask);
end

%Instantaneous speeds before and after a turn 
function [SpeedBeforeTurn, SpeedAfterTurn] = InstSpeed_Turn(TurnCell,SpeedCell)
         
         InstSpeed = cellfun(@(x) x(:,9), SpeedCell,'UniformOutput',0); 
         
         SpeedBeforeTurn = cell(size(TurnCell,1),1); 
         SpeedAfterTurn = cell(size(TurnCell,1),1); 
         
         for i = 1:size(TurnCell,1)
             RunEnd = TurnCell{i,1};
             RunStart = TurnCell{i,2};
             
             if length(RunEnd) > length(RunStart)
                loopEnd =  length(RunEnd)-1;
             else
                loopEnd = length(RunEnd);  
             end
             
             for j = 1:loopEnd
                
                SpeedBeforeTurn{i}(j,1) = InstSpeed{i}(RunEnd(j)-1);  
                SpeedAfterTurn{i}(j,1) = InstSpeed{i}(RunStart(j));
             end
             
         end
    
end


%Instantaneous speeds before and after a turn 
function [MeanSpeedBeforeTurn, MeanSpeedAfterTurn] = MeanSpeed_Turn(TurnCell,SpeedCell)
         
         InstSpeed = cellfun(@(x) x(:,9), SpeedCell,'UniformOutput',0); 
         
         MeanSpeedBeforeTurn = cell(size(TurnCell,1),1); 
         MeanSpeedAfterTurn = cell(size(TurnCell,1),1); 
         
         for i = 1:size(TurnCell,1)
             RunEnd = TurnCell{i,1};
             RunStart = TurnCell{i,2};
             
             if length(RunEnd) > length(RunStart)
                loopEnd =  length(RunEnd)-1;
             else
                loopEnd = length(RunEnd);  
             end
             
             for j = 1:loopEnd
                 
                 if j == 1
                    MeanSpeedBeforeTurn{i}(j,1) = nanmean(InstSpeed{i}(1:RunEnd(j)-1));
                    if length(RunEnd) == 1
                        MeanSpeedAfterTurn{i}(j,1) = nanmean(InstSpeed{i}(RunStart(j):end));
                    else
                        MeanSpeedAfterTurn{i}(j,1) = nanmean(InstSpeed{i}(RunStart(j):RunEnd(j+1)-1));
                    end
                 end
                 %% FIX THIS!!! 
                 MeanSpeedBeforeTurn{i}(j,1) = nanmean(InstSpeed{i}(RunStart(j-1):RunEnd(j)-1));
                 MeanSpeedAfterTurn{i}(j,1) = nanmean(InstSpeed{i}(RunStart(j):RunEnd(j+1)-1)); 
                 %% FIX THIS!!! 
             end
             
         end
    
end


%Bivariate Histogram
function DistH = DensityPlot(X,Y,PltPara,hFig)
        
          EdgeX = PltPara.Edges.X;
          EdgeY = PltPara.Edges.Y;
          DispStyle = 'tile';
          Norm = PltPara.Normalization;
          AxLabel = PltPara.Label; 
           
          DistH = histogram2(X,Y,EdgeX,EdgeY,'Normalization',Norm,...
              'DisplayStyle',DispStyle,'ShowEmptyBins','on');
          colorbar; 
  
          PlotSty(hFig,AxLabel);        
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
