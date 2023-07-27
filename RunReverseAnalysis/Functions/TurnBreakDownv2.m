%% Function to structure turn events in a cell labelled "Turn"
% Each row of the cell "Turn" represents a single traj. 
% 1st column - Turn Duration
% 2nd column - Mean Turn Speed
% 3rd column - Median Turn Speed

function Turn = TurnBreakDownv2(T,fps)
         
         %Filter out trajectories
         %TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         %medV = cellfun(@(x) medianN(x(:,9)), S);
         
         %MaskTraj = medV > minV & TotalTime > minT;
         TSubset = T;
         %TSubset = T(MaskTraj,:);
         %SSubset = S(MaskTraj,:); 
         %Define the cell "Run"
         Turn = cell(size(TSubset,1),1);
         for i  = 1:size(TSubset,1)
             %Call RunStart & RunEnd indices from "T"
             RunSt = TSubset{i,2}; 
             RunEnd = TSubset{i,3};
             for j = 1:length(RunSt)
                 %Turn duration
                 TurnDur = (RunSt(j) - RunEnd(j))./fps;
                 %Mean Turn Speed
                 %MeanTurnS = mean(SSubset{i}(RunEnd(j):RunSt(j),9));
                 %Meadin Turn Speed 
                 %MedTurnS = median(SSubset{i}(RunEnd(j):RunSt(j),9));
                 
                 %Store the value in the cell "Run"
                 Turn{i}(j,1) = TurnDur; 
                 %Turn{i}(j,2) = MeanTurnS; 
                 %Turn{i}(j,3) = MedTurnS;
             end
             
          end
end