%% Turn Angle Distribution for single WT strain 
% v1.0: plot TA distribution for KMT9 
% by Ercag
% November 2021 
clearvars;
clc;
close all; 
%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Desktop';
%% Call the run reverse analysis files

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
P.YTitle = 'PDF'; 

P.Edges = 0:7:180; 
P.FaceColor = [1 0 0]; 

for i = 1:length(Files)
    load(Files{i}) 
    
    TurnAngle{i,1} = Results.Ang(:,3); %note: all turn angles are already filtered
    
    hf{i} = figure(i);
    P.X = cell2mat(TurnAngle{i,1}); 
    P.Title = ['WT(KMT9) - ROI_' num2str(i)] ;
    hist{i} =  plotHist(hf{i},P);
    
    Exp.Main = ExpPath; 
    Exp.Filename = ['KMT9_TurnAngle_Dist_ROI_' num2str(i)];
    ExpFig(hf{i},Exp)
        
end

hf{end+1} = figure;
P_Cmb.X = cell2mat(cellfun(@cell2mat,TurnAngle,'UniformOutput',false)); 
P_Cmb.Title = ['WT(KMT9) - Combined'] ;
P_Cmb.XTitle = P.XTitle;
P_Cmb.YTitle = P.YTitle;
P_Cmb.Edges  = P.Edges;
P_Cmb.FaceColor = P.FaceColor; 

hist{end+1} =  plotHist(hf{end},P_Cmb);

Exp.Main = ExpPath; 
Exp.Filename = ['KMT9_TurnAngle_Dist'];
ExpFig(hf{end},Exp)
        



%% Functions 
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