%% Plot and save single cell trajectories 
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = 'Z:\Data\3D_Tracking_Data'; 
VideoDate = '20191206';
MainPath = fullfile(MainPath,VideoDate);

CallStrainLabels = {'KMT43','KMT53'};
%Define regular expression key to search the strain label 
RegExp_StrainLabel = ['(?<=' VideoDate ')\\+\w*'];
%Define regular expression key to search ROI number
RegExp_ROI = '\\+ROI+[_]+\d\\'; 
%Define regular expression key to search for Lambda(smoothing parameter)
%number 
%RegExp_Lambda = 'Lambda_\d';

%Define regular expression key to search for Tracking label(e.g.
%20190210_Tracking) 
%RegExp_TrackLabel = '\\+\d*+_Tracking+\\'; 

%Set parameters to seek out the right files 
Lambda = 10; 

%Retrieve the file list 
Files = getallfilenames(MainPath);
%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files with lambda label other than set value above 
Files = Files(contains(Files,['_Lambda_' num2str(Lambda)]));

%Define export path
MainExportPath = 'Z:\Data\RunReverseAnalysis';


%Define parameters for the run-reverse analysis 
N = 1; %number of iterations
PlotSwitch = true; %is plotting individual bugs wanted? 
%Save figures? 
SaveFigSwitch.Flag = true;


j = 1; 
%Target the specific strain label in the list 
FilesSubset = Files(contains(Files,CallStrainLabels{j}));
i = 3;
%Find out Sample Label
[inLabel, outLabel] = regexp(FilesSubset{i}, RegExp_StrainLabel);
StrainLabel = FilesSubset{i}(inLabel+1:outLabel); 
%Find out ROI number 
[inROI, outROI] = regexp(FilesSubset{i},RegExp_ROI);   
ROI = FilesSubset{i}(inROI+1:outROI-1);
%Define regular expression key to find the IPTG concentration 
RegExp_IPTG = '(?<=_)\d*(?=\w*)';
%Find the value for IPTG concentration
[inIPTG, outIPTG] = regexp(StrainLabel,RegExp_IPTG);
IPTG_Str = StrainLabel(inIPTG:outIPTG);

%Define the export path for the figures 
FullExpPath = fullfile(MainExportPath,VideoDate,StrainLabel,ROI);
mkdir(FullExpPath);
SaveFigSwitch.ExpPath = FullExpPath; 

%load the mat file 
load(FilesSubset{i}) 
%Run the reverse-run analysis 
Results = IterativeRunTumbleAnalysisFinal(B_Smooth,N,PlotSwitch,SaveFigSwitch);
        