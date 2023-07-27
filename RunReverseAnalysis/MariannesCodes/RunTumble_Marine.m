% RunTumble_Marine defines what is a run and what is a reorientation event
% in a marine bacteria, based on a 3 steps definition of medA (median dAlpha
% value multiplied a given nb as a threshold)
% Currently not using speed for distinguishing run from turns
%
function [R, runstart, runend]=RunTumble_Marine(X, dX, dAlpha,fps,ThreshFactorA,varargin)
%
V=sqrt(sum(dX.^2,2));

%median speed & median angle variation per bug info
medV=nanmedian(V);sV=nanstd(V);
medA=nanmedian(dAlpha);

% Threshold factors (speed and angle variation)
%ThreshFactorA=6;
ThreshFactorV=10;%

% Minimal duration of run ? 0 is none, 1 is at least two points between two
% turns
c=1;

loop=1;
while loop<4
    loop=loop+1;


% set angular threshold 
ThreshAngle=ThreshFactorA*medA;
% set speed threshold 
ThreshSpeed=medV-sV*ThreshFactorV; %
%
n=size(X,1);

%initialize run and tumble matrices. Each column is an event. Overestimate
%number of events, then later throw out the rest.
R=false(n,round(n));

%declare beginning to be run.
R(1:2,1)=logical( [1;1]);

%keep track of tripped  thresholds
T=logical(zeros(2,3));

% For each trajectory point
Lalpha=dAlpha>ThreshAngle;% logical index saying if above threshold or not (turn or not)
Lspeed=V<ThreshSpeed;% logical index saying wether speed is lower than threshold speed or not

%collect start times of runs and tumbles
runstart=[];
runend=[];

jr=1; %run counter
jt=0;%tumble counter
i=3;
while i<n-3
    %if currently running, check for tumble (i.e. the end of a run)
    if R(i-1,jr)==1

        %tumble (run end) criterion
        if Lalpha(i)%||(Lspeed(i)
            %declare new tumble: tumble counter is increased by one
            jt=jt+1;
            runend=[ runend i];
        else
            %otherwise declare continued run
            R(i,jr)=1;
        end
        i=i+1;
    else
        %if you're tumbling, check whether the beginning of a run
        %should be called
        
        if ~any(Lalpha(i:i+c))%&&~any(Lspeed(i:i+c)%
            %start new run
            jr=jr+1;
            R(i,jr)=1;%
            runstart=[runstart i];
            i=i+1;
        else
            i=i+1;
            
        end
        
        
    end
    
end
R(:,sum(R)==0)=[];

% Now that a first iteration defined the "Runs", compute medA and medV on them only
dAlpha_Runs=[];V_Runs=[];
for i=1:size(R,2)
    dAlpha_Runs=[dAlpha_Runs; dAlpha(R(:,i))];
    V_Runs=[V_Runs; V(R(:,i))];
end

% New values for next iteration
medA=nanmedian(dAlpha_Runs);%
medV=nanmedian(V_Runs);
end



%plot track colored by run/tumble
TimeStep=1/fps;
plot3(X(:,1), X(:,2), X(:,3), 'Color', [ 0.8 0.8 0.8],'LineWidth',3);
hold on;
colourorder={ 'b', 'c'};

for i=1:size(R,2)
    j=mod(i,2)+1;    
    %plot runs
    plot3(X(R(:,i),1), X(R(:,i),2), X(R(:,i),3), 'Color', colourorder{j},'LineWidth',3);
end

for i=1:(length(runstart))
    %plot tumbles
    quiver3(X(runend(i):(runstart(i)-1),1), X(runend(i):(runstart(i)-1),2), X(runend(i):(runstart(i)-1),3),TimeStep*dX(runend(i):(runstart(i)-1),1), TimeStep*dX(runend(i):(runstart(i)-1),2), TimeStep*dX(runend(i):(runstart(i)-1),3),0, 'Color','r','LineWidth',2)
end
if ~isempty(runend) & ~isempty(runstart)
    if runend(end)>runstart(end) %if the bug tumbles at the end of the trajectory
        %quiver3(X(runend(end):(end-4),1), X(runend(end):(end-4),2), X(runend(end):(end-4),3),TimeStep*dX(runend(end):(end-4),1), TimeStep*dX(runend(end):(end-4),2), TimeStep*dX(runend(end):(end-4),3),0, 'Color','r')
        plot3(X(runend(end):(end-4),1), X(runend(end):(end-4),2), X(runend(end):(end-4),3),'ko')
    end
end

hold off
axis tight
set(gca, 'DataAspectRatio', [ 1 1 1]);
xlabel('x (\mu{}m)')
ylabel('y (\mu{}m)')
zlabel('z (\mu{}m)')


