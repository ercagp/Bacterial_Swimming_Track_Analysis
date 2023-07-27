%% Plot Speed Distributions
%by Ercag 
%January 2020
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data'; 
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
%fps = 30; 

%Retrieve the file list 
Files = getallfilenames(MainPath);
%Eliminate the other video dates 
%Files = Files(contains(Files,VideoDate{1}) | contains(Files,VideoDate{2}));

%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files with lambda label other than set value above 
Files = Files(contains(Files,['_Lambda_' num2str(Lambda)]));
%Exclude KMT43_25uM_Sample2 
%Files = Files(~contains(Files,'KMT43_25uM_Sample2')); (why? probably
%because of drift) 

%Define export path
MainExportPath = 'Z:\Data\RunReverseAnalysis';
FullExportPath = fullfile(MainExportPath); 
%mkdir(FullExportPath)

%Minimum Trajectory length & speed
minT = 2; %sec 
minV = 5; %um/sec

%Which strain to analyze? 
selectStrain = 1; %nth in CallStrainLabels
%Which IPTG level to compare? 
IPTG_selected = '100'; %uM


%Histogram parameters 
BinSize = 2; %um/sec
MaxBin = 175; %um/sec
Bins = 0:BinSize:MaxBin; 

k = 1;

for j = 1:length(CallStrainLabels)
    %Target the specific strain label in the list 
    FilesSubset = Files(contains(Files,FullStrainLocation{j}));
    %Exclude one ROI
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
        %Find the value of IPTG concentration
        [inIPTG, outIPTG] = regexp(StrainLabel,RegExp_IPTG);
        IPTG_Str = StrainLabel(inIPTG:outIPTG);
        
        %load the mat file 
        load(FilesSubset{i})
        %Create cell for speeds 
        Speeds = B_Smooth.Speeds;
        %Extract FPS 
        fps = B_Smooth.Parameters.fps; 
        
        %Choose the trajectory meeting the min. traj. length and speed cond. 
        %TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,Speeds); 
        %medV = cellfun(@(x) medianN(x(:,9)), Speeds);
    
        %MaskTraj = medV > minV & TotalTime > minT;
        %Speeds = Speeds(MaskTraj);
        AllSpeeds_Cell = cellfun(@(x) x(:,9), Speeds,'UniformOutput',false);
        AllSpeeds = cell2mat(AllSpeeds_Cell);
            
        MeanSpeeds = cellfun(@(x) nanmean(x(:,9)), Speeds, 'UniformOutput',true); 
        MedSpeeds = cellfun(@(x) nanmedian(x(:,9)), Speeds, 'UniformOutput',true); 
        
        %Plot the inst. speed distribution of all bugs        
        if j == selectStrain

            figure(1)
            histSpeed{i} = histogram(AllSpeeds,Bins,'DisplayStyle','Stairs',...
                           'Normalization','PDF',...
                           'DisplayName',[IPTG_Str 'uM']);
            histSpeed{i}.LineWidth = 1.5;
            hold on 
            
            figure(2) 
            histMean{i} = histogram(MeanSpeeds,Bins,'DisplayStyle','Stairs',...
                          'Normalization','PDF',...
                          'DisplayName',[IPTG_Str 'uM']);
            histMean{i}.LineWidth = 1.5; 
            hold on 
            
            figure(3) 
            histMed{i} = histogram(MedSpeeds,Bins,'DisplayStyle','Stairs',...
                         'Normalization','PDF',...
                         'DisplayName',[IPTG_Str 'uM']);
            histMed{i}.LineWidth = 1.5; 
            hold on 
        end 
        
        %Compare different strain's speed distributions
        if strcmp(IPTG_Str,IPTG_selected)
            figure(4)
            histSpeed_select{k} = histogram(AllSpeeds,Bins,'DisplayStyle','stairs',...
                                 'Normalization','pdf',...
                                 'DisplayName',[CallStrainLabels{j} '-' IPTG_Str 'uM']);
            histSpeed_select{k}.LineWidth = 1.5; 
            hold on
            
            figure(5) 
            histMean_select{k} = histogram(MeanSpeeds,Bins,'DisplayStyle','Stairs',...
                                'Normalization','PDF',...
                                'DisplayName',[CallStrainLabels{j} '-' IPTG_Str 'uM']);
           
            histMean_select{k}.LineWidth = 1.5; 
            hold on 
            
            figure(6) 
            histMed_select{k} = histogram(MedSpeeds,Bins,'DisplayStyle','Stairs',...
                         'Normalization','PDF',...
                         'DisplayName',[CallStrainLabels{j} '-' IPTG_Str 'uM']);
            histMed_select{k}.LineWidth = 1.5; 
            hold on 
          
            k = k + 1; 
        end
        %Save IPTG value 
        IPTG(i) = str2double(IPTG_Str);  
    end
    IPTG_cell{j} = IPTG;
end

hf_1 = figure(1);

legend([histSpeed{2} histSpeed{3} histSpeed{4} histSpeed{1}],...
    {histSpeed{2}.DisplayName, histSpeed{3}.DisplayName, histSpeed{4}.DisplayName, histSpeed{1}.DisplayName},...
    'Location','Best','Interpreter','none')
ax_hist = gca; 
ax_hist.XLabel.String = 'Speed (\mum/sec)';
ax_hist.YLabel.String = 'PDF';
%ax_hist.YLim = [0 1.05];
title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_hist)
printfig(hf_1, fullfile(FullExportPath,VideoDate{selectStrain},[CallStrainLabels{selectStrain} '_SpeedDist_FullPopulation.pdf']),'-dpdf')


hf_2 = figure(2); 

legend([histMean{2} histMean{3} histMean{4} histMean{1}],...
    {histMean{2}.DisplayName, histMean{3}.DisplayName, histMean{4}.DisplayName, histMean{1}.DisplayName},...
    'Location','Best','Interpreter','none')
ax_histMean = gca; 
ax_histMean.XLabel.String = 'Mean Speed (\mum/sec)';
ax_histMean.YLabel.String = 'PDF';
%ax_hist.YLim = [0 1.05];
title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_histMean)

%printfig(hf_2, fullfile(FullExportPath,VideoDate{selectStrain},[CallStrainLabels{selectStrain} '_MeanSpeedDist_FullPopulation.pdf']),'-dpdf')


hf_3 = figure(3); 

legend([histMed{2} histMed{3} histMed{4} histMed{1}],...
    {histMed{2}.DisplayName, histMed{3}.DisplayName, histMed{4}.DisplayName, histMed{1}.DisplayName},...
    'Location','Best','Interpreter','none')
ax_histMed = gca; 
ax_histMed.XLabel.String = 'Median Speed (\mum/sec)';
ax_histMed.YLabel.String = 'PDF';
%ax_hist.YLim = [0 1.05];
title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_histMed)

%printfig(hf_3, fullfile(FullExportPath,VideoDate{selectStrain},[CallStrainLabels{selectStrain} '_MedSpeedDist_FullPopulation.pdf']),'-dpdf')



hf_4 = figure(4);

legend('Location','Best','Interpreter','none')
ax_hist_select = gca; 
ax_hist_select.XLabel.String = 'Speed (\mum/sec)';
ax_hist_select.YLabel.String = 'PDF';
%ax_hist.YLim = [0 1.05];
%title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_hist_select)
%printfig(hf_4, fullfile(FullExportPath,VideoDate{1},['AllStrains_' IPTG_selected 'uM_SpeedDist_FullPopulation.pdf']),'-dpdf')

hf_5 = figure(5); 

legend('Location','Best','Interpreter','none')
ax_histMean_select = gca; 
ax_histMean_select.XLabel.String = 'Mean Speed (\mum/sec)';
ax_histMean_select.YLabel.String = 'PDF';
%ax_hist.YLim = [0 1.05];
%title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_histMean_select)

%printfig(hf_5, fullfile(FullExportPath,VideoDate{1},['AllStrains_' IPTG_selected 'uM_MeanSpeedDist_FullPopulation.pdf']),'-dpdf')

hf_6 = figure(6); 

legend('Location','Best','Interpreter','none')
ax_histMed_select = gca; 
ax_histMed_select.XLabel.String = 'Median Speed (\mum/sec)';
ax_histMed_select.YLabel.String = 'PDF';
%ax_hist.YLim = [0 1.05];
%title(CallStrainLabels{selectStrain},'Interpreter','none');
ErcagGraphics
settightplot(ax_histMed_select)

%printfig(hf_6, fullfile(FullExportPath,VideoDate{1},['AllStrains_' IPTG_selected 'uM_MedSpeedDist_FullPopulation.pdf']),'-dpdf')

