function SpeedStats=SpeedStatistics_Scaled(B)


% check if speeds have already been computed for input structure, else do
% it
% if ~isfield(B, 'Speeds')
%     S=BugsToSpeeds_ForStruct(B);
% else
%     S=B;
% end

% ScaleXY=S.Parameters.Refstack.ScaleXY;
% ScaleZ=S.Parameters.Refstack.ScaleZ;


medV=cellfun(@(x) (median(x(:,9), 'omitnan')), S.Speeds, 'UniformOutput', 1);
allV=cellfun(@(x)  (x(~isnan(x(:,9)),9)), S.Speeds, 'UniformOutput', 0);
meanV=cellfun(@(x) (mean(x(:,9), 'omitnan')), S.Speeds, 'UniformOutput', 1);
TrajDur=cellfun(@(x) (ExtractTrajDur(x,S.Parameters.fps)),  S.Speeds, 'UniformOutput', 1);
allv=cellfun(@(x)  (x(~isnan(x(:,9)),6:8)), S.Speeds, 'UniformOutput', 0);


SpeedStats.allV=allV;
SpeedStats.allv=allv;
SpeedStats.medV=medV;
SpeedStats.meanV=meanV;
SpeedStats.TrajDur=TrajDur;


end

function ActualDuration=ExtractTrajDur(Speeds,fps)
t=Speeds(:,1);
deltat=mean(diff(t));
NumberOfTimePoints=sum(~(isnan(Speeds(:,9))));
ActualDuration=NumberOfTimePoints*deltat/fps;
end



