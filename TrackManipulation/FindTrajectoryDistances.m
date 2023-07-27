function [OverlapFrames, PairwiseDistances] = FindTrajectoryDistances(S, k1, k2)
% [OverlapFrames, PairwiseDistances] = FindTrajectoryDistances(S, k1, k2)
% finds distances between trajectories k1 and k2 as a function of time


% parameters
ScaleXY=S.Parameters.Refstack.ScaleXY;
ScaleZ=S.Parameters.Refstack.ScaleZ;


% pull out the relevant sets of positions
if isfield(S, 'Speeds')
    Bug1=S.Speeds{k1}(:,1:4);
    Bug2=S.Speeds{k2}(:,1:4);
else
    Bug1=S.Bugs{k1}(:,1:4);
    Bug2=S.Bugs{k2}(:,1:4);
end

% calibrate positions into microns
Bug1=CalPos(Bug1, [ ScaleXY, ScaleXY, ScaleZ]);
Bug2=CalPos(Bug2, [ ScaleXY, ScaleXY, ScaleZ]);

%find where they overlap in time 
[OverlapFrames,l1_OverlapTime, l2_OverlapTime]=intersect(Bug1(:,1), Bug2(:,1));

Bug1_ov=Bug1(l1_OverlapTime, 2:4);
Bug2_ov=Bug2(l2_OverlapTime, 2:4);


PairwiseDistances=sqrt(sum((Bug1_ov-Bug2_ov).^2,2));



end


function Bug=CalPos(Bug, scalingfactors)
% scale data in space and time


m=size(Bug,1);
Bug(:,2:4)=Bug(:,2:4).*repmat(scalingfactors,m,1);

end
