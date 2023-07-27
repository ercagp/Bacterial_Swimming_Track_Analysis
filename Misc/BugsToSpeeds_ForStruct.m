%Katja's function to analyze speeds 
function S=BugsToSpeeds_ForStruct(B,varargin)


%scaling conversion factors:
ScaleXY=B.Parameters.Refstack.ScaleXY;
ScaleZ=B.Parameters.Refstack.ScaleZ;

fps=B.Parameters.fps;

if nargin>1
    plotmode=varargin{1};
else
    plotmode='plotoff';
end

Bugs=B.Bugs;

Speeds=cell(size(Bugs));
for i=1:length(Bugs)
    
    X=Bugs{i}(:,2:4);
    X(:,1:2)=X(:,1:2)*ScaleXY;
    X(:,3)=X(:,3)*ScaleZ;
    
    [dX, V, dAlpha]=BergVelocities(X,fps,plotmode);
    Speeds{i}=[ Bugs{i} dX V dAlpha ];
    
    if ~strcmp(plotmode, 'plotoff')
        title(['Bug ' num2str(i) ]);
        drawnow;
        axis(gca);
        %reply=input('next?');
    end
end

S.Speeds=Speeds;
S.Parameters=B.Parameters;


