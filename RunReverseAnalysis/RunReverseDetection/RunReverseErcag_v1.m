%% Run-reverse analysis and plots for KMT43,KMT47,KMT48 & KMT53
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data//KMT47_25uM/ROI_1'; 
VideoDate = {'20191204','20191206'};
%FullPath = fullfile(MainPath,VideoDate);

CallStrainLabels = {'KMT53','KMT43'};
%Define regular expression key to search the strain label 
RegExp_StrainLabel{1} = ['(?<=' VideoDate{1} ')\\+\w*'];
RegExp_StrainLabel{2} = ['(?<=' VideoDate{2} ')\\+\w*'];
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
Files = Files(contains(Files,VideoDate{1}) | contains(Files,VideoDate{2}));

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
PlotSwitch = true; %is plotting individual bugs wanted? 
SaveFigSwitch.Flag = false; 


%Minimum Trajectory length & speed
minT = 2; %sec 
minV = 5; %um/sec

k = 1;

for j = 1:length(CallStrainLabels)
    %Target the specific strain label in the list 
    FilesSubset = Files(contains(Files,CallStrainLabels{j}));
    %Preallocate 
    TotalTurns = zeros(1,length(FilesSubset));
    EventRate = zeros(1,length(FilesSubset));
    IPTG = zeros(1,length(FilesSubset));
    TotalTrajLength = zeros(1,length(FilesSubset));
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
        
        Delta_tCell = cellfun(@(x) delta_t(B_Smooth.Parameters.fps,x)', RunEnds,'UniformOutput',0);
        
        Delta_tAll{i} = cell2mat(Delta_tCell);
        binsize = 1/B_Smooth.Parameters.fps; 
        bins = 0:binsize:3;
        
%         hf_deltat = figure;
%         histogram(Delta_tAll{i},bins,'DisplayStyle','stairs')
%         xlabel('\Deltat(s)')
%         ylabel('counts')
%         title([StrainLabel '--' ROI],'Interpreter','none')
%         ErcagGraphics
%         settightplot(gca)
%         drawnow()
%         Export_Deltat = fullfile(FullExportPath,'Delta_t');
%         mkdir(Export_Deltat)
%         printfig(hf_deltat,fullfile(Export_Deltat,[cell2mat(CallStrainLabels) '_' IPTG_Str 'uM' ROI '.pdf']),'-dpdf')
        
        %Compare different delta_t distributions
        if strcmp(ROI,'ROI_1') && strcmp(IPTG_Str,'100')
            hf_deltat_cmp = figure(5);
            hist = histogram(Delta_tAll{i},bins,'DisplayStyle','stairs','Normalization','pdf');
            hold on 
            drawnow
            xlabel('\Deltat(s)')
            ylabel('PDF')
            ErcagGraphics
        
            legend_cell{k} = [CallStrainLabels{j} '-' IPTG_Str 'uM_' ROI];
            k = k + 1; 
        else
            disp('otherROI');
        end
        
        
        disp([StrainLabel '--' ROI])
        
        SizeRunEnds = cellfun(@length, RunEnds);
        %Total number of turns per acquisition 
        TotalTurns(i) = sum(SizeRunEnds); 
        %Total trajectory duration per acquisition 
        TrajLength=cell2mat(cellfun(@(x) (size(x,1)/B_Smooth.Parameters.fps), B_Smooth.Speeds, 'UniformOutput', 0));
        TotalTrajLength(i) = sum(TrajLength(TrajLength>minT)); 
        %Turns per time (total # of turns / total traj. durations) 
        EventRate(i) = TotalTurns(i)/TotalTrajLength(i);
        IPTG(i) = str2double(IPTG_Str);        
    end
    IPTG_cell{j} = IPTG;
    EventRate_cell{j} = EventRate; 
    TotalTurns_cell{j} = TotalTurns;
    
end

RunReverse.Strains = CallStrainLabels;
RunReverse.IPTG = IPTG_cell;
RunReverse.TotalTurns = TotalTurns_cell;
RunReverse.EventRate = EventRate_cell; 

save(fullfile(FullExportPath,[CallStrainLabels{1:end} '_RunReverseStruct.mat']),'RunReverse')
%Normalize the number of turn to the maximum 
MaxTurn = max(cell2mat(TotalTurns_cell)); 
TotalTurns_Norm = cellfun(@(x) x./MaxTurn, TotalTurns_cell,'UniformOutput',0); 

%Mean Total Turns 

%KMT43
% avgIPTG{1} = unique(IPTG_cell{1},'stable'); 
% TotalTurnsMAT = reshape(TotalTurns_cell{1}(1:end-3),[2,length(TotalTurns_cell{1}(1:end-3))/2]); 
% avgTotalTurns{1} = [mean(TotalTurnsMAT,1) mean(TotalTurns_cell{1}(end-3:end))]; 
% stdTotalTurns{1} = [std(TotalTurnsMAT,1,1) std(TotalTurns_cell{1}(end-3:end))];
% 
% %KMT53
% avgIPTG{2} = unique(IPTG_cell{2},'stable');
% TotalTurnsMAT_KMT53 = reshape(TotalTurns_cell{2},[2,length(TotalTurns_cell{2})/2]);
% avgTotalTurns{2} = mean(TotalTurnsMAT_KMT53,1); 
% stdTotalTurns{2} = std(TotalTurnsMAT_KMT53,1,1); 
%avgTotalTurns{2} = [avgTotalTurns{2},TotalTurns_cell{2}(end)]; 


%Define plot parameters
ColorMap = [1 0 0; 0 0 1];

for m = 1:length(CallStrainLabels)
hf_1 = figure(1);  
pl{m} = plot(IPTG_cell{m},TotalTurns_cell{m},'.','Color',ColorMap(m,:),'MarkerSize',15);
hold on 

hf_2 = figure(2);
plnorm{m} = plot(IPTG_cell{m},TotalTurns_Norm{m},'.','Color',ColorMap(m,:),'MarkerSize',15);
hold on 

hf_3 = figure(3); 
pleventrate{m} =  plot(IPTG_cell{m},EventRate_cell{m},'.','Color',ColorMap(m,:),'MarkerSize',15);
hold on 
end

figure(hf_deltat_cmp)
title([CallStrainLabels{1} ' vs. ' CallStrainLabels{2}]);
legend(legend_cell,'Interpreter','none')
settightplot(gca);
Export_Deltat = fullfile(FullExportPath,'Delta_t');
mkdir(Export_Deltat)
printfig(hf_deltat_cmp,fullfile(Export_Deltat,[cell2mat(CallStrainLabels) '_allIPTG.pdf']),'-dpdf')


% hf_3 = figure(3);
% err{1} = errorbar(avgIPTG{1},avgTotalTurns{1},stdTotalTurns{1});
% err{1}.Marker = '.';
% err{1}.LineStyle = 'none';
% err{1}.LineWidth = 1.0;
% err{1}.MarkerSize = 15;
% err{1}.Color = ColorMap(1,:);
% 
% hold on 
% err{2} = errorbar(avgIPTG{2},avgTotalTurns{2},stdTotalTurns{2});
% err{2}.Marker = '.';
% err{2}.LineStyle = 'none';
% err{2}.LineWidth = 1.0;
% err{2}.MarkerSize = 15;
% err{2}.Color = ColorMap(2,:);
%plot(avgIPTG{2}(end),TotalTurns_cell{2}(end),'.','Color',ColorMap(2,:),'MarkerSize',15)


figure(1)
ax = gca;
ax.XLabel.String = 'IPTG (\muM)' ;
ax.YLabel.String = 'Total # of Turns (a.u.)' ;
ax.XLim = [20 105];
ax.XTick = [25 35 50 75 100];
legend(CallStrainLabels,'Location','SouthEast')
ErcagGraphics
%settightplot(ax)
printfig(hf_1,fullfile(FullExportPath,[CallStrainLabels{1:end} '_IPTGvsNumofTurns']),'-dpdf')

figure(2) 
ax_2 = gca;
ax_2.XLabel.String = 'IPTG (\muM)' ;
ax_2.YLabel.String = 'Norm. Total # of Turns (a.u.)' ;
ax_2.XLim = [20 105];
ax_2.XTick = [25 50 75 100];
legend(CallStrainLabels,'Location','SouthEast')
ErcagGraphics
settightplot(ax_2)
printfig(hf_2,fullfile(FullExportPath,[CallStrainLabels{1:end} '_IPTGvsNumofTurns_Normed']),'-dpdf')

figure(3) 
ax_3 = gca; 
ax_3.XLabel.String = 'IPTG (\muM)' ;
ax_3.YLabel.String = 'Turning Event Rate (s^{-1})' ;
ax_3.XLim = [20 105];
ax_3.XTick = [25 50 75 100];
legend(CallStrainLabels,'Location','SouthEast');
ErcagGraphics
settightplot(ax)
printfig(hf_3,fullfile(FullExportPath,[CallStrainLabels{1:end} '_MeanIPTGvsEventRate']),'-dpdf')



function delta_tVec = delta_t(fps,RunEnds)
delta_tVec = diff(RunEnds).*(1/fps); 
end