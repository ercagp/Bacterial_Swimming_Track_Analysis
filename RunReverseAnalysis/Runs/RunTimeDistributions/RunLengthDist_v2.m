%% Work out Run Length distributions v2
%by Ercag 
%May 2020 
clearvars;
close all;
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/TurnRunDurations';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53'}; 

%Filtering parameters
IPTGSel = 100; %uM 

%Plot parameters 
fps = 30; %Hz
NormType = 'count';

for in = 1:3
    Lab{in}.XAx = 'Run Duration (sec)';
    if strcmp(NormType,'PDF')
       Lab{in}.YAx = 'PDF'; 
    else
       Lab{in}.YAx = 'Counts'; 
    end
end

%Set bin arrays 
minB = 0;
maxB = 3.5; 

Bins{1} = minB:1/fps:maxB; %sec.
Bins{2} = 0:1/fps:0.5; %sec

Lim.X = [minB maxB]; 


for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunDur = cell(length(Files),1);
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 
        %Compute run lengths through matrix T
        RunDur{i} = AltRunLength(Speeds,T,minT,minV,fps);%RunLength(Speeds,T,minT,minV,fps); 
%         %Plot run durations for individual strains
%         if IPTG(i) == 25
%         hf_ind = figure(10+j);
%         hist_ind = histogram(RunDur{i},Bins{1},'DisplayStyle','Stairs',...
%                                 'Normalization','count','LineWidth',2);
%         hold on
%         Lab{1}.Title = {StrainLabels{j},['[IPTG] = ' num2str(IPTG(i)) ' \muM']};
%         plt = true;
%         end
             
    end
    
    RDur = matchrepeat(IPTG,RunDur);
    %TDur = matchrepeat(IPTG,TurnDur);
    %TA_TDur = [TA(:,2),TDur(:,2)]; %TurnAngles-TurnDurations
    for k = 1:size(RDur,1)
        %Title for each figure 
        Lab{1}.Title  = StrainLabels{j};
        Lab{2}.Title  = StrainLabels{j};

        %Run durations
        hf{j} = figure(j);
        hist{k,j} = histogram(RDur{k,2},Bins{1},'DisplayStyle','Stairs',...
                'Normalization',NormType,'LineWidth',2);  
        hold on
        
        %Turn durations
        %hf{length(StrainLabels)+j} = figure(length(StrainLabels)+j);
        %hist_TDur{k,j} = histogram(TDur{k,2},Bins{2},'DisplayStyle','Stairs',...
         %       'Normalization','count','LineWidth',2); 
        %hold on
         
        %Selected run durations 
        if RDur{k,1} == IPTGSel
           hf_select = figure(3*length(StrainLabels)+1); 
           hist_select{j} = histogram(RDur{k,2},Bins{1},'DisplayStyle','Stairs',...
               'Normalization',NormType,'Linewidth',2);
           hold on
           Lab{3}.Title = ['[IPTG] = ', num2str(RDur{k,1}) '\muM']; 
        end

    end
    figure(hf{j})
    PlotSty(hf{j},Lab{1},Lim) 
    %Insert legend 
    legLabels = cellfun(@num2str,RDur(:,1),'UniformOutput',0);
    legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
    NewOrder = [2 3 4 1];
    legend([hist{NewOrder,j}],legLabels(NewOrder),'Location','NorthEast')
    if strcmp(NormType,'PDF')
       printfig(hf{j},fullfile(ExpPath,['[20200522]NPDF_' StrainLabels{j} '_RunDurations.pdf']),'-dpdf')
    else
       printfig(hf{j},fullfile(ExpPath,['[20200522]' StrainLabels{j} '_RunDurations.pdf']),'-dpdf')
    end
    
    
%     figure(hf{length(StrainLabels)+j})
%     PlotSty(hf{length(StrainLabels)+j},Lab{2},Lim{2}) 
%     %Insert legend 
%     legLabels = cellfun(@num2str,TDur(:,1),'UniformOutput',0);
%     legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
%     NewOrder = [2 3 4 1];
%     legend([hist_TDur{NewOrder,j}],legLabels(NewOrder),'Location','NorthEast')
    %printfig(hf{length(StrainLabels)+j},fullfile(ExpPath,['[20200506]' StrainLabels{j} '_TurnDurations.pdf']),'-dpdf')
end
    figure(hf_select)
    PlotSty(hf_select,Lab{3},Lim)
    legend([hist_select{1:end}],StrainLabels,'Location','NorthEast')
    if strcmp(NormType,'PDF')
       printfig(hf_select,fullfile(ExpPath,['[20200522]NPDF_RunDur_AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
    else
       printfig(hf_select,fullfile(ExpPath,['[20200522]RunDur_AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
    end

    
    
%% Functions     
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

% function RunL = RunLength(S,T,minT,minV,fps)
%          %Filter out trajectories
%          TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
%          medV = cellfun(@(x) medianN(x(:,9)), S);
%         
%          MaskTraj = medV > minV & TotalTime > minT;
%          SSubset = S(MaskTraj); 
%          TSubset = T(MaskTraj,:); 
%          
%          TrajL = cellfun(@(x) x(end,1),SSubset);
%          RunL = []; 
%          for i  = 1:size(TSubset,1)
%              RunStart = TSubset{i,2};
%              RunEnd = TSubset{i,3};
%              R = TSubset{i,1}; %Run matrix
%                              
%              if isempty(RunStart) && isempty(RunEnd)
%                 %Take the whole trajectory as a single run
%                 RL = 3:size(R,1)-6;
%              else
%                %Check if the trajectory starts by a run
%                if R(3,1)
%                   RLSt = (RunEnd(1)-3)+1;
%                else
%                   RLSt = []; 
%                end
%                RL = RunEnd(2:length(RunStart))-RunStart(1:(end-1))+1;
%                
%                if  length(RunEnd) > length(RunStart)
%                    RLEnd = RunEnd(length(RunEnd))-RunStart(end)+1;
%                else
%                    RLEnd = (size(R,1)-6)-RunStart(end)+1;  
%                end
%                RL = [RLSt, RL, RLEnd]; 
%             end
%             RunL = [RunL; RL']; 
%          end
%          RunL = RunL./fps;
% end

%Alternative version of Run length function 
function RunL = AltRunLength(S,T,minT,minV,fps)
         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1))./fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         MaskTraj = medV > minV & TotalTime > minT;
         TSubset = T(MaskTraj,:); 
         
         %Exclude trajectories without turn events 
         TSubset = TSubset(~cellfun(@isempty,TSubset(:,2)),:);
                 
         RunL = []; 
         for i  = 1:size(TSubset,1)
             R = TSubset{i,1}; %Run matrix
             %Empty RL before loop
             RL = [];
             for j = 1:size(R,2)
                 if j == 1
                    RL(j) = sum(R(3:end,j))+1;
                 else
                    RL(j) = sum(R(1:end,j))+1;
                 end  
             end
                    
            RunL = [RunL; RL']; 
         end
         RunL = RunL./fps;
end

