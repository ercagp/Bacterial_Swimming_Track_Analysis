%% Check problems with Turn Frequency and Event Rate calculations 
% May 2021 
% by Ercag 
clearvars; 
close all; 
%% Load Run-Reverse Data Files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/RunReverseAnalysis/';
StrainLabels = {'KMT43'}; %{'KMT43','KMT47','KMT53','KMT48'}; 
Lambda = 0.5; 
fps = 30; %Hz


k = 1; 
for j = 1:length(StrainLabels) 
    %Find .mat files
    Files = callResultsv2(MainPath, StrainLabels{j},Lambda);

    IPTG = zeros(length(Files),1);
    EventRate = zeros(length(Files),1); 
    TurnFreq = zeros(length(Files),1); 
    TurnFreq_Correct = zeros(length(Files),1); 
    TurnSum = zeros(length(Files),1);
    
        for i = 1:length(Files) 
            %Load file and calculate turn event rates
            load(Files{i})    
            IPTG(i) = RunReverse.Info.IPTG;
            %% Event Rate
            EventRate(i) = RunReverse.EventRate;
            
            %% Turn Frequency 
            %Total # of turns 
            TurnSum(i) = RunReverse.TotalTurns;
            FltMask =  filterout(Speeds,Results.minT,Results.minV,fps);
            SpeedSubset = Speeds(FltMask); 
            [TMask, TFlt] = filteroutTurn(Results.T,FltMask);
            TrajDur(i) = sum(cellfun(@(x) size(x(:,1),1)./fps,SpeedSubset(TMask)));                                      
            %Frequency 
            TurnFreq(i) = TurnSum(i)/TrajDur(i);
            
            %% Correct Turn Frequency 
            FltMask =  filterout(Speeds,Results.minT,Results.minV,fps);
            SpeedSubset = Speeds(FltMask); 
            TrajDur_Correct(i) = sum(cellfun(@(x) size(x(:,1),1)./fps,SpeedSubset));                                      
            %Frequency 
            TurnFreq_Correct(i) = TurnSum(i)/TrajDur_Correct(i);
        end
end


%% Functions 
function [FilterMask] = filterout(S,minT,minV,fps)

         %Filter out trajectories
         TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         medV = cellfun(@(x) medianN(x(:,9)), S);
        
         FilterMask = medV > minV & TotalTime > minT;
         %SSubset = S(FilterMask); 
end



function [TurnFltMask,TFinal] = filteroutTurn(T,InitialFilter)
         
         TFlt = T(InitialFilter,:);
         TurnFltMask = ~cellfun(@(x) isempty(x), TFlt(:,3));
         TFinal = TFlt(TurnFltMask,:); 
end

    
