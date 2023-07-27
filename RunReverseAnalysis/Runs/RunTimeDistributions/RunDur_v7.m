%% Plot Run-Time Distributions (PDFs)
% v7.0: This version includes fitting to each binned distribution 
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
StrainLabels = {'KMT43'};
Lambda = 0.5;

%% Input parameters 

%Acquisition and ADMM parameter
fps = 30; %Hz
Edges = 1/fps.*[(2.5:2:45), 46.5];
%Color map for fitting and model curves
ColorMap_Fit(1,:) = [0,0,0]; 
A = lines(3);
ColorMap_Fit(2,:) = A(2,:); 
ColorMap_Fit(3,:) = A(3,:);

%% Plot Run-Time Distributions in three different subset of bins 
for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    Runs = cell(length(Files),2); 
    RunDur = cell(length(Files),2); 
    RunDurAll = cell(length(Files),2); 
    
    for i = 1:length(Files)
        load(Files{i})
        %Correct the wrong IPTG label 
        IPTG(i) = RunReverse.Info.IPTG;
        if IPTG(i) == 1
           IPTG(i) = IPTG(i)*1000;
        end
        
        %Store IPTG value
        Runs{i,1} = IPTG(i);
        RunDur{i,1} = IPTG(i);
        RunDurAll{i,1} = IPTG(i);
        
        Runs{i,2} = RunBreakDownv3(Speeds,Results.T,fps); %Only Complete Runs!
        AvMat = cell2mat(Runs{i,2}(:,2)); 
        
        %Select run durations by their mean speed
        V = [0,35,75,150,200];
        ColorMap = linspecer(length(V)-1,'qualitative');

        
        RunDur{i,2} = AvMat(AvMat(:,2) > V(1) & AvMat(:,2) < V(2),1); 
        RunDur{i,3} = AvMat(AvMat(:,2) > V(2) & AvMat(:,2) < V(3),1);
        RunDur{i,4} = AvMat(AvMat(:,2) > V(3) & AvMat(:,2) < V(4),1);
        RunDur{i,5} = AvMat(AvMat(:,2) > V(4) & AvMat(:,2) <= V(5),1);
        
        RunDurAll{i,2} = AvMat(:,1); 
    end
    
    RD_0 = matchrepeat(RunDur(:,1),RunDur(:,2));
    RD_1 = matchrepeat(RunDur(:,1),RunDur(:,3));
    RD_2 = matchrepeat(RunDur(:,1),RunDur(:,4));
    RD_3 = matchrepeat(RunDur(:,1),RunDur(:,5));
    RD_All = matchrepeat(RunDurAll(:,1),RunDurAll(:,2)); 
    
    RD_Cmb = [RD_0(:,1), RD_0(:,2), RD_1(:,2), RD_2(:,2), RD_3(:,2)]; 
    

    
    for k = 1:size(RD_Cmb,1) 
        for l = 1:length(V)-1
                        
            ind = l + (length(V)*(k-1));
            hf{ind} = figure(ind);

            Plot.X =  RD_Cmb{k,l+1};
            if length(Plot.X) < 2 
               continue
            end
            Plot.Edges = Edges; 
            Plot.FaceColor = ColorMap(l,:);
            Plot.Title = {[StrainLabels{j} ' @ ' num2str(RD_Cmb{k,1}) '\mu{}M'],...
                          [num2str(V(l)) '-' num2str(V(l+1)) '\mu{}m/sec']};
            Plot.XTitle = 'Run Duration (sec.)';
            Plot.YTitle = 'PDF';                        
            
            plotHist(hf{ind},Plot)
            hold on 
            
            %Model curve
            PModel.X = Plot.X; 
            PModel.Edges = Plot.Edges; 
            PModel.GammaExp = 2; 

            Model_Gamma = ModelRun(PModel);
            h_Model{ind} = plot(PModel.Edges,Model_Gamma,'-','Color',ColorMap_Fit(1,:),'LineWidth',2);
            
            %Fitting  
            PFit_Gamma.Type = 'gamma'; 
            PFit_Gamma.X = Plot.X; 
            PFit_Gamma.Edges = Plot.Edges; 
            [Fit_Gamma,Fit_Para] = FitRun(PFit_Gamma);

            hFit_Gamma{ind} = plot(PFit_Gamma.Edges,Fit_Gamma,'--','Color',ColorMap_Fit(2,:),'LineWidth',2);
            
            %Exponential-Fitting
            PFit_Exp.Type = 'exp';           
            PFit_Exp.X = Plot.X; 
            PFit_Exp.Edges = Plot.Edges; 
            [Fit_Exp,~] = FitRun(PFit_Exp);

            hFit_Exp{ind} = plot(PFit_Exp.Edges,Fit_Exp,'--','Color',ColorMap_Fit(3,:),'LineWidth',2);
            
            %Legend
            legend([hFit_Exp{ind},hFit_Gamma{ind},h_Model{ind}],{'Exp. Fit','Gamma Fit','Model'})
            
            hold off
            %Export Figure 
            ExpFile.Strain = StrainLabels{j};
            ExpFile.PlotLabel = [num2str(V(l)) '-' num2str(V(l+1)) '_MeanSpeedBinned_RunDurations'];
            ExpFile.IPTG = num2str(RD_Cmb{k,1});
            ExpFig(hf{ind},ExpFile,ExpPath)
        end
        %Plot all run durations without binning 
        hf{end+1} = figure;
        
        Plot_All.X =  RD_All{k,2};
        Plot_All.Edges = Edges; 
        Plot_All.Title = {[StrainLabels{j} ' @ ' num2str(RD_Cmb{k,1}) '\mu{}M']};
        Plot_All.XTitle = 'Run Duration (sec.)';
        Plot_All.YTitle = 'PDF';                    
        
        plotHist(hf{end},Plot_All)
        hold on 
        
        %Model curve
        PModel_All.X = Plot_All.X; 
        PModel_All.Edges = Plot_All.Edges; 
        PModel_All.GammaExp = 2; 

        Model_All_Gamma = ModelRun(PModel_All);
        h_All_Model{k} = plot(PModel_All.Edges,Model_All_Gamma,'-','Color',ColorMap_Fit(1,:),'LineWidth',2);
       
        %Fitting  
        PFit_All_Gamma.Type = 'gamma'; 
        PFit_All_Gamma.X = Plot_All.X; 
        PFit_All_Gamma.Edges = Plot_All.Edges; 
        [Fit_All_Gamma,Fit_All_Para] = FitRun(PFit_All_Gamma);

        hFit_All_Gamma{k} = plot(PFit_All_Gamma.Edges,Fit_All_Gamma,'--','Color',ColorMap_Fit(2,:),'LineWidth',2);
        
        
        %Exponential-Fitting
        PFit_All_Exp.Type = 'exp'; 
        PFit_All_Exp.X = Plot_All.X; 
        PFit_All_Exp.Edges = Plot_All.Edges; 
        [Fit_All_Exp,~] = FitRun(PFit_All_Exp);

        hFit_All_Exp{k} = plot(PFit_All_Exp.Edges,Fit_All_Exp,'--','Color',ColorMap(3,:),'LineWidth',2);
                       
        hold off 
        
        %Legend
        legend([hFit_All_Exp{k},hFit_All_Gamma{k},h_Model{k}],{'Exp. Fit','Gamma Fit','Model'})
            
        %Export Figure 
        ExpFile.Strain = StrainLabels{j};
        ExpFile.PlotLabel = ['AllRuns_RunDurations'];
        ExpFile.IPTG = num2str(RD_All{k,1});
        ExpFig(hf{end},ExpFile,ExpPath)
    end
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