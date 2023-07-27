%% Turn Angle Distribution for single WT strain binned for mean run speeds before each turn 
% v1.0: plot TA distribution for KMT9 
% by Ercag
% November 2021 
clearvars;
clc;
close all; 
%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Desktop';

%% Call the run reverse analysis files
fps = 30; 
MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverse_Data';
StrainLabels = {'KMT9'};
Lambda = 0.5;

%% Call TurnAngle vector and plot turn angle distribution 
%Find .mat files
Files{1} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_1','[20190604]KMT9_OD_0.19_ROI_1_Lambda_0.5_Results.mat');
Files{2} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_2','[20190604]KMT9_OD_0.19_ROI_2_Lambda_0.5_Results.mat');

%Preallocate
TurnAngle = cell(length(Files),1); 

%Plot parameters
P.XTitle = 'Turn Angle (degrees)'; 
P2.XTitle = 'Turn Angle (degrees)'; 
P3.XTitle = 'Turn Angle (degrees)'; 
P4.XTitle = 'Turn Angle (degrees)'; 


P.YTitle = 'PDF'; 
P1.YTitle = 'PDF'; 
P2.YTitle = 'PDF'; 
P3.YTitle = 'PDF'; 
P4.YTitle = 'PDF'; 

P.Edges = 0:7:180; 
P2.Edges = P.Edges; 
P3.Edges = P.Edges; 
P4.Edges = P.Edges; 

P.FaceColor = [1 0 0]; 
P2.FaceColor = P.FaceColor; 
P3.FaceColor = P.FaceColor; 
P4.FaceColor = P.FaceColor; 

for i = 1:length(Files)
    load(Files{i}) 
    
    TurnAngle{i,1} = Results.Ang(:,3); %note: all turn angles are already filtered
    Runs{i,1} = RunBreakDownv6(Speeds,Results.T,fps); %!!! Complete + Incomplete Runs!!! 
    
    [Before{i,1}, ~] = Separate(Runs{i,1},TurnAngle{i,1}); 
    
    %Replace all empty ROW vectors by COLUMN vectors to 
    % be able to run CELL2MAT command
    Before_Clean{i,1} = replace_empty(Before{i,1});
    
    All = cell2mat(Before_Clean{i,1}); 
    
    %Select run durations by their mean speed
    V = [0,35,75,150,200];
    
    Binned_Speed_TurnAng{i,1} = All(All(:,2) > V(1) & All(:,2) <= V(2),:); 
    Binned_Speed_TurnAng{i,2} = All(All(:,2) > V(2) & All(:,2) <= V(3),:); 
    Binned_Speed_TurnAng{i,3} = All(All(:,2) > V(3) & All(:,2) <= V(4),:); 
    Binned_Speed_TurnAng{i,4} = All(All(:,2) > V(4) & All(:,2) <= V(5),:); 
    
    hf{1} = figure(1); 
    P.X = Binned_Speed_TurnAng{i,1}(:,1); 
    P.Title = ['WT(KMT9) - ROI_' num2str(i)];
    hist{1} =  plotHist(hf{1},P);
    
    hf{2} = figure(2); 
    P2.X = Binned_Speed_TurnAng{i,2}(:,1); 
    P2.Title =  P.Title;
    hist{2} =  plotHist(hf{2},P2);  
    
    hf{3} = figure(3); 
    P3.X = Binned_Speed_TurnAng{i,3}(:,1); 
    P3.Title =  P.Title;
    hist{3} =  plotHist(hf{3},P3);
    
    hf{4} = figure(4); 
    P4.X = Binned_Speed_TurnAng{i,4}(:,1); 
    P4.Title =  P.Title;
    hist{4} =  plotHist(hf{4},P4);


%   hf{i} = figure(i);
%      
% 
%   Exp.Main = ExpPath; 
%   Exp.Filename = ['KMT9_TurnAngle_Dist_ROI_' num2str(i)];
%   ExpFig(hf{i},Exp)        
end

BinnedSTA_Cmb{1} = [Binned_Speed_TurnAng{1,1};Binned_Speed_TurnAng{2,1}];
BinnedSTA_Cmb{2} = [Binned_Speed_TurnAng{1,2};Binned_Speed_TurnAng{2,2}];
BinnedSTA_Cmb{3} = [Binned_Speed_TurnAng{1,3};Binned_Speed_TurnAng{2,3}];
BinnedSTA_Cmb{4} = [Binned_Speed_TurnAng{1,4};Binned_Speed_TurnAng{2,4}];


hf{end+1} = figure; 
Plot.XTitle = P.XTitle; 
Plot.YTitle = P.YTitle; 
Plot.Edges = P.Edges; 
Plot.FaceColor = P.FaceColor;
Plot.Title = 'WT(KMT9) - <V>_{Run} = [0-35] \mu{}m/sec.' ;
Plot.X = BinnedSTA_Cmb{1}(:,1); 
hist{end+1} =  plotHist(hf{end},Plot);
S.Main = ExpPath;
S.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_0_35_um'; 
ExpFig(hf{end},S)


hf{end+1} = figure;
Plot.XTitle = P.XTitle; 
Plot.YTitle = P.YTitle; 
Plot.Edges = P.Edges; 
Plot.FaceColor = P.FaceColor;
Plot.Title = 'WT(KMT9) - <V>_{Run} = [35-75] \mu{}m/sec.' ;
Plot.X = BinnedSTA_Cmb{2}(:,1); 
hist{end+1} =  plotHist(hf{end},Plot);
S.Main = ExpPath;
S.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_35_75_um'; 
ExpFig(hf{end},S)


hf{end+1} = figure;
Plot.XTitle = P.XTitle; 
Plot.YTitle = P.YTitle; 
Plot.Edges = P.Edges; 
Plot.FaceColor = P.FaceColor;
Plot.Title = 'WT(KMT9) - <V>_{Run} = [75-150] \mu{}m/sec.' ;
Plot.X = BinnedSTA_Cmb{3}(:,1); 
hist{end+1} =  plotHist(hf{end},Plot);
S.Main = ExpPath;
S.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_75_150_um'; 
ExpFig(hf{end},S)

hf{end+1} = figure;
Plot.XTitle = P.XTitle; 
Plot.YTitle = P.YTitle; 
Plot.Edges = P.Edges; 
Plot.FaceColor = P.FaceColor;
Plot.Title = 'WT(KMT9) - <V>_{Run} = [150-200] \mu{}m/sec.' ;
Plot.X = BinnedSTA_Cmb{4}(:,1); 
hist{end+1} =  plotHist(hf{end},Plot);
S.Main = ExpPath;
S.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_150_200_um'; 
ExpFig(hf{end},S)


hf{end+1} = figure;
XEdges = 0:10:180;
YEdges = 0:5:35; 
histogram2(BinnedSTA_Cmb{1}(:,1),BinnedSTA_Cmb{1}(:,2),XEdges,YEdges,...
                          'DisplayStyle','tile','ShowEmptyBins','on','Normalization','PDF');
title('WT(KMT9) - <V>_{Run} = [0-35] \mu{}m/sec.')
xlabel('Turn Angle')
ylabel('Mean Run Speed Before Turn')
colorbar                                            
ErcagGraphics
S2D.Main = ExpPath;
S2D.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_0_35_um'; 
ExpFig(hf{end},S2D)


hf{end+1} = figure 
XEdges = 0:10:180;
YEdges = 35:5:75; 
histogram2(BinnedSTA_Cmb{2}(:,1),BinnedSTA_Cmb{2}(:,2),XEdges,YEdges,...
                          'DisplayStyle','tile','ShowEmptyBins','on','Normalization','PDF');
colorbar                                             

title('WT(KMT9) - <V>_{Run} = [35-75] \mu{}m/sec.')
xlabel('Turn Angle')
ylabel('Mean Run Speed Before Turn')

ErcagGraphics
S2D.Main = ExpPath;
S2D.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_35_75_um'; 
ExpFig(hf{end},S2D)

figure 
XEdges = 0:10:180;
YEdges = 75:5:150; 
histogram2(BinnedSTA_Cmb{3}(:,1),BinnedSTA_Cmb{3}(:,2),XEdges,YEdges,...
                          'DisplayStyle','tile','ShowEmptyBins','on','Normalization','PDF');
colorbar                                             

xlabel('Turn Angle')
ylabel('Mean Run Speed Before Turn')
title('WT(KMT9) - <V>_{Run} = [75-150] \mu{}m/sec.')

ErcagGraphics
S2D.Main = ExpPath;
S2D.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_75_150_um'; 
ExpFig(hf{end},S2D)


figure 
XEdges = 0:10:180;
YEdges = 150:5:200; 
histogram2(BinnedSTA_Cmb{4}(:,1),BinnedSTA_Cmb{4}(:,2),XEdges,YEdges,...
                          'DisplayStyle','tile','ShowEmptyBins','on','Normalization','PDF');
colorbar                                             

xlabel('Turn Angle')
ylabel('Mean Run Speed Before Turn')
title('WT(KMT9) - <V>_{Run} = [150-200] \mu{}m/sec.')
ErcagGraphics
S2D.Main = ExpPath;
S2D.Filename = 'KMT9_TurnAngleDist_MeanRunBinned_150_200_um'; 
ExpFig(hf{end},S2D)

%% Functions
function [Bfr, Aft] = Separate(Run,Ang) 
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

function Hist = plotHist(h_Fig,P)
         figure(h_Fig)
         X = P.X; 
         Edges = P.Edges;
         XTitle = P.XTitle;
         YTitle = P.YTitle; 
         Title = P.Title; 
         
         if isfield(P,'DispStyle')
             DispStyle = P.DispStyle; 
         else
             DispStyle = 'bar';
         end
         
         if isfield(P,'Norm')
             Norm = P.Norm;
         else
             Norm = 'PDF';
         end
         
         if isfield(P,'EdgeColor')
            EdgeColor = P.EdgeColor; 
         else
            EdgeColor = [0 0 0];  
         end 
         
         if isfield(P,'FaceColor')
             FaceColor = P.FaceColor; 
         else
             FaceColor = 'auto'; 
         end
         
         if isfield(P,'LineWidth')
             LineWidth = P.LineWidth;
         else
             LineWidth = 0.5; 
         end                  
    
         Hist = histogram(X,Edges,'DisplayStyle',DispStyle,'Normalization',Norm,'EdgeColor',EdgeColor,...
                         'FaceColor',FaceColor,'LineWidth',LineWidth);        
         title(Title);
         xlabel(XTitle);
         ylabel(YTitle);
         ErcagGraphics
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