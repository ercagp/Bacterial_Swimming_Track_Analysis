%% Function to structure runs in a cell labelled "Run"
% Each row of the cell "Run" represents a single traj. 
% 1st column - Run duration
% 2nd column - Mean run speed
% 3rd column - Median run speed 
% 4th column - Standard deviation of the population's run speed
function Run = RunBreakDown(S,R,fps)
         %Parameters
         T = R.T;
         minV = R.minV; 
         minT = R.minT; 

         %Filter out trajectories
         %TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         %medV = cellfun(@(x) medianN(x(:,9)), S);
         
         %MaskTraj = medV > minV & TotalTime > minT;
         TSubset = T; %T(MaskTraj,:);
         SSubset = S; %S(MaskTraj,:); 
         %Define the cell "Run"
         Run = cell(size(TSubset,1),1);
         for i  = 1:size(TSubset,1)
             %Call RunStart & RunEnd indices from "T"
             RunSt = TSubset{i,2}; 
             RunEnd = TSubset{i,3};
             
             for j = 1:length(RunEnd)-1
                 %Calculate run duration
                 RunDur = (RunEnd(j+1) - RunSt(j))./fps;
                 %Mean speed of the run 
                 MeanRunS = mean(SSubset{i}(RunSt(j):RunEnd(j+1)-1,9));
                 %Median speed of the run 
                 MedRunS = median(SSubset{i}(RunSt(j):RunEnd(j+1)-1,9));
                 %Standard deviation of the run speed
                 StdRunS = std(SSubset{i}(RunSt(j):RunEnd(j+1)-1,9));
                 
                 %Store the value in the cell "Run"
                 Run{i}(j,1) = RunDur; 
                 Run{i}(j,2) = MeanRunS; 
                 Run{i}(j,3) = MedRunS;
                 Run{i}(j,4) = StdRunS;
             end
             
          end
end