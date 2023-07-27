%% Plot Run-Time Distributions (PDFs)
% v6.0: this version separates run-time distributions in four different mean
% speed binning [0-35],[35-75],[75-150] & [150-200] um/sec. 
% Also, it uses RunBreakDownv3 to include only complete runs. 

% November 2021 
%by Ercag Pince 
clearvars;
close all; 
%% Define Export Path for figures

ExpPath = 'C:\Users\ercagp\Desktop';
%% Call the run reverse analysis files

MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverse_Data';
StrainLabels = {'KMT9'};
Lambda = 0.5;

%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz
%% Plot Run-Time Distributions in three different subset of bins 
%Find .mat files
Files{1} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_1','[20190604]KMT9_OD_0.19_ROI_1_Lambda_0.5_Results.mat');
Files{2} = fullfile(MainPath, '20190604\KMT9_OD_0.19\ROI_2','[20190604]KMT9_OD_0.19_ROI_2_Lambda_0.5_Results.mat');

%Preallocate
Runs = cell(length(Files),1); 
RunDur = cell(length(Files),4);
RunDurAll = cell(length(Files),1);
AvMat = cell(length(Files),1); 
%Define color map 
ColorMap = lines(2);

for i = 1:length(Files)
    load(Files{i})
              
    Runs{i,1} = RunBreakDownv3(Speeds,Results.T,fps); %Only Complete Runs!
    AvMat = cell2mat(Runs{i,1}(:,2)); 
    
    %Select run durations by their mean speed
    V = [0,35,75,150,200];
    %ColorMap = linspecer(length(V)-1,'qualitative');
    
    RunDur{i,1} = AvMat(AvMat(:,2) > V(1) & AvMat(:,2) < V(2),1); 
    RunDur{i,2} = AvMat(AvMat(:,2) > V(2) & AvMat(:,2) < V(3),1);
    RunDur{i,3} = AvMat(AvMat(:,2) > V(3) & AvMat(:,2) < V(4),1);
    RunDur{i,4} = AvMat(AvMat(:,2) > V(4) & AvMat(:,2) <= V(5),1); 
    
    RunDurAll{i,1} = AvMat(:,1); 
                 
end

%Combine ROI_1 & ROI_2
hf = figure;
Plt_Cmb.X = cell2mat(RunDurAll); 
Plt_Cmb.Edges =  1/fps.*(2.5:2:75); 
Plt_Cmb.XTitle = 'Run Duration (sec.)'; 
Plt_Cmb.YTitle = 'PDF'; 
Plt_Cmb.Title = 'WT (KMT9) - Combined'; 
hist_Cmp = plotHist(hf,Plt_Cmb); 
hold on 

hf = figure; 
Plt_Cmb.X = cell2mat(RunDur(:,3));
Plt_Cmb.Edges =  1/fps.*(2.5:2:75);
Plt_Cmb.XTitle = 'Run Duration (sec.)';
Plt_Cmb.YTitle = 'PDF';
Plt_Cmb.Title = 'WT (KMT9) - Combined'; 
hist_Cmp = plotHist(hf,Plt_Cmb);
hold on; 

Edges = Plt_Cmb.Edges; 
ColorMap(1,:) = [0,0,0]; 
A = lines(3);
ColorMap(2,:) = A(2,:); 
ColorMap(3,:) = A(3,:); 

%Model 
gamma_exp = 2; 
mean_t = nanmean(Plt_Cmb.X);
Exp_1 = Edges.^(gamma_exp-1);
Exp_2 = exp(-gamma_exp.*Edges/mean_t); 
Exp_3 = gamma(gamma_exp)*((mean_t./gamma_exp)^(gamma_exp));
Gamma_Dist = (Exp_1.*Exp_2)/Exp_3; 

h_Model = plot(Edges,Gamma_Dist,'-','Color',ColorMap(1,:),'LineWidth',2);

%Fitting 
GammaPD = fitdist(Plt_Cmb.X ,'gamma');
Fit = gampdf(Plt_Cmb.Edges,GammaPD.a,GammaPD.b);
h_Fit = plot(Plt_Cmb.Edges,Fit,'--','Color',ColorMap(2,:),'LineWidth',2);

%Exponential Fitting 
ExpPD = fitdist(Plt_Cmb.X ,'exp');
Fit_Exp = exppdf(Plt_Cmb.Edges,ExpPD.mu); 
h_Exp = plot(Plt_Cmb.Edges,Fit_Exp,'.-','Color',ColorMap(3,:),'LineWidth',2);

%Legend
legend([h_Exp,h_Fit,h_Model],{'Exp. Fit','Gamma Fit','Model'})

hold off

hf.Position = [1090 746 658 509]; 

Exp.Main = ExpPath; 
Exp.Filename = ['KMT9_Fast_75_150_um_sec_RunTimeDist'];
ExpFig(hf,Exp)



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