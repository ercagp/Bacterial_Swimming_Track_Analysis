%% Calculate Turn Duration and Plot distributions
%June 2020 
%by Ercag
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/TurnAnalysis/TurnDurations/CheckData';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
StrainLabels = {'KMT43','KMT47','KMT53'}; 
%ADMM Parameter
Lambda = 0.5; 

%Selected IPTG for the plot 
IPTGSel = 100; %uM 

%Plot parameters 
fps = 30; %Hz
NormType = 'PDF';
%Define colormap 
%For different [IPTG]
% ColorMap{1} = [0.85 0.33 0.10];
% ColorMap{2} = [0.93 0.69 0.13]; 
% ColorMap{3} = [0.49 0.18 0.56]; 
% ColorMap{4} = [0 0.45 0.74];
%For different strains
ColorMap{1} = [0 0.45 0.74]; %KMT43
ColorMap{2} = [0.85 0.33 0.10]; %KMT47
ColorMap{3} = [0.93 0.69 0.13]; %KMT53

if strcmp(NormType,'PDF')
   Lab.YAx = 'PDF'; 
else
   Lab.YAx = 'Counts'; 

end

Lab.XAx = 'Turn Duration (sec.)';


%Set bin arrays 
minB = 1/fps;
maxB = 0.40; 
BinSize = 1/fps;

Bins = minB:BinSize:maxB; %sec.

Lim.X = [minB maxB]; 

for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnCell = cell(length(Files),1);
    Temp = [];
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        
        minT = Results.minT;
        minV = Results.minV; 
        T = Results.T; 
        %Compute the cell containing run infomation 
        TurnCell{i} = TurnBreakDown(Speeds,T,minV,minT,fps);
        Temp = cell2mat(TurnCell{i}); 
        %Plot parameters 
        Lab.Title = {StrainLabels{j}, ['[IPTG] = ' num2str(IPTG(i)) ' \muM']};
        
        %Plot individual acq.
        hf = figure(i+(j-1)*16);
        histogram(Temp,Bins,'Normalization',...
                    NormType,'FaceColor',ColorMap{j});
        PlotSty(hf,Lab,Lim)
        printfig(hf,fullfile(ExpPath,StrainLabels{j},['[20200610]' StrainLabels{j} '_[IPTG]_' num2str(IPTG(i)) 'uM_' num2str(i) '_TurnDur_' NormType '.pdf']),'-dpdf');
    end
end




%% Functions     
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
         settightplot(ax); 
end

    
    