%Plot longer trajectories than a duration threshold
%by Ercag
%February 2019
clearvars; 
close all;
%% Define the parameters of the subset 
pltparameters.minDur = 5; % Seconds
pltparameters.maxSpeed = 200; % um/s
pltparameters.minSpeed = 10; % um/s
%maxSpeedColorBar = 150; %The maximum value of the colorbar in um/s

%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data'; 
Video_Date = '20191204';
Strain_Label = 'KMT47_25uM';
Sample_Label = Strain_Label;
Extra_SubFolder = '';
ROI = 'ROI_1'; %Region of Interest
Track_Label = '20191205_Tracking';
Folder =  fullfile(Main_Path,Video_Date,Sample_Label,...
         Extra_SubFolder,ROI,Track_Label);
%Define the lambda value of ADDM; 
lambda = 10; 

%Define Export Path 

Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
Export_Folder = fullfile(Export_Path,Video_Date,Sample_Label,Extra_SubFolder,ROI,Track_Label,['lambda_' num2str(lambda)],'LongTrajectories');

%Make Export Path 
mkdir(Export_Folder);

%Find the files 
FullPath = fullfile(Main_Path,Video_Date,Strain_Label); 
Target_Flag = 'off';
Files = getallfilenames(FullPath,Target_Flag);
%Select filtered trajectories with particular lambda value 
Files = Files(contains(Files,['ADMM_Lambda_' num2str(lambda)])); 
%ROI-1 or ROI-2? 
ROIN = str2num(ROI(end));

load(Files{1})

%% Speed Statistics
%Calculate the speed vector
S=BugsToSpeeds_ForStruct(B_Smooth);
%Perform Speed Statistics 
SpeedStats = SpeedStatistics(S);

%Retrieve a subset of trajectories which are longer than minDur seconds
%with maximum and minimum speeds of maxSpeed and minSpeed
[k, kind] = MotileLongTrajectorySubset(SpeedStats,pltparameters.minSpeed,pltparameters.minDur);

eps = 5; %um/sec 
maxSpeedColorBar = round(max(SpeedStats.allV{kind(1)}) + eps); 
figure(1)
PlotColouredSpeedTrajectory_ForStruct(S, kind(1),maxSpeedColorBar) %Change the last input to maxSpeed! 
hf = gcf;
%Preserve the aspect ratio of each plot 
aspectRatio = hf.Position(3)./hf.Position(4);
title([Strain_Label ' Bug#' num2str(kind(1))],'interpreter','none')
%Construct the position grid for the figures 
% Width = 400;
% Height = Width./aspectRatio;
% dX = 10; 
% dY = 5; 
% XCoor = 0:Width+dX:2090; 
% YCoor = 940:-(round(Height)+dY):0;

% [X, Y] = meshgrid(XCoor,YCoor); 
% X = [X(1,:), X(2,:), X(3,:)];
% Y = [Y(1,:), Y(2,:), Y(3,:)]; 

%Plot the selected trajectories by "kind" index numbers
k = 1;  
for i = 2:length(kind)
figure(i)
maxSpeedColorBar = round(max(SpeedStats.allV{kind(i)}) + eps); 
PlotColouredSpeedTrajectory_ForStruct(S, kind(i),maxSpeedColorBar) %Change the last input to maxSpeed! 
hf = gcf;
% hf.OuterPosition(1) = X(i);
% hf_Outerposition(2) = Y(i);
hf.OuterPosition(4) = hf.OuterPosition(3)./aspectRatio;
%Title each figure 
title([Strain_Label ' Bug#' num2str(kind(i))],'interpreter','none')
%Create a box around the 3D plot
ax = gca;
ax.BoxStyle = 'full';
savefig(hf,[Export_Folder filesep Sample_Label '_Cell_' num2str(kind(i)) '.fig'])
end
distFig();

%% Histograms and distribution 
%Find out the speed distribution of the subset 
allV_subset = SpeedStats.allV(kind);
%Find out r vector of the subset
%r_subset = r(kind);
%Preallocate bins in the histogram 
h = zeros(1,length(kind));
edgesV = 0:2:70;
edgesR = 100:1:500;


total_size = length(kind); 
subp_n = ceil(sqrt(total_size));

hf_hist = figure(length(kind)+1);

% for i = 1:total_size
%     %Histogram for the speed distribution
%     subplot(subp_n,subp_n,i)
%     h(i)=histogram(allV_subset{i}, edgesV,'Normalization','pdf','DisplayStyle','stairs');
%     title(['Cell #' num2str(kind(i))])
%     drawnow()
%     
%     %Histogram for the position(in radial direction) distribution 
% %     figure(length(kind)+2)
% %     subplot(subp_n,subp_n,i)
% %     histogram(r_subset{i},edgesR,'DisplayStyle','stairs')
% %     title(['Cell #' num2str(kind(i))])
% %     drawnow()
% end

%distFig('Screen','External')

%Save them to the target export folder 
%printfig(hf_hist,[Export_Folder filesep Sample_Label '_Hist.pdf'],'-dpdf')
% savefig(hf_1,[Export_Folder filesep Sample_Label '_Trajectories.fig'])
% printfig(hf_1,[Export_Folder filesep Sample_Label '_Trajectories.pdf'],'-dpdf')
%print(hf_1,[Export_Folder filesep Sample_Label '_Trajectories'],'-depsc2')

%Save the parameters to a text file 
createtext(pltparameters,fullfile(Export_Folder,Strain_Label));





function createtext(parameters,Export_Label)
ID = fopen([Export_Label '_LongTrajPlottingParameters.txt'],'w'); 
fprintf(ID,['Minimum Duration = ' num2str(parameters.minDur) ' sec' '\n']);
fprintf(ID,['Max. Speed = ' num2str(parameters.maxSpeed) ' µm/sec' '\n']);
fprintf(ID,['Min. Speed = ' num2str(parameters.minSpeed) ' µm/sec' '\n']);
fclose(ID); 
end


%% Extra features 
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