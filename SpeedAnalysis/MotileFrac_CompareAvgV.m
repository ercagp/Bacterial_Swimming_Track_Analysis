%Compare average speed of the motile fraction between strains 
%This code is a continuation of the analysis conducted in 
%"DiscardImmotileFrac_ComputeAvgV.m"
%by Ercag Pince
clearvars;
close all; 

%% Define the path and load data
MainPath = '/Users/ercagpince/Dropbox/Research/3DTrackingAnalysisData'; 
Files = getallfilenames(MainPath);
VideoDates = {'20191018'};
Files = Files(contains(Files,'avgVThreshold') & contains(Files,VideoDates{1}));

%Define Export Path 
ExportPath = '/Users/ercagpince/Desktop/AverageSpeed';

%AllStrains = {};
AllStrains = {'KMT9','KMT9(R)','KMT11','KMT11(R)','KMT11(R)','KMT10','KMT10','KMT12','KMT12'};

AllavgVSubset = [];
AllsemVSubset = [];

for KMT_i = 1:length(Files)
    %Load data
    load(Files{KMT_i})
    %for j = 1:length(StrainLabels)
      %AllStrains = [AllStrains StrainLabels{j}];
    %end
    display(StrainLabels)
    AllavgVSubset = [AllavgVSubset avgVSubset]; 
    AllsemVSubset = [AllsemVSubset semVSubset]; 
end

%% Plot the average velocity of each strain
hf_1 = figure; 
for i = 1:size(AllavgVSubset,1)
    er{i} = errorbar(1:length(AllavgVSubset),AllavgVSubset(i,:),AllsemVSubset(i,:),'.-');
    hold on 
end

title('Average Speed of Motile Fraction');
ax = gca; 
ax.XTickLabels = AllStrains;
ax.TickLabelInterpreter = 'none';
ax.YLabel.String = '<V> (\mum/sec)';

title('Average Speed of Motile Fraction'); 
ax = gca;
ax.XTick = 1:length(StrainLabels);
ax.XTickLabels = AllStrains;
ax.TickLabelInterpreter = 'none';
ax.YLabel.String = '<V> (\mum/s)';

set([er{1:end}], 'LineWidth',1.5); 
set([er{1:end}], 'MarkerSize',3); 

%ColorMap 
ColorMap = linspecer(length(er));
er{1}.Color = ColorMap(1,:); 
er{2}.Color = ColorMap(2,:); 
er{3}.Color = ColorMap(3,:); 

%Adjust style 
ErcagGraphics
settightplot(ax)

VThreshLabel = strsplit(num2str(threshSpeedArray));
VThreshLabel = cellfun(@(x) [x ' µm/s'],VThreshLabel,'UniformOutput',0); % add units next to each label 

leg1 = legend(VThreshLabel,'Location','Best');


%Adjust style 
ErcagGraphics
settightplot(ax)
ax.FontSize = 12;

%Save the figure to the target(i.e. export) folder 
printfig(hf_1,fullfile(ExportPath,'AvgV'),'-dpdf')
printfig(hf_1,fullfile(ExportPath,'AvgV'),'-dpng')


