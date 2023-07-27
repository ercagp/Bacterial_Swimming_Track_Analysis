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

%Combine ROI_1 & ROI_2 and plot run-times for the whole population 
hf = figure(1);
Plt_Cmb.X = cell2mat(RunDurAll); 
Plt_Cmb.Edges =  1/fps.*(2.5:2:75); 
Plt_Cmb.XTitle = 'Run Duration (sec.)'; 
Plt_Cmb.YTitle = 'PDF'; 
Plt_Cmb.Title = 'WT (KMT9) - Combined'; 
hist_Cmp = plotHist(hf,Plt_Cmb); 
hold on 

ColorMap(1,:) = [0,0,0]; 
A = lines(3);
ColorMap(2,:) = A(2,:); 
ColorMap(3,:) = A(3,:); 

%Model 
PModel.X = Plt_Cmb.X; 
PModel.Edges = Plt_Cmb.Edges; 
PModel.GammaExp = 2; 

Model_Gamma = ModelRun(PModel);
h_Model = plot(PModel.Edges,Model_Gamma,'-','Color',ColorMap(1,:),'LineWidth',2);

%Gamma-Fitting
PFit_Gamma.Type = 'gamma'; 
PFit_Gamma.X = Plt_Cmb.X; 
PFit_Gamma.Edges = Plt_Cmb.Edges; 
[Fit_Gamma,Fit_Para] = FitRun(PFit_Gamma);

hFit_Gamma = plot(PFit_Gamma.Edges,Fit_Gamma,'--','Color',ColorMap(2,:),'LineWidth',2);

%Exponential-Fitting
PFit_Exp.Type = 'exp'; 
PFit_Exp.X = Plt_Cmb.X; 
PFit_Exp.Edges = Plt_Cmb.Edges; 
[Fit_Exp,~] = FitRun(PFit_Exp);

hFit_Exp = plot(PFit_Exp.Edges,Fit_Exp,'--','Color',ColorMap(3,:),'LineWidth',2);

%Legend
legend([hFit_Exp,hFit_Gamma,h_Model],{'Exp. Fit','Gamma Fit','Model'})

hold off
% 
hf.Position = [1090 746 658 509]; 

Exp.Main = ExpPath; 
Exp.Filename = ['KMT9_AllPopulation_RunTimeDist'];
ExpFig(hf,Exp)

%% Plot run-times for subpopulations binned by their velocities 
hf_Binned = cell(length(V)-1,1);
hist_Binned = cell(length(V)-1,1);
h_Model_Binned = cell(length(V)-1,1);
hFit_Gamma_Binned = cell(length(V)-1,1);
hFit_Exp_Binned = cell(length(V)-1,1);
Fit_Gamma_Binned = cell(length(V)-1,1);
Fit_Exp_Binned = cell(length(V)-1,1);
Fit_Para_Binned = cell(length(V)-1,1);

for i = 1:length(V)-1
    
    %The distribution
    hf_Binned{i} = figure(i+1); 
    Plt_Binned(i).X = cell2mat(RunDur(:,i));
    Plt_Binned(i).Edges =  1/fps.*(2.5:2:75);
    Plt_Binned(i).XTitle = 'Run Duration (sec.)';
    Plt_Binned(i).YTitle = 'PDF';
    Plt_Binned(i).Title = {'WT (KMT9) - Combined',['<V>_{Run}:[' num2str(V(i)) '-' num2str(V(i+1)) '] \mu{}m/sec']}; 
    hist_Binned{i} = plotHist(hf_Binned{i},Plt_Binned(i));
    hold on; 
    
    %Model 
    PModel_Binned(i).X = Plt_Binned(i).X; 
    PModel_Binned(i).Edges = Plt_Binned(i).Edges; 
    PModel_Binned(i).GammaExp = 2; 

    Model_Gamma_Binned{i} = ModelRun(PModel_Binned(i));
    h_Model_Binned{i} = plot(PModel_Binned(i).Edges,Model_Gamma_Binned{i},'-','Color',ColorMap(1,:),'LineWidth',2);

    %Gamma-Fitting
    PFit_Gamma_Binned(i).Type = 'gamma'; 
    PFit_Gamma_Binned(i).X = Plt_Binned(i).X ; 
    PFit_Gamma_Binned(i).Edges = Plt_Binned(i).Edges; 
    [Fit_Gamma_Binned{i},Fit_Para_Binned{i}] = FitRun(PFit_Gamma_Binned(i));

    hFit_Gamma_Binned{i} = plot(PFit_Gamma_Binned(i).Edges,Fit_Gamma_Binned{i},'--','Color',ColorMap(2,:),'LineWidth',2);

    %Exponential-Fitting
    PFit_Exp_Binned(i).Type = 'exp'; 
    PFit_Exp_Binned(i).X = Plt_Binned(i).X ; 
    PFit_Exp_Binned(i).Edges = Plt_Binned(i).Edges; 
    [Fit_Exp_Binned{i},~] = FitRun(PFit_Exp_Binned(i));

    hFit_Exp_Binned{i} = plot(PFit_Exp_Binned(i).Edges,Fit_Exp_Binned{i},'--','Color',ColorMap(3,:),'LineWidth',2);
    hold off
    
    hf_Binned{i}.Position = [1090 746 658 509]; 

    Exp_Binned(i).Main = ExpPath; 
    Exp_Binned(i).Filename = ['KMT9_' num2str(V(i)) '_' num2str(V(i+1)) '_um_sec_RunTimes_Binned'];
    ExpFig(hf_Binned{i},Exp_Binned(i))
end

%% Functions 
function ModelGamma = ModelRun(P)
         X = P.X;
         Edges = P.Edges; 
         gamma_exp = P.GammaExp; 
         mean_t = mean(X,'omitnan');
         Exp_1 = Edges.^(gamma_exp-1);
         Exp_2 = exp(-gamma_exp.*Edges/mean_t); 
         Exp_3 = gamma(gamma_exp)*((mean_t./gamma_exp)^(gamma_exp));
         ModelGamma = (Exp_1.*Exp_2)/Exp_3; 
end

function [FitOut,FitPara] = FitRun(P_Fit)
         X = P_Fit.X;
         Edges = P_Fit.Edges; 
         FitType = P_Fit.Type; 
         Fit_Obj = fitdist(X ,FitType);         
         
         if strcmp(FitType, 'gamma') 
             FitOut = gampdf(Edges,Fit_Obj.a,Fit_Obj.b);
             FitPara.Shape = Fit_Obj.a; 
             FitPara.Scale = Fit_Obj.b; 
         else
             FitOut = exppdf(Edges,Fit_Obj.mu); 
             FitPara.mu = Fit_Obj.mu; 
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