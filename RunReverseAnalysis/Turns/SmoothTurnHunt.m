%% Hunting for smooth turn events
%May 2020 
%by Ercag
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\AngularAnalysis\Correlations\DensityPlots';

%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\Data';
StrainLabels = {'KMT43','KMT47','KMT48','KMT53'}; 


%Plot parameters 
fps = 30; %Hz 

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),1);
    S = cell(length(Files),1); 
    SBeforeT = cell(length(Files),1);
    SAfterT = cell(length(Files),1); 
    for i = 1:length(Files)
        load(Files{i}) 
        %Parameters 
        minT = Results.minT;
        minV = Results.minV;
        %Observables
        IPTG(i) = RunReverse.Info.IPTG;
        TurnAngle{i} = cell2mat(Results.Ang(:,3));
        
        %Filter out trajectories 
        TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,Speeds); 
        medV = cellfun(@(x) medianN(x(:,9)), Speeds);
        
        MaskTraj = medV > minV & TotalTime > minT;
        FiltSpeeds = Speeds(MaskTraj);
        TSubset = Results.T(MaskTraj,:);
        % ---- Test ----%
        [SBeforeT{i}, SAfterT{i}] = FindSpeedTA(TSubset,FiltSpeeds);        
    end
    TA = matchrepeat(IPTG,TurnAngle);
    SBT = matchrepeat(IPTG,SBeforeT); 
    SAT = matchrepeat(IPTG,SAfterT); 
    
    for n = 1:length(TA(:,1))
        %Velocity Before Turn vs. Turn Angle
        figure(n+(length(TA(:,1))*(j-1)))
        X = [SBT{n,2},TA{n,2}];
        XEdge = 0:4:150;
        YEdge = 0:4:180;
        
        histogram2(SBT{n,2},TA{n,2},XEdge,YEdge,'DisplayStyle','tile',...
            'ShowEmptyBins','on','Normalization','PDF');
        
        %hist3(X,'CdataMode','auto','FaceColor','Interp',...
        %    'NBins',[50 50])
        %view(2)
        colorbar
        title({StrainLabels{j}, ['[IPTG] = ' num2str(TA{n,1}) '\muM']})
        
        xlabel('Speed Before Turn(\mum/sec)'); 
        ylabel('Turn Angle (degrees)');
        %printfig(figure(n+(length(TA(:,1))*(j-1))),fullfile(ExpPath,['[20201109]SAH_MeanLast3Speed_BeforeTurn_' StrainLabels{j} '_[IPTG]_' num2str(TA{n,1}) 'uM.pdf']),'-dpdf');
        
        %Velocity After Turn vs. Turn Angle
        figure(n+(3*length(TA(:,1))*(j-1)))
        X = [SAT{n,2},TA{n,2}];
        histogram2(SAT{n,2},TA{n,2},XEdge,YEdge,'DisplayStyle','tile',...
            'ShowEmptyBins','on','Normalization','PDF'); 
        %hist3(X,'CdataMode','auto','FaceColor','Interp',...
         %   'NBins',[50 50])
        %view(2)
        colorbar
        title({StrainLabels{j}, ['[IPTG] = ' num2str(TA{n,1}) '\muM']})
        
        xlabel('Speed After Turn(\mum/sec)'); 
        ylabel('Turn Angle (degrees)');
        %printfig(figure(n+(3*length(TA(:,1))*(j-1))),fullfile(ExpPath,['[20201109]SAH_MeanLast3Speed_AfterTurn_' StrainLabels{j} '_[IPTG]_' num2str(TA{n,1}) 'uM.pdf']),'-dpdf');
        
        
    end
    
end 

%% Functions     
function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             if iscell(Y)
                R{i,2} = cell2mat(Y(Mask)); 
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
         settightplot(ax); 
end


% function [VB, VA] = FindSpeedTA(T,S)
%          dX = cellfun(@(x) x(:,6:8),S,'UniformOutput',0);
%          VA = cell(size(dX,1),1);
%          VB = cell(size(dX,1),1);
%          for j = 1:size(dX,1)
%              RunStart = T{j,2};
%              RunEnd = T{j,3};
%              VB_TA = zeros(length(RunStart),1);
%              VA_TA = zeros(length(RunStart),1);
%              for i = 1:length(RunStart)
%                 %Check if the bug turns at beginning of a
%                 %trajectory 
%                   if RunEnd(i) == 2  
%                   FirstSet = RunEnd(i)-1;
%                   else
%                   FirstSet = (RunEnd(i)-1):(RunEnd(i));
%                   end
%                   SecondSet = (RunStart(i)):(RunStart(i)+1);
% 
%                   %Velocity vector sum
%                   dX1 = sum(dX{j}(FirstSet,:));
%                   dX2 = sum(dX{j}(SecondSet,:)); 
%                   %Speeds
%                   VB_TA(i) = sqrt(sum(dX1.^2));
%                   VA_TA(i) = sqrt(sum(dX2.^2));
%              end
%              VB{j} = VB_TA; 
%              VA{j} = VA_TA; 
%          end
%          VB = cell2mat(VB);
%          VA = cell2mat(VA);
% end

function [VB_run, VA_run] = FindSpeedTA_run(T,S)
         VA = cell(length(S),1);
         VB = cell(length(S),1);
         
         for i = 1:length(S)
             R = T{i,1}; %Run Matrix 
             RunSpeed = zeros(size(R,2),1); 
             for j = 1:size(R,2)
             %Apply the logical mask to find runspeed
                 RunSpeed(j) = mean(S{i}(R(:,j),9));  
             end
             VB{i} = RunSpeed(1:end-1); 
             VA{i} = RunSpeed(2:end);
         end
         VB_run = cell2mat(VB(~cellfun(@isempty,VB)));
         VA_run = cell2mat(VA(~cellfun(@isempty,VA)));
end

function [VB, VA] = FindSpeedTA(T,S)
         VA = cell(length(S),1);
         VB = cell(length(S),1);
         
         for i = 1:length(S)
             R = T{i,1}; %Run Matrix
             RunSpeed = cell(size(R,2),1);
             MeanS = zeros(size(R,2),1);
             for j = 1:size(R,2)
                 %Apply the logical mask to find runspeed
                 RunSpeed{j} = S{i}(R(:,j),9);
                 %Find the mean of last three point speeds before a turn
                 MeanS(j) = mean(RunSpeed{j}(end-2:end));
             end
             VB{i} = MeanS(1:end-1); 
             VA{i} = MeanS(2:end);
         end
         VB = cell2mat(VB(~cellfun(@isempty,VB)));
         VA = cell2mat(VA(~cellfun(@isempty,VA)));
end
             
