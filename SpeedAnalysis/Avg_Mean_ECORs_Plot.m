%Plot mean and weighted mean of the mean speeds
%of ECORs (combined data) 
%Nature Rebuttal
%February 2019 
%Ercag 
clearvars;
close all; 

%Define Export Folder 
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Average_MeanSpeeds';

%Define the loading path
Folder = Export_Folder;  %Notice that the data is recalled from the export folder
File_List = dir([Folder filesep '*.mat']);

number_ECOR = length(File_List);%Number of ECORs 

for i = 1:number_ECOR
    load([File_List(i).folder filesep File_List(i).name])
    ECOR_avgV(i) = mean(avgV_allBugs);
    std_avgV(i) = std(avgV_allBugs);
    axis_text{i} = File_List(i).name(1:6);
end

%Drop the hyphen on ECOR8_
axis_text{contains(axis_text,'ECOR8')}(end) = [];

%Average of the mean speed for each strain 

hf_1 = figure(1);
err_1 = errorbar(1:number_ECOR,ECOR_avgV, std_avgV,'.');
err_1.LineWidth = 1.5;
err_1.MarkerSize = 11; 
err_1.Color = [0 0 1]; 

ax = gca;
ax.XLim = [0 7];
ax.XTick = 1:number_ECOR;
ax.XTickLabel = axis_text;
ax.YAxis.Label.String = 'Speed (\mum/s)';
ax.Title.String = 'Mean bug speeds';
%ErcagGraphics
ax.XAxis.Label.FontSize = 7;

%settightplot(ax);
printfig(hf_1,[Export_Folder filesep 'AllECORs_avgmeanSpeeds'],'-dpdf')

% 
% hf_2 = figure(2); 
% err_2 = errorbar(1:number_ECOR,ECOR_weighted_avg,std_ECOR_weighted_avg,'.','MarkerSize',8);
% err_2.LineWidth = 1.5;
% err_2.MarkerSize = 11; 
% err_2.Color = [1 0 0]; 
% ax_2 = gca;
% ax_2.XLim = [0 7];
% ax_2.XTick = 1:number_ECOR;
% ax_2.XTickLabel = axis_text;
% ax_2.YAxis.Label.String = 'Speed (\mum/s)';
% ax_2.Title.String = 'The average of weighted mean speeds'; 
%ErcagGraphics

%settightplot(ax_2);

% printfig(hf_2,[Export_Folder filesep 'AllECORs_avgweightedmeanSpeeds'],'-dpdf')




