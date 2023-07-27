function [B_ds ] = DownSampleBugStructure( B, newfreq )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

oldfreq=B.Parameters.fps;
dsfactor=oldfreq/newfreq;

if mod(dsfactor,1) ~= 0 
    disp('Old frequency must be integer multiple of new frequency! Aborted.');
    return;
end

B_ds=B;
Bugs=B.Bugs;

Bugs=cellfun(@(x)  ( x(1:dsfactor:end, :)  ), Bugs, 'UniformOutput', 0);

B_ds.Bugs=Bugs;
B_ds.Refstack.Parameters.fps=newfreq;
B_ds.RecordingFrequency=oldfreq;

end
