%% Run-reverse analysis and plots for KMT43,KMT47,KMT48 & KMT53
clearvars;
close all; 
%% Define Path and call up trajectory files 
%%%%----Parameters----%%%% 
%Define strain label 
StrainLabel = 'KMT53';
WhichMachine = 'Mac'; %Indicate in which OS you're running the code 

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
    MainPath = 'F:\Dropbox\Research\NikauBackup\Data\3D_Tracking_Data'; 
    GenExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\Data';
end

VideoDate = '20210624';
%Define export file format
FileFormat = '-dpng';

%Define regular expression key to search for the strain label,ROI & IPTG
RegExp_IPTG = ['(?<=' StrainLabel '[_])\d*(?=\w*)']; 
RegExp_ROI = 'ROI[_]\d'; 
RegExp_SampleNo = 'Sample[_]\d';  

%Retrieve the specific file list
if strcmp(WhichMachine,'Win')
    Files = callTracks_win(MainPath,StrainLabel,VideoDate,Lambda);
    Key_StrainLabelFolder = [ '(?<=' VideoDate '\\)\w*'];
else
    Files = callTracks_Mac(MainPath,StrainLabel,VideoDate,Lambda);
    Key_StrainLabelFolder = [ '(?<=' VideoDate '\/)\w*'];
end
    
%Select the strain and ROI to be analyzed
disp('List of the Files\n')
for li = 1:length(Files)
     disp([num2str(li) '--' Files{li}]);
end
QU = input('Continue[Y/N]?\n','s');

if strcmpi(QU,'n')
   error('Analysis Ended')
end


%% Run-reverse analysis 

for i = 1:length(Files)
    StrainLabelFolder = regexp(Files{i},Key_StrainLabelFolder,'match','once');
    %Find the value for IPTG concentration
    IPTG_Str = regexp(Files{i},RegExp_IPTG,'match','once');
    IPTG = str2double(IPTG_Str);
    %Find out ROI number 
    ROI = regexp(Files{i},RegExp_ROI,'match','once'); 
    SampleNo = regexp(Files{i},RegExp_SampleNo,'match','once'); 
    
    disp([StrainLabel '--' ROI])
    %Show the IPTG value 
    disp(['IPTG = ' IPTG_Str 'uM'])
    %Define complete export path 
    ExpPath = fullfile(GenExpPath,VideoDate,StrainLabelFolder,SampleNo,ROI);
    %Turn on SaveFigSwitch (See below for the function)
    SaveFigSwitch = SaveFigT(SaveFig,ExpPath,FileFormat);

    %load the mat file 
    load(Files{i}) 
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
        
    % Report which turn criterion is triggered
    % ReportDetectionCrit(Results,TotalTurns)

    %% Store and save data
    RunReverse.Info.Strain = StrainLabel;
    RunReverse.Info.IPTG = IPTG;
    RunReverse.TotalTurns = TotalTurns;
    RunReverse.TotalTrajLength = TotalTrajLength;
    RunReverse.EventRate = EventRate;

    %Create the export path 
    if ~exist(ExpPath,'dir')
        mkdir(ExpPath);
    end

    %Save data in .mat file 
    save(fullfile(ExpPath,['[' VideoDate ']' StrainLabelFolder '_' SampleNo '_' ROI '_Lambda_' num2str(Lambda) '_Results.mat']),'Results','RunReverse','Speeds')
 
end

%% Figures 

%% Functions
%Generate and save figures?

function ReportDetectionCrit(Results,TotalTurns)
     disp(['Total # of turn points detected = ' num2str(TotalTurns)]);
     disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'); 
     disp(['Total # of turn points would be detected by the first criterion = ' num2str(length(cell2mat(Results.ConditionCheck(:,1))))]) 
     disp(['Total # of turn points detected by the second criterion = ' num2str(length(cell2mat(Results.ConditionCheck(:,2))))]);
     disp(['Total # of turn points would be detected by both = ' num2str(length(cell2mat(Results.ConditionCheck(:,3))))]); 
end
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