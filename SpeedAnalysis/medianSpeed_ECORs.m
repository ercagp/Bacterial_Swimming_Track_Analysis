%Compare Median Speed distribution of ECORs
%Ercag
%February 2019
clearvars
close all; 

Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs';


Folder = 'Z:\Data\3D_Tracking_Data';
list = dir(fullfile(Folder, '**', '*.mat')); 


subset = list(20:end); 
logical_subset = contains({subset.name},'ADMM','IgnoreCase',true);

subset_ADMM = subset(logical_subset); 
edgesV = 0:2:100;
fig = figure; 
for i = 1:length(subset_ADMM)
    load([subset_ADMM(i).folder filesep subset_ADMM(i).name])
    
    %calculate the median 
    S=BugsToSpeeds_ForStruct(B_Smooth);
    SpeedStats = SpeedStatistics(S); 
   
    
    %plot the median speed distribution
    h(i)=histogram(SpeedStats.medV ,edgesV,'Normalization','pdf');
    hold on 
    
end
hold off

legend(h, 'ECOR20 - ROI1','ECOR20 - ROI2','ECOR8','ECOR19','ECOR21')

ax = gca;
ax.XLabel.String = 'Median Velocity(\mum/sec.)';
ax.YLabel.String = 'PDF';
settightplot(ax)


printfig(fig,[Export_Folder filesep 'Median_Speed_Dist_ECOR'],'-dpdf')

