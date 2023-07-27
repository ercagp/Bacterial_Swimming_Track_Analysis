%% Enter Data
clearvars;
close all;

%% Generic Information 
%Define acquisitions (strain details) 
KMT9.AcqInfo.Date = '20191014';
KMT9.AcqInfo.StrainLabel = 'KMT9_5mM_Glu_1';
KMT9.AcqInfo.IPTG = 0; %uM
KMT9.AcqInfo.ROI = 1; 

KMT47.AcqInfo.Date = '20191204';
KMT47.AcqInfo.StrainLabel = 'KMT47_50uM';
KMT47.AcqInfo.IPTG = 50; %uM 
KMT47.AcqInfo.ROI = 1; 

%% Cases
%Various cases I've tried to understand the run-reverse analysis
%parameters(escape criterion, tumble criteria...etc.) 

%% Both Turn Criteria are in place (all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)))  
%%%%%%%---Parameters---%%%%%%%% 
KMT9.Both.String = 'Both Turn Criteria';
KMT47.Both.String = 'Both Turn Criteria';
%The angle threshold 
KMT9.Both.Parameters.AbsT = 50; %degrees
KMT47.Both.Parameters.AbsT = 50; %degrees
%Lambda value 
KMT9.Both.Parameters.Lambda = 0.5; 
KMT47.Both.Parameters.Lambda = 0.5;
%Turn criterion 
KMT9.Both.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
KMT47.Both.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i))'; 
%Escape criterion 
KMT9.Both.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.Both.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%# of false Positive and negatives
KMT9.Both.Data.FP = 5;
KMT9.Both.Data.FN = 3;
KMT47.Both.Data.FP = 5;
KMT47.Both.Data.FN = 4;

%#of Trajectories 
KMT9.Both.Data.N = 50; 
KMT47.Both.Data.N = 50;

% Total trajectory duration 
KMT9.Both.Data.TrajDur = 169.7;%seconds 
KMT47.Both.Data.TrajDur = 210.55;%seconds 

%# of detected turns  
KMT9.Both.Data.TotalTurn = 155; 
KMT47.Both.Data.TotalTurn = 174; 
%# of turns detected by the 1st cri. (all(LalphaT(i:i+1)))
KMT9.Both.Data.FirstCri = [];
KMT47.Both.Data.FirstCri = [];
%# of turns detected by the 2nd cri. (LalphaT(i) && LalphaT3(i))
KMT9.Both.Data.SecondCri = [];
KMT47.Both.Data.SecondCri = [];

%%%%%%%---Turn analysis of all trajectories---%%%%%%%%
%Totalnumber of analyzed trajectories
KMT9.Both.Data.All.N = 1113;
KMT47.Both.Data.All.N = 635;
%# of detected turns  
KMT9.Both.Data.All.TotalTurn = 3902;
KMT47.Both.Data.All.TotalTurn = 1843;

%Total number of turns detected by the first criterion (all(LalphaT(i:i+1)))
KMT9.Both.Data.All.FirstCri = 922;
KMT47.Both.Data.All.FirstCri = 413;
%Total number of turns detected by the second criterion (LalphaT(i) && LalphaT3(i))
KMT9.Both.Data.All.SecondCri = 3854;
KMT47.Both.Data.All.SecondCri = 1807;
%# of turns detected by the 1st & 2nd cri. (all(LalphaT(i:i+1)) && (LalphaT(i) && LalphaT3(i)))
KMT9.Both.Data.All.BothCri = 874;
KMT47.Both.Data.All.BothCri = 377;
%% 1st Turn Criterion Dropped (i.e., only (LalphaT(i) && LalphaT3(i)) in place) 
%%%%%%%---Parameters---%%%%%%%% 
KMT9.Only2nd.String = 'Only Second Turn Criterion'; 
KMT47.Only2nd.String = 'Only Second Turn Criterion'; 
%The angle threshold 
KMT9.Only2nd.Parameters.AbsT = 50; %degrees
KMT47.Only2nd.Parameters.AbsT = 50; %degrees
%Lambda value 
KMT9.Only2nd.Parameters.Lambda = 0.5; 
KMT47.Only2nd.Parameters.Lambda = 0.5; 
%Turn criterion
KMT9.Only2nd.Parameters.TurnCri = 'LalphaT(i) && LalphaT3(i)'; 
KMT47.Only2nd.Parameters.TurnCri = 'LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.Only2nd.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.Only2nd.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
% Total trajectory duration 
KMT9.Only2nd.Data.TrajDur = 169.7;%seconds 
KMT47.Only2nd.Data.TrajDur = 211.41;%seconds 
%#of Trajectories 
KMT9.Only2nd.Data.N = 50; 
KMT47.Only2nd.Data.N = 50;
%# of detected turns  
KMT9.Only2nd.Data.TotalTurn = 151; 
KMT47.Only2nd.Data.TotalTurn = 171; 
%False Positives and negatives
KMT9.Only2nd.Data.FP = 3;
KMT9.Only2nd.Data.FN = 2;
KMT47.Only2nd.Data.FP = 6;
KMT47.Only2nd.Data.FN = 3;

%# of turns detected by the 1st cri. (all(LalphaT(i:i+1)))
KMT9.Only2nd.Data.FirstCri = 31;
KMT47.Only2nd.Data.FirstCri = 36;
%# of turns detected by the 2nd cri. (LalphaT(i) && LalphaT3(i))
KMT9.Only2nd.Data.SecondCri = 151;
KMT47.Only2nd.Data.SecondCri = 171;
%# of turns detected by the 1st & 2nd cri. (all(LalphaT(i:i+1)) && (LalphaT(i) && LalphaT3(i)))
KMT9.Only2nd.Data.BothCri = 30;
KMT47.Only2nd.Data.BothCri = 35;

%%%%%%%---Turn analysis of all trajectories---%%%%%%%%
%Totalnumber of analyzed trajectories
KMT9.Only2nd.Data.All.N = 1113;
KMT47.Only2nd.Data.All.N = 635;

%# of detected turns  
KMT9.Only2nd.Data.All.TotalTurn = 3880;
KMT47.Only2nd.Data.All.TotalTurn = 1826;

%# of turns detected by the 1st criterion (all(LalphaT(i:i+1)))
KMT9.Only2nd.Data.All.FirstCri = 932;
KMT47.Only2nd.Data.All.FirstCri = 421;

%# of turns detected by the 2nd criterion (LalphaT(i) && LalphaT3(i))
KMT9.Only2nd.Data.All.SecondCri = 1113;
KMT47.Only2nd.Data.All.SecondCri = 1826;

%# of turns detected by the 1st & 2nd cri. (all(LalphaT(i:i+1)) && (LalphaT(i) && LalphaT3(i)))
KMT9.Only2nd.Data.All.BothCri = 881;
KMT47.Only2nd.Data.All.BothCri = 381;

%% Only LalphaT (i.e.LalphaT(i))
%%%%%%%---Parameters---%%%%%%%% 
KMT9.LalphaT.String = 'Only LalphaT';
KMT47.LalphaT.String = 'Only LalphaT';
%The angle threshold 
KMT9.LalphaT.Parameters.AbsT = 50; %degrees
KMT47.LalphaT.Parameters.AbsT = 50; %degrees
%Turn criterion
KMT9.LalphaT.Parameters.TurnCri = 'LalphaT(i)'; 
KMT47.LalphaT.Parameters.TurnCri = 'LalphaT(i)';
%Escape criterion 
KMT9.LalphaT.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.LalphaT.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
% Total trajectory duration 
KMT9.LalphaT.Data.TrajDur = 169.7;%seconds 
KMT47.LalphaT.Data.TrajDur = 211.41;%seconds 
%#of Trajectories 
KMT9.LalphaT.Data.N = 50; 
KMT47.LalphaT.Data.N = 50;
%# of detected turns  
KMT9.LalphaT.Data.TotalTurn = 159; 
KMT47.LalphaT.Data.TotalTurn = 182; 

%# of False positive and negatives 
KMT9.LalphaT.Data.FP = 3;
KMT9.LalphaT.Data.FN = 1;
KMT47.LalphaT.Data.FP = 8;
KMT47.LalphaT.Data.FN = 4;

%%%%%%%---Turn analysis of all trajectories---%%%%%%%%
%Totalnumber of analyzed trajectories
KMT9.LalphaT.Data.All.N = 1113;
KMT47.LalphaT.Data.All.N = 635;

%# of detected turns  
KMT9.LalphaT.Data.All.TotalTurn = 4034;
KMT47.LalphaT.Data.All.TotalTurn = 1935;

%% Buglist shuffled 
%%%%%%%---Parameters---%%%%%%%% 
KMT9.BugLShuff.String = 'Random trajectories(not in order)';
KMT47.BugLShuff.String = 'Random trajectories(not in order)';
%The angle threshold 
KMT9.BugLShuff.Parameters.AbsT = 50; %degrees
KMT47.BugLShuff.Parameters.AbsT = 50; %degrees
%Lambda value 
KMT9.BugLShuff.Parameters.Lambda = 0.5; %degrees
KMT47.BugLShuff.Parameters.Lambda = 0.5; %degrees
%Turn Criterion 
KMT9.BugLShuff.Parameters.TurnCri = 'LalphaT(i) && LalphaT3(i)'; 
KMT47.BugLShuff.Parameters.TurnCri = 'LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.BugLShuff.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.BugLShuff.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
% Total trajectory duration 
KMT9.BugLShuff.Data.TrajDur = 197.86;%seconds 
KMT47.BugLShuff.Data.TrajDur = 194.06;%seconds 
%#of Trajectories 
KMT9.BugLShuff.Data.N = 50; 
KMT47.BugLShuff.Data.N = 50;
%False positive and negatives 
KMT9.BugLShuff.Data.FP = 2;
KMT9.BugLShuff.Data.FN = 2;
KMT47.BugLShuff.Data.FP = 9;
KMT47.BugLShuff.Data.FN = 4;
%# of detected turns  
KMT9.BugLShuff.Data.TotalTurn = 156;
KMT47.BugLShuff.Data.TotalTurn = 122;
%# of turns detected by the 1st cri. (all(LalphaT(i:i+1)))
KMT9.BugLShuff.Data.FirstCri = 28;
KMT47.BugLShuff.Data.FirstCri = 22;
%# of turns detected by the 2nd cri. (LalphaT(i) && LalphaT3(i))
KMT9.BugLShuff.Data.SecondCri = 158;
KMT47.BugLShuff.Data.SecondCri = 122;
%# of turns detected by the 1st & 2nd cri. (all(LalphaT(i:i+1)) && (LalphaT(i) && LalphaT3(i)))
KMT9.BugLShuff.Data.BothCri = 26;
KMT47.BugLShuff.Data.BothCri = 19;

%% Escape criteria limited -- Check two consecutive points to escape
%%%%%%%---Parameters---%%%%%%%% 
KMT9.Esc.String = 'Escape criterion reduced to two consecutive points';
KMT47.Esc.String = 'Escape criterion reduced to two consecutive points';
%The angle threshold 
KMT9.Esc.Parameters.AbsT = 50; %degrees
KMT47.Esc.Parameters.AbsT = 50; %degrees
%Lambda Value 
KMT9.Esc.Parameters.Lambda = 0.5; 
KMT47.Esc.Parameters.Lambda = 0.5; 
%Turn Criterion 
KMT9.Esc.Parameters.TurnCri = 'LalphaT(i) && LalphaT3(i)'; 
KMT47.Esc.Parameters.TurnCri = 'LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.Esc.Parameters.EscCri = '~any(LalphaR(i:(i+1)))'; 
KMT47.Esc.Parameters.EscCri = '~any(LalphaR(i:(i+1)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%#of Trajectories 
KMT9.Esc.Data.N = 50; 
KMT47.Esc.Data.N = 50;
% Total trajectory duration 
KMT9.Esc.Data.TrajDur = 169.7;%seconds 
KMT47.Esc.Data.TrajDur = 211.41;%seconds 
%# of detected turns  
KMT9.Esc.Data.TotalTurn = 158; 
KMT47.Esc.Data.TotalTurn = 182; 
%False positive and negatives 
KMT9.Esc.Data.FP = 5;
KMT9.Esc.Data.FN = 2;
KMT47.Esc.Data.FP = 9;
KMT47.Esc.Data.FN = 4;
%# of turns detected by the 1st cri. (all(LalphaT(i:i+1)))
KMT9.Esc.Data.FirstCri = 31;
KMT47.Esc.Data.FirstCri = 38;
%# of turns detected by the 2nd cri. (LalphaT(i) && LalphaT3(i))
KMT9.Esc.Data.SecondCri = 158;
KMT47.Esc.Data.SecondCri = 188;
%# of turns detected by the 1st & 2nd cri. (all(LalphaT(i:i+1)) && (LalphaT(i) && LalphaT3(i)))
KMT9.Esc.Data.BothCri = 31;
KMT47.Esc.Data.BothCri = 31;

%%%%%%%---Turn analysis of all trajectories---%%%%%%%%
%Totalnumber of analyzed trajectories
KMT9.Esc.Data.All.N = 1113;
KMT47.Esc.Data.All.N = 635;

%# of detected turns  
KMT9.Esc.Data.All.TotalTurn = 4115;
KMT47.Esc.Data.All.TotalTurn = 2057;

%# of turns detected by the 1st criterion (all(LalphaT(i:i+1)))
KMT9.Esc.Data.All.FirstCri = 970;
KMT47.Esc.Data.All.FirstCri = 463;

%# of turns detected by the 2nd criterion (LalphaT(i) && LalphaT3(i))
KMT9.Esc.Data.All.SecondCri = 4115;
KMT47.Esc.Data.All.SecondCri = 2057;

%# of turns detected by the 1st & 2nd cri. (all(LalphaT(i:i+1)) && (LalphaT(i) && LalphaT3(i)))
KMT9.Esc.Data.All.BothCri = 918;
KMT47.Esc.Data.All.BothCri = 413;

%% Minimum angle threshold 
% AbsT = 30; %degrees
%%%%%%%---Parameters---%%%%%%%% 
KMT9.MinAng{1}.String = 'Minimum angle threshold = 30 degrees';
KMT47.MinAng{1}.String = 'Minimum angle threshold = 30 degrees';
%The angle threshold 
KMT9.MinAng{1}.Parameters.AbsT = 30; %degrees
KMT47.MinAng{1}.Parameters.AbsT = 30; %degrees
%Lambda Value 
KMT9.MinAng{1}.Parameters.Lambda = 0.5; 
KMT47.MinAng{1}.Parameters.Lambda = 0.5; 
%Turn Criterion 
KMT9.MinAng{1}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
KMT47.MinAng{1}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.MinAng{1}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.MinAng{1}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%#of Trajectories 
KMT9.MinAng{1}.Data.N = 50; 
KMT47.MinAng{1}.Data.N = 50;
% Total trajectory duration 
KMT9.MinAng{1}.Data.TrajDur = 169.2;%seconds 
KMT47.MinAng{1}.Data.TrajDur = 210.55;%seconds 
%# of detected turns  
KMT9.MinAng{1}.Data.TotalTurn = 169; 
KMT47.MinAng{1}.Data.TotalTurn = 201; 
%False positive and negatives 
KMT9.MinAng{1}.Data.FP = 15;
KMT9.MinAng{1}.Data.FN = 1;
KMT47.MinAng{1}.Data.FP = 28;
KMT47.MinAng{1}.Data.FN = 3;


% AbsT = 35; %degrees
%%%%%%%---Parameters---%%%%%%%% 
KMT9.MinAng{2}.String = 'Minimum angle threshold = 35 degrees';
KMT47.MinAng{2}.String = 'Minimum angle threshold = 35 degrees';
%The angle threshold 
KMT9.MinAng{2}.Parameters.AbsT = 35; %degrees
KMT47.MinAng{2}.Parameters.AbsT = 35; %degrees
%Lambda Value 
KMT9.MinAng{2}.Parameters.Lambda = 0.5; 
KMT47.MinAng{2}.Parameters.Lambda = 0.5; 
%Turn Criterion 
KMT9.MinAng{2}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
KMT47.MinAng{2}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.MinAng{2}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.MinAng{2}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%#of Trajectories 
KMT9.MinAng{2}.Data.N = 50; 
KMT47.MinAng{2}.Data.N = 50;
% Total trajectory duration 
KMT9.MinAng{2}.Data.TrajDur = 169.5;%seconds 
KMT47.MinAng{2}.Data.TrajDur = 210.55;%seconds 
%# of detected turns  
KMT9.MinAng{2}.Data.TotalTurn = 164; 
KMT47.MinAng{2}.Data.TotalTurn = 196; 
%False positive and negatives 
KMT9.MinAng{2}.Data.FP = 13;
KMT9.MinAng{2}.Data.FN = 1;
KMT47.MinAng{2}.Data.FP = 18;
KMT47.MinAng{2}.Data.FN = 6;

% AbsT = 40; %degrees
%%%%%%%---Parameters---%%%%%%%% 
KMT9.MinAng{3}.String = 'Minimum angle threshold = 40 degrees';
KMT47.MinAng{3}.String = 'Minimum angle threshold = 40 degrees';
%The angle threshold 
KMT9.MinAng{3}.Parameters.AbsT = 40; %degrees
KMT47.MinAng{3}.Parameters.AbsT = 40; %degrees
%Lambda Value 
KMT9.MinAng{3}.Parameters.Lambda = 0.5; 
KMT47.MinAng{3}.Parameters.Lambda = 0.5; 
%Turn Criterion 
KMT9.MinAng{3}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
KMT47.MinAng{3}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.MinAng{3}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.MinAng{3}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%#of Trajectories 
KMT9.MinAng{3}.Data.N = 50; 
KMT47.MinAng{3}.Data.N = 50;
% Total trajectory duration 
KMT9.MinAng{3}.Data.TrajDur = 169.7;%seconds 
KMT47.MinAng{3}.Data.TrajDur = 210.55;%seconds 
%# of detected turns  
KMT9.MinAng{3}.Data.TotalTurn = 161; 
KMT47.MinAng{3}.Data.TotalTurn = 190; 
%False positive and negatives 
KMT9.MinAng{3}.Data.FP = 8;
KMT9.MinAng{3}.Data.FN = 4;
KMT47.MinAng{3}.Data.FP = 11;
KMT47.MinAng{3}.Data.FN = 4;

% AbsT = 45; %degrees
%%%%%%%---Parameters---%%%%%%%% 
KMT9.MinAng{4}.String = 'Minimum angle threshold = 45 degrees';
KMT47.MinAng{4}.String = 'Minimum angle threshold = 45 degrees';
%The angle threshold 
KMT9.MinAng{4}.Parameters.AbsT = 45; %degrees
KMT47.MinAng{4}.Parameters.AbsT = 45; %degrees
%Lambda Value 
KMT9.MinAng{4}.Parameters.Lambda = 0.5; 
KMT47.MinAng{4}.Parameters.Lambda = 0.5; 
%Turn Criterion 
KMT9.MinAng{4}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
KMT47.MinAng{4}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.MinAng{4}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.MinAng{4}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%#of Trajectories 
KMT9.MinAng{4}.Data.N = 50; 
KMT47.MinAng{4}.Data.N = 50;
% Total trajectory duration 
KMT9.MinAng{4}.Data.TrajDur = 169.87;%seconds 
KMT47.MinAng{4}.Data.TrajDur = 210.55;%seconds 
%# of detected turns  
KMT9.MinAng{4}.Data.TotalTurn = 157; 
KMT47.MinAng{4}.Data.TotalTurn = 181; 
%False positive and negatives 
KMT9.MinAng{4}.Data.FP = 6;
KMT9.MinAng{4}.Data.FN = 5;
KMT47.MinAng{4}.Data.FP = 9;
KMT47.MinAng{4}.Data.FN = 7;

% AbsT = 50; %degrees
%%%%%%%---Parameters---%%%%%%%% 
KMT9.MinAng{5}.String = 'Minimum angle threshold = 50 degrees';
KMT47.MinAng{5}.String = 'Minimum angle threshold = 50 degrees';
%The angle threshold 
KMT9.MinAng{5}.Parameters.AbsT = 50; %degrees
KMT47.MinAng{5}.Parameters.AbsT = 50; %degrees
%Lambda Value 
KMT9.MinAng{5}.Parameters.Lambda = 0.5; 
KMT47.MinAng{5}.Parameters.Lambda = 0.5; 
%Turn Criterion 
KMT9.MinAng{5}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
KMT47.MinAng{5}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.MinAng{5}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.MinAng{5}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%#of Trajectories 
KMT9.MinAng{5}.Data.N = 50; 
KMT47.MinAng{5}.Data.N = 50;
% Total trajectory duration 
KMT9.MinAng{5}.Data.TrajDur = 169.7;%seconds 
KMT47.MinAng{5}.Data.TrajDur = 210.55;%seconds 
%# of detected turns  
KMT9.MinAng{5}.Data.TotalTurn = 155; 
KMT47.MinAng{5}.Data.TotalTurn = 174; 
%False positive and negatives 
KMT9.MinAng{5}.Data.FP = 5;
KMT9.MinAng{5}.Data.FN = 3;
KMT47.MinAng{5}.Data.FP = 4;
KMT47.MinAng{5}.Data.FN = 5;

% AbsT = 55; %degrees
%%%%%%%---Parameters---%%%%%%%% 
KMT9.MinAng{6}.String = 'Minimum angle threshold = 55 degrees';
KMT47.MinAng{6}.String = 'Minimum angle threshold = 55 degrees';
%The angle threshold 
KMT9.MinAng{6}.Parameters.AbsT = 55; %degrees
KMT47.MinAng{6}.Parameters.AbsT = 55; %degrees
%Lambda Value 
KMT9.MinAng{6}.Parameters.Lambda = 0.5; 
KMT47.MinAng{6}.Parameters.Lambda = 0.5; 
%Turn Criterion 
KMT9.MinAng{6}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
KMT47.MinAng{6}.Parameters.TurnCri = 'all(LalphaT(i:i+1)) || (LalphaT(i) && LalphaT3(i)'; 
%Escape criterion 
KMT9.MinAng{6}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 
KMT47.MinAng{6}.Parameters.EscCri = '~any(LalphaR(i:(i+2)))'; 

%%%%%%%---Selected Trajectories---%%%%%%%% 
%#of Trajectories 
KMT9.MinAng{6}.Data.N = 50; 
KMT47.MinAng{6}.Data.N = 50;
% Total trajectory duration 
KMT9.MinAng{6}.Data.TrajDur = 169.7;%seconds 
KMT47.MinAng{6}.Data.TrajDur = 210.55;%seconds 
%# of detected turns  
KMT9.MinAng{6}.Data.TotalTurn = 142; 
KMT47.MinAng{6}.Data.TotalTurn = 169; 
%False positive and negatives 
KMT9.MinAng{6}.Data.FP = 2;
KMT9.MinAng{6}.Data.FN = 2;
KMT47.MinAng{6}.Data.FP = 4;
KMT47.MinAng{6}.Data.FN = 6;

%% Save the workspace
%Export Path
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/QualityControl';
FileName = '[QC]RunReverseAnalysis_allData_KMT47_KMT9.mat';
save(fullfile(ExpPath,FileName))

