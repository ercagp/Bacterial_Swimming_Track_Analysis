%% Run-reverse analysis and plots for KMT43,KMT47,KMT48 & KMT53
clearvars;
close all; 
%% Define Path and call up trajectory files 
%%%%----Parameters----%%%% 
%Define strain label 
StrainLabel = 'KMT53';
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
%Define the date of acquisition
VideoDate = '20190604';

%Define regular expression key to search for the strain label,ROI & IPTG
RegExp_IPTG = ['(?<=' StrainLabel '[_])\d*(?=\w*)']; 
RegExp_ROI = 'ROI[_]\d'; 

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
Si = input('Enter the index of the selected file\n');
TargetFile = cell2mat(Files(Si)); 
StrainLabelFolder = regexp(TargetFile,Key_StrainLabelFolder,'match','once');


%% Run-reverse analysis 
%Find the value for IPTG concentration
IPTG_Str = regexp(TargetFile,RegExp_IPTG,'match','once');
IPTG = str2double(IPTG_Str);
%Find out ROI number 
ROI = regexp(TargetFile,RegExp_ROI,'match','once');   
disp([StrainLabel '--' ROI])
%Show the IPTG value 
disp(['IPTG = ' IPTG_Str 'uM'])
%Define complete export path 
ExpPath = fullfile(GenExpPath,VideoDate,StrainLabelFolder,ROI);
%Turn on SaveFigSwitch (See below for the function)
SaveFigSwitch = SaveFigT(SaveFig,ExpPath,FileFormat);

%load the mat file 
load(TargetFile) 
%Extract fps value 
fps = B_Smooth.Parameters.fps; 
%Run the reverse-run analysis 
Results = IterativeRunTumbleAnalysisFinal(B_Smooth,RunReversePara,PlotSwitch,SaveFigSwitch);
%The vector giving the indices at which turn events occur 
RunEnds = Results.T(:,3);
%Retrieve turn angles of all bugs; 
TurnAngleAll = cell2mat(Results.Ang(:,3)); 
        
%Calculate time difference between individual points 
% Delta_tCell = cellfun(@(x) delta_t(B_Smooth.Parameters.fps,x)', RunEnds,'UniformOutput',0);
%         
% Delta_tAll = cell2mat(Delta_tCell);
% binsize = 1/B_Smooth.Parameters.fps; 
% bins = 0:binsize:3;

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
        
% Report 
disp(['Total # of turn points detected = ' num2str(TotalTurns)]);
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'); 
disp(['Total # of turn points would be detected by the first criterion = ' num2str(length(cell2mat(Results.ConditionCheck(:,1))))]) 
disp(['Total # of turn points detected by the second criterion = ' num2str(length(cell2mat(Results.ConditionCheck(:,2))))]);
disp(['Total # of turn points would be detected by both = ' num2str(length(cell2mat(Results.ConditionCheck(:,3))))]); 
    
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
save(fullfile(ExpPath,['[' VideoDate ']' StrainLabelFolder '_' ROI '_Lambda_' num2str(Lambda) '_Results.mat']),'Results','RunReverse','Speeds')

%Normalize the number of turn to the maximum 
% MaxTurn = max(cell2mat(TotalTurns_cell)); 
% TotalTurns_Norm = cellfun(@(x) x./MaxTurn, TotalTurns_cell,'UniformOutput',0); 

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
% hf_TurnAngle = figure(1); 
% figure(hf_TurnAngle); 
%Extract the turn angle matrix 
% TurnAngles = cell2mat(Results.Ang(:,3));

%Define plot parameters
% ColorMap = [1 0 0; 0 0 1];

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



% function delta_tVec = delta_t(fps,RunEnds)
% delta_tVec = diff(RunEnds).*(1/fps); 
% end

%Plot turn angle distribution 
%angleEdges = 0:5:180;
%PlotTurnAngle(TurnAngleAll,angleEdges,FullExportPath,StrainLabel); 
% function PlotTurnAngle(ThetaTurn,angleEdges,ExpPath,StrainLabel)
%          hf_TurnAngle = figure();
%          histogram(ThetaTurn,angleEdges,'DisplayStyle','stairs','LineWidth',1,...
%              'Normalization','PDF');
%          xlabel('Turn Angle')
%          ylabel('PDF')
%          ErcagGraphics
%          printfig(hf_TurnAngle,'-dpdf',fullfile(ExpPath,[StrainLabel '_TurnAngle_Dist_AllBugs.pdf']));
% end

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