%The script that smoothens trajectories of bacteria 
%using alternating direction method of multipliers(ADMM) 
%Functions performing ADMM calculations were written by Katja Taute
%November 2018
clearvars; 
close all; 

%% Define the path and load the data 
Main_Path = 'Z:\Data\3D_Tracking_Data\20210324';
TargetFlag = 'on';
Files = getallfilenames(Main_Path,TargetFlag);
%
Files = Files(contains(Files,'.mat'));
%Drop the files that were processed 
[FinalFiles, Raw] = eliminate(Files);

%% Define the parameters
%Define the lambda value 
lambda = 0.5;
%Switch plot option on/off
plot_switch = 'plotoff';

%Create cell for B
B_cell = cell(1,length(FinalFiles));
File_Smooth = cell(1,length(FinalFiles));

%% Perform the ADMM filtering
for i = 1:length(FinalFiles)
    B_cell{i} = load(FinalFiles{i});
    %ADMM smoothing 
    B_Smooth = ADMMPositionSmoothing(B_cell{i}.B,lambda,plot_switch); 
    
    File_Smooth{i} = [FinalFiles{i}(1:end-4) '_ADMM_Lambda_' num2str(lambda) '.mat'];
    save(fullfile(File_Smooth{i}),'B_Smooth') 
end

function [FF, RawF]= eliminate(Files)
         RegKey =  '(?<=Bugs[_])\d*\w\d*';
         
         SmoothF = Files(contains(Files,'ADMM'));
         RawF = Files(~contains(Files,'ADMM'));
         newMask = []; 
         for i = 1:length(RawF)
             stamp = cell2mat(regexp(RawF(i),RegKey,'match','once'));
             mask = cellfun(@(x) strcmp(regexp(x,RegKey,'match','once'),stamp),SmoothF); 
             newMask = [newMask ; sum(mask)]; 
         end
         FF = RawF(~newMask);

end
% %Save smoothened trajectories 
% File_Smooth = [Files.name(1:end-4) '_ADMM_Lambda_' num2str(lambda) '.mat'];
% %save to the same directory as the initial file
% save([Files.folder filesep File_Smooth],'B_Smooth');

