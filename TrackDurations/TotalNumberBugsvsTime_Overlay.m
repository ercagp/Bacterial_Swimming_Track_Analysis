%Overlay the total number of cells data of KMT9 & KMT9F
%by Ercag Pince
%October 2019 
clearvars;
close all; 

%%  Define path and load data
MainPath = 'Z:\Data\3D_Tracking_Data_Analysis'; 
VideoDates = {'20190920','20190924'};

%Define export path
MainExportPath = 'Z:\Data\3D_Tracking_Data_Analysis';
FullExportPath = fullfile(MainExportPath,'20190924');

StrainKeyword = 'KMT9';
StrainLabel = StrainKeyword; 
FileKeyword = ['avgBugsTracked_' StrainKeyword]; 

%% Call data and overlay plots 
hf_1 = figure(1);
for dataI = 1:length(VideoDates)
    load(fullfile(MainPath,VideoDates{dataI},FileKeyword));
    err{dataI} = errorbar(timeVec, AvgBugsTracked, StdBugsTracked,'.');
    hold on 
end
hold off 

%Error bar Style 
err{1}.LineWidth = 1.5;
err{2}.LineWidth = 1.5;
err{1}.MarkerSize = 15; 
err{2}.MarkerSize = 15; 
% err_1.Color = [0 0 1]; 

%Setting axes properties
ax = gca; 
ax.XLim = [-5 130]; 
%ax.YLim = [20 90];
ax.XAxis.Label.String = 'Time (mins)';
ax.YAxis.Label.String = 'Average # of Bugs per Acq. (a.u.)';
ax.Title.String = StrainKeyword;
ax.Title.Interpreter = 'none'; 

%Legend 
lg_1 = legend(VideoDates,'Location','Best');
lg_1.Interpreter = 'none';

%General Style 
ErcagGraphics
settightplot(ax)

%% Save figures in PDF, FIG and PNG formats
printfig(hf_1,fullfile(MainExportPath,'20190924', 'KMT9_TotalNumberBugsvsTimeDates'),'-dpng')
printfig(hf_1,fullfile(MainExportPath,'20190924', 'KMT9_TotalNumberBugsvsTimeDates'),'-dpdf')
savefig(hf_1,fullfile(MainExportPath,'20190924', 'KMT9_TotalNumberBugsvsTimeDates'))