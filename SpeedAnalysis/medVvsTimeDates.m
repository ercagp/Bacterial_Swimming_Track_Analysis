%Compare median speed vs. Time of data taken at different days
%by Ercag Pince
%October 2019 
clearvars;
close all; 

%% Define the path and load data
MainPath = 'Z:\Data\3D_Tracking_Data_Analysis'; 
VideoDates = {'20190920','20190924'};
StrainKeyword = 'KMT9';
StrainLabel = StrainKeyword; 
FileKeyword = ['medV_' StrainKeyword]; 

%Define Export Address 
MainExportPath = 'Z:\Data\3D_Tracking_Data_Analysis'; 

%% Call data and overlay plots 
%Define time vector 
timeVec = [0 15 30 60 120]; %mins. 
%Open a figure panel 
hf_1 = figure(1);
for dataI = 1:length(VideoDates)
    load(fullfile(MainPath,VideoDates{dataI},FileKeyword));
    err{dataI} = errorbar(timeVec, medV, semedV,'.');
    hold on 
end

%Error bar Style 
err{1}.LineWidth = 1.5;
err{2}.LineWidth = 1.5;
err{1}.MarkerSize = 15; 
err{2}.MarkerSize = 15; 
% err_1.Color = [0 0 1]; 

%Setting axes properties
ax = gca; 
ax.XLim = [-5 130]; 
ax.YLim = [20 90];
ax.XAxis.Label.String = 'Time (mins)';
ax.YAxis.Label.String = 'Median V (\mum/s)';
ax.Title.String = {'KMT9', 'Whole Population'};
ax.Title.Interpreter = 'none'; 

%Legend 
lg_1 = legend(VideoDates,'Location','Best');
lg_1.Interpreter = 'none';

%General Style 
ErcagGraphics
settightplot(ax)

%% Save figures in PDF, FIG and PNG formats
printfig(hf_1,fullfile(MainExportPath,'20190924', 'KMT9_MedianSpeedvsTimeDates'),'-dpng')
printfig(hf_1,fullfile(MainExportPath,'20190924', 'KMT9_MedianSpeedvsTimeDates'),'-dpdf')
savefig(hf_1,fullfile(MainExportPath,'20190924', 'KMT9_MedianSpeedvsTimeDates'))