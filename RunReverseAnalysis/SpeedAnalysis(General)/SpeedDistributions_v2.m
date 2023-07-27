%% Plot Speed Distributions
%by Ercag 
%January 2020
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data'; 
%% Define Export Path 
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/SpeedAnalysis';
%% Define call and experimental parameters 
VideoDates = {'20210624'};
StrainLabels = {'KMT53'};

%Set parameters to seek out the right files 
Lambda = 0.5; 
%Minimum Trajectory length & speed
minT = 0; %sec 
minV = 20; %um/sec

%Exclude KMT43_25uM_Sample2 
%Files = Files(~contains(Files,'KMT43_25uM_Sample2')); (why? probably
%because of drift) 

%Which strain to analyze? 
selectStrain = 1; %nth in StrainLabels
%Which IPTG level to compare? 
IPTGSel = 100; %uM

%Histogram parameters 
BinSize = 2; %um/sec
MaxBin = 175; %um/sec
Bins = 0:BinSize:MaxBin; 

Lim.X = [0 MaxBin]; 

k = 1; 
for j = 1:length(StrainLabels)
    %Call files
    Files = callBugStruct(MainPath,StrainLabels{j},Lambda);
    %Call regexp keys
    regExpLib = giveKeys(StrainLabels{j});
    %Find the ROI,labels of the tracking files & [IPTG]
    ROI{j} = regexp(Files,regExpLib.ROI,'match','once');
    TrackLabels{j} = regexp(Files,regExpLib.TrackLabel,'match','once');
    IPTG{j} = regexp(Files,regExpLib.IPTG,'match','once');
    IPTGvec{j} = cellfun(@str2num,IPTG{j});
    
    %Preallocate
    AllSpeeds = cell(length(Files),1);
    MeanSpeeds = cell(length(Files),1);
    MedSpeeds = cell(length(Files),1);
    
    for i = 1:length(Files)
        load(Files{i})
        %Isolate cell with velocity & speed vectors
        S = B_Smooth.Speeds;
        %Extract FPS 
        fps = B_Smooth.Parameters.fps; 
        
        %Filter out trajectories
        TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
        medV = cellfun(@(x) medianN(x(:,9)), S);
        
        MaskTraj = medV > minV & TotalTime > minT;
        S = S(MaskTraj);
        
        AllSpeeds{i} = cell2mat(cellfun(@(x) x(:,9), S,'UniformOutput',false));
        MeanSpeeds{i} = cellfun(@(x) nanmean(x(:,9)), S, 'UniformOutput',true); 
        MedSpeeds{i} = cellfun(@(x) nanmedian(x(:,9)), S, 'UniformOutput',true);
    end
    
    %Match IPTG values and speeds
    AS = matchrepeat(IPTGvec{j},AllSpeeds);
    MeanS = matchrepeat(IPTGvec{j},MeanSpeeds);
    MedS = matchrepeat(IPTGvec{j},MedSpeeds);
    
    %-----Plot Individual Strain varying [IPTG]-----%
    for n = 1:length(AS(:,1))
        hf_AS(j) = figure(3*j-2);
        hist_AS(n) = histogram(AS{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','PDF','LineWidth',1.5);
        title(StrainLabels{j})
        hold on
        
        hf_MS(j) = figure(3*j-1); 
        hist_MS(n) = histogram(MeanS{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','PDF','LineWidth',1.5);
        title(StrainLabels{j})
        hold on 
      
        hf_MedS(j) = figure(3*j);
        hist_MedS(n) = histogram(MedS{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','PDF','LineWidth',1.5);
        title(StrainLabels{j})
        hold on
        %Legend entries ([IPTG])
        LegLab{n,j} = [num2str(AS{n,1}) ' \muM'];
        
         %-----Compare Strains at fixed [IPTG]-----%
         if AS{n,1} == IPTGSel
            hf_cmpAS = figure(10);
            hist_cmpAS(j) = histogram(AS{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','PDF','LineWidth',1.5);
            hold on 
            title({['IPTG = ' num2str(AS{n,1}) ' \muM'],'Inst. Speed'})
                          
            hf_cmpMS = figure(11); 
            hist_cmpMS(j) = histogram(MeanS{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','PDF','LineWidth',1.5);
            hold on 
            title({['IPTG = ' num2str(AS{n,1}) ' \muM'],'Mean Speed'})

            
            hf_cmpMedS = figure(12); 
            hist_cmpMedS(j)= histogram(MedS{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','PDF','LineWidth',1.5);
            hold on 
            title({['IPTG = ' num2str(AS{n,1}) ' \muM'],'Median Speed'})
         end
         
    end
    %Sort [IPTG] values
    newOrder = [5 2 3 6 4 1];
    legend(hist_AS(newOrder),LegLab{newOrder,j},'Location','Best');
    legend(hist_MS(newOrder),LegLab{newOrder,j},'Location','Best');
    legend(hist_MedS(newOrder),LegLab{newOrder,j},'Location','Best');
    
     
end
%Legend for the comparative plots 
legend(hist_cmpAS,StrainLabels,'Location','Best')
legend(hist_cmpMS,StrainLabels,'Location','Best')
legend(hist_cmpMedS,StrainLabels,'Location','Best')


Lab(1).XAx = 'Inst. Speed (\mum/s)' ;
Lab(2).XAx = 'Mean Speed (\mum/s)' ;
Lab(3).XAx = 'Median Speed(\mum/s)';
Lab(1).YAx = 'PDF' ;
Lab(2).YAx = 'PDF' ;
Lab(3).YAx = 'PDF';

PlotSty(hf_cmpAS,Lab(1),Lim)
PlotSty(hf_cmpMS,Lab(2),Lim)
PlotSty(hf_cmpMedS,Lab(3),Lim)

%% Save figures
for sty = 1:3
    PlotSty(hf_AS(sty),Lab(1),Lim)
    PlotSty(hf_MS(sty),Lab(2),Lim)
    PlotSty(hf_MedS(sty),Lab(3),Lim)
    
    printfig(hf_AS(sty),fullfile(ExpPath,['[20200708]' StrainLabels{sty} '_InstSpeed']),'-dpdf')
    printfig(hf_MS(sty),fullfile(ExpPath,['[20200708]' StrainLabels{sty} '_MeanSpeed']),'-dpdf')
    printfig(hf_MedS(sty),fullfile(ExpPath,['[20200708]' StrainLabels{sty} '_MedianSpeed']),'-dpdf')   
end

printfig(hf_cmpAS,fullfile(ExpPath,['[20200708]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM_InstSpeed']),'-dpdf')
printfig(hf_cmpMS,fullfile(ExpPath,['[20200708]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM_MeanSpeed']),'-dpdf')
printfig(hf_cmpMedS,fullfile(ExpPath,['[20200708]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM_MedianSpeed']),'-dpdf')


%% Functions 
function MATFiles = callBugStruct(FilePath,StrainLabel,Lambda)
        Files = getallfilenames(FilePath);
        %Eliminate the raw(not-smoothened) trajectories
        Files = Files(contains(Files,'ADMM') & contains(Files,['_Lambda_' num2str(Lambda)]) & contains(Files,'.mat')); 
        regExpKey = ['(?<=/\d*/)' StrainLabel '_\w*'];
        MATFiles  = Files(~cellfun(@isempty,regexp(Files,regExpKey,'once')));
end

function regExpLib = giveKeys(StrainLabel)
         %Define regular expression key to search for 
         regExpLib.TrackLabel = '(?<=ROI_\d/)\d*(?=_Tracking)';
         regExpLib.ROI = 'ROI[_]\d';
         %regExpLib.StrainLab = ['(?<=' VideoDate ')\w*_[\w*]'];
         regExpLib.Lambda = 'Lambda_\d';
         regExpLib.IPTG = ['(?<=' StrainLabel '_)\d*(?=\w*)'];
end

function R = matchrepeat(X,Y)
         UX = unique(X,'stable');
         R = cell(length(UX),2);
         for i = 1:length(UX)
             Mask = X == UX(i);
             R{i,1} = unique(X(Mask));
             if iscell(Y)
                R{i,2} = cell2mat(Y(Mask)); 
             else
                R{i,2} = Y(Mask); 
             end
         end
end

function PlotSty(hFig,Lab,Lim)
         figure(hFig);
         ax = gca; 
         %ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         ax.XLim = Lim.X;
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         settightplot(ax); 
end
