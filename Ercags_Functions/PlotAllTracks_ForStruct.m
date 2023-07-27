function total_number = PlotAllTracks_ForStruct(BugStruct,varargin)


Bugs=BugStruct.Bugs;
ScaleXY=BugStruct.Parameters.Refstack.ScaleXY;
ScaleZ=BugStruct.Parameters.Refstack.ScaleZ;

if nargin>1
    labelmode=varargin{1};
else
    labelmode='none';
end


%RoughFocus=790;
RoughFocus=BugStruct.Parameters.Refstack.RoughFocus;
%RoughFocus=873;

TrackTimes=cellfun(@(x) (max(x(:,1))-min(x(:,1))+1), Bugs);
TrackDistances=cellfun(@(x) ( sqrt( var(x(:,2))+var(x(:,3)) + var(x(:,4)))   ), Bugs);


l=TrackDistances>0;
Bugsl=Bugs(l);
BugIndeces=1:length(Bugs);
BugIndecesl=BugIndeces(l);
total_number = sum(l)

if sum(l)==1
    colours=[0,0,1];
else
    colours=jet(sum(l));
end

for i=1:length(Bugsl)
    
    x=ScaleXY*Bugsl{i}(:,2);
    y=ScaleXY*Bugsl{i}(:,3);
    z=ScaleZ*(Bugsl{i}(:,4)-RoughFocus);
    
    plot3(x,y,z, 'o-', 'Color', colours(i,:),'MarkerSize', 2);
    
    hold on;
    if strcmp(labelmode, 'label')
        text(x(1),y(1),z(1), num2str(BugIndecesl(i)));
    end
end
hold off
set(gca, 'DataAspectRatio',[ 1 1 1]);
axis([0 416 0 351 -110 110])
ErcagGraphics
xlabel('x (\mu{}m)')
ylabel('y (\mu{}m)')
zlabel('z (\mu{}m)')





