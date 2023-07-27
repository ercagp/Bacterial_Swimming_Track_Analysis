function Theta = TurnAngle(Runs,TrajValues)
         RunStart = Runs.runstart;
         RunEnd = Runs.runend; 
         dX = TrajValues.dX;
         
         %Preallocate
         Theta = zeros(1,length(RunStart));
         for i = 1:length(RunStart)
             %Check if the bug turns at beginning of a
             %trajectory 
             if RunEnd(i) == 2  
                FirstSet = RunEnd(i)-1;
             else
                FirstSet = (RunEnd(i)-3):(RunEnd(i)-1);
             end
             SecondSet = (RunStart(i)):(RunStart(i)+2);
             %Velocity vector sum
             dX1 = sum(dX(FirstSet,:));
             dX2 = sum(dX(SecondSet,:)); 
             %Speeds
             V1 = sqrt(sum(dX1.^2));
             V2 = sqrt(sum(dX2.^2));
             %Angle between speed vectors
             Theta(i) = acosd(sum(dX1.*dX2)/(V1*V2)); 
         end   
end