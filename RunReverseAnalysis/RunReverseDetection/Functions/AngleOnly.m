function [R, runstart, runend, L, dAlpha3,FirstCond, SecondCond, BothCond]=AngleOnly(TrajValues, dAlpha, AlphaThreshold)

X = TrajValues.X;
dX = TrajValues.dX; 

%% strategy:
% A tumble starts if either:
% 2 successive angular changes > AngleThreshold  AND  both velocities < threshold
% or
% 1 angular change > AngleThreshold AND angular 3 frames change > AngleThreshold

% the thresholds need to be adjusted to the speed/ typical angular change observed in the trajectories
% method 1: adjust angular threshold according to mean angular change:

%% compute speeds
V=sqrt(sum(dX.^2,2));
%% set angular threshold
% ThreshFactorT=AlphaFactor;
% ThreshFactorR=ThreshFactorT;
% medDAlpha=medianN(dAlpha);
% stdDAlpha=stdN(dAlpha);
% stdmDAlpha=stdmN(dAlpha);
% threshangleT=medDAlpha+stdmDAlpha*ThreshFactorT;
% threshangleR=medDAlpha+stdmDAlpha*ThreshFactorR;
% threshangleT=medDAlpha+ThreshFactorT*medDAlpha;
% threshangleR=threshangleT;
threshangleT=AlphaThreshold;
threshangleR=threshangleT;
%CatchThreshold = 70; %degrees

%% set speed threshold
%ThreshFactorV=VFactor;
% ThreshSpeed=medV-sV*ThreshFactorV;
%ThreshSpeed=VThreshold;
n=size(X,1);

%initialize run and tumble matrices. Each column is an event. Overestimate
%number of events, then later throw out the rest.
R=false(n,round(n/5));

%declare beginning to be run.
R(1:2,1)=logical( [1;1]);

%% compute angular differences:
%angular differences from paired velocities:
dAlpha2=NaN(n,1);
for i=3:n-2
    %add velocities
    dX1=dX(i-2,:)+dX(i-1,:);
    dX2=dX(i,:)+dX(i+1,:);
    %compute speeds
    V1=sqrt( sum(dX1.^2));
    V2=sqrt( sum(dX2.^2));
    %compute angle between them
    dAlpha2(i)=acosd ( sum(dX1.*dX2)/(V1*V2) );
    
end

%angular differences from triple velocities:
dAlpha3=NaN(n,1);
for i=4:n-3
    %add velocities
    %add velocities
    dX1=sum(dX(i-3:i-1,:));
    dX2=sum(dX(i:i+2,:));
    %compute speeds
    V1=sqrt( sum(dX1.^2));
    V2=sqrt( sum(dX2.^2));
    %compute angle between them
    dAlpha3(i)=acosd ( sum(dX1.*dX2)/(V1*V2) ); 
end



%% logical indeces

%logical index saying whether dAlpha is larger than a threshold angle
%Berg uses 35 degrees.
%for tumbles
LalphaT=dAlpha>threshangleT;
LalphaT2=dAlpha2>threshangleT;
LalphaT3=dAlpha3>threshangleT;

%for runs
LalphaR=dAlpha>threshangleR;
LalphaR2=dAlpha2>threshangleR;
LalphaR3=dAlpha3>threshangleR;

% speed threshold
%Lspeed=V<ThreshSpeed;

%L=[Lspeed LalphaT LalphaT3];
L=[LalphaT LalphaT3];

%% do actual run/tumble detection

%collect start times of runs and tumbles
runstart=[];
runend=[];
FirstCond = []; 
SecondCond = []; 
BothCond = []; 

jr=1; %run counter
jt=0;%tumble counter
i=3;
while i<n-2 % while angular changes can be computed until n-3, escape from a tumble becomes impossible at that time.
    
    %if currently running, check for tumble (i.e. the end of a run)
    if R(i-1,jr)==1
        %Count turns
        if (LalphaT(i) && LalphaT3(i)) 
            %declare new turn: turn counter is increased by one
            jt=jt+1;
            runend=[runend i];
        else
            %otherwise declare continued run
            R(i,jr)=1;
        end
        i=i+1;
    else
        %if you're tumbling, check whether the beginning of a run
        %should be called
        % Berg:if ~any(Lalpha(i:(i+2)))
        % disp([ 'checking for run at ' num2str(i)])
        
        if ~any(LalphaR(i:(i+2)))
            %start new run
            jr=jr+1;
            
            %New assignment
            R(i,jr) = 1;
            %R(i:(i+2),jr)=1;
            
            runstart=[runstart i];
            i=i+1;
            %disp([ 'starting run at ' num2str(i)])
        else
            i=i+1;
            %disp([ 'continuing tumble at ' num2str(i)])
        end
        
        
    end
    
end

R(:,sum(R)==0)=[];
%Lines added by Ercag
% AngleSubset = dAlpha(dAlpha > CatchThreshold); 
% dAlphaIndex = find(dAlpha > CatchThreshold);
%Compare to runend vector to exclude double-detected points 
% InterSection = intersect(dAlphaIndex,runend);
%Store reversal events in a vector
% RevEvents = [runend dAlphaIndex(~ismember(dAlphaIndex,InterSection))'];
% RevEvents = sort(RevEvents); 
%RevEvents = runend; 
%Remove consecutive points 
%  if ~isempty(RevEvents)
%     RevEvents = RevEvents([~(diff(RevEvents) == 1) true]);
%  else
%     disp('No reversals detected');
%  end

%Compare two detected run-reverses and caught by secondary thresholding 
% for l = 1:length(AngleSubset)
%     
% end
end
