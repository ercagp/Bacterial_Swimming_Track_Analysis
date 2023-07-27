%% Determine motile population fraction and plot
%by Ercag
%August 2020 
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\3D_Tracking_Data'; 
%% Define Export Parameters 
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\MotileFractionAnalysis'; %Export Path
ExpDate = '[20200805]'; %Export date
ExpTag = 'MotileFraction_'; %Export tag

StrainLabel = 'KMT53'; 
VideoDates = {'20191204','20191206'}; 
Lambda = 0.5; 
minV = 20; %microns /sec 
minT = 0; %sec

Ticks = 10:10:length(VideoDates)*10; 

hf = figure; 
%% Calculate motile fraction 
MFrac = NaN(20,length(VideoDates));
for i = 1:length(VideoDates)
    Files = callTracks(MainPath,StrainLabel,VideoDates{i},Lambda);
 
    for j = 1:length(Files)
        load(Files{j}) 
        SpeedStats = SpeedStatistics(B_Smooth); 
        MFrac(j,i) = GetMotileFrac(SpeedStats,minV,minT); 
    end
    FracHist = 100.*MFrac(~isnan(MFrac(:,i)),i);
    %Plot a scatter plot 
    figure(hf);
    plot(Ticks(i)*ones(length(FracHist),1),FracHist,'x','MarkerSize',13);
    hold on
    drawnow()
end
ax = gca;
ax.XLim = [5 Ticks(end)+5];
ax.XAxis.TickValues = Ticks;
ax.XAxis.TickLabels = VideoDates;
ax.Title.String = StrainLabel; 
ax.YLabel.String = 'Motile Fraction (percentage)';
ErcagGraphics;
hf.Position = [100 850 1000 500];
settightplot(ax)

%% Export the scatter plot 
printfig(hf,fullfile(ExpPath,[ExpDate ExpTag StrainLabel]),'-dpng')
printfig(hf,fullfile(ExpPath,[ExpDate ExpTag StrainLabel]),'-dpdf')

%% Functions 

function MFrac = GetMotileFrac(Stats,minV,minT)
         %Mask for motile population
         NMM = Stats.medV < minV; 
         %Mask for motile population
         MM = Stats.medV > minV &  Stats.TrajDur > minT;
         
         MFrac = sum(MM) / (sum(MM)+sum(NMM)); 
end