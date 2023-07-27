%Overlay MSD plots of different ECOR strains
%Nature Rebuttal
%by Ercag
%February 2019
clearvars;
close all; 

%% Define the path and load data
Main_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs';
Sample_label = {'ECOR18','ECOR21'};
total_num = length(Sample_label); %Total number of ECOR strain data to recall 

%Export Path 
Export_Folder = [Main_Folder filesep 'Combined' filesep 'MSD_compare'];
mkdir(Export_Folder);

%Define colormap values for MSD curves
c_map = colormap(lines(total_num));
c_map = mat2cell(c_map, ones(size(c_map,1),1));


for i = 1:total_num
Folder{i} = [Main_Folder filesep 'Combined' filesep Sample_label{i} filesep 'LongTrajectories'];
     
File_name{i} = [Sample_label{i} '_MSD_EnsembleAvg_Combined.mat'];
load([Folder{i} filesep File_name{i}])

%MSD_cell{i} = MSD_ensemble;
%MSD_Scaled_cell{i} = MSD_Scaled_ensemble;

figure(1)
plot(tau(ensemble_vec),MSD_ensemble,...
    'Color',c_map{i},...
    'LineWidth',3)
hold on 

figure(2)
plot(tau(ensemble_scaled_vec),MSD_Scaled_ensemble,...
    'Color',c_map{i},...
    'LineWidth',3)
hold on 

end

hf_1 = figure(1);
legend(Sample_label,'Location','NorthWest')
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';
ax.XLabel.String = '\tau(s)';
ax.YLabel.String = '<\Deltar(\tau)^2>';
ErcagGraphics
settightplot(ax)

hf_2 = figure(2);
legend(Sample_label,'Location','NorthWest')
ax_2 = gca;
ax_2.XScale = 'log';
ax_2.YScale = 'log';
ax_2.XLabel.String = '\tau(s)';
ax_2.YLabel.String = '<\Deltar(\tau)^2>/<v^2>';
ErcagGraphics
settightplot(ax)

%% Save Figures 
printfig(hf_1,[Export_Folder filesep Sample_label{1} '-' Sample_label{2} '_MSD_Compare_Combined.pdf'],'-dpdf')
printfig(hf_2,[Export_Folder filesep Sample_label{1} '-' Sample_label{2} '_MSDScaled_Compare_Combined.pdf'],'-dpdf')

