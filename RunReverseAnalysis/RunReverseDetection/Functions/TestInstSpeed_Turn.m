function [SpeedBeforeRun, SpeedAfterRun] = TestInstSpeed_Turn(TurnCell,SpeedCell)
         
         InstSpeed = cellfun(@(x) x(:,9), SpeedCell,'UniformOutput',0); 
         
         SpeedBeforeRun = cell(size(TurnCell,1),1); 
         SpeedAfterRun = cell(size(TurnCell,1),1); 
         
         for i = 1:size(TurnCell,1)
             RunEnd = TurnCell{i,1};
             RunStart = TurnCell{i,2};
             
             if length(RunEnd) > length(RunStart)
                loopEnd =  length(RunEnd)-1;
             else
                loopEnd = length(RunEnd);  
             end
             
             for j = 1:loopEnd
                
                SpeedBeforeRun{i}(j,1) = InstSpeed{i}(RunEnd(j)-1);  
                SpeedAfterRun{i}(j,1) = InstSpeed{i}(RunStart(j));
             end
             
         end
         
    
end