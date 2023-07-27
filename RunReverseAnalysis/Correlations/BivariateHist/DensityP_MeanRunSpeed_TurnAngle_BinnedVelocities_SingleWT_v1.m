%% Turn Angle vs. Mean Run Speed before turn for binned data (with respect to mean run speed) 
%by Ercag
% November 2021 
clearvars;
close all; 
clc; 
%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\AngularAnalysis\Correlations';

%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverse_Data';
StrainLabels = {'KMT9'};
Lambda = 0.5;
%% Input parameters 
%Acquisition and ADMM parameter
fps = 30; %Hz

%% Find persistence for each velocity bin ([0-35], [35-75], [75-150], [150-200]) before !!each turn!!. 
%Find .mat files
Files{1} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_1','[20190604]KMT9_OD_0.19_ROI_1_Lambda_0.5_Results.mat');
Files{2} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_2','[20190604]KMT9_OD_0.19_ROI_2_Lambda_0.5_Results.mat');

%Preallocate
TurnAngle = cell(length(Files),1); 
Runs = cell(length(Files),1); 
Before = cell(length(Files),1); 
Binned_STA_Cmb = cell(length(Files),1); 

%Select run durations by their mean speed
V = [0,35,75,150,200];


for i = 1:length(Files)
    load(Files{i}) 
    
    TurnAngle{i,1} = Results.Ang(:,3); %note: all turn angles are already filtered
    Runs{i,1} = RunBreakDownv6(Speeds,Results.T,fps); %!!! Complete + Incomplete Runs!!! 
    
    [Before{i,1}, ~] = test_sep(Runs{i,1},TurnAngle{i,1}); 
    
    %Replace all empty ROW vectors by COLUMN vectors to 
    % be able to run CELL2MAT command
    Before_Clean{i,1} = replace_empty(Before{i,1});
    
    All = cell2mat(Before_Clean{i,1}); 
        
    Binned_Speed_TurnAng{i,1} = All(All(:,2) > V(1) & All(:,2) <= V(2),:); 
    Binned_Speed_TurnAng{i,2} = All(All(:,2) > V(2) & All(:,2) <= V(3),:); 
    Binned_Speed_TurnAng{i,3} = All(All(:,2) > V(3) & All(:,2) <= V(4),:); 
    Binned_Speed_TurnAng{i,4} = All(All(:,2) > V(4) & All(:,2) <= V(5),:); 
       
end 

for k = 1:size(Binned_Speed_TurnAng,2)
    Binned_Speed_CMB{k} = cell2mat(Binned_Speed_TurnAng(:,k)); 
    
    hf{k} = figure(k); 
    Plot.X = Binned_Speed_CMB{k}(:,1); 
    Plot.Y = Binned_Speed_CMB{k}(:,2); 
    Plot.XEdges = 0:10:180; 
    Plot.YEdges = V(k):7:V(k+1); 
    Plot.XTitle = 'Turn Angles (Degrees)'; 
    Plot.YTitle = 'Mean Run Speed Before Turn (\mu{}m/sec)';
    Plot.Title = ['Binned, <V>_{Run}:' num2str(V(k)) '-' num2str(V(k+1)) '\mu{}m/sec.']; 
    
    
    hist{k} = plotHist(hf{k},Plot);
       
    Exp.Main = ExpPath;
    Exp.Filename = ['KMT9_DensityPlot_TA_MeanRunSpeedBeforeT_MeanRunSpeed_Binned_' num2str(V(k)) '_' num2str(V(k+1)) 'mum_sec'];
    ExpFig(hf{k},Exp)
end




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


function ExpFig(hFig,Strings)
Main = Strings.Main; 
Filename = Strings.Filename;
%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];
Total = fullfile(Main,[Stamp Filename]); 


printfig(hFig,Total,'-dpng')
printfig(hFig,Total,'-dpdf')
end


