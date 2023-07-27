%Katja's function to analyze speed
function S=BugsToSpeeds(Bugs,varargin)


%scaling conversion factors:
ScaleXY=0.1625;
ScaleZ=0.134;

if nargin>1
    fps= varargin{1};
else
    fps=15;
end

if nargin>2
    plotmode=varargin{2};
else
    plotmode='plotoff';
end



S=cell(size(Bugs));
for i=1:length(Bugs)
    
    X=Bugs{i}(:,2:4);
    X(:,1:2)=X(:,1:2)*ScaleXY;
    X(:,3)=X(:,3)*ScaleZ;
    
    [dX, V, dAlpha]=BergVelocities(X,fps,plotmode);
    S{i}=[ Bugs{i} dX V dAlpha ];
    
    if ~strcmp(plotmode, 'plotoff')
        title(['Bug ' num2str(i) ]);
        drawnow;
        axis(gca);
        %reply=input('next?');
    end
end


