%% Run-reverse analysis and plots for KMT43,KMT47,KMT48 & KMT53
clearvars;
close all; 
%% Define Path and call up trajectory files 
%%%%----Parameters----%%%% 
%Define strain label 
StrainLabel = 'KMT9';
WhichMachine = 'Win'; %Indicate in which OS you're running the code 

%% Set Run-Reverse Analysis Parameters 
RunReversePara.minT = 0; %sec - Traj. Duration cutoff
RunReversePara.minV = 20; %um/sec - Speed cutoff 
RunReversePara.AbsT = 50; %angular cutoff
RunReversePara.N = 1; %Number of iterations; 

%Set smooting parameter
Lambda = 0.5;

PlotSwitch = false; %Plot individual bugs for inspection? 
SaveFig = false; %Save figures?

%%%%----Locating files----%%%%
%Define the file path
if strcmp(WhichMachine,'Mac')
    MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data';
    %Generic Export Path
    GenExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/Data';
else
    MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\3D_Tracking_Data'; 
    GenExpPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\RunReverse_Data';
end
%Define export file format
FileFormat = '-dpng';
VideoDate = '20190604';
StrainFolder = 'KMT9_OD_0.19'; 

Files{1} = fullfile(MainPath,VideoDate,StrainFolder,'ROI_2','20190608_Tracking','Bugs_20190608T095835_ADMM_Lambda_0.5.mat'); 

%Select the strain and ROI to be analyzed
disp('List of the Files\n')
for li = 1:length(Files)
    disp([num2str(li) '--' Files{li}]);
end
%% Run-reverse analysis 
%Find out ROI number 
RegExp_ROI = 'ROI[_]\d';
ROI = regexp(Files{1},RegExp_ROI,'match','once');   
disp([StrainFolder '--' ROI]);
%Define complete export path 
ExpPath = fullfile(GenExpPath,VideoDate,StrainFolder,ROI);
%Turn on SaveFigSwitch (See below for the function)
SaveFigSwitch = SaveFigT(SaveFig,ExpPath,FileFormat);

%load the mat file 
load(Files{1}) 
%Extract fps value 
fps = B_Smooth.Parameters.fps; 
%Run the reverse-run analysis 
Results = IterativeRunTumbleAnalysisFinal(B_Smooth,RunReversePara,PlotSwitch,SaveFigSwitch);
%The vector giving the indices at which turn events occur 
RunEnds = Results.T(:,3);
%Retrieve turn angles of all bugs; 
TurnAngleAll = cell2mat(Results.Ang(:,3)); 
        
SizeRunEnds = cellfun(@length, RunEnds);
%Total number of turns per acquisition
TotalTurns = sum(SizeRunEnds); 
%Total trajectory duration per acquisition 
TrajLength = cellfun(@(x) (size(x,1)/fps), B_Smooth.Speeds, 'UniformOutput', 1);
TotalTrajLength = sum( TrajLength ( TrajLength > RunReversePara.minT ) ); 
%Turn event rate per time (total # of turns / total traj. durations) per acquisition
EventRate = TotalTurns/TotalTrajLength;
%Speeds cell (ADMM filtered)
Speeds = B_Smooth.Speeds;   
%% Store and save data
RunReverse.Info.Strain = StrainFolder;
RunReverse.TotalTurns = TotalTurns;
RunReverse.TotalTrajLength = TotalTrajLength;
RunReverse.EventRate = EventRate;

%Create the export path 
if ~exist(ExpPath,'dir')
    mkdir(ExpPath);
end

%Save data in .mat file 
save(fullfile(ExpPath,['[' VideoDate ']' StrainFolder '_' ROI '_Lambda_' num2str(Lambda) '_Results.mat']),'Results','RunReverse','Speeds')

%% Figures 
%Generate and save figures?
function SaveFigSwitch = SaveFigT(SaveFig,ExpPath,FileFormat)
         if SaveFig 
            SaveFigSwitch.Flag = true; 
            SaveFigSwitch.ExpPath = ExpPath; 
            SaveFigSwitch.Format = FileFormat;
         else 
            SaveFigSwitch.Flag = false;
            SaveFigSwitch.ExpPath = []; 
            SaveFigSwitch.Format = [];
        end
end