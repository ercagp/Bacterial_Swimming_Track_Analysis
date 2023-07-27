%Calculate MSD and plot it for each trajectory 
close all; 
clearvars -except B_Smooth


%Select the number of bugs
bug_i = 436; 

B = B_Smooth;

%Gathering X,Y,Z coordinates
Bugs=B.Bugs;
ScaleXY=B.Parameters.Refstack.ScaleXY;
ScaleZ=B.Parameters.Refstack.ScaleZ;
RoughFocus=B.Parameters.Refstack.RoughFocus;
fps = B.Parameters.fps;

x=ScaleXY*Bugs{bug_i}(:,2);
y=ScaleXY*Bugs{bug_i}(:,3);
z=ScaleZ*(Bugs{bug_i}(:,4)-RoughFocus);

r = sqrt(x.^2 + y.^2  + z.^2); 
tau_i = length(r)+1;

for i = tau_i  
MSD_bug(i) = MSD(r,i,fps);
end

tau = tau_i./fps;

plot(tau,MSD_bug,'.')

ax = gca; 
%ax.YScale = 'log';
%ax.XScale = 'log';