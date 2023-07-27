function CoexMat = FindCoexistingTrajectories(S, MinTime)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Ercag: The script locates the frame number vector of each bug 
% and match them with other bugs' in the set stored in S.Bugs in 
% for at least "MinTime" number of frames.



n=length(S.Bugs);
CoexMat=sparse(n,n);

Frames=cellfun( @(x) x(:,1), S.Bugs, 'UniformOutput', 0 );

for i=1:n
    for j=i+1:n
        int=intersect(Frames{i}, Frames{j});
        if length(int)>=MinTime
            CoexMat(i,j)=true;
        end
    end
end





end

