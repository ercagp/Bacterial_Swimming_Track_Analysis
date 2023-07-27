%% Break down the "Turn" cell 
% Each row of the cell "Turn" represents a single traj. 
% 1st column - Turn Angle 
% 2nd column - Corresponding trajectory points where the runs start
% ("RunStart")
% 3rd column - Corresponding trajectory points where the runs end
% ("RunEnd")
function TurnCell = TurnAngleBreakDown(T,TACell)
         
         RunEnd = T(:,3);
         RunStart = T(:,2);
         
         TurnAngle = TACell(:,3); %Turn Angle Cell
         
         TurnCell = cell(size(T,1),3);
         
         TurnCell(:,1) = RunEnd; 
         TurnCell(:,2) = RunStart; 
         TurnCell(:,3) = TurnAngle; 
end