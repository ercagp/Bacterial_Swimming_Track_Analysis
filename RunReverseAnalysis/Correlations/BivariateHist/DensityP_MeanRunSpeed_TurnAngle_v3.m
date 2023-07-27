%% Turn angle vs. Run speed before & after a turn 
% by Ercag
% 
% November 2021 
clearvars;
close all; 

%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\AngularAnalysis\Correlations';
%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Documents\Rowland_Data\RunReverseAnalysis\RunReverse_Data';
StrainLabels = {'KMT53'};
Lambda = 0.5;
%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz

%% Plot 2D-histogram of Turn Freq. vs. mean run speed before & after

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),2);
    Runs = cell(length(Files),2); 
    MeanRunSpeed = cell(length(Files),2); 
    BeforeAfter = cell(length(Files),2);
    Before_Turn = cell(length(Files),2);
    After_Turn = cell(length(Files),2);
    
    for i = 1:length(Files)
        %Call the run-reverse file 
        load(Files{i});
        %Correct the wrong IPTG label 
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        
        %Store IPTG value
        TurnAngle{i,1} = IPTG(i);
        Runs{i,1} = IPTG(i);
        MeanRunSpeed{i,1} = IPTG(i); 
        BeforeAfter{i,1} = IPTG(i); 
        Before_Turn{i,1} = IPTG(i); 
        After_Turn{i,1} = IPTG(i); 
        
        TurnAngle{i,2} = Results.Ang(:,3); %note: all turn angles are already filtered
        Runs{i,2} = RunBreakDownv6(Speeds,Results.T,fps); %!!! Complete + Incomplete Runs!!! 
               
        %Remove single run trajectories
        TurnAngle{i,2} = TurnAngle{i,2}(cellfun(@(x) size(x,1) > 1, Runs{i,2}(:,2)));
        Runs{i,2} = Runs{i,2}(cellfun(@(x) size(x,1) > 1, Runs{i,2}(:,2)),:);         
       
        %Mean run speeds before & after a turn
        BeforeAfter{i,2}(:,1) = Runs{i,2}(:,2); %AvMats 
        BeforeAfter{i,2}(:,2) = TurnAngle{i,2}; %Turn angles
        
        %Isolate mean run speeds BEFORE turn                 
        Before_Turn{i,2}(:,1) = BeforeAfter{i,2}(:,2); % Turn angles   
        Before_Turn{i,2}(:,2) = cellfun(@(x) x(1:end-1,2), BeforeAfter{i,2}(:,1), 'UniformOutput',false); %Mean speeds before a turn in the left column
        
        After_Turn{i,2}(:,1) = BeforeAfter{i,2}(:,2); % Turn angles   
        After_Turn{i,2}(:,2) = cellfun(@(x) x(2:end,2), BeforeAfter{i,2}(:,1), 'UniformOutput',false); %Mean speeds after a turn in the left column                                      
    end
    %Match the data belonging to the same IPTG value
    Before_Cmb = matchrepeat(Before_Turn(:,1),Before_Turn(:,2));
    After_Cmb = matchrepeat(After_Turn(:,1),After_Turn(:,2));

    for k = 1:size(Before_Cmb,1)
        
        BT = cell2mat(Before_Cmb{k,2});
        AT = cell2mat(After_Cmb{k,2});
                
        hf{k} = figure(k);
        %Before turn 
%         Plot.X = BT(:,1);
%         Plot.Y = BT(:,2);
%         Plot.XTitle = 'Turn Angles';
%         Plot.YTitle = 'Mean Run Speed Before Turn'; 
%         Plot.Title = [StrainLabels{j} ' @ ' num2str(Before_Cmb{k,1}) '\mu{}M']; 
%         %Define X- and Y-Edges
%         Plot.XEdges = 0:10:180; % Turn angles
%         Plot.YEdges = 0:10:200; % Mean speed before a turn 
%         hist_BFR{k} = plotHist(hf{k},Plot); 

         %After Turn
         Plot.X = AT(:,1);
         Plot.Y = AT(:,2);
         Plot.XTitle = 'Turn Angles';
         Plot.YTitle = 'Mean Run Speed After Turn'; 
         Plot.Title = [StrainLabels{j} ' @ ' num2str(After_Cmb{k,1}) '\mu{}M']; 
         %Define X- and Y-Edges
         Plot.XEdges = 0:10:180; % Turn angles
         Plot.YEdges = 0:10:200; % Mean speed after a turn 
         hist_BFR{k} = plotHist(hf{k},Plot);  
        
        ExpFile.Strain = StrainLabels{j};
        ExpFile.PlotLabel = 'TurnAngle_MeanSpeedAfterTurn';
        ExpFile.IPTG = num2str(After_Cmb{k,1});
        ExpFig(hf{k},ExpFile,ExpPath)
    end


end
%% Functions

function [Bfr, Aft] = test_sep(Run,Ang) 
         Bfr = cell(size(Run,1),2);
         Aft = cell(size(Run,1),2);
         for i = 1:size(Run,1)
             if isempty(Run{i,2})
                MeanSpeeds = double.empty(0,1);
             else
                MeanSpeeds = [Run{i,2}(:,3)];
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
         x(I(:,1),1) = cellfun(@rep,x(I(:,1)),'UniformOutput',0);
         x(I(:,2),2) = cellfun(@rep,x(I(:,2)),'UniformOutput',0);
         %I fucking hate this type of pointers!                  
    function  y = rep(~)
              y = double.empty(0,1);
    end
end


function Hist = plotHist(h_Fig,P)
         figure(h_Fig)
         X = P.X; 
         Y = P.Y; 
         XEdges = P.XEdges;
         YEdges = P.YEdges;
         XTitle = P.XTitle;
         YTitle = P.YTitle; 
         Title = P.Title; 
        
         Hist = histogram2(X,Y,XEdges,YEdges,...
                          'DisplayStyle','tile','ShowEmptyBins','on','Normalization','PDF');        
         colorbar; 
         title(Title);
         xlabel(XTitle);
         ylabel(YTitle);
         ErcagGraphics
end

function ExpFig(h_Fig,S,ExpPath)
         %Time stamp for the PNG/PDF files
         Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];
                        
            
         if ~exist(ExpPath,'dir')
            mkdir(ExpPath)
         end   
         
         FullFileName = [Stamp S.Strain '_' S.PlotLabel '_IPTG_' S.IPTG 'uM'];
         
         printfig(h_Fig,fullfile(ExpPath,FullFileName),'-dpng');
         printfig(h_Fig,fullfile(ExpPath,FullFileName),'-dpdf');
         savefig(h_Fig,fullfile(ExpPath,FullFileName));
end