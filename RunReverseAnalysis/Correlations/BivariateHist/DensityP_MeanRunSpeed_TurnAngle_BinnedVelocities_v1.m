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
StrainLabels = {'KMT47'};
%% Input parameters 
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5;

%Select run durations by their mean speed
V = [0,35,75,150,200];

%% Find persistence for each velocity bin ([0-35], [35-75], [75-150], [150-200]) before !!each turn!!. 

for j = 1:length(StrainLabels)
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    
    
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),1); 
    Runs = cell(length(Files),1); 
    Before = cell(length(Files),1); 
    Before_Clean = cell(length(Files),1); 
    Binned_Speed_TurnAng = cell(length(Files),4); 
    
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
       
    end 
    
    for k = 2:size(Binned_Speed_TurnAng,2)
    
        BinnedSTA(k-1).Cmb = matchrepeat(Binned_Speed_TurnAng(:,1),Binned_Speed_TurnAng(:,k));
        
        for kk = 1:size(BinnedSTA(k-1).Cmb,1)
                 
                 hf{kk} = figure(kk); 
                 Plot.X = BinnedSTA(k-1).Cmb{kk,2}(:,1); 
                 Plot.Y = BinnedSTA(k-1).Cmb{kk,2}(:,2); 
                 
                 Plot.XEdges = 0:10:180; 
                 Plot.YEdges = V(k-1):7:V(k); 
                 Plot.XTitle = 'Turn Angles (Degrees)'; 
                 Plot.YTitle = 'Mean Run Speed Before Turn (\mu{}m/sec)';
                 Plot.Title = {[StrainLabels{j} '- [IPTG] @ ' num2str(BinnedSTA(k-1).Cmb{kk,1}) '\muM'] ,['<V>_{Run}:' num2str(V(k-1)) '-' num2str(V(k)) '\mu{}m/sec.']}; 
                 plotHist(hf{kk},Plot)
                 
                 Exp.Main = ExpPath;
                 Exp.Filename = [StrainLabels{j} '_DensityPlot_TA_MeanRunSpeedBeforeT_IPTG_' num2str(BinnedSTA(k-1).Cmb{kk,1}) 'uM_MeanRunSpeed_Binned_' num2str(V(k-1)) '_' num2str(V(k)) 'mum_sec'];
                 ExpFig(hf{kk},Exp)
        end
        
    end
%     for k = 2:size(Binned_Speed_TurnAng,2)
%         Binned_Speed_CMB{k} = cell2mat(Binned_Speed_TurnAng(:,k)); 
%     
%         hf{k} = figure(k); 
%         Plot.X = Binned_Speed_CMB{k}(:,1); 
%         Plot.Y = Binned_Speed_CMB{k}(:,2); 
%         Plot.XEdges = 0:10:180; 
%         Plot.YEdges = V(k):7:V(k+1); 
%         Plot.XTitle = 'Turn Angles (Degrees)'; 
%         Plot.YTitle = 'Mean Run Speed Before Turn (\mu{}m/sec)';
%         Plot.Title = ['Binned, <V>_{Run}:' num2str(V(k)) '-' num2str(V(k+1)) '\mu{}m/sec.']; 
%         
%         hist{k} = plotHist(hf{k},Plot);
%        
%         Exp.Main = ExpPath;
%         Exp.Filename = [StrainLabels{j} '_DensityPlot_TA_MeanRunSpeedBeforeT_MeanRunSpeed_Binned_' num2str(V(k)) '_' num2str(V(k+1)) 'mum_sec'];
%         ExpFig(hf{k},Exp)
%     end

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


