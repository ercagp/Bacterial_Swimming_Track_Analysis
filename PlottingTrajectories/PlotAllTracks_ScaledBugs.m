% Function to plot scaled bugs 
% An upgraded version of Katja's "PlotAllTracks_ForStruct"
% by Ercag 
% June 2019 

function PlotAllTracks_ScaledBugs(B_Scaled) 
%Lines from PlotAllTracks_ForStruct
TrackDistances=cellfun(@(x) ( sqrt( var(x(:,2))+var(x(:,3)) + var(x(:,4)))   ), B_Scaled);

l=TrackDistances>0;
Bugsl=B_Scaled(l);


if sum(l)==1
    colours=[0,0,1];
else
    colours=jet(sum(l));
end
%Lines from PlotAllTracks_ForStruct

figure
    for i = 1:length(Bugsl) 
    plot3(Bugsl{i}(:,2),Bugsl{i}(:,3),Bugsl{i}(:,4),'o-', 'Color', colours(i,:),...
        'MarkerSize', 2)
    hold on 
    end
hold off
set(gca, 'DataAspectRatio',[ 1 1 1]);
axis([0 416 0 351 -110 110])
KatjasGraphics
xlabel('x (\mu{}m)')
ylabel('y (\mu{}m)')
zlabel('z (\mu{}m)')
end
