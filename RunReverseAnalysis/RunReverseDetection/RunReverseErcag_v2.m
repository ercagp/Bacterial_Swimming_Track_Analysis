%% Run-reverse analysis and plots for KMT43,KMT47,KMT48 & KMT53
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data/'; 
VideoDate = {'20191204'};

CallStrainLabels = {'KMT47'};
%Select only one trajectory? 
SelectOne = true; 
%Define regular expression key to search for the strain label 
RegExp_StrainLabel{1} = ['(?<=' VideoDate{1} '/)\w*(?=[_])'];
%Define regular expression key to search for the IPTG value
RegExp_IPTG{1} = ['(?<=' VideoDate{1} '/\w*[_])\d*'];
%Define regular expression key to search for the ROI number
RegExp_ROI = 'ROI[_]\d'; 

%Set smoothing(lambda) parameter to search for 
Lambda = 0.5; 
%Frame per sec. 
fps = 30; 

%Retrieve the file list 
Files = getallfilenames(MainPath);
%Eliminate the other video dates 
Files = Files(contains(Files,VideoDate));

%Eliminate the raw(not-smoothened) trajectories
Files = Files(contains(Files,'ADMM')); 
%Eliminate the files with lambda label other than set value above 
Files = Files(contains(Files,['_Lambda_' num2str(Lambda)]));

if SelectOne 
   disp('List of the Files\n')
   for li = 1:length(Files)
       disp([num2str(li) '--' Files{li}]);
   end
   Si = input('Enter the index of the selected file\n');
   Files = Files(Si); 
   SubDirect = cell2mat(regexp(Files,[ '(?<=' VideoDate{1} '/)\w*/'],'match','once'));
else 
   SubDirect = ''; 
end


%Define export path
MainExportPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl/2ndConditionRelaxed_Space/Only_Lalpha_MarkedPoints';
FullExportPath = fullfile(MainExportPath,SubDirect); 
mkdir(FullExportPath)

%Define parameters for the run-reverse analysis 
N = 1; %number of iterations
PlotSwitch = false; %Plot individual bugs for inspection? 
SaveFig = false; %Save the figures?

if SaveFig 
   SaveFigSwitch.Flag = true; 
   SaveFigSwitch.ExpPath = FullExportPath;
else 
   SaveFigSwitch.Flag = [];
   SaveFigSwitch.ExpPath = []; 
end


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
        StrainLabel = cell2mat(regexp(FilesSubset{i}, RegExp_StrainLabel{j},'match'));
        %Find the value for IPTG concentration
        IPTG(i) = str2double(cell2mat(regexp(FilesSubset{i},RegExp_IPTG{j},'match')));
        %Find out ROI number 
        ROI = cell2mat(regexp(FilesSubset{i},RegExp_ROI,'match'));   
        
        %Show the strain label and ROI number 
        disp([StrainLabel '--' ROI])
        %Show the IPTG value 
        disp(['IPTG = ' num2str(IPTG(i)) 'uM'])
        
        %load the mat file 
        load(FilesSubset{i}) 
        %Run the reverse-run analysis 
        Results = IterativeRunTumbleAnalysisFinal(B_Smooth,N,minT,minV,PlotSwitch,SaveFigSwitch);
        %The vector giving the indices at which turn events occur 
        RunEnds = Results.T(:,3);
        %Retrieve turn angles of all bugs; 
        TurnAngleAll = cell2mat(Results.Ang(:,3)); 
        %Plot turn angle distribution 
        angleEdges = 0:5:180;
        PlotTurnAngle(TurnAngleAll,angleEdges,FullExportPath,StrainLabel); 
        
        %Calculate time difference between individual points 
        Delta_tCell = cellfun(@(x) delta_t(B_Smooth.Parameters.fps,x)', RunEnds,'UniformOutput',0);
        
        Delta_tAll{i} = cell2mat(Delta_tCell);
        binsize = 1/B_Smooth.Parameters.fps; 
        bins = 0:binsize:3;
       
        SizeRunEnds = cellfun(@length, RunEnds);
        %Total number of turns per acquisition
        TotalTurns(i) = sum(SizeRunEnds); 
        %Total trajectory duration per acquisition 
        TrajLength = cell2mat(cellfun(@(x) (size(x,1)/B_Smooth.Parameters.fps), B_Smooth.Speeds, 'UniformOutput', 0));
        TotalTrajLength(i) = sum(TrajLength(TrajLength>minT)); 
        %Turns per time (total # of turns / total traj. durations) 
        EventRate(i) = TotalTurns(i)/TotalTrajLength(i);
        
        % Report 
        disp(['Total # of turn points detected = ' num2str(TotalTurns)]);
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'); 
        disp(['Total # of turn points would be detected by the first criterion = ' num2str(length(cell2mat(Results.ConditionCheck(:,1))))]) 
        disp(['Total # of turn points detected by the second criterion = ' num2str(length(cell2mat(Results.ConditionCheck(:,2))))]);
        disp(['Total # of turn points would be detected by both = ' num2str(length(cell2mat(Results.ConditionCheck(:,3))))]); 
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
save(fullfile(FullExportPath,[CallStrainLabels{1:end} '_Results.mat']),'Results')

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


%% Figures 
hf_TurnAngle = figure(1); 
figure(hf_TurnAngle); 
%Extract the turn angle matrix 
TurnAngles = cell2mat(Results.Ang(:,3));

%Define plot parameters
ColorMap = [1 0 0; 0 0 1];

% for m = 1:length(CallStrainLabels)
% hf_1 = figure(1);  
% pl{m} = plot(IPTG_cell{m},TotalTurns_cell{m},'.','Color',ColorMap(m,:),'MarkerSize',15);
% hold on 
% 
% hf_2 = figure(2);
% plnorm{m} = plot(IPTG_cell{m},TotalTurns_Norm{m},'.','Color',ColorMap(m,:),'MarkerSize',15);
% hold on 
% 
% hf_3 = figure(3); 
% pleventrate{m} =  plot(IPTG_cell{m},EventRate_cell{m},'.','Color',ColorMap(m,:),'MarkerSize',15);
% hold on 
% end

% figure(hf_deltat_cmp)
% title([CallStrainLabels{1} ' vs. ' CallStrainLabels{2}]);
% legend(legend_cell,'Interpreter','none')
% settightplot(gca);
% Export_Deltat = fullfile(FullExportPath,'Delta_t');
% mkdir(Export_Deltat)
% printfig(hf_deltat_cmp,fullfile(Export_Deltat,[cell2mat(CallStrainLabels) '_allIPTG.pdf']),'-dpdf')


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


% figure(1)
% ax = gca;
% ax.XLabel.String = 'IPTG (\muM)' ;
% ax.YLabel.String = 'Total # of Turns (a.u.)' ;
% ax.XLim = [20 105];
% ax.XTick = [25 35 50 75 100];
% legend(CallStrainLabels,'Location','SouthEast')
% ErcagGraphics
% %settightplot(ax)
% printfig(hf_1,fullfile(FullExportPath,[CallStrainLabels{1:end} '_IPTGvsNumofTurns']),'-dpdf')
% 
% figure(2) 
% ax_2 = gca;
% ax_2.XLabel.String = 'IPTG (\muM)' ;
% ax_2.YLabel.String = 'Norm. Total # of Turns (a.u.)' ;
% ax_2.XLim = [20 105];
% ax_2.XTick = [25 50 75 100];
% legend(CallStrainLabels,'Location','SouthEast')
% ErcagGraphics
% settightplot(ax_2)
% printfig(hf_2,fullfile(FullExportPath,[CallStrainLabels{1:end} '_IPTGvsNumofTurns_Normed']),'-dpdf')
% 
% figure(3) 
% ax_3 = gca; 
% ax_3.XLabel.String = 'IPTG (\muM)' ;
% ax_3.YLabel.String = 'Turning Event Rate (s^{-1})' ;
% ax_3.XLim = [20 105];
% ax_3.XTick = [25 50 75 100];
% legend(CallStrainLabels,'Location','SouthEast');
% ErcagGraphics
% settightplot(ax)
% printfig(hf_3,fullfile(FullExportPath,[CallStrainLabels{1:end} '_MeanIPTGvsEventRate']),'-dpdf')



function delta_tVec = delta_t(fps,RunEnds)
delta_tVec = diff(RunEnds).*(1/fps); 
end

function PlotTurnAngle(ThetaTurn,angleEdges,ExpPath,StrainLabel)
         hf_TurnAngle = figure();
         histogram(ThetaTurn,angleEdges,'DisplayStyle','stairs','LineWidth',1,...
             'Normalization','PDF');
         xlabel('Turn Angle')
         ylabel('PDF')
         ErcagGraphics
         printfig(hf_TurnAngle,'-dpdf',fullfile(ExpPath,[StrainLabel '_TurnAngle_Dist_AllBugs.pdf']));
end