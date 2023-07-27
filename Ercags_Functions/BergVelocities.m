function [dX, V, dAlpha]=BergVelocities(X,fps,varargin)
%computes velocities and angular changes like Berg and Brown 1972



if nargin>2
    plotmode=varargin{1};
else
    plotmode='plotoff';
end


T=1/fps; %number of seconds between frames

n=size(X,1);
dX=NaN(n,3);
dAlpha=NaN(n,1);
V=NaN(n,1);

for i=3:(n-2)
    dX(i,:)= 2/(3*T)*( X(i+1,:)-X(i-1,:) ) - 1/(12*T)*( X(i+2,:)-X(i-2,:) ) ;
    V(i)= sqrt( sum( dX(i,:).^2) );
    
end

for i=3:(n-3)
    
    dAlpha(i)=acosd( sum(dX(i,:).*dX(i+1,:)) / (V(i)*V(i+1)) );
    dAlpha(i)=real(dAlpha(i)); % in rate circumstances, numerical errors lead to a tiny imaginary contribution
end

if ~strcmp(plotmode,'plotoff')
    % plot track with speed colours
    plot3(X(:,1), X(:,2), X(:,3), '-', 'Color',[ 0.8 0.8 0.8]);
    hold on;
    speedcolours=ametrine(50);
    
    for i=3:(n-3)
        speedindex=max(1,min(50, round(V(i))));
        %[X(i,1), X(i,2), X(i,3)]
        plot3(X(i,1), X(i,2), X(i,3), 'o', 'MarkerEdgeColor', speedcolours(speedindex,:), 'MarkerSize',4);
        quiver3(X(i,1), X(i,2), X(i,3), dX(i,1)*T, dX(i,2)*T, dX(i,3)*T, 'Color', speedcolours(speedindex,:));
        hold on
    end
    caxis([ 0 50])
    colormap ametrine
    chandle=colorbar;
    set(get(chandle,'title'),'String','speed (\mu{}m/s)', 'FontSize', 16);
    hold off
    KatjasGraphics
    axis tight
    set(gca, 'DataAspectRatio', [ 1 1 1]);
    xlabel('x (\mu{}m)')
    ylabel('y (\mu{}m)')
    zlabel('z (\mu{}m)')
    drawnow;
    
   
    
end



