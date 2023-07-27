%% Find out relationship of turn angles with turn durations   
% May 2020 by Ercag
clearvars;
close all; 
%% Define Export Path for figures
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/TurnRunDurations';
%% Call the run reverse analysis files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43','KMT47','KMT53'}; 
j = 1;
%for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResults(MainPath, StrainLabels{j});
    %Preallocate
    IPTG = zeros(length(Files),1);
    TurnAngle = cell(length(Files),1);
    TurnDur = cell(length(Files),1); 
    
    for i = 1:length(Files) 
        load(Files{i}) 
        IPTG(i) = RunReverse.Info.IPTG; 
        TurnAngle{i} = cell2mat(Results.Ang(:,3));
        TurnDur{i} = Results.RTStats.TumbleLengths';
    end
    TA = matchrepeat(IPTG,TurnAngle);
    TDur = matchrepeat(IPTG,TurnDur);
    TA_TDur = [TA(:,2),TDur(:,2)]; %TurnAngles-TurnDurations

    for k = 1:size(TA_TDur,1)
        X = [TA_TDur{k,2}.*1000,TA_TDur{k,1}];
        X = X(X(:,1)<200,:); 
        
%         hist{k} = histogram(X(:,1),0:20:1000,'DisplayStyle','Stairs',...
%             'Normalization','PDF','LineWidth',1.5)
%         hold on 
%         ErcagGraphics
        hf = figure();
        hist3(X,'CdataMode','auto','FaceColor','Interp',...
            'NBins',[50 50])
        xlabel('TurnDurations (msec)'); 
        ylabel('TurnAngles (degrees)');
        colorbar
        view(2)
        title({StrainLabels{j},['IPTG = ' num2str(TA{k,1}) '\muM']})
        printfig(hf,fullfile(ExpPath,['[20200506]' StrainLabels{j} '_[IPTG]_' num2str(TA{k,1}) 'uM_TurnDurTurnAngles.pdf']),'-dpdf')
    end
%     legLabels = cellfun(@num2str,TA(:,1),'UniformOutput',0);
%     legLabels = cellfun(@(x) strcat(x,' \muM'),legLabels,'UniformOutput',0);
%     NewOrder = [2 3 4 1];
%     legend([hist{NewOrder}],legLabels(NewOrder),'Location','NorthWest')

%end


function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             R{i,2} = cell2mat(Y(Mask)); 
         end
end