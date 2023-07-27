%% Function to structure runs in a cell labelled "Run"
% Each row of the cell "Run" represents a single traj. 
% 1st column - Instantaneous speeds
% 2nd column - Average values and run duration matrix per bug (AvMat)* 
% 3rd column - Bug Index 

% *1st Column of the "AvMat" - Run durations 
%  2nd Column of the "AvMat" - Mean speed value of each run 
%  3rd Column of the "AvMat" - Median speed value of each run 
%  4th Column of the "AvMat" - Standard deviation of speed of each run 
function Run = RunBreakDownv3(S,T,fps)
         
         Run = cell(size(T,1),3);
         
         for i  = 1:size(T,1)          
             %Call RunStart & RunEnd indices from "T"   
             RunSt = T{i,2};
             RunEnd = T{i,3};
             
             for j = 1:length(RunEnd)-1
                 %Calculate instantaneous run speeds
                 RunSpeed = S{i}(RunSt(j):RunEnd(j+1)-1,9);
                 %Calculate run duration
                 RunDur = (RunEnd(j+1) - RunSt(j))./fps;
                 %Mean speed of the run 
                 MeanRun = mean(S{i}(RunSt(j):RunEnd(j+1)-1,9));
                 %Median speed of the run 
                 MedRun = median(S{i}(RunSt(j):RunEnd(j+1)-1,9));
                 %Standard deviation of the run speed
                 StdRun = std(S{i}(RunSt(j):RunEnd(j+1)-1,9)); 
                 
                 %Instantaneous run speeds 
                 Run{i,1} = [Run{i,1}; RunSpeed];
                 
                 %Store the value in the cell "Run"
                 Run{i,2}(j,1) = RunDur; 
                 Run{i,2}(j,2) = MeanRun; 
                 Run{i,2}(j,3) = MedRun;
                 Run{i,2}(j,4) = StdRun;
                 

             end
                 Run{i,3} = i; %Index of the bug    
          end
end