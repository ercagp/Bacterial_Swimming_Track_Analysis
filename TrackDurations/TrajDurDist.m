%% Plot trajectory duration histogram of the strains entered run-reverse analysis 
%by Ercag
%May 2020 
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data'; 
%% Define Export Path 
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/TrajDurations';
%% Define call and experimental parameters 
VideoDates = {'20191206','20191204'};
StrainLabels = {'KMT43','KMT47','KMT53'};

%Set parameters to seek out the right files 
Lambda = 0.5; 
%Minimum Trajectory length & speed
minT = 2; %sec 
minV = 5; %um/sec
%frames per sec. 
fps = 30; %Hz

%Which strain to analyze? 
selectStrain = 1; %nth in StrainLabels
%Which IPTG level to compare? 
IPTGSel = 50; %uM

%Histogram parameters 
BinSize = 1/fps; %sec
MaxBin = 10; %sec
Bins = minT:2*BinSize:MaxBin; 

%Parameters for histogram settings
Lim.X = [minT MaxBin]; 
Lab(1).XAx = 'Traj. Dur. (sec)' ;
Lab(1).YAx = 'Counts' ;

for j = 1:length(StrainLabels)
    %Call files
    Files = callBugStruct(MainPath,StrainLabels{j},Lambda);
    %Call regexp keys
    regExpLib = giveKeys(StrainLabels{j});
    %Find [IPTG]
    IPTG{j} = regexp(Files,regExpLib.IPTG,'match','once');
    IPTGvec{j} = cellfun(@str2num,IPTG{j});
    
    %Preallocate
    DurDist = cell(length(Files),1);
    TotalBugs = cell(length(Files),1);
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
        %Trajectory durations
        DurDist{i} = cellfun(@(x) length(x(:,1)).*1/fps,S); 
        TotalBugs{i} = size(S,1); 
    end
    
    %Match IPTG values and speeds
    DD = matchrepeat(IPTGvec{j},DurDist);
%    TB = matchrepeat(IPTGvec{j},TotalBugs);
    for n = 1:length(DD(:,1))
        %-----Plot TrajDur distribution for individual Strain @ various [IPTG]-----%
        hf_DD(j) = figure(j);
        hist_DD(n) = histogram(DD{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','count','LineWidth',1.5);
        title(StrainLabels{j})
        hold on   
        %Legend entries ([IPTG])
        LegLab{n,j} = [num2str(DD{n,1}) ' \muM'];
        %-----Compare Strains at fixed [IPTG]-----%
        if DD{n,1} == IPTGSel
           hf_cmpDD = figure(4);
           hist_cmpDD(j) = histogram(DD{n,2},Bins,'DisplayStyle','Stairs',...
                              'Normalization','count','LineWidth',1.5);
           hold on 
           title({['IPTG = ' num2str(DD{n,1}) ' \muM'],'Trajectory Durations'})
        end
        %-----Plot 1-CDF of TrajDur for individual Strain @ various [IPTG]-----%
        
    end
    %Reorder legend entries
    if j == 1 || j == 2
       newOrder = [2 3 4 1];
       legend(hist_DD(newOrder),LegLab{newOrder,j},'Location','Best');
    else
       legend(hist_DD(1:end),LegLab{:,j},'Location','Best');
    end
    

    
    %Impose style 
    PlotSty(hf_DD(j),Lab(1),Lim)
    %Export graphics
    printfig(hf_DD(j),fullfile(ExpPath,['[20200513]' StrainLabels{j} '_TrajDurDist_Counts']),'-dpdf')
    
end
%Legend for the comparative plots 
legend(hist_cmpDD(1:end),StrainLabels,'Location','Best')
%Impose style
PlotSty(hf_cmpDD,Lab(1),Lim) 
%Export graphics
printfig(hf_cmpDD,fullfile(ExpPath,['[20200513]AllStrains_[IPTG]_' num2str(IPTGSel) 'uM_TrajDurDist_Counts']),'-dpdf')




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

function [S,TotalT] = filterout(S,minT,minV)
         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
         
         MaskTraj = medV > minV & TotalTime > minT;
         S = S(MaskTraj); 
         TotalT = sum(cellfun(@(x) length(x(:,1)).*1/fps,S)); 
end
