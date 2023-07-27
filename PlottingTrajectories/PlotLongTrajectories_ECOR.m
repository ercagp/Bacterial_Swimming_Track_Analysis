%Analysis of ECOR data
%Plot longer trajectories than a duration threshold
%Nature Rebuttal 
%by Ercag
%February 2019
clearvars; 
close all;
%% Define the parameters of the subset 
minDur = 20; % Seconds
maxSpeed = 50; % um/s
minSpeed = 10; % um/s

%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20190215';
ECOR_Label = 'ECOR19_z175micron';
Sample_Label = ECOR_Label;
Extra_SubFolder = '';
ROI = 'ROI_2'; %Region of Interest
Track_Label = '20190311_Tracking';
Folder =  fullfile(Main_Path,Video_Date,Sample_Label,...
         Extra_SubFolder,ROI,Track_Label);
%Define the lambda value of ADDM; 
lambda = 1; 

%Check if the file belongs to raw or smoothed tracks, 
    if ismember(0,lambda)
    %Case of raw trajectories    
    list_mat = dir([Folder filesep '*.mat']); 
    new_list_handle = cellfun(@(x) contains(x,'ADMM'),{list_mat.name});
    %Eliminate the labels containing string 'ADMM' 
    list_mat(new_list_handle) = [];
    raw_flag = true; 
    else
    %Case of trend filtered trajectories 
    list_mat = dir([Folder filesep '*' num2str(lambda) '.mat']);
    raw_flag = false; 
    end
%Define Export Path 

Export_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs';
Export_Folder = fullfile(Export_Path,Video_Date,Sample_Label,Extra_SubFolder,ROI,Track_Label,['lambda_' num2str(lambda)],'LongTrajectories');

%Make Export Path 
mkdir(Export_Folder);

%Find the list specifically contains the ADMM label
list_final = findlist(Folder,lambda);
FileName = list_final.name; 
load(fullfile(Folder,FileName))

%% Speed Statistics
%Check if the trajectory is trend filtered or raw 
    if raw_flag 
    BugStruct = B; 
    else
    BugStruct = B_Smooth;
    end
%Calculate r vector at each position of time point 
r = calculateR(BugStruct);
    
%Calculate the speed vector
S=BugsToSpeeds_ForStruct(BugStruct);
%Perform Speed Statistics 
SpeedStats = SpeedStatistics(S);

%Retrieve a subset of trajectories which are longer than minDur seconds
%with maximum and minimum speeds of maxSpeed and minSpeed
[k, kind] = MotileLongTrajectorySubset(SpeedStats,minSpeed,minDur);

%Plot the selected trajectories by "kind" index numbers
PlotColouredSpeedTrajectory_ForStruct(S, kind, 30) %Change the last input to maxSpeed! 
title(ECOR_Label)
hf_1 = gcf;

%Create a box around the 3D plot
ax = gca;
ax.BoxStyle = 'full';

%Save them to the target export folder 
savefig(hf_1,[Export_Folder filesep Sample_Label '_Trajectories'])
printfig(hf_1,[Export_Folder filesep Sample_Label '_Trajectories'],'-dpdf')
print(hf_1,[Export_Folder filesep Sample_Label '_Trajectories'],'-depsc2')

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

%% Histograms and distribution 
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
% 
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

%% Functions within 
function list_final = findlist(Folder,lambda)
%Flag for the decision if the file is raw or trend filtered
raw_flag = ismember(0,lambda); 

list_mat = dir([Folder filesep '*.mat']); 
%Find the list of trend filtered files 
new_list_handle = cellfun(@(x) contains(x,'ADMM'),{list_mat.name});
list_mat_ADMM = list_mat(new_list_handle); 
%Find the list of raw files
list_mat_raw = list_mat(~new_list_handle); 

    if raw_flag
    list_final = list_mat_raw;
    else
    %Find the file having a specific lambda number
    final_handle = cellfun(@(x) contains(x,['Lambda_' num2str(lambda)]),{list_mat_ADMM.name});
    list_final = list_mat_ADMM(final_handle);
    end
end
