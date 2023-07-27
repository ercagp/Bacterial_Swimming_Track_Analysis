%% Plot mean Turning rates vs. IPTG 
clearvars;
close all; 
%% Call the files 
%Set main load path
MainPath = '/Volumes/Pince/Data/RunReverseAnalysis'; 
Files = getallfilenames(MainPath);

%Set color maps
ColorMap(2,:) = [1 0 0];
ColorMap(3,:) = [0 0 1];
ColorMap(1,:) = [0.6350, 0.0780, 0.1840];
ColorMap(4,:) = [0, 0.5, 0];

Labels = []; 

Files = Files(contains(Files,'_RunReverseStruct'));
%Exclude the other mat files (which do not have label format [])
KeyMAT = '(?<=\[\d*\])\w*'; 
FilesFinal = Files(~cellfun(@isempty,regexp(Files,KeyMAT))); 

%Find strain labels of the targeted .mat files 
KeyStrainLabel = '(?<=\[\d*\])\w*(?=_RunReverseStruct)';
StrainLabels = regexp(FilesFinal,KeyStrainLabel,'match','once');
unSL = unique(StrainLabels);
errbrTotal = [];
for i = 1:length(unSL)
    %Find the matching strings inside StrainLabels  
    LogMask = cellfun(@(x) strcmp(x,unSL{i}),StrainLabels);
    StrLabel = unique(StrainLabels(LogMask));
    %Locate the target file using the samemask 
    SelectedFiles = FilesFinal(LogMask);
    %Define the vectors which is gonna be concatanated inside the loop
    IPTGAll{i} = []; 
    TotalTurns{i} = []; 
    EventRate{i} = []; 

    for j = 1:sum(LogMask) 
        disp(SelectedFiles{j})
        disp(StrLabel) 
        load(SelectedFiles{j})
        
        IPTGAll{i} = [RunReverseNew.IPTG, IPTGAll{i}];
        TotalTurns{i} = [RunReverseNew.TotalTurns, TotalTurns{i}];
        EventRate{i} = [RunReverseNew.EventRate, EventRate{i}];
    end
    unIPTGAll{i} = unique(IPTGAll{i},'stable');
    for k = 1:length(unIPTGAll{i}) 
        IPTG = IPTGAll{i}(IPTGAll{i} == unIPTGAll{i}(k)); 
        TotalTurnsIPTG = TotalTurns{i}(IPTGAll{i} == unIPTGAll{i}(k));
        EventRateIPTG = EventRate{i}(IPTGAll{i} == unIPTGAll{i}(k));
            
        avgTotalTurn = mean(TotalTurnsIPTG); 
        avgEventRate = mean(EventRateIPTG); 
        semEventRate = std(EventRateIPTG)/sqrt(length(EventRateIPTG)); 
            
        errbr = errorbar(unique(IPTG),avgEventRate,semEventRate);
        hold on 
        drawnow(); 
        errbr.Marker = '.';
        errbr.LineStyle = 'none';
        errbr.LineWidth = 1.0;
        errbr.MarkerSize = 20;
        errbr.Color = ColorMap(i,:); %Same strain 
    end
    errbrTotal = [errbrTotal;errbr];
    Labels = [Labels; StrLabel]; 
end

legend(errbrTotal(1:end),Labels,'Location','NorthWest');
ax = gca;
ax.XLabel.String = 'IPTG (\muM)' ;
ax.YLabel.String = 'Event Rate (s^{-1})' ;
ax.XLim = [20 105];
ax.XTick = [25 50 75 100];
ErcagGraphics
settightplot(ax)



