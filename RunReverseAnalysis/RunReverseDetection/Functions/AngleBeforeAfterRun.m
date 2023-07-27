function [AngleBefore, AngleAfter] = AngleBeforeAfterRun(RunEnd,TurnAngle)
         
         Limit = length(RunEnd)-1;
         
         AngleBefore = zeros(1,Limit);
         AngleAfter = zeros(1,Limit);
         
         if Limit == 0 
            AngleBefore(1) = TurnAngle(RunEnd(1));
            %AngleAfter(1) = dAlpha(RunEnd(i+1)); 
         else
            for i = 1:Limit
                AngleBefore(i) = TurnAngle(RunEnd(i));
                AngleAfter(i) = TurnAngle(RunEnd(i+1)); 
            end
         end
end