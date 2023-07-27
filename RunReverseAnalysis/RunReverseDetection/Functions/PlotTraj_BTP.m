function hf_PlotTraj = PlotTraj_BTP(TrajValues,Runs,fps)
X = TrajValues.X;
dX = TrajValues.dX; 
runend = Runs.runend;
runstart = Runs.runstart;
R = Runs.R; 

hf_PlotTraj = figure(1);


%plot track colored by run/tumble
T=1/fps;
plot3(X(:,1), X(:,2), X(:,3), 'Color', [ 0.8 0.8 0.8],'LineWidth',3);
hold on;
%Lines added by Ercag - plot the large angles 
plot3(X(runend,1),X(runend,2), X(runend,3), 'o','MarkerSize',7,'Color',rgb('Magenta'))
%First condition
%plot3(X(FirstCond,1),X(FirstCond,2),X(FirstCond,3),'o','MarkerSize',7,'Color',rgb('Lime'))
%Second condition 
%plot3(X(SecondCond,1),X(SecondCond,2),X(SecondCond,3),'o','MarkerSize',7,'Color',rgb('Magenta'))
%Both conditions
%plot3(X(BothCond,1),X(BothCond,2),X(BothCond,3),'o','MarkerSize',7,'Color',rgb('Gold'))


%Lines added by Ercag - plot the large angles 
colourorder={ 'b', 'c'};
% for i=1:length(runstart)
%     j=mod(i,2)+1;
%
%     %plot runs
%     quiver3(X(runstart(i):runend(i),1), X(runstart(i):runend(i),2), X(runstart(i):runend(i),3),T*dX(runstart(i):runend(i),1), T*dX(runstart(i):runend(i),2), T*dX(runstart(i):runend(i),3), 0, 'Color', colourorder{j});
%     hold on;
%     %plot3(X(runend(i):(runstart(i+1)-1),1), X(runend(i):(runstart(i+1)-1),2), X(runend(i):(runstart(i+1)-1),3),'or-');
% end

for i=1:size(R,2)
    j=mod(i,2)+1;
    
    %plot runs
    %quiver3(X(R(:,i),1), X(R(:,i),2), X(R(:,i),3),T*dX(R(:,i),1), T*dX(R(:,i),2), T*dX(R(:,i),3), 0, 'Color', colourorder{j});
    plot3(X(R(:,i),1), X(R(:,i),2), X(R(:,i),3),'Color', colourorder{j}) 
    hold on;
    %plot3(X(runend(i):(runstart(i+1)-1),1), X(runend(i):(runstart(i+1)-1),2), X(runend(i):(runstart(i+1)-1),3),'or-');
end

for i=1:(length(runstart))
    %plot tumbles
    quiver3(X(runend(i):(runstart(i)-1),1), X(runend(i):(runstart(i)-1),2), X(runend(i):(runstart(i)-1),3),T*dX(runend(i):(runstart(i)-1),1), T*dX(runend(i):(runstart(i)-1),2), T*dX(runend(i):(runstart(i)-1),3),0, 'Color','r','LineWidth',2)
end
if ~isempty(runend) & ~isempty(runstart)
    if runend(end)>runstart(end) %if the bug tumbles at the end of the trajectory
        quiver3(X(runend(end):(end-5),1), X(runend(end):(end-5),2), X(runend(end):(end-5),3),T*dX(runend(end):(end-5),1), T*dX(runend(end):(end-5),2), T*dX(runend(end):(end-5),3),0, 'Color','r','LineWidth',2)
    end
end

% for i=1:n
%     text(X(i,1), X(i,2), X(i,3), num2str(i));
% end
hold off
KatjasGraphics
axis tight
set(gca,'Clipping','off');
set(gca, 'DataAspectRatio', [ 1 1 1]);
xlabel('x (\mu{}m)')
ylabel('y (\mu{}m)')
zlabel('z (\mu{}m)')