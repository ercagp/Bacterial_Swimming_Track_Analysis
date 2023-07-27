%Plot trajectories of the bugs 
%that swam slower threshSpeed (threshold speed)
%by Ercag
%September 2019     
clearvars; 
close all;
%% Define the parameters of the subset 
%minDur = 20; % Seconds
threshSpeedArray = 10; % um/s

%% Define the path and load data
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis'; 
Video_Date = '20191018';
Main_Path = fullfile(Main_Path,Video_Date); 
%Keyword to find the files associated with the strain label
Strain_Keyword = 'KMT9_';
%Keyword to find the folder associated with the strain label
%Strain_Folder_Keyword = 'KMT9_Glu+\w';
Final_Keyword = 'CombinedBugStruct';%'\\+ROI+\w+\w+\\';
%Regexp keyword for detecting strain label 
RegExp_StrainLabel = ['(?<=' Video_Date '\\)\w*']; 
%Retrieve the file list 
Files = getallfilenames(Main_Path,'off');
%Eliminate the files that are not labelled as the indicated strain name
Files = Files(cellfun(@(x) contains(x,Strain_Keyword),Files)); 
%Find the combined Bugstruct
Files = Files(cellfun(@(x) contains(x,Final_Keyword),Files)); 
%Deduce strain labels 
StrainLabel = regexp(Files,RegExp_StrainLabel,'Match');
StrainLabel = cellfun(@(x) x{1},StrainLabel,'UniformOutput',0);

%Define export path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis';
%Define Smoothing Parameter Lambda
% lambda = 1;
% Lambda_Label = ['lambda_' num2str(lambda)];

%Define the t vector 
t = [0 90]; 

i_max = length(Files);
j_max = length(threshSpeedArray);

for j = 1:j_max
    V_max = threshSpeedArray(j); %m/sec, Max of the speed colorbar
    for i = 1:i_max
    %% Create export paths and load the data 
    %Load the file 
    load(Files{i});
    %% Create the structure containing speed info 
    S.Speeds = CB.Speeds;%B_Smooth.Speeds;
    S.Parameters = CB.Parameters;%B_Smooth.Parameters;
    %Get the speed statistics
    SpeedStats = SpeedStatistics(S);
    %% Select the bugs slower than threshSpeed
    B_Subset = CB;%B_Smooth;
    % Prepare logical mask to eliminate the tracks with speed higher than
    % threshV
    %ThreshMask = cellfun(@(x) ~any(x>threshSpeedArray(j)),SpeedStats.allV);
    ThreshMask = threshSpeedArray(j)>SpeedStats.medV;
    %Create the subset cell 
    B_Subset.Speeds = CB.Speeds(ThreshMask);%B_Smooth.Speeds(ThreshMask);
    B_Subset.Bugs = CB.Bugs(ThreshMask);%B_Smooth.Bugs(ThreshMask);
    SpeedStatsSubset = SpeedStatistics(B_Subset);
    %Register total number of cell with speed lower than the threshold
    SubsetPopulation(j,i) = sum(ThreshMask);
    %% Calculate the percentage of the motile fraction 
    MotileFrac(j,i) = (size(CB.Bugs,1)- SubsetPopulation(j,i))./size(CB.Bugs,1); 
    %% Plot the velocity mapped tracks 
%     figure 
%     PlotColouredSpeedTrajectory2_ForStruct(B_Subset,V_max);
%     drawnow()
    end 
end

%% Plot the number of bugs slower than threshSpeed for each time point
hf_2 = figure;
ax = gca;
%Color order 
ColorMap = linspecer(length(Files));

%%Left axis 
VThreshLabel = strsplit(num2str(threshSpeedArray));
VThreshLabel = cellfun(@(x) [x ' µm/s'],VThreshLabel,'UniformOutput',0); % add units next to each label 

% Right axis 
%yyaxis right
ax = gca;
%ax.YColor = RightColor; 

%First two strains listed in StrainLabel 
plR_1 = plot(t,MotileFrac(:,1:2),'.-');
hold on 
%The next two strains listed in StrainLabel
plR_2 = plot(t,MotileFrac(:,3:4),'.-');
%The last two strains listed in StrainLabel
plR_3 = plot(t,MotileFrac(:,5:6),'.-');


hold off

%Exchange colors of the lines
ColorMapNew{1} = plR_1.Color; 
ColorMapNew{2} = plR_2.Color;
plR_1.Color = ColorMapNew{2};
plR_2.Color = ColorMapNew{1};


%p1R = plot(t(1:i_max),100.*MotileFrac,'.-');
%plR = plot(t,Moti
xlabel('Time(mins)');
ylabel('Motile Fraction %')
 
%set(plR_1,'Color',num2cell(ColorMap,2)) 
set([plR_1 plR_2 plR_3],'LineWidth',2)
set([plR_1 plR_2 plR_3],'MarkerSize',25);

% %set(plR_2,{'Color'},num2cell(ColorMap,2)) 
% set(plR_2,'LineWidth',2)
% set(plR_2,'MarkerSize',17);

%Set title
ax.Title.String = ['% Motile KMT9 Population (' Video_Date ')'] ;  
ax.Title.Interpreter = 'none';
ax.XLim = [0 90]; %mins

% p1R.Color(4) = 0.7;
% p2R.Color(4) = 0.7;
% p3R.Color(4) = 0.7;

legStrainLabels{1} = StrainLabel{1}(1:end-2); 
legStrainLabels{2} = StrainLabel{3}(1:end-2);
legStrainLabels{3} = StrainLabel{5}(1:end-2);
% 
%Take only the concentration tags on the labels 
legS = regexp(legStrainLabels,'(?<=KMT9_GLu_)\w*','Match');
legS{3} = {'MMVF_3'};
legS = cellfun(@(x) x{1},legS,'UniformOutput',0);


%Add legend
leg1 = legend(legS,'Location','Best', 'Interpreter','none');


ErcagGraphics
settightplot(ax)

printfig(hf_2,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'MotileFraction_medV_' num2str(threshSpeedArray) 'micronspersec_thresh']),'-dpng')
printfig(hf_2,fullfile(Main_Export_Path,Video_Date, [Strain_Keyword 'MotileFraction_medV_'  num2str(threshSpeedArray) 'micronspersec_thresh']),'-dpdf')



