close all; 
EdgesTurn = 1/30:1/30:0.4; 
TA = cell2mat(TurnAngle); 
Turn = cell2mat(Turns); 

[N,Edges,Bin] = histcounts(TA,length(EdgesTurn)-1);
[NT, EdgesT,BinT] = histcounts(Turn,EdgesTurn);
figure 
histogram(TA,Edges)
figure 
histogram(Turn,EdgesT);

for i = 1:length(EdgesT)-1
    TotalTurnBin = sum(Turn(BinT == i));
    display(TotalTurnBin)
    N_TA_Norm(i) = N(i) / TotalTurnBin; 
    
end

figure
histogram('BinEdges',Edges,'BinCounts',N_TA_Norm)
