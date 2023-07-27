%% Bar plot detection
%by Ercag Pince
%April 2020 
clearvars;
clc;
close all; 

ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl/';
ImpPath = ExpPath; 

ExpPath_KMT9 = fullfile(ExpPath,'Plot_Results','KMT9_Results');
ExpPath_KMT47 = fullfile(ExpPath,'Plot_Results','KMT47_Results');
ExpPath_Both = fullfile(ExpPath,'Plot_Results');


%% Load structured run-reverse analysis data 
ImpFN = '[QC]RunReverseAnalysis_allData_KMT47_KMT9.mat';
load(fullfile(ImpPath,ImpFN)); 

%% KMT47 
%%%---Selected Trajectories---%%% 
%%%---False positives & negatives on different criterion---%%% 
hf_KMT47{1} = figure;
XDataStr = {'Both Turn Cri.','Only 2nd Turn Cri.','Only LalphaT','BugShuff','Esc.Cri.'}; 
%False Positives of the set given above
YData(1) = KMT47.Both.Data.FP;
YData(2) = KMT47.Only2nd.Data.FP;
YData(3) = KMT47.LalphaT.Data.FP;
YData(4) = KMT47.BugLShuff.Data.FP;
YData(5) = KMT47.Esc.Data.FP; 
X = categorical(XDataStr); 
X = reordercats(X,XDataStr);
B{1} = bar(X,YData);
hold on; 
%Define Labels 
Labels{1}.X = X;
Labels{1}.Y = '# of False Positives';
Labels{1}.Title = 'KMT47 - Selected Trajectories';
%Position offset for insertion of the text
TOffset{1}.X = 0.05;
TOffset{1}.Y = 0.5;
Factor{1}.X = 0.5; 
Factor{1}.Y = 0.5;

%Impose style
PlotStyle(hf_KMT47{1},B{1},Labels{1},YData,TOffset{1}); 
%Insert text 
%TextKMT47_FP = InsText(XDataStr,YData,TOffset{1},Factor{1}); 

%Save figure
printfig(hf_KMT47{1},fullfile(ExpPath_KMT47,'KMT47_FalsePositives_DifferentConditions.pdf'),'-dpdf') 
savefig(hf_KMT47{1},fullfile(ExpPath_KMT47,'KMT47_FalsePositives_DifferentConditions.fig'));

%False negatives -- Data
hf_KMT47{2} = figure; 
YData_FN(1) = KMT47.Both.Data.FN;
YData_FN(2) = KMT47.Only2nd.Data.FN;
YData_FN(3) = KMT47.LalphaT.Data.FN;
YData_FN(4) = KMT47.BugLShuff.Data.FN;
YData_FN(5) = KMT47.Esc.Data.FN; 
%Bar plot
B{2} = bar(X,YData_FN);
%Define labels
Labels{2}.X = X;
Labels{2}.Y = '# of False Negatives';
Labels{2}.Title = Labels{1}.Title;
%Position offset for insertion of the text
TOffset{2}.X = 0.05;
TOffset{2}.Y = 0.25;
Factor{2}.X = 0.5; 
Factor{2}.Y = 0.15;
%Impose style
PlotStyle(hf_KMT47{2},B{2},Labels{2},YData_FN,TOffset{2}); 
%Insert text 
%TextKMT47_FN = InsText(XDataStr,YData_FN,TOffset{2},Factor{2}); 

%Save figure
printfig(hf_KMT47{2},fullfile(ExpPath_KMT47,'KMT47_FalseNegatives_DifferentConditions.pdf'),'-dpdf') 
savefig(hf_KMT47{2},fullfile(ExpPath_KMT47,'KMT47_FalseNegatives_DifferentConditions.fig'));

%%%---Total # of Turns---%%% 
hf_KMT47{3} = figure; 
YDataTurns(1) = KMT47.Both.Data.TotalTurn;
YDataTurns(2) = KMT47.Only2nd.Data.TotalTurn;
YDataTurns(3) = KMT47.LalphaT.Data.TotalTurn; 
YDataTurns(4) = KMT47.BugLShuff.Data.TotalTurn; 
YDataTurns(5) = KMT47.Esc.Data.TotalTurn;
%Bar plot
B{3} = bar(X,YDataTurns);
%Define labels
Labels{3}.X = X;
Labels{3}.Y = '# of detected turns';
Labels{3}.Title = Labels{1}.Title;
%Position offset for insertion of the text
TOffset{3}.X = 0.60;
TOffset{3}.Y = 5;
Factor{3}.X = 0.25; 
Factor{3}.Y = 1.5;
%Impose style
PlotStyle(hf_KMT47{3},B{3},Labels{3},YDataTurns,TOffset{3}); 
%Insert text 
TextKMT47_TotalTurns = InsText(XDataStr,YDataTurns,TOffset{3},Factor{3}); 

%Save figure
printfig(hf_KMT47{3},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_DifferentConditions_Selected.pdf'),'-dpdf') 
savefig(hf_KMT47{3},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_DifferentConditions_Selected.fig'));


%%%---All Trajectories---%%% 
%----------------------------
%%%---Compare total # of turns for different set of criteria---%%% 
hf_KMT47{4} = figure;
XDataAllCmpStr = {'Both Turn Cri.','Only 2nd Turn Cri.','Only LalphaT','Esc.Cri.'}; 
YDataAll_Cmp(1) = KMT47.Both.Data.All.TotalTurn; 
YDataAll_Cmp(2) = KMT47.Only2nd.Data.All.TotalTurn; 
YDataAll_Cmp(3) = KMT47.LalphaT.Data.All.TotalTurn; 
YDataAll_Cmp(4) = KMT47.Esc.Data.All.TotalTurn;

XDataAll_Cmp = categorical(XDataAllCmpStr); 
XDataAll_Cmp = reordercats(XDataAll_Cmp,XDataAllCmpStr);
%Bar plot
B{4} = bar(XDataAll_Cmp,YDataAll_Cmp); 
%Define labels
Labels{4}.X = XDataAllCmpStr;
Labels{4}.Y = '# of detected turns';
Labels{4}.Title = 'KMT47 -- All Trajectories';
%Position offset for insertion of the text
TOffset{4}.X = 0.60;
TOffset{4}.Y = 50;
Factor{4}.X = 0.25; 
Factor{4}.Y = 2;
%Impose style
PlotStyle(hf_KMT47{4},B{4},Labels{4},YDataAll_Cmp,TOffset{4}); 
%Insert text 
TextKMT47_FN = InsText(XDataAllCmpStr,YDataAll_Cmp,TOffset{4},Factor{4}); 

%Save figure
printfig(hf_KMT47{4},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_DifferentConditions_All.pdf'),'-dpdf') 
savefig(hf_KMT47{4},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_DifferentConditions_All.fig'));

%%%---Compare # of turns detected by various conditions---%%% 
%%%---Both turn criteria in place---%%% 
hf_KMT47{5} = figure; 
XDataAll_BothStr = {'1st cri.','2nd cri.','1st & 2nd cri.'};
YDataAll_Both(1) = KMT47.Both.Data.All.FirstCri;
YDataAll_Both(2) = KMT47.Both.Data.All.SecondCri; 
YDataAll_Both(3) = KMT47.Both.Data.All.BothCri; 

XDataAll_Both = categorical(XDataAll_BothStr);
XDataAll_Both = reordercats(XDataAll_Both,XDataAll_BothStr);
%Bar plot 
B{5} = bar(XDataAll_Both,YDataAll_Both);
%Define labels
Labels{5}.X = XDataAll_BothStr;
Labels{5}.Y = '# of detected turns';
Labels{5}.Title = {'KMT47','Both 1st&2nd cri. -- All Trajectories'};
%Position offset for insertion of the text
TOffset{5}.X = 0.50;
TOffset{5}.Y = 50;
Factor{5}.X = 0.25; 
Factor{5}.Y = 2;
%Impose style
PlotStyle(hf_KMT47{5},B{5},Labels{5},YDataAll_Both,TOffset{5}); 
%Insert text 
TextKMT47_FN = InsText(XDataAll_BothStr,YDataAll_Both,TOffset{5},Factor{5}); 

%Save figure
printfig(hf_KMT47{5},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_BothTurnCri_All.pdf'),'-dpdf') 
savefig(hf_KMT47{5},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_BothTurnCri_All.fig'));

%%%---Only second turn criterion in place---%%% 
hf_KMT47{6} = figure; 
XDataAll_Only2ndStr = {'1st cri.','2nd cri.','1st & 2nd cri.'};
YDataAll_Only2nd(1) = KMT47.Only2nd.Data.All.FirstCri;
YDataAll_Only2nd(2) = KMT47.Only2nd.Data.All.SecondCri; 
YDataAll_Only2nd(3) = KMT47.Only2nd.Data.All.BothCri; 

XDataAll_Only2nd = categorical(XDataAll_Only2ndStr); 
XDataAll_Only2nd = reordercats(XDataAll_Only2nd,XDataAll_Only2ndStr);
%Bar plot 
B{6} = bar(XDataAll_Only2nd,YDataAll_Only2nd); 
%Define Labels
Labels{6}.X = XDataAll_Only2ndStr;
Labels{6}.Y = '# of detected turns';
Labels{6}.Title = {'KMT47','Only 2nd cri. -- All Trajectories'};
%Position offset for insertion of the text
TOffset{6}.X = 0.50;
TOffset{6}.Y = 50;
Factor{6}.X = 0.25; 
Factor{6}.Y = 2;
%Impose style
PlotStyle(hf_KMT47{6},B{6},Labels{6},YDataAll_Only2nd,TOffset{6}); 
%Insert text 
TextKMT47_FN = InsText(XDataAll_Only2ndStr,YDataAll_Only2nd,TOffset{6},Factor{6}); 

%Save figure
printfig(hf_KMT47{6},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_Only2ndTurnCri_All.pdf'),'-dpdf') 
savefig(hf_KMT47{6},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_Only2ndTurnCri_All.fig'));

%%%---Minimum angular threshold analysis---%%% 
%%%---# of False Positives---%%% 
hf_KMT47{7} = figure; 
for i = 1:length(KMT47.MinAng)
    YMinAng_FP(i) = KMT47.MinAng{i}.Data.FP; 
    XMinAng(i) =  KMT47.MinAng{i}.Parameters.AbsT; 
end

%Plot Angular Threshold vs. false positives 
plot(XMinAng,YMinAng_FP,'.-','Color',rgb('FireBrick'),...
    'MarkerSize',20,...
    'LineWidth',1.5);
title({'KMT47 - Angular Threshold Analysis','False Positives'});
xlabel('Abs. angle threshold (degrees)');
ylabel('# of False Positives');
ErcagGraphics
settightplot(gca);

%Save figure
printfig(hf_KMT47{7},fullfile(ExpPath_KMT47,'KMT47_FalsePositives_MinAngThres.pdf'),'-dpdf') 
savefig(hf_KMT47{7},fullfile(ExpPath_KMT47,'KMT47_FalsePositives_MinAngThres.fig'));

%%%---# of False Negatives---%%% 
hf_KMT47{8} = figure; 
for i = 1:length(KMT47.MinAng)
    YMinAng_FN(i) = KMT47.MinAng{i}.Data.FN; 
end



%Plot min. ang. thresh. vs. false negatives 
plot(XMinAng,YMinAng_FN,'.-','Color',[0 0 1],...
    'MarkerSize',20,...
    'LineWidth',1.5);
title({'KMT47 - Angular Threshold Analysis','False Negatives'});
xlabel('Abs. angle threshold (degrees)');
ylabel('# of False Negatives');
ErcagGraphics
settightplot(gca);

%Save figure
printfig(hf_KMT47{8},fullfile(ExpPath_KMT47,'KMT47_FalseNegatives_MinAngThres.pdf'),'-dpdf') 
savefig(hf_KMT47{8},fullfile(ExpPath_KMT47,'KMT47_FalseNegatives_MinAngThres.fig'));


%%%---# of Turns---%%% 
hf_KMT47{9} = figure; 
for i = 1:length(KMT47.MinAng)
    YMinAng_TotalTurn(i) = KMT47.MinAng{i}.Data.TotalTurn; 
end

XMinAngStr = num2cell(XMinAng);
XMinAngStr = cellfun(@num2str,XMinAngStr,'UniformOutput',0);
XMinAng_Bar = categorical(XMinAngStr);
XMinAng_Bar = reordercats(XMinAng_Bar,XMinAngStr); 
%Bar plot 
B{7} = bar(XMinAng_Bar,YMinAng_TotalTurn); 
%Define Labels
Labels{7}.X = XMinAngStr;
Labels{7}.Y = '# of detected turns';
Labels{7}.Title = {'KMT47 - Angular Threshold Analysis','Selected Trajectories'};
xlabel('Abs. angle threshold (degrees)')
%Position offset for insertion of the text
TOffset{7}.X = 0.70;
TOffset{7}.Y = 5;
Factor{7}.X = 0.25; 
Factor{7}.Y = 2;
%Impose style
PlotStyle(hf_KMT47{9},B{7},Labels{7},YMinAng_TotalTurn,TOffset{7}); 
%Insert text 
TextKMT47_FN = InsText(XMinAngStr,YMinAng_TotalTurn,TOffset{7},Factor{7});

%Save figure
printfig(hf_KMT47{9},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_MinAngThres_Selected.pdf'),'-dpdf') 
savefig(hf_KMT47{9},fullfile(ExpPath_KMT47,'KMT47_TotalTurns_MinAngThres_Selected.fig'));

%% KMT9 
%%%---Selected Trajectories---%%% 
%%%---False positives & negatives on different criterion---%%% 
hf_KMT9{1} = figure;
XDataStr = {'Both Turn Cri.','Only 2nd Turn Cri.','Only LalphaT','BugShuff','Esc.Cri.'}; 
%False Positives of the set given above
YDataKMT9(1) = KMT9.Both.Data.FP;
YDataKMT9(2) = KMT9.Only2nd.Data.FP;
YDataKMT9(3) = KMT9.LalphaT.Data.FP;
YDataKMT9(4) = KMT9.BugLShuff.Data.FP;
YDataKMT9(5) = KMT9.Esc.Data.FP; 
X_KMT9 = categorical(XDataStr); 
X_KMT9 = reordercats(X_KMT9,XDataStr);
B{8} = bar(X_KMT9,YDataKMT9);
hold on; 
%Define Labels 
Labels{8}.X = X;
Labels{8}.Y = '# of False Positives';
Labels{8}.Title = 'KMT9 - Selected Trajectories';
%Position offset for insertion of the text
TOffset{8}.X = 0.05;
TOffset{8}.Y = 0.25;
Factor{8}.X = 0.5; 
Factor{8}.Y = 0.5;

%Impose style
PlotStyle(hf_KMT9{1},B{8},Labels{8},YDataKMT9,TOffset{8},true);
%Insert text 
%TextKMT9_FP = InsText(XDataStr,YDataKMT9,TOffset{8},Factor{8}); 

%Save figure
printfig(hf_KMT9{1},fullfile(ExpPath_KMT9,'KMT9_FalsePositives_DifferentConditions.pdf'),'-dpdf') 
savefig(hf_KMT9{1},fullfile(ExpPath_KMT9,'KMT9_FalsePositives_DifferentConditions.fig'));

%False negatives -- Data
hf_KMT9{2} = figure; 
YDataKMT9_FN(1) = KMT9.Both.Data.FN;
YDataKMT9_FN(2) = KMT9.Only2nd.Data.FN;
YDataKMT9_FN(3) = KMT9.LalphaT.Data.FN;
YDataKMT9_FN(4) = KMT9.BugLShuff.Data.FN;
YDataKMT9_FN(5) = KMT9.Esc.Data.FN; 
%Bar plot
B{9} = bar(X_KMT9,YDataKMT9_FN);
%Define labels
Labels{9}.X = X_KMT9;
Labels{9}.Y = '# of False Negatives';
Labels{9}.Title = Labels{8}.Title;
%Position offset for insertion of the text
TOffset{9}.X = 0.05;
TOffset{9}.Y = 0.25;
Factor{9}.X = 0.5; 
Factor{9}.Y = 0.15;
%Impose style
PlotStyle(hf_KMT9{2},B{9},Labels{9},YDataKMT9_FN,TOffset{9},true); 
%Insert text 
%TextKMT47_FN = InsText(XDataStr,YData_FN,TOffset{2},Factor{2}); 

%Save figure
printfig(hf_KMT9{2},fullfile(ExpPath_KMT9,'KMT9_FalseNegatives_DifferentConditions.pdf'),'-dpdf') 
savefig(hf_KMT9{2},fullfile(ExpPath_KMT9,'KMT9_FalseNegatives_DifferentConditions.fig'));


%%%---Total # of Turns---%%% 
hf_KMT9{3} = figure; 
YDataKMT9_Turns(1) = KMT9.Both.Data.TotalTurn;
YDataKMT9_Turns(2) = KMT9.Only2nd.Data.TotalTurn;
YDataKMT9_Turns(3) = KMT9.LalphaT.Data.TotalTurn; 
YDataKMT9_Turns(4) = KMT9.BugLShuff.Data.TotalTurn; 
YDataKMT9_Turns(5) = KMT9.Esc.Data.TotalTurn;
%Bar plot
B{10} = bar(X_KMT9,YDataKMT9_Turns);
%Define labels
Labels{10}.X = X_KMT9;
Labels{10}.Y = '# of detected turns';
Labels{10}.Title = Labels{8}.Title;
%Position offset for insertion of the text
TOffset{10}.X = 0.5;
TOffset{10}.Y = 5;
Factor{10}.X = 0.25; 
Factor{10}.Y = 1.5;
%Impose style
PlotStyle(hf_KMT9{3},B{10},Labels{10},YDataKMT9_Turns,TOffset{10},true); 
%Insert text 
TextKMT9_TotalTurns = InsText(X_KMT9,YDataKMT9_Turns,TOffset{10},Factor{10}); 

%Save figure
printfig(hf_KMT9{3},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_DifferentConditions_Selected.pdf'),'-dpdf') 
savefig(hf_KMT9{3},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_DifferentConditions_Selected.fig'));

%%%---All Trajectories---%%% 
%----------------------------
%%%---Compare total # of turns for different set of criteria---%%% 
hf_KMT9{4} = figure;
XDataAllCmpStr_KMT9 = {'Both Turn Cri.','Only 2nd Turn Cri.','Only LalphaT','Esc.Cri.'}; 
YDataAll_Cmp_KMT9(1) = KMT9.Both.Data.All.TotalTurn; 
YDataAll_Cmp_KMT9(2) = KMT9.Only2nd.Data.All.TotalTurn; 
YDataAll_Cmp_KMT9(3) = KMT9.LalphaT.Data.All.TotalTurn; 
YDataAll_Cmp_KMT9(4) = KMT9.Esc.Data.All.TotalTurn;

XDataAll_Cmp_KMT9 = categorical(XDataAllCmpStr_KMT9); 
XDataAll_Cmp_KMT9 = reordercats(XDataAll_Cmp_KMT9,XDataAllCmpStr);
%Bar plot
B{11} = bar(XDataAll_Cmp_KMT9,YDataAll_Cmp_KMT9); 
%Define labels
Labels{11}.X = YDataAll_Cmp_KMT9;
Labels{11}.Y = '# of detected turns';
Labels{11}.Title = 'KMT9 -- All Trajectories';
%Position offset for insertion of the text
TOffset{11}.X = 0.5;
TOffset{11}.Y = 100;
Factor{11}.X = 0.25; 
Factor{11}.Y = 2.5;
%Impose style
PlotStyle(hf_KMT9{4},B{11},Labels{11},YDataAll_Cmp_KMT9,TOffset{11},true); 
%Insert text 
TextKMT9_Cmp = InsText(XDataAllCmpStr_KMT9,YDataAll_Cmp_KMT9,TOffset{11},Factor{11}); 

%Save figure
printfig(hf_KMT9{4},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_DifferentConditions_All.pdf'),'-dpdf') 
savefig(hf_KMT9{4},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_DifferentConditions_All.fig'));

%%%---Compare # of turns detected by various conditions---%%% 
%%%---Both turn criteria in place---%%% 
hf_KMT9{5} = figure; 
XDataAll_BothStr_KMT9 = {'1st cri.','2nd cri.','1st & 2nd cri.'};
YDataAll_Both_KMT9(1) = KMT9.Both.Data.All.FirstCri;
YDataAll_Both_KMT9(2) = KMT9.Both.Data.All.SecondCri; 
YDataAll_Both_KMT9(3) = KMT9.Both.Data.All.BothCri; 

XDataAll_Both_KMT9 = categorical(XDataAll_BothStr_KMT9);
XDataAll_Both_KMT9 = reordercats(XDataAll_Both_KMT9,XDataAll_BothStr_KMT9);
%Bar plot 
B{12} = bar(XDataAll_Both_KMT9,YDataAll_Both_KMT9);
%Define labels
Labels{12}.X = XDataAll_BothStr_KMT9;
Labels{12}.Y = '# of detected turns';
Labels{12}.Title = {'KMT9','Both 1st&2nd cri. -- All Trajectories'};
%Position offset for insertion of the text
TOffset{12}.X = 0.50;
TOffset{12}.Y = 100;
Factor{12}.X = 0.25; 
Factor{12}.Y = 2;
%Impose style
PlotStyle(hf_KMT9{5},B{12},Labels{12},YDataAll_Both_KMT9,TOffset{12},true); 
%Insert text 
TextKMT9_Both_Cmp = InsText(XDataAll_BothStr_KMT9,YDataAll_Both_KMT9,TOffset{12},Factor{12}); 

%Save figure
printfig(hf_KMT9{5},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_BothTurnCri_All.pdf'),'-dpdf') 
savefig(hf_KMT9{5},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_BothTurnCri_All.fig'));

%%%---Only second turn criterion in place---%%% 
hf_KMT9{6} = figure; 
XDataAll_Only2ndStr_KMT9 = {'1st cri.','2nd cri.','1st & 2nd cri.'};
YDataAll_Only2nd_KMT9(1) = KMT9.Only2nd.Data.All.FirstCri;
YDataAll_Only2nd_KMT9(2) = KMT9.Only2nd.Data.All.SecondCri; 
YDataAll_Only2nd_KMT9(3) = KMT9.Only2nd.Data.All.BothCri; 

XDataAll_Only2nd_KMT9 = categorical(XDataAll_Only2ndStr_KMT9); 
XDataAll_Only2nd_KMT9 = reordercats(XDataAll_Only2nd_KMT9,XDataAll_Only2ndStr_KMT9);
%Bar plot 
B{13} = bar(XDataAll_Only2nd_KMT9,YDataAll_Only2nd_KMT9); 
%Define Labels
Labels{13}.X = XDataAll_Only2ndStr;
Labels{13}.Y = '# of detected turns';
Labels{13}.Title = {'KMT9','Only 2nd cri. -- All Trajectories'};
%Position offset for insertion of the text
TOffset{13}.X = 0.50;
TOffset{13}.Y = 25;
Factor{13}.X = 0.25; 
Factor{13}.Y = 2;
%Impose style
PlotStyle(hf_KMT9{6},B{13},Labels{13},YDataAll_Only2nd_KMT9,TOffset{13},true); 
%Insert text 
TextKMT47_FN = InsText(XDataAll_Only2ndStr,YDataAll_Only2nd_KMT9,TOffset{13},Factor{13}); 

%Save figure
printfig(hf_KMT9{6},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_Only2ndTurnCri_All.pdf'),'-dpdf') 
savefig(hf_KMT9{6},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_Only2ndTurnCri_All.fig'));

%%%---Minimum angular threshold analysis---%%% 
%%%---# of False Positives---%%% 
hf_KMT9{7} = figure; 
for i = 1:length(KMT9.MinAng)
    YMinAng_FP_KMT9(i) = KMT9.MinAng{i}.Data.FP; 
    XMinAng_KMT9(i) =  KMT9.MinAng{i}.Parameters.AbsT; 
end

%Plot Angular Threshold vs. false positives 
plot(XMinAng_KMT9,YMinAng_FP_KMT9,'.-','Color',rgb('FireBrick'),...
    'MarkerSize',20,...
    'LineWidth',1.5);
title({'KMT9 - Angular Threshold Analysis','False Positives'});
xlabel('Abs. Angle Threshold (degrees)');
ylabel('# of False Positives');
ErcagGraphics
settightplot(gca);

%Save figure
printfig(hf_KMT9{7},fullfile(ExpPath_KMT9,'KMT9_FalsePositives_MinAngThres.pdf'),'-dpdf') 
savefig(hf_KMT9{7},fullfile(ExpPath_KMT9,'KMT9_FalsePositives_MinAngThres.fig'));

%%%---# of False Negatives---%%% 
hf_KMT9{8} = figure; 
for i = 1:length(KMT9.MinAng)
    YMinAng_FN_KMT9(i) = KMT9.MinAng{i}.Data.FN; 
end

%Plot min. ang. thresh. vs. false negatives 
plot(XMinAng_KMT9,YMinAng_FN_KMT9,'.-','Color',[0 0 1],...
    'MarkerSize',20,...
    'LineWidth',1.5);
title({'KMT9 - Angular Threshold Analysis','False Negatives'});
xlabel('Abs. angle threshold (degrees)');
ylabel('# of False Negatives');
ErcagGraphics
settightplot(gca);
%Save figure
printfig(hf_KMT9{8},fullfile(ExpPath_KMT9,'KMT9_FalseNegatives_MinAngThres.pdf'),'-dpdf') 
savefig(hf_KMT9{8},fullfile(ExpPath_KMT9,'KMT9_FalseNegatives_MinAngThres.fig'));


%%%---# of Turns---%%% 
hf_KMT9{9} = figure; 
for i = 1:length(KMT9.MinAng)
    YMinAng_TotalTurn_KMT9(i) = KMT9.MinAng{i}.Data.TotalTurn; 
end

XMinAngStr_KMT9 = num2cell(XMinAng_KMT9);
XMinAngStr_KMT9 = cellfun(@num2str,XMinAngStr_KMT9,'UniformOutput',0);
XMinAng_Bar_KMT9 = categorical(XMinAngStr_KMT9);
XMinAng_Bar_KMT9 = reordercats(XMinAng_Bar_KMT9,XMinAngStr_KMT9); 
%Bar plot 
B{14} = bar(XMinAng_Bar_KMT9,YMinAng_TotalTurn_KMT9); 
%Define Labels
Labels{14}.X = XMinAngStr_KMT9;
Labels{14}.Y = '# of detected turns';
Labels{14}.Title = {'KMT9 - Angular Threshold Analysis','Selected Trajectories'};
xlabel('Abs. angle threshold (degrees)')
%Position offset for insertion of the text
TOffset{14}.X = 0.50;
TOffset{14}.Y = 5;
Factor{14}.X = 0.25; 
Factor{14}.Y = 2;
%Impose style
PlotStyle(hf_KMT9{9},B{14},Labels{14},YMinAng_TotalTurn_KMT9,TOffset{14},true); 
%Insert text 
TextKMT9_TotalTurnAll = InsText(XMinAngStr_KMT9,YMinAng_TotalTurn_KMT9,TOffset{14},Factor{14});

%Save figure
printfig(hf_KMT9{9},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_MinAngThres_Selected.pdf'),'-dpdf') 
savefig(hf_KMT9{9},fullfile(ExpPath_KMT9,'KMT9_TotalTurns_MinAngThres_Selected.fig'));


%% Compare KMT9 & KMT47
%%%---Minimum angular threshold analysis---%%% 
%%%---# of False Positives---%%% 
hf_common{1} = figure; 
%Plot min. ang. thresh. vs. false positives
pFP_KMT47 = plot(XMinAng,YMinAng_FP,'.-','Color',rgb('FireBrick'),...
    'MarkerSize',20,...
    'LineWidth',1.5);
hold on 
pFP_KMT9 = plot(XMinAng_KMT9,YMinAng_FP_KMT9,'.-','Color',rgb('RoyalBlue'),...
    'MarkerSize',20,...
    'LineWidth',1.5);
title('Angular Threshold Analysis - False Positives');
xlabel('Abs. angle threshold (degrees)');
ylabel('# of False Positives');
legend([pFP_KMT9,pFP_KMT47],{'KMT9','KMT47'})
hold off
ErcagGraphics
settightplot(gca);
%Save figure
printfig(hf_common{1},fullfile(ExpPath_Both,'KMT9&KMT47_FalsePositives_MinAngThres.pdf'),'-dpdf') 
savefig(hf_common{1},fullfile(ExpPath_Both,'KMT9&KMT47_FalsePositives_MinAngThres.fig')) 

%%%---# of False Negatives---%%% 
hf_common{2} = figure; 
%Plot min. ang. thresh. vs. false negatives
pFP_KMT47 = plot(XMinAng,YMinAng_FN,'.-','Color',rgb('FireBrick'),...
    'MarkerSize',20,...
    'LineWidth',1.5);
hold on 
pFP_KMT9 = plot(XMinAng_KMT9,YMinAng_FN_KMT9,'.-','Color',rgb('RoyalBlue'),...
    'MarkerSize',20,...
    'LineWidth',1.5);
title('Angular Threshold Analysis - False Negatives');
xlabel('Abs. angle threshold (degrees)');
ylabel('# of False Negatives');
legend([pFP_KMT9,pFP_KMT47],{'KMT9','KMT47'})
hold off
ErcagGraphics
settightplot(gca);
%Save figure
printfig(hf_common{2},fullfile(ExpPath_Both,'KMT9&KMT47_FalseNegatives_MinAngThres.pdf'),'-dpdf') 
savefig(hf_common{2},fullfile(ExpPath_Both,'KMT9&KMT47_FalseNegatives_MinAngThres.fig')) 

%%%---# Compare Number of Turns---%%% 
hf_common{3} = figure; 
BarOffsetX = 1.5;
%Position offset for insertion of the text
TOffset{15}.Y = 10;
%Bar plot 
B{15} = bar(XMinAng_KMT9,YMinAng_TotalTurn_KMT9);
B{15}.FaceColor = rgb('RoyalBlue');
B{15}.EdgeColor = rgb('RoyalBlue');
%B{15}.FaceAlpha = 0.75;
%B{15}.EdgeAlpha = 0.75;
hold on 
B{16} = bar(XMinAng_KMT9 + BarOffsetX,YMinAng_TotalTurn); 
B{16}.FaceColor = rgb('FireBrick');
B{16}.EdgeColor = rgb('FireBrick');
%B{16}.FaceAlpha = 0.75;
%B{16}.EdgeAlpha = 0.75;

set([B{15},B{16}], 'BarWidth',0.5);
legend([B{15},B{16}], {'KMT9','KMT47'});

axcmpTurn_both = gca; 
axcmpTurn_both.Title.String = {'KMT9 & KMT47--Angular Threshold Analysis','# of Detected Turns'};
axcmpTurn_both.YLabel.String = '# of detected turns';
axcmpTurn_both.XLim = [28,59]; 
ErcagGraphics
settightplot(axcmpTurn_both);

%Save figure
printfig(hf_common{3},fullfile(ExpPath_Both,'KMT9&KMT47_TotalTurns_MinAngThres_Selected.pdf'),'-dpdf') 
savefig(hf_common{3},fullfile(ExpPath_Both,'KMT9&KMT47_TotalTurns_MinAngThres_Selected.fig')) 


%% Function
function PlotStyle(hf,B,Labels,YData,TOffset,varargin)
         figure(hf); 
         if nargin > 5
            B.FaceColor = rgb('RoyalBlue');
            B.EdgeColor = rgb('RoyalBlue');
         else
            B.FaceColor = rgb('FireBrick');
            B.EdgeColor = rgb('FireBrick');
         end
         B.BarWidth = 0.5;
         ax = gca; 
         ax.Title.String = Labels.Title;
         ax.YLabel.String = Labels.Y;
         ax.YLim = [0 max(YData)+(TOffset.Y*3)];
         ErcagGraphics 
end

function Text = InsText(TextCell,YData,TOffset,Factor)
         TextPosX = 1:length(TextCell);
         for i = 1:length(YData)
             TextStr{i} = num2str(YData(i));
             TextPosY(i) = YData(i);
             Text{i} = text(TextPosX(i) - Factor.X*TOffset.X , TextPosY(i)+TOffset.Y, TextStr{i}); 
             Text{i}.FontSize = 15;
         end
end

function InsLabel()
end
