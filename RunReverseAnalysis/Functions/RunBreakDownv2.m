%% Function to structure runs in a cell labelled "Run"
% Each row of the cell "Run" represents a single traj. 
% 1st column - Run duration
% 2nd column - Mean run speed
% 3rd column - Median run speed 
% 4th column - Standard deviation of the population's run speed
function Run = RunBreakDownv2(S,T,fps)
         
         %Filter out trajectories
         %TotalTime = cellfun(@(x) length(x(:,1)).*1/fps,S); 
         %medV = cellfun(@(x) medianN(x(:,9)), S);
         
         %MaskTraj = medV > minV & TotalTime > minT;
         %BugInd = find(MaskTraj);
         
         %TSubset = T(MaskTraj,:);
         %SSubset = S(MaskTraj,:); 
         %Define the cell "Run"
         %Run = cell(size(TSubset,1),3);
         Run = cell(size(T,1),3);
         
         for i  = 1:size(T,1)%size(TSubset,1)             
             %Call RunStart & RunEnd indices from "T"   
             RunSt = T{i,2};%TSubset{i,2}; 
             RunEnd = T{i,3}; %TSubset{i,3};
             
             for j = 1:length(RunEnd)-1
                 %Calculate instantaneous run speeds
                 RunSpeed = S{i}(RunSt(j):RunEnd(j+1)-1,9);%SSubset{i}(RunSt(j):RunEnd(j+1)-1,9);
                 %Calculate run duration
                 RunDur = (RunEnd(j+1) - RunSt(j))./fps;
                 %Mean speed of the run 
                 MeanRun = mean(S{i}(RunSt(j):RunEnd(j+1)-1,9));%mean(SSubset{i}(RunSt(j):RunEnd(j+1)-1,9));
                 %Median speed of the run 
                 MedRun = median(S{i}(RunSt(j):RunEnd(j+1)-1,9));%median(SSubset{i}(RunSt(j):RunEnd(j+1)-1,9));
                 %Standard deviation of the run speed
                 StdRun = std(S{i}(RunSt(j):RunEnd(j+1)-1,9)); %std(SSubset{i}(RunSt(j):RunEnd(j+1)-1,9));
                 
                 %Store the value in the cell "Run"
                 Run{i,1}(j,1) = RunDur; 
                 Run{i,1}(j,2) = MeanRun; 
                 Run{i,1}(j,3) = MedRun;
                 Run{i,1}(j,4) = StdRun;
                 
                 %Instantaneous run speeds 
                 Run{i,2} = [Run{i,2}; RunSpeed];
             end
                 Run{i,3} = i;%BugInd(i); %Index of the bug   
          end
end