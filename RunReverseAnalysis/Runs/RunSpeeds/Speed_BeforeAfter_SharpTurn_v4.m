%% Swimming speed difference before and after a turn event 
%May 2020 
%by Ercag 
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\AngularAnalysis\SpeedBeforeAfterTurns';
%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Frames per second 
fps = 30; %Hz
%Lambda value 
Lambda = 0.5; 

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


j = 3; 
%Find .mat files
  Files = callResultsv2(MainPath, StrainLabels{j},Lambda);    
  %Find video dates and ROIs
%     VideoDates = regexp(Files,RegKeyVD,'match','once');
%     ROI = regexp(Files,RegKeyROI,'match','once');
%     %Preallocate
%     IPTG = zeros(length(Files),1);
%     Q = cell(length(Files),1);
    for i = 1:length(Files) 
        load(Files{i})
        display(Files{i})
        IPTG(i) = RunReverse.Info.IPTG; 
        %Before and after a turn 
        BA  = MatchSpeedTurnA(Speeds,Results,fps);
        
       
        %Plot parameters
%         PP.Bins = Bins;
%         PP.IPTG = RunReverse.Info.IPTG; 
%         PP.StrainLabel = StrainLabels{j};  
%         PP.GenExpPath = GenExpPath; 
%         PP.VideoDate = VideoDates{i};
%         PP.ROI = ROI{i};
%         PP.FigFormat = FigFormat;
%         PP.LHead = LHead; 
%         PP.Labels.XAx = Lab.XAx;
%         PP.Labels.YAx = 'Counts'; 
%         PP.Labels.Title = {[PP.StrainLabel '-' PP.ROI],['[IPTG] = ' num2str(PP.IPTG) '\muM']};
%         PP.Lim.X = Lim.X;
%         PP.AngLow =  InitialPara.AngLow; 
        
%         hf_Q = figure(i);
%         %Plot individual Q 
%         PlotQ(hf_Q,Q{i},PP);
        
    end
%     QS = matchrepeat(IPTG,Q);
    
%     FigureCount = length(findobj('type','figure')); 
%     for k = 1:size(QS,1)
%         IPTGLab = QS{k,1};
%         %Set the title
%         Lab.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLab) ' \muM']};
%         %plot the histogram
%         hf{k} = figure(FigureCount+k);
%         hist(k) = histogram(QS{k,2},Bins,...
%                 'Normalization',NormType,'LineWidth',1,...
%                 'FaceColor',ColorMap{j});
%             
%         ax = gca;
%         hold on
%         plot(0.5*ones(1,1000),linspace(0,(ax.YLim(2).*0.98),1000),'--k','LineWidth',1.5);
%         plot(-0.5*ones(1,1000),linspace(0,(ax.YLim(2).*0.98),1000),'--k','LineWidth',1.5);
%         PlotSty(hf{k},Lab,Lim)
% 
%         
% %         printfig(hf{k},fullfile(ExpPath,['[20201112]' StrainLabels{j} '_RunSpeedBeforeAfter_SharpTurns_[IPTG]_' num2str(IPTGLab) '_uM.pdf']),'-dpdf')
% %         printfig(hf{k},fullfile(ExpPath,['[20201112]' StrainLabels{j} '_RunSpeedBeforeAfter_SharpTurns_[IPTG]_' num2str(IPTGLab) '_uM.png']),'-dpng')
% 
%     end


 %% Functions 
 function BeforeAfter = MatchSpeedTurnA(Speeds,R,fps) 
          %R: Results structure
          Runs = RunBreakDownv6(Speeds,R.T,fps);
          Angles = R.Ang(:,3); 
          
          FltMask = filterout(Speeds,R.minT,R.minV,fps); 
          RunSubset = Runs(FltMask,:);
          AngSubset = Angles(FltMask);
          
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

  

function 

%  function R = matchrepeat(X,Y)
%          UX = unique(X,'stable');
%          R = cell(length(UX),2);
%          for i = 1:length(UX)
%              Mask = X == UX(i);
%              R{i,1} = unique(X(Mask));
%              R{i,2} = cell2mat(Y(Mask)); 
%          end
% end

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




