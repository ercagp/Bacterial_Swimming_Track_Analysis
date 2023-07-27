%Calculate MSD and plot it for each trajectory 
close all; 
clearvars -except B_Smooth


%Select the numbers of bugs
bug_i = [38,44,114,116,289,374,514,524,525,599,638,825,833,853,883]; 
%Set the colormap 
c_map = colormap(colorcube(length(bug_i)));
c_map = mat2cell(c_map, ones(size(c_map,1),1));

B = B_Smooth;

%Gathering X,Y,Z coordinates
Bugs=B.Bugs;
ScaleXY=B.Parameters.Refstack.ScaleXY;
ScaleZ=B.Parameters.Refstack.ScaleZ;
RoughFocus=B.Parameters.Refstack.RoughFocus;
fps = B.Parameters.fps;

h_fig = figure;

i_loop = 1;
for i = bug_i
x=ScaleXY*Bugs{i}(:,2);
y=ScaleXY*Bugs{i}(:,3);
z=ScaleZ*(Bugs{i}(:,4)-RoughFocus);

r = sqrt(x.^2 + y.^2  + z.^2); 

tau_i = 1:100;

    for j = tau_i
    MSD_bug{i}(j) = MSD(r,j,fps);
    end

tau = tau_i./fps;

p{i_loop} = plot(tau,MSD_bug{i},'.','MarkerSize',13,...
    'Color',c_map{i_loop});

legendtext{i_loop} = num2str(i);
hold on
i_loop = i_loop + 1; 
end

legend(legendtext)
hold off 

ax = gca; 
%ax.YScale = 'log';
%ax.XScale = 'log';