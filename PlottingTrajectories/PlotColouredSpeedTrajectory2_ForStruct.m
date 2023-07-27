function PlotColouredSpeedTrajectory2_ForStruct(S,varargin)
%ALL trajectories of more than 1s
%varagin : maximum speed value

colortype='point';% 'point', 'average' or 'random'

fps=S.Parameters.fps;
T=1/fps;

%scaling conversion factors:
ScaleXY=S.Parameters.Refstack.ScaleXY;
ScaleZ=S.Parameters.Refstack.ScaleZ;
RoughFocus=S.Parameters.Refstack.RoughFocus;

V=S.Speeds;
TrackTimes=cellfun(@(x) (max(x(:,1))-min(x(:,1))+1)/fps , V);
k=TrackTimes>1;

%at what speed should the colour scale max out?
if nargin>1
    maxVcolour= varargin{1};
else
    maxVcolour=100;
end
%plot details
randomind=rand(length(k),1);

for i=1:length(k)
    if k(i)
      
    X=V{i}(:,2:4);
    X(:,1:2)=X(:,1:2)*ScaleXY;
    X(:,3)=(X(:,3)-RoughFocus)*ScaleZ;    
%     X=V{i}(:,2:4);% no need for scale as the resultas are already in um  
%     X(:,2)=350-X(:,2);% correction for true orientation
%     X(:,3)=-X(:,3);% correction for true orientation
    n=size(X,1);
    
    dX=V{i}(:,6:8);
    subV=V{i}(:,9);
    
    hold on;
    %plot3(X(:,1), X(:,2), X(:,3), '-', 'Color',[ 0.8 0.8 0.8],'LineWidth',1);
    speedcolours=jet(maxVcolour);
    
    speedindex=[];
    
    switch colortype
        case 'point'
            speedindex(1)=max(1,min(maxVcolour, round( mean(subV(2:3)) )));
            speedindex(n)=max(1,min(maxVcolour, round( mean(subV((n-2):(n-1))) )));
    
            for j=2:(n-1)
                    speedindex(j)=max(1,min(maxVcolour, round(subV(j))));
            end
    
        case 'average'
            speedindex=ones(1,n)*round( nanmean(subV(2:(end-1))) );
            
        case 'random'
            speedindex=ones(1,n)*randomind(i)*maxVcolour;
    end
    
    color_line3(X(:,1), X(:,2), X(:,3),speedindex');hold on
    
    end
end

colormap jet

    if ~strcmp(colortype,'random')
        chandle=colorbar('EastOutside');
%         chandle.Position(1) = 0.1; %From left
%         chandle.Position(2) = 0.1; %From bottom
        caxis([ 0 maxVcolour]);
        colormap jet   ;
        set(get(chandle,'title'),'String','speed (\mu{}m/s)', 'FontSize', 16);
        hold off
    end
    
    %MariannesGraphics
    %drawnow; view(30,15)
    set(gca, 'DataAspectRatio', [ 1 1 1]);
    %axis tight
    axis([0 416 0 351 -110 110])
    ErcagGraphics
    xlabel('x (\mu{}m)')
    ylabel('y (\mu{}m)')
    zlabel('z (\mu{}m)')

   
  
    
    
    



