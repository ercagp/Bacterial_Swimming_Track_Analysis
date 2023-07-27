%Function to scale trajectories in "Bugs" structure
function Bugs_Scaled = ScaleTraj(B)
%Call the parameters
ScaleXY=B.Parameters.Refstack.ScaleXY;
ScaleZ=B.Parameters.Refstack.ScaleZ;
RoughFocus=B.Parameters.Refstack.RoughFocus;
%
X = cellfun(@(x) x(:,2).*ScaleXY, B.Bugs,'UniformOutput',0);
Y = cellfun(@(x) x(:,3).*ScaleXY, B.Bugs,'UniformOutput',0);
Z = cellfun(@(x) (x(:,4)-RoughFocus).*ScaleZ, B.Bugs,'UniformOutput',0);
N = cellfun(@(x) x(:,1), B.Bugs,'UniformOutput',0);
SD = cellfun(@(x) x(:,5), B.Bugs,'UniformOutput',0);

Bugs_Scaled = cellfun(@(n,x,y,z,sd) [n,x,y,z,sd], N,X,Y,Z,SD,'UniformOutput',0);
end