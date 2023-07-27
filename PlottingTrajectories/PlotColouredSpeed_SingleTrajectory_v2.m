function PlotColouredSpeed_SingleTrajectory_v2(Bugs,varargin)


fps=Bugs.Parameters.fps;
T=1/fps;

%A small shift for the annotations on each trajectory
Eps = 3; 


%scaling conversion factors:
ScaleXY=Bugs.Parameters.Refstack.ScaleXY;
ScaleZ=Bugs.Parameters.Refstack.ScaleZ;
RoughFocus=Bugs.Parameters.Refstack.RoughFocus;


%which bugs to plot
BugSet=varargin{1};

%at what speed should the colour scale max out?
if nargin>2
    maxVcolour= varargin{2};
else
    maxVcolour=100;
end

% check for label argument
labelflagpresent=cellfun(@(x)  (ischar(x)), varargin);
if ~any(labelflagpresent)
    labelflag='labeloff';
else
    labelflag=varargin{labelflagpresent};
end


%plot details
MarkerSize= 3;
LineWidth = 2.5; 


S=Bugs.Speeds;

for i=BugSet
    
    X=S{i}(:,2:4);
    X(:,1:2)=X(:,1:2)*ScaleXY;
    X(:,3)=(X(:,3)-RoughFocus)*ScaleZ;
    n=size(X,1);
    
    dX=S{i}(:,6:8);
    V=S{i}(:,9);
    
    
    % plot track with speed colours
    plot3(X(1,1), X(1,2), X(1,3), 'ok', 'MarkerSize', MarkerSize*2, 'MarkerFaceColor','k');
    hold on;
    plot3(X(:,1), X(:,2), X(:,3), '-', 'Color',[ 0.8 0.8 0.8],'LineWidth',LineWidth);
    speedcolours=jet(maxVcolour);
    
    for j=3:(n-3)
        speedindex=max(1,min(maxVcolour, round(V(j))));
        %[X(i,1), X(i,2), X(i,3)]
        plot3(X(j,1), X(j,2), X(j,3), 'o', 'MarkerEdgeColor', speedcolours(speedindex,:),'MarkerSize', MarkerSize, 'MarkerFaceColor', speedcolours(speedindex,:));
        %quiver3(X(j,1), X(j,2), X(j,3), dX(j,1)*T, dX(j,2)*T, dX(j,3)*T, 'Color', speedcolours(speedindex,:));
        hold on
    end
    switch labelflag
        case 'label'
            text(X(1,1)+Eps, X(1,2)+Eps, X(1,3)+Eps, num2str(i), 'FontSize', 16);
    end
end
caxis([ 0 maxVcolour])
colormap jet

% check if colorbar already exists, otherwise create it
ch=get(gcf, 'Children');
chandle=findobj(ch,'Type', 'colorbar');
if isempty(chandle)
    chandle=colorbar;
    %adjust width of colorbar
%     cpos=get(chandle, 'Position');
%     %cpos(1)=cpos(1)+cpos(3)/2;
%     cpos(3)=cpos(3)/2;
%     set(chandle, 'Position', cpos);
     set(get(chandle,'title'),'String','speed (\mu{}m/s)', 'FontSize', 16);
end
hold off
KatjasGraphics
set(gca, 'DataAspectRatio', [ 1 1 1]);
axis tight
xlabel('x (\mu{}m)')
ylabel('y (\mu{}m)')
zlabel('z (\mu{}m)')
%title(['Bug ' num2str(i)]);

drawnow;
set(gca, 'Position', [ 0.15 0.15 0.6 0.8])

figure(gcf);






