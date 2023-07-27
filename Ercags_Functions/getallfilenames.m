function names = getallfilenames(path,varargin)
%Getting all 1st order subdirectories
%only_targets = 'on';
if strcmp(varargin,'on')
    target_flag = 'on';
else 
    target_flag = 'off';
end

list_folder = getallsubdirectories_v3(path,target_flag);
names = {};
for i = 1:length(list_folder) 
    first_list = dir(list_folder{i}); 
    first_names = getrid({first_list.name});
    temp_cell = cell(1,length(first_names));
    for j = 1:length(first_names)
    temp_cell{j} = fullfile(list_folder{i},first_names{j});
    end
    names = [names, temp_cell];
end
    names = names';
end


function ls = getrid(ls)
 %exclude '.' and '..'    
 exc_logic = cellfun(@(x) strcmp(x,'.'),ls);
 ls(exc_logic) = [];
 exc_logic = cellfun(@(x) strcmp(x,'..'),ls);
 ls(exc_logic) = [];
end

