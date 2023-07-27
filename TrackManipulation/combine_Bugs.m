%Combine Structures 
function CB = combine_Bugs(FileStruct)
    Main_Data_Folder = FileStruct.Main_Folder;
    Video_Date = FileStruct.VideoDate;
    Sample_Label = FileStruct.SampleLabel; 
    Ext_Label = FileStruct.Extensions;
    ROI = FileStruct.ROI;
    Tracking_Label = FileStruct.TrackingLabel;
    lambda = FileStruct.lambda;
    
    BugPosition = {}; 
    BugSpeeds = {}; 
    for i = 1:length(Sample_Label)
    Folder{i} = [Main_Data_Folder  filesep Video_Date{i} filesep ,...
         Sample_Label{i} Ext_Label{i} filesep,...
         ROI{i} filesep Tracking_Label{i}];
    %Case of trend filtered trajectories 
    %list_cell{i} = dir([Folder{i} filesep '*' num2str(lambda) '.mat']);
   
    list_folder = dir([Folder{i} filesep '*.mat']); 
%   %Find the mat file with particular "lambda" number 
    lambda_logic = cellfun(@(x) ~isempty(regexp(x,['Lambda_' num2str(lambda)], 'once')),{list_folder.name}');
    
    FileName{i} = list_folder(lambda_logic).name;
    load([Folder{i} filesep FileName{i}])
    BugPosition = vertcat(BugPosition,B_Smooth.Bugs);
    BugSpeeds = vertcat(BugSpeeds,B_Smooth.Speeds);
    end
    
    %Generate the structure 
    CB.Parameters = B_Smooth.Parameters; 
    CB.Bugs = BugPosition; 
    CB.Speeds = BugSpeeds; 
end
