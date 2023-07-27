%% Plot mean Turning rates vs. IPTG 
clearvars;
close all; 
%% Call the files 
MainPath = 'Z:\Data\RunReverseAnalysis\'; 
Files = getallfilenames(MainPath);

Files = Files(contains(Files,'_RunReverseStruct')); 

ColorMap(1,:) = [1 0 0];
ColorMap(4,:) = [0 0 1];
ColorMap(2,:) = [0.6350, 0.0780, 0.1840];
ColorMap(3,:) = [0, 0.5, 0];


KMT53_IPTGall =[];
KMT53_EventRate = [];
KMT53_TotalTurn  = [];


KMT48_IPTGall =[];
KMT48_EventRate = [];
KMT48_TotalTurn  = [];

Labels = [];
err_ind = 1; 

for i = 1:length(Files)
    load(Files{i})
    for j = 1:length(RunReverse.Strains)
        
        disp(RunReverse.Strains{j})
        if strcmp(RunReverse.Strains{j},'KMT53')
            KMT53_IPTGall  = [KMT53_IPTGall ; RunReverse.IPTG{j}];
            KMT53_TotalTurn  = [KMT53_TotalTurn ; RunReverse.TotalTurns{j}];
            KMT53_EventRate = [KMT53_EventRate ; RunReverse.EventRate{j}];
            continue
        elseif strcmp(RunReverse.Strains{j},'KMT48')
            KMT48_IPTGall  = [KMT48_IPTGall ; RunReverse.IPTG{j}];
            KMT48_TotalTurn  = [KMT48_TotalTurn ; RunReverse.TotalTurns{j}];
            KMT48_EventRate = [KMT48_EventRate ; RunReverse.EventRate{j}];
            continue
        else
           
        IPTGall = RunReverse.IPTG{j};
        IPTG = unique(IPTGall,'stable');
        
        TotalTurn = RunReverse.TotalTurns{j};
        EventRate = RunReverse.EventRate{j};   
            for k = 1:length(IPTG)
                avgTotalTurn(k) = mean(TotalTurn(IPTGall == IPTG(k)));
                avgEventRate(k) = mean(EventRate(IPTGall == IPTG(k)));
                stdEventRate(k) = std(EventRate(IPTGall == IPTG(k)));
            end
            

        err{err_ind} = errorbar(IPTG,avgEventRate,stdEventRate); 
        err{err_ind}.Marker = '.';
        err{err_ind}.LineStyle = 'none';
        err{err_ind}.LineWidth = 1.0;
        err{err_ind}.MarkerSize = 20;
        err{err_ind}.Color = ColorMap(err_ind,:);
        hold on
        Labels = [Labels; RunReverse.Strains{j}];  
        legend(Labels)
        end
    end
err_ind = err_ind + 1;    
end

%% KMT53 special
KMT53_IPTG = unique(KMT53_IPTGall,'stable'); 
KMT53_IPTG = KMT53_IPTG'; 
for m = 1:length(KMT53_IPTG)
    KMT53_avgTotalTurn(m) = mean(KMT53_TotalTurn(KMT53_IPTGall == KMT53_IPTG(m)));
    KMT53_avgEventRate(m) = mean(KMT53_EventRate(KMT53_IPTGall == KMT53_IPTG(m))); 
    KMT53_stdEventRate(m) = std(KMT53_EventRate(KMT53_IPTGall == KMT53_IPTG(m)));
end

err_KMT53 = errorbar(KMT53_IPTG,KMT53_avgEventRate,KMT53_stdEventRate); 
err_KMT53.Marker = '.';
err_KMT53.LineStyle = 'none';
err_KMT53.LineWidth = 1.0;
err_KMT53.MarkerSize = 20;
err_KMT53.Color = ColorMap(end,:);

legend([Labels;'KMT53'],'Location','NorthWest')

ax = gca;
ax.XLabel.String = 'IPTG (\muM)' ;
ax.YLabel.String = 'Turning Event Rate (s^{-1})' ;
ax.XLim = [20 105];
ax.XTick = [25 50 75 100];
ErcagGraphics
settightplot(ax)

printfig(gcf,fullfile(MainPath,'AllStrains_MeanIPTGvsEventRate'),'-dpdf')

hf_2 = figure(2);
KMT48_IPTG = unique(KMT48_IPTGall,'stable'); 
 
for l = 1:length(KMT48_IPTG)
    KMT48_avgTotalTurn(l) = mean(KMT48_TotalTurn(KMT48_IPTGall == KMT48_IPTG(l)));
    KMT48_avgEventRate(l) = mean(KMT48_EventRate(KMT48_IPTGall == KMT48_IPTG(l))); 
    KMT48_stdEventRate(l) = std(KMT48_EventRate(KMT48_IPTGall == KMT48_IPTG(l)));
end

err_KMT53 = errorbar(KMT53_IPTG,KMT53_avgEventRate,KMT53_stdEventRate); 
hold on 
err_KMT53.Marker = '.';
err_KMT53.LineStyle = 'none';
err_KMT53.LineWidth = 1.0;
err_KMT53.MarkerSize = 20;
err_KMT53.Color = ColorMap(end,:);

err_KMT48 = errorbar(KMT48_IPTG,KMT48_avgEventRate,KMT48_stdEventRate); 
err_KMT48.Marker = '.';
err_KMT48.LineStyle = 'none';
err_KMT48.LineWidth = 1.0;
err_KMT48.MarkerSize = 20;
err_KMT48.Color = ColorMap(3,:);

legend('KMT53','KMT48'); 

ax = gca;
ax.XLabel.String = 'IPTG (\muM)' ;
ax.YLabel.String = 'Turning Event Rate (s^{-1})' ;
ax.XLim = [20 105];
ax.YLim = [0 1.20];
ax.XTick = [25 50 75 100];
ErcagGraphics
settightplot(ax)

printfig(hf_2,fullfile(MainPath,'KMT48_KMT53_MeanIPTGvsEventRate'),'-dpdf');



