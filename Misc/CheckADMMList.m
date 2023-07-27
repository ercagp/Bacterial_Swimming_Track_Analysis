% Check the smoothened trajectories .mat list 
% April 2021 
%by Ercag @ UPENN
clearvars -except Home
clc 
close all; 

FPath = fullfile(Home,'/20210330');

List = getallfilenames(FPath);
FList = List(contains(List,'.mat')); 

display(FList);