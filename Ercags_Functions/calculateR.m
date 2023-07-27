function r = calculateR(B)

%Gathering X,Y,Z coordinates and other parameters
%Bugs=B.Bugs;
ScaleXY=B.Parameters.Refstack.ScaleXY;
ScaleZ=B.Parameters.Refstack.ScaleZ;
RoughFocus=B.Parameters.Refstack.RoughFocus;

%Scale X,Y,Z coordinates to microns 
   
xyz_cell = cellfun(@(x) [x(:,2)*ScaleXY, x(:,3)*ScaleXY,(x(:,4)-RoughFocus)*ScaleZ], B.Bugs,'UniformOutput',false);
%Calculate r matrices 
r = cellfun(@(xyz) sqrt(xyz(:,1).^2 + xyz(:,2).^2 + xyz(:,3).^2),xyz_cell,'UniformOutput',false); 


%    x=ScaleXY*Bugs{i}(:,2);
%    y=ScaleXY*Bugs{i}(:,3);
%    z=ScaleZ*(Bugs{i}(:,4)-RoughFocus);
%    r{i,:} = sqrt(x.^2 + y.^2  + z.^2);
%    
% scaled_cell(:,1) = cellfun(@(x) x(:,2)*ScaleXY, Bugs,'UniformOutput',false);
% scaled_cell(:,2) = cellfun(@(y) y(:,3)*ScaleXY, Bugs,'UniformOutput',false);
% scaled_cell(:,3) = cellfun(@(z) (z(:,4)-RoughFocus)*ScaleZ, Bugs,'UniformOutput',false);

end