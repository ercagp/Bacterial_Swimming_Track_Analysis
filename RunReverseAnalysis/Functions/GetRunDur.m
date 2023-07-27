%% Function to get the run duration from the "T" cell
% Main difference from RunBreakDown ==> This script takes ONLY the COMPLETE
% runs in a given trajectory 
% - January 2021
% - by Ercag
function RunDur = GetRunDur(T,fps)
         RunDur = cell(size(T,1),1);
         for i  = 1:size(T,1)
             RunEnd = T{i,3}; 
             RunStart = T{i,2};
             %If the trajectory ends with a turn 
             if length(RunEnd) > length(RunStart) 
                RunDur{i} = (RunEnd(2:end) - RunStart(1:end))./fps; 
             else
                RunDur{i} = (RunEnd(2:end) - RunStart(1:end-1))./fps;
             end
         end
         RunDur = cellfun(@transpose,RunDur,'UniformOutput',0);
          %rectify cell2mat error by transposing empty matrices 
%         Mask = cellfun(@isempty,RunDur);
%         RunDur(Mask) = cellfun(@transpose,RunDur(Mask),'UniformOutput',0);
end