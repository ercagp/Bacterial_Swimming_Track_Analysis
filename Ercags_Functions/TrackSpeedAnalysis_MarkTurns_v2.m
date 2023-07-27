function  TrackSpeedAnalysis_MarkTurns_v2(B, Results, whichbug,varargin)

if nargin > 3 
  SaveFig.Flag = varargin(4);
  SaveFig.ExpPath = varargin(4).ExpPath; 
  
else
  SaveFig.Flag = 0; 
end

%Define figure handles and assign numbers
hvDist = figure(5);
hDeltat = figure(6);
htimeSeries = figure(7); 
htimeSeries.Position = [100 100 2000 1000];

%Set label head for PDF & PNG files 
Date = datetime; 
LHead = ['[' num2str(year(Date)) num2str(month(Date)) sprintf('%02d',day(Date)) ']'];

ScaleXY=B.Parameters.Refstack.ScaleXY;
ScaleZ=B.Parameters.Refstack.ScaleZ;
RoughFocus=B.Parameters.Refstack.RoughFocus;
fps=B.Parameters.fps;


%Select bug
k = whichbug;

Speeds = B.Speeds;
t = Speeds{k}(:,1)/fps*mean(diff(Speeds{k}(:,1)));
v = Speeds{k}(:,9);
x = Speeds{k}(:,2)*ScaleXY;
y = Speeds{k}(:,3)*ScaleXY;
z = (Speeds{k}(:,4)-RoughFocus)*ScaleZ;
%dalpha = Speeds{k}(:,10);

% Assign runstart and runend indices

RunStart = Results.T{k,3};
RunEnd = Results.T{k,2}; 


% compute angles between sums of 2 subsequent velocity vectors

vec=Speeds{k}(:,6:8);
vec1= vec(1:end-1,:);
vec2=vec(2:end,:);
vecs=vec1+vec2;
vecs_1=vecs(1:end-2,:);
vecs_2=vecs(3:end,:);
dalpha2=real( acosd(sum(vecs_1.*vecs_2,2)./(  sqrt(sum(vecs_1.^2,2)).*sqrt(sum(vecs_2.^2,2)) ) ) );
dalpha2=[NaN; NaN; dalpha2; NaN];

dX = Speeds{k}(:,6:8);
ind_end = size(dX,1);

dAlpha3=NaN(ind_end,1);

for ind = 4:ind_end-3
    %add velocities
    %add velocities
    dX1=sum(dX(ind-3:ind-1,:));
    dX2=sum(dX(ind:ind+2,:));
    %compute speeds
    V1=sqrt(sum(dX1.^2));
    V2=sqrt(sum(dX2.^2));
    %compute angle between them
    dAlpha3(ind)=acosd ( sum(dX1.*dX2)/(V1*V2) );
end


%% speed histogram
figure(hvDist); 
vbinsize=min(5,round(max(v)/20));
vbins=0:vbinsize:max(v);
histogram(v, vbins, 'DisplayStyle', 'stairs');
xlabel('v (\mu{}m/s)')
ylabel('counts')
ErcagGraphics

%% over time
PlotVariables=[v, dAlpha3, x, y, z ];
VariableNames={'v (\mu{}m/s)', 'd\alpha3','x (\mu{}m)','y (\mu{}m)','z (\mu{}m)'};

figure(htimeSeries);
clf(figure(htimeSeries))
[ha, ~] = tight_subplot(5, 1, 0, 0.1, 0.1);
YLimMode={ 'manual', 'manual', 'auto', 'auto', 'auto'};
AxesYLims={[ 0 1.1*max(v)], [ 0 180], [ 0 400], [ 0 350],  110*[ -1 1]}; 
for i=1:length(ha)
    axes(ha(i));
    plot(t,PlotVariables(:,i), 'o-');
    %highlight turning events 
    hold on
    for ri = 1:length(RunEnd)-1
        plot(t(RunStart(ri):RunEnd(ri+1)),PlotVariables(RunStart(ri):RunEnd(ri+1),i), 'ro-');
    end
    

    set(ha(i), 'XLim', [t(1) t(end)],...
        'XGrid', 'on',...
        'XMinorGrid', 'on', ...
         'YGrid', 'on',...
        'YMinorGrid', 'on', ...
        'XTickLabel', [] ...
    );
    ErcagGraphics
    ylabel(VariableNames{i})
    if strcmp(YLimMode{i},'manual')
        set(gca, 'YLim', AxesYLims{i});
    end
end
xlabel('time (s)');
set(ha(end), 'XTickLabelMode', 'auto')
% same time zoom for all plots
linkaxes(ha, 'x');

%% Print figures i3f necessary 
if SaveFig.Flag
   ExpPath = SaveFig.ExpPath; 
   %Make new folders to save figures
   VelDistFolder = fullfile(ExpPath,'VelocityDist');
   TimeSeriesFolder = fullfile(ExpPath,'TimeSeries');
   DeltaTFolder = fullfile(ExpPath,'Delta_t_analysis');

   if ~(exist(VelDistFolder,'dir') && exist(TimeSeriesFolder,'dir') && exist(DeltaTFolder,'dir'))
      mkdir(VelDistFolder);
      mkdir(TimeSeriesFolder); 
      mkdir(DeltaTFolder);
   end
   %Save figures 
   printfig(hvDist,fullfile(VelDistFolder, [LHead '[VDist]Bug#' num2str(k) '.pdf']),'-dpdf')
   printfig(hDeltat,fullfile(DeltaTFolder, [LHead '[Delta_t]Bug#' num2str(k) '.pdf']),'-dpdf')
   printfig(htimeSeries,fullfile(TimeSeriesFolder, [LHead '[TimeSeries]Bug#' num2str(k) '.pdf']),'-dpdf')
   savefig(htimeSeries,fullfile(TimeSeriesFolder, [LHead '[TimeSeries]Bug#' num2str(k) '.fig']))
end
    

end

