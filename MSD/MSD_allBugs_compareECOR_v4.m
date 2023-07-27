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
mat_list = cell(1,length(ECOR_label));
for mat_i = 1:length(ECOR_label)
mat_list{mat_i} = findmat(Main_Path,ECOR_label{mat_i}); 
end

%% Parameters
%Define the lag time tau to define the range of MSD plot
max_tau_MSD = 45; % max_tau_MSD/fps = ... seconds
tau_MSD = 1:max_tau_MSD; 
fps = 15; %15 frames/sec
tau = tau_MSD./fps; %actual time vector

%Set the colormap 
c_map = colormap(linspecer(length(ECOR_label)));
c_map = mat2cell(c_map, ones(size(c_map,1),1));

%% Compute MSD
MSD_R = cell(1,length(mat_list));
Norm_MSD_R = cell(1,length(mat_list));
err_SD_R = cell(1,length(mat_list));
err_Norm_SD_R = cell(1,length(mat_list));
for j = 1:length(mat_list)
%load the combined .mat file
load(mat_list{j})

%Input parameters
ScaleXY=CB.Parameters.Refstack.ScaleXY;
ScaleZ=CB.Parameters.Refstack.ScaleZ;
RoughFocus=CB.Parameters.Refstack.RoughFocus;
fps = CB.Parameters.fps;

%Scale X,Y & Z values in the trajectories 
CB_scaled = cellfun(@(x) scale_func(x,ScaleXY,ScaleZ,RoughFocus), CB.Bugs,'UniformOutput',0);
X = cellfun(@(x) x(:,2),CB_scaled,'UniformOutput',0);
Y = cellfun(@(x) x(:,3),CB_scaled,'UniformOutput',0);
Z = cellfun(@(x) x(:,4),CB_scaled,'UniformOutput',0);

l_X = cellfun(@length,X);
l_Y = cellfun(@length,Y);
l_Z = cellfun(@length,Z);

%Speed Stats (S contains vectors v_x, v_y & v_z) 
S = SpeedStatistics(CB);
%Find the <V>^2 for each bug 
V_sq = (S.meanV).^2;

    for i = 1:max_tau_MSD
    %Find the cell elements whose length is larger than or equal
    %to the index value "i"
    X_select = X(l_X>=i); 
    Y_select = Y(l_Y>=i); 
    Z_select = Z(l_Z>=i); 
    
    %Square displacement in x,y & z directions 
    SD_x = cellfun(@(x) SquareDisp(x,i)',X_select,'UniformOutput',0);
    SD_y = cellfun(@(x) SquareDisp(x,i)',Y_select,'UniformOutput',0);
    SD_z = cellfun(@(x) SquareDisp(x,i)',Z_select,'UniformOutput',0);
    
    %Square displacement in R
    SD_R =  cellfun(@(x,y,z) x+y+z, SD_x, SD_y , SD_z,'UniformOutput',0);
    
    %Select the velocity values of elements that enter the average
    V_sq_select = V_sq(l_X>=i);

    %Normalized Square Displacements 
    Norm_SD_R = cell(length(SD_R),1);
        for k = 1:length(SD_x) 
            Norm_SD_R{k} = SD_R{k} ./ V_sq_select(k);
        end
    
    %Mean Square displacement 
    MSD_R{j}(i) = nanmean(cell2mat(SD_R)); 
    
    %Normalized MSD 
    Norm_MSD_R{j}(i) = nanmean(cell2mat(Norm_SD_R));
    
    %Error in Square Displacement 
    err_SD_R{j}(i) = std(cell2mat(SD_R))./sqrt(length(cell2mat(SD_R)));
    
    %Error in Normalized Square Displacement
    err_Norm_SD_R{j}(i) = std(cell2mat(Norm_SD_R))./sqrt(length(cell2mat(Norm_SD_R)));
    end

hf_MSD = figure(1);
err = errorbar(tau,MSD_R{j},err_SD_R{j});
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
err_norm = errorbar(tau,Norm_MSD_R{j},err_Norm_SD_R{j});
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

%Draw the diagonal curve
figure(1)
plot(tau,tau,'-k'); 
% figure(2)
% plot(tau,tau,'-k');

leg_1 = legend(ax_MSD,ECOR_label,'Location','NorthWest');
leg_2 = legend(ax_MSD_norm,ECOR_label,'Location','NorthWest');

hold off 

savefig(hf_MSD_norm, fullfile(Export_Folder,'MSD_norm_v4'))
savefig(hf_MSD,fullfile(Export_Folder,'MSD_v4'))

%save_list = {'MSD_R','Norm_MSD_R','err_SD_R','err_Norm_SD_R'};
%save(fullfile(Export_Folder,'MSD_ECOR18_19'),'MSD_R','Norm_MSD_R','err_Norm_SD_R','err_SD_R','tau')

%% Extra Functions
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
