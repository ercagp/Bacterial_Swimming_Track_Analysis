%% Swimming speed difference before and after a turn event 
%May 2020 
%by Ercag 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/AngularAnalysis/SpeedBeforeAfterTurns';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Frames per second 
fps = 30; %Hz

%Plot parameters
NormType = 'PDF';
Lab.XAx = '(V_{n+1} - V_{n})/(V_{n+1} + V_{n})';
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
minB = -1.2;
maxB = 1.2; %Q
BinSize = 0.05;
Bins = minB:BinSize:maxB; %Q

Lim.X = [minB maxB];
RegKeyVD = '(?<=Data/)\d*';
RegKeyROI = 'ROI[_]\d';

FigFormat = '-dpng';
Date = datetime; 
LHead = ['[' num2str(year(Date)) num2str(month(Date)) sprintf('%02d',day(Date)) ']'];


j = 1; 
%Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Find video dates and ROIs
    VideoDates = regexp(Files,RegKeyVD,'match','once');
    ROI = regexp(Files,RegKeyROI,'match','once');
    %Preallocate
    IPTG = zeros(length(Files),1);
    Q = cell(length(Files),1);
    for i = 1:length(Files) 
        load(Files{i})
        display(Files{i})
        IPTG(i) = RunReverse.Info.IPTG; 
        
        InitialPara.minT = Results.minT;
        InitialPara.minV = Results.minV;
        InitialPara.fps = 30; %Hz 
        InitialPara.AngLow = 150; %Turn angle threshold
        
        %Complete set of variables (Angles,Run-Reverse Mat. & Speeds cell)
        Var.Ang = Results.Ang(:,3); 
        Var.T = Results.T;
        Var.Speeds = Speeds;
        
        QCell = SpeedTurn(Var,InitialPara);
%         DeltaS = cell2mat(SA) - cell2mat(SB); 
%         SumS = cell2mat(SA) + cell2mat(SB); 
        Q{i} = cell2mat(QCell);     
        %Q{i} = DeltaS./SumS;
        
        %Plot parameters
        PP.Bins = Bins;
        PP.IPTG = RunReverse.Info.IPTG; 
        PP.StrainLabel = StrainLabels{j};  
        PP.GenExpPath = GenExpPath; 
        PP.VideoDate = VideoDates{i};
        PP.ROI = ROI{i};
        PP.FigFormat = FigFormat;
        PP.LHead = LHead; 
        PP.Labels.XAx = Lab.XAx;
        PP.Labels.YAx = 'Counts'; 
        PP.Labels.Title = {[PP.StrainLabel '-' PP.ROI],['[IPTG] = ' num2str(PP.IPTG) '\muM']};
        PP.Lim.X = Lim.X;
        hf_Q = figure(i);
        %Plot individual Q 
        PlotQ(hf_Q,Q{i},PP);
        
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
        %printfig(hf{k},fullfile(ExpPath,['[20201111]' StrainLabels{j} '_MeanRunSpeedBeforeAfter_SharpTurns_[IPTG]_' num2str(IPTGLab) '_uM.pdf']),'-dpdf')
    end


 %% Functions 
 function [Q] = SpeedTurn(CompleteSet,Parameters)        
          
          AngLow = Parameters.AngLow; 
          Subset = FilterTraj(CompleteSet,Parameters);  
            
          TSubset = Subset.T; 
          AngSubset = Subset.Ang;
          SSubset = Subset.Speeds; 
          
%           SpeedBfr = cell(size(TSubset,1),1);
%           SpeedAft = cell(size(TSubset,1),1);
          Q = cell(size(TSubset,1),1); 
          for i  = 1:size(TSubset,1)
              RunEnd = TSubset{i,3};
              RunStart = TSubset{i,2};
              Speeds = SSubset{i}(:,9);
              TurnAngles = AngSubset{i}; 
              
              %Eliminate indices of the points with smaller TA than the turn angle threshold
              RunEnd = RunEnd(TurnAngles > AngLow);
              RunStart = RunStart(TurnAngles > AngLow);
              
              %Define where the loop ends
              %j_end = length(RunEnd)-2;
              j_end = length(RunEnd);
              for j = 1:j_end
                  
                  if j == j_end && length(RunStart) < length(RunEnd)
                     continue
                  else
                     %Instantaneous speed before and after large turns 
                     SpeedDiff = Speeds(RunStart(j))-Speeds(RunEnd(j)-1);
                     SpeedSum = Speeds(RunStart(j))+Speeds(RunEnd(j)-1); 
                     Q{i} = SpeedDiff / SpeedSum;
                     
                     %SpeedBfr{i} = [SpeedBfr{i}; Speeds(RunStart(j):RunEnd(j+1)-1)];
                     %SpeedAft{i} = [SpeedAft{i}; Speeds(RunStart(j+1):RunEnd(j+2)-1)]; 
                     %Calculate mean run speeds before and after turns
                     %SpeedBfr{i}(j) = mean(Speeds(RunStart(j):RunEnd(j+1)-1));
                     %SpeedAft{i}(j) = mean(Speeds(RunStart(j+1):RunEnd(j+2)-1));
                  end
              end
          end
          
          %Transpose inner matrices 
          %SpeedBfr = cellfun(@(x) x',SpeedBfr,'UniformOutput',0);
          %SpeedAft = cellfun(@(x) x',SpeedAft,'UniformOutput',0);
   end
      
 
 function FilteredSubset = FilterTraj(WholeSet,Parameters) 
          T = WholeSet.T;
          S = WholeSet.Speeds;
          Ang = WholeSet.Ang; 
            
          fps = Parameters.fps;
          minV = Parameters.minV;
          minT = Parameters.minT; 
          %Filter out trajectories
          TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
          medV = cellfun(@(x) medianN(x(:,9)), S);
         
          MaskTraj = medV > minV & TotalTime > minT;
          
          FilteredSubset.T = T(MaskTraj,:);
          FilteredSubset.Ang = Ang(MaskTraj,:); 
          FilteredSubset.Speeds = S(MaskTraj,:);
 end
 
 function hPlt = PlotQ(hf,Q,PltParameters)
          Lab = PltParameters.Labels;
          Lim = PltParameters.Lim; 
          GenExpPath = PltParameters.GenExpPath;
          VideoDate  = PltParameters.VideoDate;
          StrainLabel = PltParameters.StrainLabel;
          IPTG = PltParameters.IPTG;
          ROI  = PltParameters.ROI;
          FigFormat = PltParameters.FigFormat; 
          LHead = PltParameters.LHead;
          Bins = PltParameters.Bins;
          
          %Define Target Export Path 
          ExpPath = fullfile(GenExpPath,VideoDate,[StrainLabel '_' num2str(IPTG) 'uM'],ROI,'SpeedAnalysis','SpeedBeforeAfter_SharpTurn');
          if ~exist(ExpPath,'dir')
             mkdir(ExpPath)
          end
          hPlt = histogram(Q,Bins,'DisplayStyle','bar');
          hold on 
          ax = gca; 
          plot(0.5*ones(1,100),linspace(0,ax.YLim(2),100),'--k','LineWidth',1.5);
          plot(-0.5*ones(1,100),linspace(0,ax.YLim(2),100),'--k','LineWidth',1.5);
          PlotSty(hf,Lab,Lim);
          printfig(hf,fullfile(ExpPath,[LHead '[SpeedAnalysis]' StrainLabel '_SpeedBeforeAfter_SharpTurn_[IPTG]_' num2str(IPTG) '_uM_' ROI]),FigFormat)

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




