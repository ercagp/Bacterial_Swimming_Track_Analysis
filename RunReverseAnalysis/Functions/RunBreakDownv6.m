%% Function to structure runs(complete+incomplete) in a cell labelled "Run"
%v6 - This version stores instantaneous speeds of each run as a separate
%vector

% Each row of the cell "Run" represents a single traj. 
% 1st column - Instantaneous speeds
% 2nd column - Average values and run duration matrix per bug (AvMat)* 
% 3rd column - Bug Index 

% *1st Column of the "AvMat" - Run durations 
%  2nd Column of the "AvMat" - Mean speed value of each run 
%  3rd Column of the "AvMat" - Median speed value of each run 
%  4th Column of the "AvMat" - Standard deviation of speed of each run 
function Run = RunBreakDownv6(S,T,fps)
         
         V = cellfun(@(x) x(:,9), S,'UniformOutput',0); %Instantaneous Speeds
         Run = cell(size(T,1),2);
         
         for i  = 1:size(T,1)          
             RMat = T{i,1}; %Run matrix  

             for j = 1:size(RMat,2)
                 RunSpeed = V{i}(RMat(:,j)); 
                 
                 Run{i,1}{j,1} = RunSpeed; %Instantaneous Speeds
                 %AvMat
                 Run{i,2}(j,1) = sum(RMat(:,j))./fps;  %Run durations  
                 Run{i,2}(j,2) = nanmean(RunSpeed); % Mean run speeds
                 Run{i,2}(j,3) = nanmedian(RunSpeed); % Median run speeds
                 Run{i,2}(j,4) = std(RunSpeed); % Std of the run speeds
             end
             Run{i,3} = i; %Bug index
             
          end
end