%% Bar plot of points detected by either of selection criteria
%by Ercag Pince
%April 2020 
clearvars;
clc;
close all; 

%ExpPathBoth = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl/1stConditionDropped_Space/BothConditions_MarkedPoints';
ExpPathOnlyTwo = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl/2ndConditionRelaxed_Space/Only_Lalpha_MarkedPoints';

%% Only the 2nd selection criteria (i.e. (LalphaT(i) && LalphaT3(i))) 
%Selected Trajectories 
%KMT9_5mM - 20191014 - ROI_1; 
KMT9_First = 31; % the # of would-be detected turns by the 1st criterion if the 1st criterion was in place 
KMT9_Second = 154; % the actual # of detected turns 
KMT9_Both = 30; % the # of would-be detected turns by the 1st&2nd criteria if the 1st criterion was in place 

KMT47_First = 36;
KMT47_Second = 173;
KMT47_Both = 35;

%All Trajectories 
% KMT9_5mM - 20191014 - ROI_1; 
N_KMT9All = 1133; %Total number of trajectories that enter the analysis

KMT9All_First = 932; 
KMT9All_Second = 3880; 
KMT9All_Both = 881; 
% KMT47_50uM[IPTG] - 20191014 - ROI_1
N_KMT47All = 635; 

KMT47All_First = 421; 
KMT47All_Second = 1826; 
KMT47All_Both = 381; 

%% Only LalphaT>absT in place
KMT9_LalphaT = 4034;
KMT47_LalphaT = 1935; 

%% False Positives and Negatives

%With both criteria in place 
KMT9Both_FP = 4.43; %Percentage 
KMT9Both_FN = 1.26; 
%Only the second criterion in place
KMT9OnlySecond_FP = 6.49; %Percentage
KMT9OnlySecond_FN = 1.29; 
%Only LalphaT>absT 
KMT9LalphaT_FP = 3.08;
KMT9LalphaT_FN = 0.67; 

KMT47LalphaT_FP = 6.57;  
KMT47LalphaT_FN = 2.17; 

%When bug list shuffled 
KMT9Shuff_FP = 1.24; 
KMT9Shuff_FN = 1.86; 
KMT47Shuff_FP = 6.81;
KMT47Shuff_FN = 3.03;

%Escape criterion shortened to check two points(i:i+1) 
KMT9Escape_FP = 4.96;
KMT9Escape_FN = 1.24; 
KMT47Escape_FP = 7.61; 
KMT47Escape_FN = 1.09;

KMT47Both_FP = 11.36;  %Percentage
KMT47Both_FN = 1.7; 
KMT47OnlySecond_FP = 10.40; %Percentage
KMT47OnlySecond_FN = 1.73; 

%% Bar Plots 

%KMT9 - Selected Trajectories 
% hf_KMT9Selected = figure; 
% FirstSt = '1st criterion';
% SecondSt = '2nd criterion';
% BothSt = '1st & 2nd cri.';
% X = categorical({FirstSt, SecondSt, BothSt});
% X = reordercats(X,{FirstSt, SecondSt, BothSt});
% B = bar(X,[KMT9_First, KMT9_Second, KMT9_Both]);
% B.FaceColor = rgb('FireBrick');
% B.EdgeColor = rgb('FireBrick');
% B.BarWidth = 0.5;
% title('KMT9 - Inspected Trajectories (N=50)') 
% ylabel('# of Detected Turns')
% 
% %Place text on each bar 
% Text.XOffset = 0.05;
% Text.YOffset = 5; 
% Text.X(1:3) = 1:3;
% Text.Y(1) = KMT9_First;
% Text.Y(2) = KMT9_Second; 
% Text.Y(3) = KMT9_Both;
% Text.YStr{1} = num2str(KMT9_First);
% Text.YStr{2} = num2str(KMT9_Second);
% Text.YStr{3} = num2str(KMT9_Both);
% 
% T{1} = text(Text.X(1)-Text.XOffset,Text.Y(1)+Text.YOffset,Text.YStr{1}); 
% T{2} = text(Text.X(2)-1.5*Text.XOffset,Text.Y(2)+Text.YOffset,Text.YStr{2}); 
% T{3} = text(Text.X(3)-Text.XOffset,Text.Y(3)+Text.YOffset,Text.YStr{3}); 
% 
% set([T{1:end}], 'FontSize',15); 
% %Adjust gca values 
% ax = gca;
% ax.YLim = [0 max([KMT9_First, KMT9_Second, KMT9_Both])+(Text.YOffset*3)];
% %Set style and print out 
% ErcagGraphics
% printfig(hf_KMT9Selected,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT9_Selected.pdf'))

%KMT9 - All Trajectories 
hf_KMT9All = figure; 
FirstSt = '1st criterion';
SecondSt = '2nd criterion';
BothSt = '1st & 2nd cri.';
ThirdSt = 'only LalphaT';  

X = categorical({FirstSt, SecondSt, BothSt,ThirdSt});
X = reordercats(X,{FirstSt, SecondSt, BothSt,ThirdSt});
B = bar(X,[KMT9All_First, KMT9All_Second, KMT9All_Both, KMT9_LalphaT]);
B.FaceColor = rgb('FireBrick');
B.EdgeColor = rgb('FireBrick');
B.BarWidth = 0.5;
title('KMT9 - All Trajectories (N = 1133)') 
ylabel('# of Detected Turns')

TextAll.XOffset = 0.05;
TextAll.YOffset = 100; 
TextAll.X(1:4) = 1:4;
TextAll.Y(1) = KMT9All_First;
TextAll.Y(2) = KMT9All_Second; 
TextAll.Y(3) = KMT9All_Both;
TextAll.Y(4) = KMT9_LalphaT;
TextAll.YStr{1} = num2str(KMT9All_First);
TextAll.YStr{2} = num2str(KMT9All_Second);
TextAll.YStr{3} = num2str(KMT9All_Both);
TextAll.YStr{4} = num2str(KMT9_LalphaT);

Tall{1} = text(TextAll.X(1)-1.5*TextAll.XOffset,TextAll.Y(1)+TextAll.YOffset,TextAll.YStr{1}); 
Tall{2} = text(TextAll.X(2)-2*TextAll.XOffset,TextAll.Y(2)+TextAll.YOffset,TextAll.YStr{2}); 
Tall{3} = text(TextAll.X(3)-1.5*TextAll.XOffset,TextAll.Y(3)+TextAll.YOffset,TextAll.YStr{3}); 
Tall{4} = text(TextAll.X(4)-1.5*TextAll.XOffset,TextAll.Y(4)+TextAll.YOffset,TextAll.YStr{4}); 

set([Tall{1:end}], 'FontSize',15); 
%Adjust gca values 
ax_2 = gca;
ax_2.YLim = [0 max([KMT9All_First, KMT9All_Second, KMT9All_Both, KMT9_LalphaT])+(TextAll.YOffset*3)];
%Set style and print out 
ErcagGraphics
printfig(hf_KMT9All,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT9_AllTraj.pdf'))

% 
% %KMT47 - selected trajectories 
% hf_KMT47Selected = figure; 
% FirstSt = '1st criterion';
% SecondSt = '2nd criterion';
% BothSt = '1st & 2nd cri.';
% X = categorical({FirstSt, SecondSt, BothSt});
% X = reordercats(X,{FirstSt, SecondSt, BothSt});
% B = bar(X,[KMT47_First, KMT47_Second, KMT47_Both]);
% B.FaceColor = rgb('FireBrick');
% B.EdgeColor = rgb('FireBrick');
% B.BarWidth = 0.5;
% title('KMT47 - Inspected Trajectories (N=50)') 
% ylabel('# of Detected Turns')
% 
% %Place text on each bar 
% Text47.XOffset = 0.05;
% Text47.YOffset = 5; 
% Text47.X(1:3) = 1:3;
% Text47.Y(1) = KMT47_First;
% Text47.Y(2) = KMT47_Second; 
% Text47.Y(3) = KMT47_Both;
% Text47.YStr{1} = num2str(KMT47_First);
% Text47.YStr{2} = num2str(KMT47_Second);
% Text47.YStr{3} = num2str(KMT47_Both);
% % 
% T47{1} = text(Text47.X(1)-Text47.XOffset,Text47.Y(1)+Text47.YOffset,Text47.YStr{1}); 
% T47{2} = text(Text47.X(2)-1.5*Text47.XOffset,Text47.Y(2)+Text47.YOffset,Text47.YStr{2}); 
% T47{3} = text(Text47.X(3)-Text47.XOffset,Text47.Y(3)+Text47.YOffset,Text47.YStr{3}); 
% 
% set([T47{1:end}], 'FontSize',15); 
% %Adjust gca values 
% ax_3 = gca;
% ax_3.YLim = [0 max([KMT47_First, KMT47_Second, KMT47_Both])+(Text47.YOffset*3)];
% %Set style and print out 
% ErcagGraphics
% printfig(hf_KMT47Selected,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT47_Selected.pdf'))
% 
% %KMT47 - All trajectories 
hf_KMT47All = figure; 
FirstSt = '1st criterion';
SecondSt = '2nd criterion';
BothSt = '1st & 2nd cri.';
ThirdSt = 'only LalphaT';  
X = categorical({FirstSt, SecondSt, BothSt, ThirdSt});
X = reordercats(X,{FirstSt, SecondSt, BothSt, ThirdSt});
B = bar(X,[KMT47All_First, KMT47All_Second, KMT47All_Both, KMT47_LalphaT]);
B.FaceColor = rgb('FireBrick');
B.EdgeColor = rgb('FireBrick');
B.BarWidth = 0.5;
title('KMT47 - All Trajectories (N = 635)') 
ylabel('# of Detected Turns')

%Place text on each bar 
Text47All.XOffset = 0.05;
Text47All.YOffset = 50; 
Text47All.X(1:4) = 1:4;
Text47All.Y(1) = KMT47All_First;
Text47All.Y(2) = KMT47All_Second; 
Text47All.Y(3) = KMT47All_Both;
Text47All.Y(4) = KMT47_LalphaT;
Text47All.YStr{1} = num2str(KMT47All_First);
Text47All.YStr{2} = num2str(KMT47All_Second);
Text47All.YStr{3} = num2str(KMT47All_Both);
Text47All.YStr{4} = num2str(KMT47_LalphaT);


T47All{1} = text(Text47All.X(1)-1.5*Text47All.XOffset,Text47All.Y(1)+Text47All.YOffset,Text47All.YStr{1}); 
T47All{2} = text(Text47All.X(2)-2*Text47All.XOffset,Text47All.Y(2)+Text47All.YOffset,Text47All.YStr{2}); 
T47All{3} = text(Text47All.X(3)-1.5*Text47All.XOffset,Text47All.Y(3)+Text47All.YOffset,Text47All.YStr{3}); 
T47All{4} = text(Text47All.X(4)-1.5*Text47All.XOffset,Text47All.Y(4)+Text47All.YOffset,Text47All.YStr{4}); 

set([T47All{1:end}], 'FontSize',15); 

%Adjust gca values 
ax_4 = gca;
ax_4.YLim = [0 max([KMT47All_First, KMT47All_Second, KMT47All_Both, KMT47_LalphaT])+(Text47All.YOffset*3)];
%Set style and print out 
ErcagGraphics
printfig(hf_KMT47All,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT47_AllTraj.pdf'))

%KMT9 false positives
hf_KMT9_FP = figure; 
FirstSt_FP = 'only 2nd criterion';
SecondSt_FP = '1st or 2nd criteria';
ThirdSt_FP = 'only LalphaT';  
FourthSt_FP = 'Randomized List';
X = categorical({FirstSt_FP, SecondSt_FP,ThirdSt_FP,FourthSt_FP});
X = reordercats(X,{FirstSt_FP, SecondSt_FP,ThirdSt_FP,FourthSt_FP});
B = bar(X,[KMT9OnlySecond_FP,KMT9Both_FP KMT9LalphaT_FP KMT9Shuff_FP]);
B.FaceColor = rgb('FireBrick');
B.EdgeColor = rgb('FireBrick');
B.BarWidth = 0.5;
title('KMT9 - False Positive Ratio') 
ylabel('Ratio (FP/TotalTurns)')

%Place text on each bar 
TextFP.XOffset = 0.05;
TextFP.YOffset = 0.15; 
TextFP.X(1:4) = 1:4;
TextFP.Y(1) = KMT9OnlySecond_FP;
TextFP.Y(2) = KMT9Both_FP; 
TextFP.Y(3) = KMT9LalphaT_FP;
TextFP.Y(4) = KMT9Shuff_FP; 
TextFP.YStr{1} = [num2str(KMT9OnlySecond_FP) '%'];
TextFP.YStr{2} = [num2str(KMT9Both_FP) '%'];
TextFP.YStr{3} = [num2str(KMT9LalphaT_FP) '%'];
TextFP.YStr{4} = [num2str(KMT9Shuff_FP) '%'];


TFP{1} = text(TextFP.X(1)-1.5*TextFP.XOffset,TextFP.Y(1)+TextFP.YOffset,TextFP.YStr{1}); 
TFP{2} = text(TextFP.X(2)-1.5*TextFP.XOffset,TextFP.Y(2)+TextFP.YOffset,TextFP.YStr{2}); 
TFP{3} = text(TextFP.X(3)-1.5*TextFP.XOffset,TextFP.Y(3)+TextFP.YOffset,TextFP.YStr{3}); 
TFP{4} = text(TextFP.X(4)-1.5*TextFP.XOffset,TextFP.Y(4)+TextFP.YOffset,TextFP.YStr{4}); 


set([TFP{1:end}], 'FontSize',15); 
%Adjust gca values 
ax_5 = gca;
ax_5.YLim = [0 max([KMT9OnlySecond_FP, KMT9Both_FP KMT9LalphaT_FP KMT9Shuff_FP])+(TextFP.YOffset*3)];
%Set style and print out 
ErcagGraphics

printfig(hf_KMT9_FP,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT9_FP.pdf'))

%KMT9 false negatives
hf_KMT9_FN = figure; 
FirstSt_FN = 'only 2nd criterion';
SecondSt_FN = '1st or 2nd criteria';
ThirdSt_FN = ThirdSt_FP; 
FourthSt_FN = FourthSt_FP; 
X = categorical({FirstSt_FN, SecondSt_FN,ThirdSt_FN,FourthSt_FN});
X = reordercats(X,{FirstSt_FN, SecondSt_FN,ThirdSt_FN,FourthSt_FN});
B = bar(X,[KMT9OnlySecond_FN,KMT9Both_FN KMT9LalphaT_FN KMT9Shuff_FN]);
B.FaceColor = rgb('FireBrick');
B.EdgeColor = rgb('FireBrick');
B.BarWidth = 0.5;
title('KMT9 - False Negative Ratio') 
ylabel('Ratio (FN/TotalTurns)')

%Place text on each bar 
TextFN.XOffset = 0.05;
TextFN.YOffset = 0.05; 
TextFN.X(1:4) = 1:4;
TextFN.Y(1) = KMT9OnlySecond_FN;
TextFN.Y(2) = KMT9Both_FN; 
TextFN.Y(3) = KMT9LalphaT_FN;
TextFN.Y(4) = KMT9Shuff_FN; 
TextFN.YStr{1} = [num2str(KMT9OnlySecond_FN) '%'];
TextFN.YStr{2} = [num2str(KMT9Both_FN) '%'];
TextFN.YStr{3} = [num2str(KMT9LalphaT_FN) '%'];
TextFN.YStr{4} = [num2str(KMT9Shuff_FN) '%'];

TFN{1} = text(TextFN.X(1)-1.5*TextFN.XOffset,TextFN.Y(1)+TextFN.YOffset,TextFN.YStr{1}); 
TFN{2} = text(TextFN.X(2)-1.5*TextFN.XOffset,TextFN.Y(2)+TextFN.YOffset,TextFN.YStr{2}); 
TFN{3} = text(TextFN.X(3)-1.5*TextFN.XOffset,TextFN.Y(3)+TextFN.YOffset,TextFN.YStr{3}); 
TFN{4} = text(TextFN.X(4)-1.5*TextFN.XOffset,TextFN.Y(4)+TextFN.YOffset,TextFN.YStr{4}); 

set([TFN{1:end}], 'FontSize',15); 
%Adjust gca values 
ax_5 = gca;
ax_5.YLim = [0 max([KMT9OnlySecond_FN, KMT9Both_FN KMT9LalphaT_FN KMT9Shuff_FN])+(TextFN.YOffset*3)];
%Set style and print out 
ErcagGraphics

printfig(hf_KMT9_FN,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT9_FN.pdf'))


%KMT47 false positives
hf_KMT47_FP = figure; 
X = categorical({FirstSt_FP, SecondSt_FP,ThirdSt_FP,FourthSt_FP});
X = reordercats(X,{FirstSt_FP, SecondSt_FP,ThirdSt_FP,FourthSt_FP});
B = bar(X,[KMT47OnlySecond_FP,KMT47Both_FP KMT47LalphaT_FP KMT47Shuff_FP]);
B.FaceColor = rgb('FireBrick');
B.EdgeColor = rgb('FireBrick');
B.BarWidth = 0.5;
title('KMT47 - False Positive Ratio') 
ylabel('Ratio (FP/TotalTurns)')

%Place text on each bar 
TextFP.XOffset = 0.05;
TextFP.YOffset = 0.25; 
TextFP.X(1:4) = 1:4;
TextFP.Y(1) = KMT47OnlySecond_FP;
TextFP.Y(2) = KMT47Both_FP; 
TextFP.Y(3) = KMT47LalphaT_FP;
TextFP.Y(4) = KMT47Shuff_FP; 
TextFP.YStr{1} = [num2str(KMT47OnlySecond_FP) '%'];
TextFP.YStr{2} = [num2str(KMT47Both_FP) '%'];
TextFP.YStr{3} = [num2str(KMT47LalphaT_FP) '%'];
TextFP.YStr{4} = [num2str(KMT47Shuff_FP) '%'];


TFP{1} = text(TextFP.X(1)-1.5*TextFP.XOffset,TextFP.Y(1)+TextFP.YOffset,TextFP.YStr{1}); 
TFP{2} = text(TextFP.X(2)-1.5*TextFP.XOffset,TextFP.Y(2)+TextFP.YOffset,TextFP.YStr{2}); 
TFP{3} = text(TextFP.X(3)-1.5*TextFP.XOffset,TextFP.Y(3)+TextFP.YOffset,TextFP.YStr{3}); 
TFP{4} = text(TextFP.X(4)-1.5*TextFP.XOffset,TextFP.Y(4)+TextFP.YOffset,TextFP.YStr{4}); 

set([TFP{1:end}], 'FontSize',15); 
%Adjust gca values 
ax_5 = gca;
ax_5.YLim = [0 max([KMT47OnlySecond_FP, KMT47Both_FP KMT47LalphaT_FP KMT47Shuff_FP])+(TextFP.YOffset*3)];
%Set style and print out 
ErcagGraphics

printfig(hf_KMT47_FP,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT47_FP.pdf'))



%KMT47 false negatives 
hf_KMT47_FN = figure; 
X = categorical({FirstSt_FP, SecondSt_FP,ThirdSt_FP,FourthSt_FP});
X = reordercats(X,{FirstSt_FP, SecondSt_FP,ThirdSt_FP,FourthSt_FP});
B = bar(X,[KMT47OnlySecond_FN,KMT47Both_FN,KMT47LalphaT_FN, KMT47Shuff_FN]);
B.FaceColor = rgb('FireBrick');
B.EdgeColor = rgb('FireBrick');
B.BarWidth = 0.5;
title('KMT47 - False Negative Ratio') 
ylabel('Ratio (FP/TotalTurns)')

%Place text on each bar 
TextFN.XOffset = 0.05;
TextFN.YOffset = 0.05; 
TextFN.X(1:4) = 1:4;
TextFN.Y(1) = KMT47OnlySecond_FN;
TextFN.Y(2) = KMT47Both_FN; 
TextFN.Y(3) = KMT47LalphaT_FN;
TextFN.Y(4) = KMT47Shuff_FN; 
TextFN.YStr{1} = [num2str(KMT47OnlySecond_FN) '%'];
TextFN.YStr{2} = [num2str(KMT47Both_FN) '%'];
TextFN.YStr{3} = [num2str(KMT47LalphaT_FN) '%'];
TextFN.YStr{4} = [num2str(KMT47Shuff_FN) '%'];

TFN{1} = text(TextFN.X(1)-1.5*TextFN.XOffset,TextFN.Y(1)+TextFN.YOffset,TextFN.YStr{1}); 
TFN{2} = text(TextFN.X(2)-1.5*TextFN.XOffset,TextFN.Y(2)+TextFN.YOffset,TextFN.YStr{2}); 
TFN{3} = text(TextFN.X(3)-1.5*TextFN.XOffset,TextFN.Y(3)+TextFN.YOffset,TextFN.YStr{3}); 
TFN{4} = text(TextFN.X(4)-1.5*TextFN.XOffset,TextFN.Y(4)+TextFN.YOffset,TextFN.YStr{4}); 

set([TFN{1:end}], 'FontSize',15); 
%Adjust gca values 
ax_5 = gca;
ax_5.YLim = [0 max([KMT47OnlySecond_FN, KMT47Both_FN KMT47LalphaT_FN KMT47Shuff_FN])+(TextFN.YOffset*3)];
%Set style and print out 
ErcagGraphics

printfig(hf_KMT47_FN,'-dpdf',fullfile(ExpPathOnlyTwo,'BarPlotKMT47_FN.pdf'))



