function CB = combine_BugsV3(target_list,lambda)
    BugPosition = {}; 
    BugSpeeds = {}; 
    for i = 1:length(target_list)
    Folder = target_list{i};
    
    %Take the list 
    list_folder = dir(fullfile(Folder,'*.mat')); 
    %Find the mat file with particular "lambda" number 
    lambda_logic = cellfun(@(x) ~isempty(regexp(x,['Lambda_' num2str(lambda)], 'once')),{list_folder.name}');
    
    %Load the .mat file 
    mat_file = fullfile(list_folder(lambda_logic).folder,list_folder(lambda_logic).name);
    load(mat_file);
    
    %Concatanate Bug Structures
    BugPosition = vertcat(BugPosition,B_Smooth.Bugs);
    BugSpeeds = vertcat(BugSpeeds,B_Smooth.Speeds);
    end
    
    %Generate the structure 
    CB.Parameters = B_Smooth.Parameters; 
    CB.Bugs = BugPosition; 
    CB.Speeds = BugSpeeds; 
end