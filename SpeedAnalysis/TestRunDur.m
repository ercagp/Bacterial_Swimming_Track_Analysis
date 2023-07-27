function LogMask = TestRunDur(Speeds)
         deltat = cellfun(@(x) diff(x(:,1)), Speeds,'UniformOutput',0);
         
         LogMask = cellfun(@(x) all(x == 1), deltat); 
end



% function ActualDuration=ExtractTrajDur(Speeds,fps)
% t=Speeds(:,1);
% deltat=mean(diff(t));
% NumberOfTimePoints=sum(~(isnan(Speeds(:,9))));
% ActualDuration=NumberOfTimePoints*deltat/fps;
% end