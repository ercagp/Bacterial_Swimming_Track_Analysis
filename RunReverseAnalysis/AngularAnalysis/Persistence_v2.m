%% Persistence 
%v2.0: To check the persistence <cos(\theta)> value being how close to -1 ,
%Includes other strains 
%by Ercag
%November 2021 
clearvars;
close all; 
clc; 

%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Desktop';
%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
StrainLabels = {'KMT47'};
%% Input parameters 
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5;
IPTG_X = [0, 25, 35, 50, 60, 75, 100, 1000]; 

%% Find persistence for each velocity bin ([0-35], [35-75], [75-150], [150-200]) before !!a turn!!. 

%Select run durations by their mean speed
V = [0,35,75,150,200];

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),2); 
    Runs = cell(length(Files),2); 
    Before = cell(length(Files),2); 
    Before_Clean = cell(length(Files),2); 
    %All = cell(length(Files),2); 
    Binned_Speed_TurnAng = cell(length(Files),5); 
    Persistence = zeros(length(Files),5); 
    
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        
        TurnAngle{i,1} = IPTG(i);
        Runs{i,1} = IPTG(i); 
        Before{i,1} = IPTG(i); 
        Before_Clean{i,1} = IPTG(i); 
        Binned_Speed_TurnAng{i,1} = IPTG(i); 
        Persistence(i,1) = IPTG(i); 
        
        TurnAngle{i,2} = Results.Ang(:,3); %note: all turn angles are already filtered
        Runs{i,2} = RunBreakDownv6(Speeds,Results.T,fps); %!!! Complete + Incomplete Runs!!! 
        
        [Before{i,2}, ~] = test_sep(Runs{i,2},TurnAngle{i,2});
        %Replace all empty ROW vectors by COLUMN vectors to 
        % be able to run CELL2MAT command
        Before_Clean{i,2} = replace_empty(Before{i,2});
        
        All = cell2mat(Before_Clean{i,2});
                    
        Binned_Speed_TurnAng{i,2} = All(All(:,2) > V(1) & All(:,2) <= V(2),:); 
        Binned_Speed_TurnAng{i,3} = All(All(:,2) > V(2) & All(:,2) <= V(3),:); 
        Binned_Speed_TurnAng{i,4} = All(All(:,2) > V(3) & All(:,2) <= V(4),:); 
        Binned_Speed_TurnAng{i,5} = All(All(:,2) > V(4) & All(:,2) <= V(5),:); 
        
        
        Persistence(i,2) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,2}(:,1)))); 
        Persistence(i,3) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,3}(:,1)))); 
        Persistence(i,4) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,4}(:,1)))); 
        Persistence(i,5) = mean(cos(deg2rad(Binned_Speed_TurnAng{i,5}(:,1))));         
    end
    
    Plot.X = {'0-35','35-75','75-150','150-200'}; 
    for k = 1:length(IPTG_X) 
        hf = figure(k); 
        logMask = Persistence(:,1) == IPTG_X(k);
        plot(1:4,Persistence(logMask,2:5),'o','MarkerSize',10,'Color',[0 0 1]);
        ax = gca;
        ax.XTick = 1:4;
        ax.XLim = [0.5 4.5];
        ax.YLim  = [-1 max(max(Persistence(logMask,2:5))) + 0.5];
        ax.XTickLabel = Plot.X; 
        grid on; 
        ax.XLabel.String = '<V> (\mu{}m/sec)';
        ax.YLabel.String = 'Persistence'; 
        ax.Title.String = [StrainLabels{j} ' - [IPTG] @ ' num2str(IPTG_X(k)) '\mu{m}M']; 
        ErcagGraphics; 
        
        Exp.Main = ExpPath; 
        Exp.Filename = [StrainLabels{j} '_Persistence_BinnedMeanRunSpeed_IPTG_' num2str(IPTG_X(k))];
        ExpFig(hf,Exp)
    end
end


% BinnedSTA_Cmb{1} = [Binned_Speed_TurnAng{1,1};Binned_Speed_TurnAng{2,1}];
% Pers_Cmb(1) = mean(cos(deg2rad(BinnedSTA_Cmb{1}(:,1)))); 
% 
% BinnedSTA_Cmb{2} = [Binned_Speed_TurnAng{1,2};Binned_Speed_TurnAng{2,2}];
% Pers_Cmb(2) = mean(cos(deg2rad(BinnedSTA_Cmb{2}(:,1)))); 
% 
% BinnedSTA_Cmb{3} = [Binned_Speed_TurnAng{1,3};Binned_Speed_TurnAng{2,3}];
% Pers_Cmb(3) = mean(cos(deg2rad(BinnedSTA_Cmb{3}(:,1)))); 
% 
% BinnedSTA_Cmb{4} = [Binned_Speed_TurnAng{1,4};Binned_Speed_TurnAng{2,4}];
% Pers_Cmb(4) = mean(cos(deg2rad(BinnedSTA_Cmb{4}(:,1)))); 
% 
% 
% Plot.X = {'0-35','35-75','75-150','150-200'}; 
% 
% hf = figure(1); 
% plot(1:4, Persistence(:,2:5),'o','MarkerSize',10,'Color',[0 0 1])
% ax = gca;
% ax.XTick = 1:4;
% ax.XLim = [0.5 4.5];
% ax.YLim  = [-1 floor(max(max(Persistence(:,2:5)))) + 0.5];
% ax.XTickLabel = Plot.X; 
% grid on; 
% ax.XLabel.String = '<V> (\mu{}m/sec)';
% ax.YLabel.String = 'Persistence'; 
% ax.Title.String = 'KMT53 - All Acquisitions'; 
% ErcagGraphics; 

% Exp.Main = ExpPath; 
% Exp.Filename = [StrainaLabels{j} ] %'KMT53_Persistence_BinnedMeanRunVelocities_AllAcquisitions';
% ExpFig(hf,Exp)
%% Functions 

function [Bfr, Aft] = test_sep(Run,Ang) 
         Bfr = cell(size(Run,1),2);
         Aft = cell(size(Run,1),2);
         for i = 1:size(Run,1)
             if isempty(Run{i,2})
                MeanSpeeds = double.empty(0,1);
             else
                MeanSpeeds = [Run{i,2}(:,2)];
             end
                          
             TurnAngles = [Ang{i}]; 
             %1st column: Angles
             Bfr{i,1} = TurnAngles;
             Aft{i,1} = TurnAngles;
             %2nd column: Speeds
             Bfr{i,2} = MeanSpeeds(1:end-1);
             Aft{i,2} = MeanSpeeds(2:end);
         end
         
end

function x = replace_empty(x)
         I = cellfun(@isempty, x);
         %x(I(:,1),1) = cellfun(@rep,x(I(:,1)),'UniformOutput',0);
         x(I(:,2),2) = cellfun(@rep,x(I(:,2)),'UniformOutput',0);
         %I fucking hate this type of pointers!                  
    function  y = rep(~)
              y = double.empty(0,1);
    end
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
