%% Find slow runs between [0-35]um/sec per bug and plot their trajectories
% February 2021
% v1
%by Ercag 
clearvars;
close all; 

%% Define Export Path for figures
ExpPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\RunAnalysis\TimeAnalysis\Distributions\RunTimes_IndTraj';
%% Call the run reverse analysis files 
MainPath = 'F:\Dropbox\Research\NikauBackup\Data\RunReverseAnalysis\Data';
GenExpPath = MainPath; 
StrainLabels = {'KMT43'};

%Call a sample B_Smooth to extract track parameters 
load('F:\Dropbox\Research\NikauBackup\Data\3D_Tracking_Data\20191204\KMT47_25uM\ROI_1\20191205_Tracking\Bugs_20191205T200121_ADMM_Lambda_0.5.mat'); 
%% Input parameters 
%Acquisition and ADMM parameter
fps = 30; %Hz
Lambda = 0.5; 

%Time stamp for the PNG/PDF files
Stamp =  ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

%RegExp Keys
RegKeyROI = 'ROI[_]\d';
RegKeyVD = ['(?<=Data' filesep filesep ')\d*'];

%Plot parameters 
PP.Edges = 1/fps.*[(2.5:2:75), 76.5];
PP.SpeedEdges = [0,35,75,200]; %um/sec 
%Which speed bin to plot? 
PP.SelectedBin = 1; %[75-200]; 
%Track parameters 
PP.Track = B_Smooth.Parameters; 

%% Calculate Run Durations
for j = 1:length(StrainLabels)
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);    
    %Find ROIs and Video dates
    VideoDates = regexp(Files,RegKeyVD,'match','once');
    ROI = regexp(Files,RegKeyROI,'match','once');
    

   
    %Preallocate
    IPTG = zeros(length(Files),1);
    TSub = cell(length(Files),1);
    RunSub =  cell(length(Files),1);
    SpeedSub = cell(length(Files),1);
    for i = 1:length(Files)
        load(Files{i}) 
        
        fprintf(['minimum T =' num2str(Results.minT) 'sec \n'])
        fprintf(['minimum V =' num2str(Results.minV) 'um/sec \n \n'])
        fprintf(['[IPTG] = ' num2str(RunReverse.Info.IPTG) 'uM \n \n'])
        
        IPTG(i) = RunReverse.Info.IPTG; 
        %Export path 
        PP.SaveFig.ExpPath = fullfile(ExpPath,StrainLabels{j},[num2str(IPTG(i)) 'uM']);
        if ~exist(PP.SaveFig.ExpPath,'dir')
           mkdir(PP.SaveFig.ExpPath); 
        end
        
        PP.SaveFig.Strain = StrainLabels{j};
        PP.SaveFig.IPTG = num2str(IPTG(i)); 
        PP.SaveFig.VideoDate = VideoDates{i}; 
        PP.SaveFig.ROI = ROI{i};
        %Filter out run-reverse cell and yield subsets of the T-cell &
        %Run-cells 
        [SpeedSub{i},RunSub{i},TSub{i}] = MakeSubsets(Speeds,Results,fps); 
        
        FindMatchBugs(RunSub{i},TSub{i},SpeedSub{i},PP)
        
    end
      
end


%% Functions 
function [SSubset, FilterMask] = filterout(S,minT,minV,fps)

         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         SSubset = S(FilterMask); 
end

function [SpeedSubset,RunSubset,TSubset] = MakeSubsets(Speeds,R,fps) 
          %R: Results structure
          Runs = RunBreakDownv6(Speeds,R.T,fps);
          %Angles = R.Ang(:,3); 
          
          %Filter in trajectories longer than 2sec
          tMin = 2; 
          [~,FltMask] = filterout(Speeds,tMin,R.minV,fps); 
          RunSubset = Runs(FltMask,:);
          SpeedSubset = Speeds(FltMask,:); 
          %AngSubset = Angles(FltMask);
          TSubset = R.T(FltMask,:);          
 end


function FindMatchBugs(Runs,T,Speeds,Para)
         %Function for finding the bugs matching with mean run speeds 
         
         %Edges for the run durations
         DurEdges = Para.Edges; 
         %Edges for speed binning
         SpeedEdges = Para.SpeedEdges; 
         %Which speed bin to plot? 
         SelectedBin = Para.SelectedBin; 
         %Track parameters
         TrackParameters = Para.Track;
         %Export figure parameters
         PltInput.SaveFig = Para.SaveFig;
        
                
         %Find the bugs running slower(or equal) than the max. of the
         %selected bin edge on the AVERAGE! (i.e., mean run speed <= SpeedTop) 
         SpeedTop = SpeedEdges(SelectedBin+1); 
         MaskSlow = cellfun(@any, cellfun(@(x) x(:,2) <= SpeedTop, Runs(:,2), 'UniformOutput', false));
         SlowRunSubset = Runs(MaskSlow,:);
         SlowT = T(MaskSlow,:); 
         SlowSpeeds = Speeds(MaskSlow,:); 
         

         for i = 1:size(SlowRunSubset,1)
             %Find the runs that are slower in a single trajectory 
             PltInput.Run = SlowT(i,:); 
             PltInput.Speed = SlowSpeeds{i,:}; 
         
             RunID = find(SlowRunSubset{i,2}(:,2) <= SpeedTop);
             RunID = RunID';
             BugID = SlowRunSubset{i,3}; 
            
             PlotTraj_MarkSlowRuns(TrackParameters,PltInput,BugID,RunID)
             
         end
         
         
         
end
