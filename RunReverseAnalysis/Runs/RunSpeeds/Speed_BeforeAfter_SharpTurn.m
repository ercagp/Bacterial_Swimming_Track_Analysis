%% Swimming speed difference before and after a turn event 
%May 2020 
%by Ercag 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/AngleAnalysis';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Frames per second 
fps = 30; %Hz

%Plot parameters
NormType = 'PDF';
Lab.XAx = '(V_{A} - V_{B})/(V_{A} + V_{B})';
%For different strains
ColorMap{1} = [0 0.45 0.74]; %KMT43
ColorMap{2} = [0.85 0.33 0.10]; %KMT47
ColorMap{3} = [0.93 0.69 0.13]; %KMT53

if strcmp(NormType,'PDF')
    Lab.YAx = 'PDF';
else
    Lab.YAx = 'Counts';
end

%Set bin arrays 
minB = -1;
maxB = 1; %Q
BinSize = 0.05;
Bins = minB:BinSize:maxB; %Q

Lim.X = [minB maxB]; 

j = 1; 
%Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    Q = cell(length(Files),1);
    Temp = [];
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        TurnAng = Results.Ang(:,3); 
        T = Results.T;
        %Turn angle threshold
        TALow = 140; 
        [SB, SA] = SpeedTurn(Speeds,T,TurnAng,TALow,minV,minT,fps);
        DeltaS = cell2mat(SA) - cell2mat(SB); 
        SumS = cell2mat(SA) + cell2mat(SB); 
        Q{i} = DeltaS./SumS;
    end
    QS = matchrepeat(IPTG,Q);
    for k = 1:size(QS,1)
        IPTGLab = QS{k,1};
        %Set the title
        Lab.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLab) ' \muM']};
        %plot the histogram
        hf{k} = figure(k);
        hist(k) = histogram(QS{k,2},Bins,...
                'Normalization',NormType,'LineWidth',1,...
                'FaceColor',ColorMap{j});
        PlotSty(hf{k},Lab,Lim)
        printfig(hf{k},fullfile(ExpPath,['[20200610]' StrainLabels{j} '_SpeedBeforeAfter_SharpTurns_[IPTG]_' num2str(IPTGLab) '_uM.pdf']),'-dpdf')
    end


 %% Functions 
 function [SpeedBfr, SpeedAft] = SpeedTurn(S,T,Ang,AngLow,minV,minT,fps)
          %Filter out trajectories
          TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
          medV = cellfun(@(x) medianN(x(:,9)), S);
         
          MaskTraj = medV > minV & TotalTime > minT;
          TSubset = T(MaskTraj,:);
          SSubset = S(MaskTraj,:);
          AngSubset = Ang(MaskTraj,:); 
          
          SpeedBfr = cell(size(TSubset,1),1);
          SpeedAft = cell(size(TSubset,1),1);
          for i  = 1:size(TSubset,1)
              RunEnd = TSubset{i,3};
              RunStart = TSubset{i,2};
              Speeds = SSubset{i}(:,9);
              TurnAngles = AngSubset{i}; 
              
              %Eliminate indices of the points that have larger TA than turn angle threshold
              RunEnd = RunEnd(TurnAngles > AngLow);
              RunStart = RunStart(TurnAngles > AngLow);
              
              %Define where the loop ends
              j_end = length(RunEnd);
              for j = 1:j_end
                  
                  if j == j_end && length(RunStart) < length(RunEnd)
                     continue
                  else
                     SpeedBfr{i}(j) = mean(Speeds(RunEnd(j)-3:RunEnd(j)-1));
                     SpeedAft{i}(j) = mean(Speeds(RunStart(j):RunStart(j)+2));
                  end
              end
          end
          
          %Transpose inner matrices 
          SpeedBfr = cellfun(@(x) x',SpeedBfr,'UniformOutput',0);
          SpeedAft = cellfun(@(x) x',SpeedAft,'UniformOutput',0);
 end
      
 function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             R{i,2} = cell2mat(Y(Mask)); 
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
         settightplot(ax); 
end




