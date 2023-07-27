function CB = combine_BugsV3(Main_Path,varargin)
BugPosition = {}; 
BugSpeeds = {}; 
    
if isempty(varargin)
    Lambda = 1;
else
    Lambda = varargin{1}; 
end
%Retrieve the file list 
%Include only final subfolders? 
Target_Flag = 'on';
Files = getallfilenames(Main_Path,Target_Flag);
Files = Files(cellfun(@(x) contains(x,'ADMM'),Files)); 
Files = Files(cellfun(@(x) contains(x,['Lambda_' num2str(Lambda)]),Files));

for i = 1:length(Files)
    load(Files{i});
    
    %Concatanate Bug Structures
    BugPosition = vertcat(BugPosition,B_Smooth.Bugs);
    BugSpeeds = vertcat(BugSpeeds,B_Smooth.Speeds);
end
    
    %Generate the structure 
    CB.Parameters = B_Smooth.Parameters; 
    CB.Bugs = BugPosition; 
    CB.Speeds = BugSpeeds; 
end