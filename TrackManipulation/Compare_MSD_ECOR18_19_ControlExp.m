% Compare MSDs of control experiment and actual experiment (for ECOR18&19)
clearvars;
close all; 
%% Define Path
Main_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\MSD\Control_Exp';
MSD_label = {'MSD_ECOR18_19.mat','MSD_ECOR18_19_ControlExp.mat'};
ECOR_Label = {'ECOR18','ECOR19','ECOR18 - Control Exp.','ECOR19 - Control Exp.'};

%Define Export Folder
Export_Folder = Main_Path;

%Define color map 
pre_cmap = jet;

subset_cmap = [pre_cmap(1,:); pre_cmap(10,:)]; 
subset_cmap_cont = [pre_cmap(45,:); pre_cmap(55,:)];
c_map{1} = subset_cmap;
c_map{2} = subset_cmap_cont; 
%c_map = colormap(linspecer(length(MSD_label)));

for i = 1:length(MSD_label)
    load(fullfile(Main_Path,MSD_label{i}))
    
    hf_MSD = figure(1);
    hf_norm_MSD = figure(2); 
    for j =1:length(MSD_R)
    figure(1)
    err = errorbar(tau,MSD_R{j},err_SD_R{j});
    hold on 
    
    err.LineStyle = 'none';
    err.Marker = '.';
    err.MarkerSize = 13; 
    err.Color = c_map{i}(j,:); 
  
    figure(2)
    err_norm = errorbar(tau,Norm_MSD_R{j},err_Norm_SD_R{j});
    hold on 
    
    err_norm.LineStyle = 'none';
    err_norm.Marker = '.';
    err_norm.MarkerSize = 13; 
    err_norm.Color = c_map{i}(j,:); 
    end
    
end

figure(1)
ax_MSD = gca;
ax_MSD.YScale = 'log';
ax_MSD.XScale = 'log';
ax_MSD.Title.String = 'MSD'; 
ax_MSD.YLabel.String = '<\Deltar^{2}>'; 
ax_MSD.XLabel.String = '\tau (sec)';
legend(ECOR_Label,'Location','NorthWest','Box','off')
ErcagGraphics

    
figure(2) 
ax_MSD_norm = gca;
ax_MSD_norm.YScale = 'log';
ax_MSD_norm.XScale = 'log';
ax_MSD_norm.Title.String = 'MSD/<V>^2';
ax_MSD_norm.YLabel.String = '<\Deltar^{2}>/<V>^{2}'; 
ax_MSD_norm.XLabel.String = '\tau (sec)';

legend(ECOR_Label,'Location','NorthWest','Box','off')
ErcagGraphics

savefig(hf_MSD, fullfile(Export_Folder,'MSD_ECOR18_19_ControlExp_Compare'))
savefig(hf_norm_MSD,fullfile(Export_Folder,'Norm_MSD_ECOR18_19_ControlExp_Compare'))

printfig(hf_MSD, fullfile(Export_Folder,'MSD_ECOR18_19_ControlExp_Compare'),'-dpdf')
printfig(hf_norm_MSD, fullfile(Export_Folder,'Norm_MSD_ECOR18_19_ControlExp_Compare'),'-dpdf')

