function PlotColouredSpeedTrajectory(S,varargin)


%fps=S.Parameters.fps;

if nargin>1
    fps= varargin{1};
else
    fps=15;
end

% if nargin>2
%     plotmode=varargin{2};
% else
%     plotmode='plotoff';
% end

%at what speed should the colour scale max out?
if nargin>2
    maxVcolour=varargin{2};
else
    maxVcolour=50;
end


%plot details
MarkerSize=2;


%scaling conversion factors:
ScaleXY= 0.1625; %2*0.1625;
ScaleZ=0.134;
%RoughFocus=790;
%RoughFocus=873;
RoughFocus=985;
T=1/fps;




% for i=1:length(S)
    
 %   X=S{i}(:,2:4);
    X=S(:,2:4);
    X(:,1:2)=X(:,1:2)*ScaleXY;
    X(:,3)=(X(:,3)-RoughFocus)*ScaleZ;
    n=size(X,1);
    
    %dX=S{i}(:,6:8);
    V=S(:,9);
    
    
    % plot track with speed colours
    plot3(X(1,1), X(1,2), X(1,3), 'ok', 'MarkerSize', MarkerSize*2, 'MarkerFaceColor','k');
    hold on;
    plot3(X(:,1), X(:,2), X(:,3), '-', 'Color',[ 0.8 0.8 0.8]);
    speedcolours=jet(maxVcolour);
    
    for j=3:(n-3)
        speedindex=max(1,min(maxVcolour, round(V(j))));
        %[X(i,1), X(i,2), X(i,3)]
        plot3(X(j,1), X(j,2), X(j,3), 'o', 'MarkerEdgeColor', speedcolours(speedindex,:),'MarkerSize', MarkerSize, 'MarkerFaceColor', speedcolours(speedindex,:));
        %quiver3(X(j,1), X(j,2), X(j,3), dX(j,1)*T, dX(j,2)*T, dX(j,3)*T, 'Color', speedcolours(speedindex,:));
        hold on
    end
    caxis([ 0 maxVcolour])
    colormap jet
    chandle=colorbar;
    %adjust width of colorbar
    cpos=get(chandle, 'Position');
    %cpos(1)=cpos(1)+cpos(3)/2;
    cpos(3)=cpos(3)/2;
    set(chandle, 'Position', cpos);
    set(get(chandle,'title'),'String','speed (\mu{}m/s)', 'FontSize', 16);
    hold off
    KatjasGraphics
    set(gca, 'DataAspectRatio', [ 1 1 1]);
    axis tight
    xlabel('x (\mu{}m)')
    ylabel('y (\mu{}m)')
    zlabel('z (\mu{}m)')
    %title(['Bug ' num2str(i)]);
%     drawnow;
%     if length(S)>1
%         input('next?');
%     end
    figure(gcf);
    
    
    
%end


