%% Mean run speed distribution and othr related plots
%May 2020 
%by Ercag
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/RunAnalysis/SpeedAnalysis/Distributions';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT48','KMT53'}; 

%Selected IPTG for the plot 
IPTGSel = 25; %uM 
fps = 30; %Hz


%% Define Plot parameters 
PltPara.Normalization = 'PDF';
PltPara.DispStyle = 'bar';
PltPara.EdgeColor = [0 0 0]; 
PltPara.LineWidth = 1; 
PltPara.Bins = 0:2:150; 
PltPara.Lim.X = [0 150]; 

PltPara.Label.XAx = '<V>_{Run} (\mum/sec)';
if strcmp(PltPara.Normalization,'PDF')
    PltPara.Label.YAx = 'PDF'; 
else
    PltPara.Label.YAx = 'Counts'; 
end

PltParaSelect.Normalization = 'PDF';
PltParaSelect.LineWidth = 2; 
PltParaSelect.Bins = 0:2:150; 
PltParaSelect.Lim.X = [0 150]; 
PltParaSelect.DispStyle = 'Stairs'; 
PltParaSelect.FaceColor = 'none'; 
PltParaSelect.Label.XAx = '<V>_{Run} (\mum/sec)';
if strcmp(PltParaSelect.Normalization,'PDF')
    PltParaSelect.Label.YAx = 'PDF'; 
else
    PltParaSelect.Label.YAx = 'Counts'; 
end

%Define colormap 
%For different [IPTG]
% ColorMap{1} = [0.85 0.33 0.10];
% ColorMap{2} = [0.93 0.69 0.13]; 
% ColorMap{3} = [0.49 0.18 0.56]; 
% 
%For different strains
ColorMap{1} = [0 0.45 0.74];
ColorMap{2} = [0.85 0.33 0.10]; 
ColorMap{3} = [0.93 0.69 0.13]; 
ColorMap{4} = [0.49 0.18 0.56];


for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    RunCell = cell(length(Files),1);
    RunSpeed = cell(length(Files),1);
    Temp = [];
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 
        %Compute the cell containing run infomation 
        RunCell{i} = RunBreakDown(Speeds,T,minV,minT,fps);
        Temp = cell2mat(RunCell{i}); 
        %Mean speed of runs 
        RunSpeed{i} = Temp(:,2); 
    end
    RS = matchrepeat(IPTG,RunSpeed);
    for k = 1:size(RS,1)
            IPTGLabel = RS{k,1};
            MeanRunSpeed = RS{k,2}; 
            
            %Title for each figure 
            PltPara.Label.Title  = {StrainLabels{j},['[IPTG] = ' num2str(IPTGLabel) ' \muM']};
            %Colormap 
            PltPara.FaceColor = ColorMap{j};
            %Mean run speed distribution 
            hf = figure(k+(6*(j-1)));  
            RunDist(MeanRunSpeed,PltPara,hf)
            
            if IPTGLabel == IPTGSel
                hf_select = figure(40);
                PltParaSelect.EdgeColor = ColorMap{j};
                PltParaSelect.Label.Title = ['[IPTG] = ' num2str(IPTGLabel) ' \muM']; 
                HistSelect{j} =  RunDist(MeanRunSpeed,PltParaSelect,hf_select);
                hold on 
            end
            %printfig(hf,fullfile(ExpPath,['[20201109][MeanRunSpeed]' StrainLabels{j}...
            %'_[IPTG]_' num2str(IPTGLabel) 'uM.pdf']),'-dpdf'); 
            %printfig(hf,fullfile(ExpPath,['[20201109][MeanRunSpeed]' StrainLabels{j}...
            %'_[IPTG]_' num2str(IPTGLabel) 'uM.png']),'-dpng'); 
    end
end

figure(hf_select)
legend([HistSelect{1:end}],StrainLabels,'Location','NorthEast')

%printfig(hf_select,fullfile(ExpPath,['[20201109][MeanRunSpeed]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.pdf']),'-dpdf')
%printfig(hf_select,fullfile(ExpPath,['[20201109][MeanRunSpeed]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM.png']),'-dpng')




%% Functions     

function RunDistH = RunDist(X,PltPara,hFig)
         Norm = PltPara.Normalization;
         LineW = PltPara.LineWidth;
         FaceColor = PltPara.FaceColor;
         EdgeColor = PltPara.EdgeColor; 
         Bins = PltPara.Bins; 
         AxLabel = PltPara.Label; 
         Lim = PltPara.Lim;
         DispStyle = PltPara.DispStyle;
         
         
         
         RunDistH = histogram(X,Bins,'Normalization',Norm,'LineWidth',LineW,...
                       'DisplayStyle',DispStyle,'FaceColor',FaceColor,'EdgeColor',EdgeColor);
         PlotSty(hFig,AxLabel,Lim);
         
end

function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             R{i,2} = cell2mat(Y(Mask)); 
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
         %settightplot(ax); 
end

    
    