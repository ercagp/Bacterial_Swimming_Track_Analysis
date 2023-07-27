function PlotTraj_MarkSlowRuns(Parameters,PlotInput,BugID,RunID,varargin)

%% Insert Track Parameters 
ScaleXY = Parameters.Refstack.ScaleXY;
ScaleZ = Parameters.Refstack.ScaleZ;
RoughFocus = Parameters.Refstack.RoughFocus;
fps = Parameters.fps;

%% Inputs and plotting parameters

%which bug to plot?
display(['Bug# = ' num2str(BugID)])
%which runs to highlight? 
display(['Runs = ' num2str(RunID)])

if ~isfield (PlotInput,'Title')
    PlotInput.Title = ['Bug #' num2str(BugID)]; 
end

S = PlotInput.Speed;
%Trajectory time vector
t = S(:,1)/fps*mean(diff(S(:,1)));
%Instantaneous speed vector
V = S(:,9);
%Coordinates 
X = S(:,2) .* ScaleXY;
Y = S(:,3) .* ScaleXY;
Z = (S(:,4)-RoughFocus).*ScaleZ;
%Total number of trajectory points 
n = length(X); 

% %Indices of runs and turns 
T = PlotInput.Run; 
RunEnd = T{:,3}; 
RunMat = T{:,1}; 

%at what speed should the colour scale max out?
if  nargin > 4
    maxVcolor = round(varargin{1});
else
    maxVcolor = 200; %um/sec
end
%Color palette for speed plot 
SpeedColorMap = parula(maxVcolor); 
MarkerSize = 4; 
LineWidth = 3.0; 


%% Plotting trajectories
%Plot track (baseline black & gray color) 
%Plot initial point as a black dot  
plot3(X(1), Y(1), Z(1), 'ok', 'MarkerSize', MarkerSize*2, 'MarkerFaceColor','k');
hold on 
%Plot the whole track 
plot3(X, Y, Z, '-', 'Color',[0.8 0.8 0.8],'LineWidth',LineWidth)

%Plot the color mapped track
for j = 1:(n-1)
        SpeedID = max(1,min(maxVcolor, round(V(j))));
        plot3(X(j), Y(j), Z(j), 'o', 'MarkerEdgeColor', SpeedColorMap(SpeedID,:),'MarkerSize', MarkerSize, 'MarkerFaceColor', SpeedColorMap(SpeedID,:));
        hold on
end
caxis([0 maxVcolor]);
colormap parula

% check if colorbar already exists, otherwise create it
ch = get(gcf, 'Children');
chandle = findobj(ch,'Type', 'colorbar');
if isempty(chandle)
    chandle = colorbar;
    set(get(chandle,'title'),'String','speed (\mu{}m/s)', 'FontSize', 16);
end

%Plot the detected turns 
plot3(X(RunEnd),Y(RunEnd), Z(RunEnd), 'o','MarkerSize',MarkerSize*3,'Color',rgb('Magenta'))

%Highlight selected runs 
for i = RunID
    Segment = RunMat(:,i);
    plot3(X(Segment), Y(Segment), Z(Segment), '-', 'Color',[1 0 0],...
          'LineWidth',4*LineWidth); 
end

%% Figure & plot style 
hold off
KatjasGraphics
set(gca, 'DataAspectRatio', [ 1 1 1]);
axis tight
xlabel('X (\mu{}m)')
ylabel('Y (\mu{}m)')
zlabel('Z (\mu{}m)')
title(PlotInput.Title); 

drawnow;
set(gca, 'Position', [ 0.15 0.15 0.6 0.8])
set(gcf, 'Position', [377,197,1642,1032]); 
set(gca,'Clipping','off')


%% Save figure if demanded 
if isfield(PlotInput,'SaveFig')
   %Set label head for PDF & PNG files 
   Date = datetime; 
   FileStamp = ['[' char(datetime('now','Format','yyyyMMdd')) ']'];

    
   ExpPath = PlotInput.SaveFig.ExpPath;
   Strain = PlotInput.SaveFig.Strain; 
   VideoDate = PlotInput.SaveFig.VideoDate; 
   IPTG  = PlotInput.SaveFig.IPTG; 
   ROI =  PlotInput.SaveFig.ROI; 
   BugIDStr = num2str(BugID);  
   
   FullName = fullfile(ExpPath,[FileStamp Strain '_SlowRuns_' VideoDate '_IPTG_' IPTG 'uM_' ROI '_Bug#' BugIDStr]);     
   savefig(gcf,FullName);     
end

