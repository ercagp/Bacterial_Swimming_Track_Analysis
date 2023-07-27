%Overlay MSD plots of different ECOR strains
%Nature Rebuttal
%by Ercag
%February 2019
clearvars;
close all; 

%% Define the path and load data
Video_Date = {'20190208','20190208'};
total_num = length(Video_Date); %Total number of ECOR strain data to recall 
Sample_label = {'ECOR18','ECOR18'}; 
Ext_label = {'_z_150micron_NewSlide','_z_200micron_NewSample'};
alpha_label = {'alpha_0.25','alpha_0.25'};
ROI = {'ROI_1','ROI_2'}; %Region of Interest 

%Define colormap values for MSD curves
c_map = colormap(lines(total_num));
c_map = mat2cell(c_map, ones(size(c_map,1),1));


for i = 1:total_num
Folder{i} = ['F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs',...
         filesep Video_Date{i} filesep ,...
         Sample_label{i} Ext_label{i} filesep,...
         ROI{i} filesep alpha_label{i} filesep,...
         'LongTrajectories'];
     
File_name{i} = [Sample_label{i} Ext_label{i} '_MSD_EnsembleAvg.mat'];
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

legend(Sample_label,'Location','NorthWest')

hf_1 = figure(1);
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';
ax.XLabel.String = '\tau(s)';
ax.YLabel.String = '<\Deltar(\tau)^2>';

hf_2 = figure(2);
ax_2 = gca;
ax_2.XScale = 'log';
ax_2.YScale = 'log';
ax_2.XLabel.String = '\tau(s)';
ax_2.YLabel.String = '<\Deltar(\tau)^2>/<v^2>';
