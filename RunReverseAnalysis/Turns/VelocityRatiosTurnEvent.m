%% Velocity Ratios between points before and after a turning event 
%by Ercag
%January 2020 
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = 'Z:\Data\3D_Tracking_Data'; 
VideoDate = {'20191206'};
FullPath = fullfile(MainPath,VideoDate{1});

CallStrainLabels = {'KMT43'};
%Define regular expression key to search the strain label 
RegExp_StrainLabel{1} = ['(?<=' VideoDate{1} ')\\+\w*'];
%Define regular expression key to search ROI number
RegExp_ROI = '\\+ROI+[_]+\d\\'; 

%Set parameters to seek out the right files 
Lambda = 0.5; 
%Frame per sec. 
fps = 30; 

%Retrieve the file list 
Files = getallfilenames(FullPath);
%Eliminate the other video dates 
%Files = Files(contains(Files,VideoDate{1})); %| contains(Files,VideoDate{2}));

%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files with lambda label other than set value above 
Files = Files(contains(Files,['_Lambda_' num2str(Lambda)]));

%Define export path
MainExportPath = 'Z:\Data\RunReverseAnalysis';
FullExportPath = fullfile(MainExportPath,VideoDate{1});
mkdir(FullExportPath) 

%Define parameters for the run-reverse analysis 
N = 1; %number of iterations
PlotSwitch = false; %is plotting individual bugs wanted? 
SaveFigSwitch.Flag = false; 


%Minimum Trajectory length & speed
minT = 2; %sec 
minV = 5; %um/sec

%How many points to be averaged?
AvgRange = 5;

%Parameters for the speed histograms 
binsize = 0.25; %um/sec; 
maxbin = 10; %um/sec
bins = 0:binsize:maxbin; 

for j = 1:length(CallStrainLabels)
    %Target the specific strain label in the list 
    FilesSubset = Files(contains(Files,CallStrainLabels{j}));
    %Preallocate 
    IPTG = zeros(1,length(FilesSubset));
    
    for i = 1:length(FilesSubset)
    %Find out Sample Label
    [inLabel, outLabel] = regexp(FilesSubset{i}, RegExp_StrainLabel{j});
    StrainLabel = FilesSubset{i}(inLabel+1:outLabel); 
    %Find out ROI number 
    [inROI, outROI] = regexp(FilesSubset{i},RegExp_ROI);   
    ROI = FilesSubset{i}(inROI+1:outROI-1);
    %Define regular expression key to find the IPTG concentration 
    RegExp_IPTG = '(?<=_)\d*(?=\w*)';
    %Find the value for IPTG concentration
    [inIPTG, outIPTG] = regexp(StrainLabel,RegExp_IPTG);
    IPTG_Str = StrainLabel(inIPTG:outIPTG);
    %load the mat file 
    load(FilesSubset{i}) 
    %Run the reverse-run analysis 
    Results = IterativeRunTumbleAnalysisFinal(B_Smooth,N,minT,minV,PlotSwitch,SaveFigSwitch);
    %Speeds cell 
    S = B_Smooth.Speeds; 
    %BugsTraj = B_Smooth.Bugs;
    fps = B_Smooth.Parameters.fps;
    %Choose the trajectory meeting the min. traj. length and speed cond. 
    TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
    medV = cellfun(@(x) medianN(x(:,9)), S);
    
    MaskTraj = medV > minV & TotalTime > minT; 
    T = Results.T(MaskTraj,:);
    S = S(MaskTraj); 
    %Go through each bug
        for k = 1:length(S)    
        RunEnd = T{k,3};
        SpeedBug = S{k}(:,9); 
        BeforeTurnVec = []; 
        AfterTurnVec = []; 
            for ix = 1:length(RunEnd)
                if RunEnd(ix) <= AvgRange
                    continue
                else
                BeforeTurnV = mean(SpeedBug((RunEnd(ix)-AvgRange):(RunEnd(ix)-1)));
                AfterTurnV = mean(SpeedBug((RunEnd(ix)+1):(RunEnd(ix)+AvgRange)));
                BeforeTurnVec = [BeforeTurnVec; BeforeTurnV];
                AfterTurnVec = [AfterTurnVec; AfterTurnV];
                end
            end
        BeforeTurnCell{k,:} = BeforeTurnVec;
        AfterTurnCell{k,:} = AfterTurnVec;
        RatioCell{k,:} = BeforeTurnVec./AfterTurnVec; 
        end
    %Plot Odd&Even Speeds Histogram
    hf_hist = figure; 
    hs = histogram(cell2mat(RatioCell), bins, 'DisplayStyle','Stairs','Normalization','PDF');
    drawnow();
    ax_hist = gca; 
    ax_hist.XLabel.String = 'Ratio (Before/After)';
    ax_hist.YLabel.String = 'PDF';
    title([StrainLabel '-' ROI],'Interpreter','none');
    ErcagGraphics 
    settightplot(ax_hist)
    printfig(hf_hist,fullfile(FullExportPath,['VelRatio_' StrainLabel '_' ROI]),'-dpdf')


     
    %Register IPTG concentration 
    IPTG(i) = str2double(IPTG_Str);        
    end
    IPTG_cell{j} = IPTG;
end