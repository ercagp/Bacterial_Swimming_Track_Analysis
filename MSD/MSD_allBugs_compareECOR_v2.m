%% Calculate MSD for all acquisitions(i.e. combined data) for a single ECOR strain 
% April 2019
% Ercag
close all; 
clearvars; 

%% Define Path
Main_Path = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Combined';
ECOR_label = {'ECOR18','ECOR19'};

%Define Export Folder
Export_Folder = 'F:\Dropbox\Research\Paper_Revisions\Coexistence in bacterial populations\Nature\3DTracking_ECORpairs\Average_MeanSpeeds';


%Get the list of all subfolders
mat_list{1} = findmat(Main_Path,ECOR_label{1}); 
mat_list{2} = findmat(Main_Path,ECOR_label{2});

%% Parameters
%Define the lag time tau to define the range of MSD plot
max_tau_MSD = 45; % max_tau_MSD/fps = ... seconds
tau_MSD = 1:max_tau_MSD; 
fps = 15; %15 frames/sec
tau = tau_MSD./fps; %actual time vector

%Set the colormap 
c_map = colormap(linspecer(length(ECOR_label)));
c_map = mat2cell(c_map, ones(size(c_map,1),1));

%Brownian diffusion 
k_B = 1.380e-23; %Boltzmann constant (J/K)
T = 273+20; %Temperature (K)
eta = 1.0016e-3; %Viscosity of Water (Pa*sec)
R = 1e-6; %Radius of the bug (m) 
D_free = (k_B*T)./(6*pi*eta*R); %Diffusivity (m^2/sec)

MSD_free = 6*D_free.*tau; %MSD of a Brownian particle with radius R (m^2)
MSD_free = MSD_free.*1e12; % (micron^2) 
%% Compute MSD
% err = zeros(1,length(mat_list)); 
% err_norm = zeros(1,length(mat_list)); 

for j = 1:length(mat_list)
%load the combined .mat file
load(mat_list{j})

%Gathering parameters
ScaleXY=CB.Parameters.Refstack.ScaleXY;
ScaleZ=CB.Parameters.Refstack.ScaleZ;
RoughFocus=CB.Parameters.Refstack.RoughFocus;
fps = CB.Parameters.fps;


%Scale X,Y & Z values in the trajectories 
CB_new = cellfun(@(x) scale_func(x,ScaleXY,ScaleZ,RoughFocus), CB.Bugs,'UniformOutput',0);
R_Cell = cellfun(@(x) sqrt((x(:,2).^2)+(x(:,3).^2)+(x(:,4).^2)), CB_new, 'UniformOutput',0);



MSD_R = MSD_cell(fps,R_Cell);  

%Speed Stats
S = SpeedStatistics(CB);

%Normalize each MSD cell with <V>^2
V_mean = cellfun(@nanmean, S.allV); 
V_mean_sq = V_mean.^2;

%Preallocate the MSD cell
MSD_R_Norm = cell(length(MSD_R),1); 
    for i = 1:length(MSD_R)
    MSD_R_Norm(i) = {MSD_R{i}./V_mean_sq(i)};
    end


    % MSD_cell = cellfun(@(x) MSD(x,tau_i,fps)', R_Cell,'UniformOutput',0);
    for i = 1:max_tau_MSD
     %Find the cell elements whose length is larger than or equal
     %to the index value "i"
    l_R = cellfun(@length,MSD_R_Norm);
    MSD_mean(i) = nanmean(cellfun(@(x) x(i), MSD_R(l_R>=i))); 
    std_MSD(i) = nanstd(cellfun(@(x) x(i), MSD_R(l_R>=i))); 
    error_MSD(i) = std_MSD(i)./sqrt(length(MSD_R(l_R>=i)));
    
    MSD_norm_mean(i) = nanmean(cellfun(@(x) x(i),MSD_R_Norm(l_R>=i)));
    std_norm_MSD(i) = nanstd(cellfun(@(x) x(i), MSD_R_Norm(l_R>=i)));
    error_norm_MSD(i) = std_norm_MSD(i)./sqrt(length(MSD_R_Norm(l_R>=i))); 
    end

% plot(tau,MSD_mean,'.','MarkerSize',13,...
%      'Color',c_map{j});
hf_MSD = figure(1);
err = errorbar(tau,MSD_mean,error_MSD);
hold on 

err.LineStyle = 'none';
err.Marker = '.';
err.MarkerSize = 10; 
err.Color = c_map{j}; 

ax_MSD = gca;
ax_MSD.YScale = 'log';
ax_MSD.XScale = 'log';
ax_MSD.Title.String = 'MSD'; 

hf_MSD_norm = figure(2);
err_norm = errorbar(tau,MSD_norm_mean,error_norm_MSD);
hold on 

err_norm.LineStyle = 'none';
err_norm.Marker = '.';
err_norm.MarkerSize = 10; 
err_norm.Color = c_map{j}; 

ax_MSD_norm = gca;
ax_MSD_norm.YScale = 'log';
ax_MSD_norm.XScale = 'log';
ax_MSD_norm.Title.String = 'MSD/<V>^2'; 

end
 

legend(ax_MSD,ECOR_label)
legend(ax_MSD_norm,ECOR_label)

%Draw the diagonal curve
figure(1)
plot(tau,tau,'-k'); 
figure(2)
plot(tau,tau,'-k');

hold off 

savefig(hf_MSD_norm, fullfile(Export_Folder,'MSD_norm_v2'))


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

function mat_files = findmat(Path,Label)
list = getallsubdirectories(Path);
target_path = list(cellfun(@(x) ~isempty(regexp(x,Label, 'once')),list));
mat_list = dir(fullfile(cell2mat(target_path),'*.mat')); 
mat_files = fullfile(mat_list.folder,mat_list.name);
end
