%Analysis of ECOR data
%Plot longer trajectories than a duration threshold
%and find MSDs 
%----------------------------------
%Nature Rebuttal 
%by Ercag
%February 2019
clearvars; 
close all;

%% Define the parameters of the subset 
minDur = 10; % Seconds
maxSpeed = 50; % um/s
minSpeed =10; % um/s

%% Define the path and load data
Video_Date = '20190215';
ECOR_label = 'ECOR19';
Sample_Label = [ECOR_label '_z175micron_NewSample'];
ROI = 'ROI_1'; %Region of Interest 
Folder = ['Z:\Data\3D_Tracking_Data' filesep Video_Date filesep ,...
         Sample_Label filesep ROI];
%Define the alpha value of ADDM; 
alpha = 0.25; 

%Check if the file belongs to raw or smoothed tracks, 
    if ismember(0,alpha)
    %Case of raw trajectories    
    list_mat = dir([Folder filesep '*.mat']); 
    new_list_handle = cellfun(@(x) contains(x,'ADMM'),{list_mat.name});
    %Eliminate the labels containing string 'ADMM' 
    list_mat(new_list_handle) = [];
    raw_flag = true; 
    else
    %Case of trend filtered trajectories 
    list_mat = dir([Folder filesep '*' num2str(alpha) '.mat']);
    raw_flag = false; 
    end
%Define Export Path 
Export_Folder = ['F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs',...
     filesep Video_Date filesep Sample_Label filesep ROI filesep 'alpha_' num2str(alpha),...
     filesep 'LongTrajectories'];
%Make Export Path 
mkdir(Export_Folder);

%List the smoothed trajectory file with alpha value of either 0.25 or 0.15
FileName = list_mat.name; 
load([Folder filesep FileName])

%% Speed Statistics
%Check if the trajectory is trend filtered or raw 
    if raw_flag 
    BugStruct = B; 
    else
    BugStruct = B_Smooth;
    end
   
%Create the speed structure
S.Speeds = B_Smooth.Speeds;
S.Parameters = B_Smooth.Parameters;
%Perform Speed Statistics 
SpeedStats = SpeedStatistics(S);

%Retrieve a subset of trajectories which are longer than minDur seconds
%with maximum and minimum speeds of maxSpeed and minSpeed
[k, kind] = MotileLongTrajectorySubset(SpeedStats,minSpeed,minDur);

%Plot the selected trajectories by "kind" index numbers
PlotColouredSpeedTrajectory_ForStruct(S, kind, maxSpeed, 'label')
title(ECOR_label)
hf_1 = gcf;

%% Mean square displacement
%Retrieve fps value 
fps = BugStruct.Parameters.fps;
%Define colormap values for MSD curves
%figure(2)
%c_map = colormap(colorcube(length(kind)));
%c_map = mat2cell(c_map, ones(size(c_map,1),1));

%Calculate the radial position of each bug 
r = calculateR(BugStruct);
%Calculate v^2 vector for each bug in the subset 
allV_subset = SpeedStats.allV(kind);
v_sq_subset = cellfun(@(x) x.^2, allV_subset ,'UniformOutput',false);

%Calculate the MSD of the long trajectory subset 
    for i = 1:length(kind)
        %Find out the upper bound of the lag time vector
        %and generate index vector of the lag time for each bug
        tau_i = 1:length(r{kind(i)})-1;
        tau = tau_i./fps; %The lag time vector 
        
        for j = tau_i
        MSD_bug{i}(j) = MSD(r{kind(i)},j,fps);
        end
        %Scaled MSD(with mean speed of each bug)
        MSD_Scaled{i} = MSD_bug{i}/mean(v_sq_subset{i});
        
        %Plot each MSD curve
        figure(2)
        plot(tau, MSD_bug{i},'.','MarkerSize',6,...
        'Color',[0 0 1]);
        %Define text for the legend
        %legendtext{i} = num2str(kind(i));
        hold on 
        
        %Plot each MSD curve scaled with <v^2>
        figure(3)
        plot(tau, MSD_Scaled{i},'.','MarkerSize',6,...
        'Color',[0 0 1]);
        hold on 
    end
%Find the minimum length inside MSDs 
min_MSD = min(cellfun(@length,MSD_bug)); 
ensemble_vec = 1:min_MSD;
%Take the ensemble average of the MSDs up to that (minimum) index value 
MSD_ensemble = zeros(1,min_MSD);
for k = ensemble_vec
MSD_ensemble(k) = mean(cellfun(@(x) x(k),MSD_bug));
end
%Plot ensemble averaged MSDs and overlay 
hf_2 = figure(2);
plot(tau(ensemble_vec),MSD_ensemble,'-r','LineWidth',5)
%Put the title on 
title(ECOR_label)

ax = gca;
ax.YScale = 'log';
ax.XScale = 'log';
ax.XLabel.String = '\tau(s)';
ax.YLabel.String = '<\Deltar(\tau)^2>';
ErcagGraphics
settightplot(ax)
%legend(legendtext,'Location','NorthWest')
hold off

min_MSD_scaled = min(cellfun(@length,MSD_Scaled)); 
ensemble_scaled_vec = 1:min_MSD_scaled;
%Take the ensemble average of the MSDs up to that (minimum) index value 
MSD_Scaled_ensemble = zeros(1,min_MSD_scaled);
for k = ensemble_scaled_vec
MSD_Scaled_ensemble(k) = mean(cellfun(@(x) x(k),MSD_Scaled));
end
%Plot ensemble averaged scaled MSDs and overlay 
hf_3 = figure(3);
plot(tau(ensemble_scaled_vec),MSD_Scaled_ensemble,'-r','LineWidth',5)
%Put the title on 
title(ECOR_label)

ax_2 = gca;
ax_2.YScale = 'log';
ax_2.XScale = 'log';
ax_2.XLabel.String = '\tau(s)';
ax_2.YLabel.String = '<\Deltar(\tau)^2>/<v^2>';
ErcagGraphics
settightplot(ax_2)

hold off 



%% Check the distance proximity in trajectories
%Check the proximity of the selected subset of trajectories 
% C=FindCoexistingTrajectories(BugStruct, 10); 
% I=find(C);
% [ind1, ind2]=ind2sub(size(C), I);
% 
% minD=sparse(size(C,1), size(C,2));
% for i=1:length(ind1)
%     [~,d]=FindTrajectoryDistances(BugStruct, ind1(i),ind2(i));
%     minD(ind1(i),ind2(i))=min(d);
% end

%kind(2)
%Find coexisting trajectories 
%Coex = FindCoexistingTrajectories(S{1}, 10)

%% Histograms and distribution - %% Switch on if the speed and position distributions are needed 
%Find out the speed distribution of the subset 
% allV_subset = SpeedStats.allV(kind);
% %Find out r vector of the subset
% r_subset = r(kind);
% %Preallocate bins in the histogram 
% h = zeros(1,length(kind));
% edgesV = 0:2:70;
% edgesR = 100:1:500;
% 
% 
% total_size = length(kind); 
% subp_n = ceil(sqrt(total_size));


% for i = 1:total_size
%     %Histogram for the speed distribution
%     figure(2)
%     subplot(subp_n,subp_n,i)
%     h(i)=histogram(allV_subset{i}, edgesV,'Normalization','pdf','DisplayStyle','stairs');
%     title(['Cell #' num2str(kind(i))])
%     drawnow()
%     
%     %Histogram for the position(in radial direction) distribution 
%     figure(3)
%     subplot(subp_n,subp_n,i)
%     histogram(r_subset{i},edgesR,'DisplayStyle','stairs')
%     title(['Cell #' num2str(kind(i))])
%     drawnow()
% end
% hf_2 = figure(2); 
% printfig(hf_2,[Export_Folder filesep Sample_Label '_SpeedHistogram'],'-dpdf')
%% Print figures  
savefig(hf_1,[Export_Folder filesep Sample_Label '_Trajectories'])
printfig(hf_1,[Export_Folder filesep Sample_Label '_Trajectories'],'-dpdf')

printfig(hf_2,[Export_Folder filesep Sample_Label '_MSDs'],'-dpdf')
printfig(hf_3,[Export_Folder filesep Sample_Label '_ScaledMSDs'],'-dpdf')

%% Save parameters 
save([Export_Folder filesep Sample_Label '_MSD_EnsembleAvg'],'MSD_ensemble','MSD_Scaled_ensemble','ensemble_vec','ensemble_scaled_vec','tau')





