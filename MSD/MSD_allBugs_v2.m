%% Calculate MSD for all acquisitions(i.e. combined data) for a single ECOR strain 
% April 2019
% Ercag
close all; 
clearvars; 

%% Define Path
Main_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Combined';
ECOR_label = 'ECOR8'; 
Folder = fullfile(Main_Path,ECOR_label); 
mat_list = dir(fullfile(Folder,'*.mat'));
mat_file = fullfile(mat_list.folder,mat_list.name);
%% Compute MSD
%load the combined .mat file 
load(mat_file)

%Set the colormap 
% c_map = colormap(colorcube(length(bug_i)));
% c_map = mat2cell(c_map, ones(size(c_map,1),1));

%Gathering parameters
ScaleXY=CB.Parameters.Refstack.ScaleXY;
ScaleZ=CB.Parameters.Refstack.ScaleZ;
RoughFocus=CB.Parameters.Refstack.RoughFocus;
fps = CB.Parameters.fps;


%Scale X,Y & Z values in the trajectories 
CB_new = cellfun(@(x) scale_func(x,ScaleXY,ScaleZ,RoughFocus), CB.Bugs,'UniformOutput',0);
R_Cell = cellfun(@(x) sqrt((x(:,2).^2)+(x(:,3).^2)+(x(:,4).^2)), CB_new, 'UniformOutput',0);

%Define the lag time tau to define the range of MSD plot
max_tau_MSD = 45; % max_tau_MSD/fps = ... seconds
tau_MSD = 1:max_tau_MSD; 
tau = tau_MSD./fps; %actual time vector

MSD_R = MSD_cell(fps,R_Cell);  

%Speed Stats
S = SpeedStatistics(CB);

%Normalize each MSD cell with <V>^2
V_mean = cellfun(@nanmean, S.allV); 
V_mean_sq = V_mean.^2;

MSD_R_Norm = cell(length(MSD_R),1); 
for i = 1:length(MSD_R)
    MSD_R_Norm(i) = {MSD_R{i}./V_mean(i)};
end


% MSD_cell = cellfun(@(x) MSD(x,tau_i,fps)', R_Cell,'UniformOutput',0);
 for i = 1:max_tau_MSD
     %Find the cell elements whose length is larger than or equal
     %to the index value "i"
     l_R = cellfun(@length,MSD_R_Norm);
     MSD_mean(i) = nanmean(cellfun(@(x) x(i),MSD_R_Norm(l_R>=i)));
 end


plot(tau,MSD_mean,'.','MarkerSize',13,...
     'Color',[0 0 1]);
 
ax = gca; 
ax.YScale = 'log';
ax.XScale = 'log';


function MSD_R = MSD_cell(fps,R)
l_R = cellfun(@length,R);
MSD_R = cell(length(R),1);
    for i = 1:length(l_R)
        %Check if the element l_R(i) is larger than one 
        if l_R(i) <= 1
           MSD_R(i) = {MSD(R{i},1,fps)'};
        else
           MSD_R(i) = {MSD(R{i},1:l_R(i)-1,fps)'};
        end
    end

end

function block_scaled = scale_func(cell_block,ScaleXY,ScaleZ,RoughFocus)
block_scaled(:,1) = cell_block(:,1);
block_scaled(:,2) = ScaleXY*cell_block(:,2);
block_scaled(:,3) = ScaleXY*cell_block(:,3);
block_scaled(:,4) = ScaleZ*(cell_block(:,4)-RoughFocus);
block_scaled(:,5) = cell_block(:,5);
end
