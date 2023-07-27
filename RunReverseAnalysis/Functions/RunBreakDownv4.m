%% Function to structure runs in a cell labelled "Run"
%v4 - This version includes runs that have open-ends (e.g. the beginning and
%ends of trajectories) 
% Each row of the cell "Run" represents a single traj. 
% 1st column - Run duration
% 2nd column - Mean run speed
% 3rd column - Median run speed 
% 4th column - Standard deviation of the population's run speed
function [Run, RunDur] = RunBreakDownv4(S,T,fps)
         
         V = cellfun(@(x) x(:,9), S,'UniformOutput',0); %Instantaneous Speeds
         Run = cell(size(T,1),2);
         RunDur = cell(size(T,1),1); 
         for i  = 1:size(T,1)          
             %Call RunStart & RunEnd indices from "T"   
             RMat = T{i,1};
%              RunSt = T{i,2};
%              RunEnd = T{i,3};
             
             
             for j = 1:size(RMat,2)
                 RunSpeed = V{i}(RMat(:,j)); 
                    
                 Run{i,1} = [Run{i,1}; RunSpeed]; %Instantaneous speeds
                 Run{i,2}(j,1) = nanmean(RunSpeed); 
                 Run{i,2}(j,2) = nanmedian(RunSpeed); 
                 Run{i,2}(j,3) = std(RunSpeed); 
             end
             Run{i,3} = i; %Bug index
             
             
%              for k = 1:length(RunEnd)-1
%                   RunDur{i}(k) = (RunEnd(k+1) - RunSt(k))./fps;
%              end
          end
end