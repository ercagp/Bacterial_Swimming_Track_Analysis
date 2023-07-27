%% Delta_t analysis for constructs
%by Ercag
%January 2020 
close all;
clearvars; 
%% Define Path and call up trajectory files 
MainPath = 'Z:\Data\3D_Tracking_Data'; 
VideoDate = {'20191206','20191204','20191206'};
%FullPath = fullfile(MainPath,VideoDate);

CallStrainLabels = {'KMT43','KMT47','KMT53'};
FullStrainLocation = cellfun(@(x,y) [x '\' y],VideoDate,CallStrainLabels,'UniformOutput',0); 
%Define regular expression keys to search for the strain label
for RegIx = 1:length(CallStrainLabels)
RegExp_StrainLabel{RegIx} = ['(?<=' VideoDate{RegIx} ')\\+\w*'];
end
%Define regular expression key to search ROI number
RegExp_ROI = '\\+ROI+[_]+\d\\'; 
%Define regular expression key to search for Lambda(smoothing parameter)
%number 
%RegExp_Lambda = 'Lambda_\d';

%Define regular expression key to search for Tracking label(e.g.
%20190210_Tracking) 
%RegExp_TrackLabel = '\\+\d*+_Tracking+\\'; 

%Set parameters to seek out the right files 
Lambda = 0.5; 
%Frame per sec. 
fps = 30; 

%Retrieve the file list 
Files = getallfilenames(MainPath);
%Eliminate the other video dates 
%Files = Files(contains(Files,VideoDate{1}) | contains(Files,VideoDate{2}));

%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files with lambda label other than set value above 
Files = Files(contains(Files,['_Lambda_' num2str(Lambda)]));

%Define export path
MainExportPath = 'Z:\Data\RunReverseAnalysis';
FullExportPath = fullfile(MainExportPath); 
%mkdir(FullExportPath)

%Define parameters for the run-reverse analysis 
N = 1; %number of iterations
PlotSwitch = false; %is plotting individual bugs wanted? 
SaveFigSwitch.Flag = false; 

%Minimum Trajectory length & speed
minT = 2; %sec 
minV = 5; %um/sec

%Which strain to analyze? 
selectStrain = 3; %nth in CallStrainLabels
%Which IPTG level to compare? 
IPTG_selected = '100'; %uM 

if strcmp(CallStrainLabels{selectStrain},'KMT43')
    %Exclude KMT43_25uM_Sample2 
    Files = Files(~contains(Files,'KMT43_25uM_Sample2')); 
end

%Define histogram parameters 
maxT = 2.25; %sec 
binsize = 1/fps; 
bins = 0:binsize:maxT;
%Preallocate cells and vectors 
IPTG_cell = cell(1,length(CallStrainLabels)); 

k=1; 

for j = 1:length(CallStrainLabels)
    %Target the specific strain label in the list 
    FilesSubset = Files(contains(Files,FullStrainLocation{j}));
    %Exclude ROI_2 
    FilesSubset = FilesSubset(contains(FilesSubset,'ROI_1')); 
    %Preallocate cells and vectors 
    IPTG = zeros(1,length(FilesSubset));
    Delta_tAll = cell(1, length(FilesSubset));
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
        %The vector giving the indices at which turn events occur 
        RunEnds = Results.T(:,3);
        
        %Delta_t 
        Delta_tCell = cellfun(@(x) delta_t(fps,x)', RunEnds,'UniformOutput',0);
        %All Delta_t 
        Delta_tAll{i} = cell2mat(Delta_tCell);
        
        if j == selectStrain
            %Plot the histogram for one strain across different IPTG levels 
            figure(1) 
            hist{i} = histogram(Delta_tAll{i}, bins,'DisplayStyle','stairs','Normalization','cdf',...
            'DisplayName',[IPTG_Str 'uM']);
            hist{i}.LineWidth = 1.5;
            hold on 
            %Take the bin counts and calculate 1-cdf 
            newCDF = 1 - hist{i}.Values; 
            %Plot 1-cdf
            figure(2) 
            hist_new{i} = histogram('BinEdges',bins,'BinCounts',newCDF,'DisplayStyle','Stairs',...
            'DisplayName',[IPTG_Str 'uM']);
            hist_new{i}.LineWidth = 1.5;
            hold on
        end
        
        %Compare different strain's delta_t distributions
        if strcmp(IPTG_Str,IPTG_selected)
            figure(3)
            hist_temp = histogram(Delta_tAll{i},bins,'DisplayStyle','stairs','Normalization','cdf',...
                'DisplayName',[CallStrainLabels{j} '-' IPTG_Str 'uM']);
            hist_temp.LineWidth = 1.5; 
            hold on
            
            %Take the bin counts and calculate 1-cdf 
            newCDF_cmp = 1 - hist_temp.Values;
            %plot 1-cdf
            figure(4) 
            hist_cmp = histogram('BinEdges',bins,'BinCounts',newCDF_cmp,'DisplayStyle','Stairs',...
               'DisplayName',[CallStrainLabels{j} '-' IPTG_Str 'uM']);
            hist_cmp.LineWidth = 1.5; 
            hold on 
          
            k = k + 1; 
        end
        
        
        %Save IPTG value 
        IPTG(i) = str2double(IPTG_Str);  
    end
    IPTG_cell{j} = IPTG;
end

hf_1 = figure(1);
legend([hist{2} hist{3} hist{4} hist{1}],...
    {hist{2}.DisplayName, hist{3}.DisplayName, hist{4}.DisplayName, hist{1}.DisplayName},...
    'Location','Best','Interpreter','none')
ax_hist = gca; 
ax_hist.XLabel.String = '\Deltat(sec.)';
ax_hist.YLabel.String = 'CDF';
ax_hist.YScale = 'log';
ax_hist.YLim = [0 1.05];
title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_hist)
hold off 

hf_2 = figure(2);
legend([hist_new{2} hist_new{3} hist_new{4} hist_new{1}],...
    {hist_new{2}.DisplayName, hist_new{3}.DisplayName, hist_new{4}.DisplayName, hist_new{1}.DisplayName},...
    'Location','Best','Interpreter','none')
ax_hist_new = gca; 
ax_hist_new.XLabel.String = '\Deltat(sec.)';
ax_hist_new.YLabel.String = '1-CDF';
ax_hist_new.YScale = 'log';
ax_hist_new.YLim = [0 1.05];
title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_hist_new)
hold off 
printfig(hf_2, fullfile(FullExportPath,VideoDate{selectStrain},'Delta_t',[CallStrainLabels{selectStrain} '_CDF']),'-dpdf')

hf_3 = figure(3);
legend('Location','Best','Interpreter','none')
ax_hist_cmp = gca; 
ax_hist_cmp.XLabel.String = '\Deltat(sec.)';
ax_hist_cmp.YLabel.String = 'CDF';
ax_hist_cmp.YLim = [0 1.05];
ax_hist_cmp.YScale = 'log';
ErcagGraphics
settightplot(ax_hist_cmp)
hold off 

hf_4 = figure(4); 
legend('Location','Best','Interpreter','none')
ax_hist_cmp_new = gca; 
ax_hist_cmp_new.XLabel.String = '\Deltat(sec.)';
ax_hist_cmp_new.YLabel.String = '1-CDF';
ax_hist_cmp_new.YLim = [0 1.05];
ax_hist_cmp_new.YScale = 'log';
ErcagGraphics
settightplot(ax_hist_cmp_new)
hold off 

printfig(hf_4, fullfile(FullExportPath,VideoDate{selectStrain},'Delta_t',['KMT43_47_53_IPTG_' IPTG_selected 'uM'  '_CDF']),'-dpdf')

function delta_tVec = delta_t(fps,RunEnds)
delta_tVec = diff(RunEnds).*(1/fps); 
end