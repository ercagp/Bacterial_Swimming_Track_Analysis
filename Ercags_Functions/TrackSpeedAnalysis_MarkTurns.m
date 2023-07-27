function  TrackSpeedAnalysis_MarkTurns(S,Runs, whichbug,SaveFigSwitch,varargin)

if nargin > 5  
   FirstCond = varargin{1};
   SecondCond = varargin{2};
   BothCond = varargin{3};
end

RunStart = Runs.runstart;
RunEnd = Runs.runend; 
 
%Define figure handles and assign numbers
hvDist = figure(5);
hDeltat = figure(6);
htimeSeries = figure(7); 
htimeSeries.Position = [100 100 2000 1000];

%Set label head for PDF & PNG files 
Date = datetime; 
LHead = ['[' num2str(year(Date)) num2str(month(Date)) sprintf('%02d',day(Date)) ']'];

k=whichbug;

ScaleXY=S.Parameters.Refstack.ScaleXY;
ScaleZ=S.Parameters.Refstack.ScaleZ;
RoughFocus=S.Parameters.Refstack.RoughFocus;
fps=S.Parameters.fps;

S=S.Speeds{k};
t=S(:,1)/fps*mean(diff(S(:,1)));
v=S(:,9);
x=S(:,2)*ScaleXY;
y=S(:,3)*ScaleXY;
z=(S(:,4)-RoughFocus)*ScaleZ;
dalpha=S(:,10);


% compute angles between sums of 2 subsequent velocity vectors

vec=S(:,6:8);
vec1= vec(1:end-1,:);
vec2=vec(2:end,:);
vecs=vec1+vec2;
vecs_1=vecs(1:end-2,:);
vecs_2=vecs(3:end,:);
dalpha2=real( acosd(sum(vecs_1.*vecs_2,2)./(  sqrt(sum(vecs_1.^2,2)).*sqrt(sum(vecs_2.^2,2)) ) ) );
dalpha2=[NaN; NaN; dalpha2; NaN];

dX = S(:,6:8);
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
KatjasGraphics

% Histogram for delta_t difference between consecutive turning events 
figure(hDeltat);
delta_t = diff(RunEnd).*(1/fps); 
binsize = 2*(1/fps);
delta_t_bins = 0:binsize:100*(1./fps);
histogram(delta_t,delta_t_bins,'DisplayStyle','stairs'); 
xlabel('\Deltat(s)')
ylabel('counts')
KatjasGraphics

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
    for ri = 1:length(RunStart)
        plot(t(RunEnd(ri):RunStart(ri)),PlotVariables(RunEnd(ri):RunStart(ri),i), 'ro');
    end
    
    if nargin > 5 
       plot(t(FirstCond),PlotVariables(FirstCond,i),'o','Color',rgb('Lime'));
       plot(t(SecondCond),PlotVariables(SecondCond,i),'o','Color',rgb('Magenta'));
       plot(t(BothCond),PlotVariables(BothCond,i),'o','Color',rgb('Gold'));
    else
       plot(t(RunEnd),PlotVariables(RunEnd,i), 'o','Color',rgb('Magenta'));
    end

    set(ha(i), 'XLim', [t(1) t(end)],...
        'XGrid', 'on',...
        'XMinorGrid', 'on', ...
         'YGrid', 'on',...
        'YMinorGrid', 'on', ...
        'XTickLabel', [] ...
    );
    KatjasGraphics
    ylabel(VariableNames{i})
    if strcmp(YLimMode{i},'manual')
        set(gca, 'YLim', AxesYLims{i});
    end
end
xlabel('time (s)');
set(ha(end), 'XTickLabelMode', 'auto')
% same time zoom for all plots
linkaxes(ha, 'x');

%% Print figures if necessary 
if SaveFigSwitch.Flag
   ExpPath = SaveFigSwitch.ExpPath; 
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

