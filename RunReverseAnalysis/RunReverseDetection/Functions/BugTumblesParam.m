function [T,AngleCell,ConditionCell]=BugTumblesParam(B,lTrajectory,AlphaThreshold, plotswitch,SaveFigSwitch)


Speeds = B.Speeds;
ScaleXY = B.Parameters.Refstack.ScaleXY;
ScaleZ = B.Parameters.Refstack.ScaleZ;
fps = B.Parameters.fps;
RoughFocus = B.Parameters.Refstack.RoughFocus;


T=cell(size(Speeds,1), 4);
AngleCell = cell(size(Speeds,1),5);
ConditionCell = cell(size(Speeds,1),3);

dAlphaTurns = []; 
dAlpha3Turns = []; 
ThetaTurnAll = []; 


for i = 1:length(Speeds)  
    
    %i = RandomSet 
    %size(Speeds{i},1)
    if lTrajectory(i)
        disp(['Analyzing Bug ' num2str(i)]);
        X=Speeds{i}(:,2:4);
        X(:,1:2)=X(:,1:2)*ScaleXY;
        X(:,3)=(X(:,3)-RoughFocus)*ScaleZ;
        
        dX=Speeds{i}(:,6:8);
        
        TrajValues.Length = length(Speeds{i}(:,1))./fps;
        TrajValues.X = X;
        TrajValues.dX = dX; 
        
        dAlpha=Speeds{i}(:,end);
        
        [R,runstart,runend,L,dAlpha3,FirstCond,SecondCond,BothCond]=AngleOnly(TrajValues,dAlpha,AlphaThreshold(i));
        %L(runend,:)
        %Count the numbers of points selected by First & Second conditions
        ConditionCell{i,1} = FirstCond';  
        ConditionCell{i,2} = SecondCond'; 
        ConditionCell{i,3} = BothCond';
       
        %disp(['# of points would be detected by the first criterion = ' num2str(length(cell2mat(ConditionCell(i,1))))]) 
        %disp(['# of points actually detected by the second criterion = ' num2str(length(cell2mat(ConditionCell(i,2))))]) 
        %disp(['# of points would be detected by both = ' num2str(length(cell2mat(ConditionCell(i,3))))]) 
        
     
        %Anglesbefore and after a run 
        %[AngleBefore, AngleAfter] = AngleBeforeAfterRun(runend,ThetaTurn);
        Runs.runend = runend;
        Runs.runstart = runstart;
        Runs.R = R; 
        
        %Compute turning angle
        ThetaTurn = TurnAngle(Runs,TrajValues);  

        if plotswitch
         
           %Store dAlpha & dAlpha3 at turning points 
           Angles.dAlphaTurns = [dAlphaTurns; dAlpha(runend)];
           Angles.dAlpha3Turns = [dAlpha3Turns; dAlpha3(runend)];
        
           %Store turning angles
           Angles.ThetaTurnAll = [ThetaTurnAll, ThetaTurn];
               
           %Plot bug trajectory and angle-related observables
           PlotAll_BTP(i,TrajValues,Angles,Runs,fps,SaveFigSwitch);
          
           %Plot speed analyses
           TrackSpeedAnalysis_MarkTurns(B,Runs,i,SaveFigSwitch);
           
           %Ask to switch the next bug
           QU = input('next?[Y/N]','s');
           if strcmp(QU,'N')
              error('Analysis Ended')
           end
           
        end
        T{i,1}=R;
        T{i,2}=runstart;
        T{i,3}=runend;
        T{i,4}=L;
        
        AngleCell{i,1} = dAlpha; 
        AngleCell{i,2} = dAlpha3; 
        AngleCell{i,3} = ThetaTurn'; %Turning angles 
        %AngleCell{i,4} = AngleBefore'; 
        %AngleCell{i,5} = AngleAfter'; 
        %AngleCell{i,6} = dAlpha3(runend);
        
        Rsum=sum(R,2)';
%         runstart
%         runend
%         Rsum(runend)

       

    end
    
end

end
        





