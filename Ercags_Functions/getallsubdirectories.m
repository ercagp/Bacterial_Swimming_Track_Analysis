%getallsubdirectories 
function allsubs = getallsubdirectories(main_path,varargin)

%get rid of '.' and '..' in the folder list 

% "genpath() is a command which spits out all subfolders of the parentdir in a single line of text, 
% separated by semicolons. The regular expression function regexp() searches for patterns in that string 
% and returns the option: 'matches' to the pattern. In this case 
%the pattern is any character not a semicolon = `[^;], repeated one or more times in a row = *.
%So this will search the string and group all the characters that are not
%semicolons into separate outputs - in this case all the subfolder directories."
%see https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
list = regexp(genpath(main_path),'[^:]*','match'); %---Change ; to : for Mac!!!----

%Drop the parent directory 
list(1) = [];
 
if strcmp(varargin,'on')
    %Capture only the target subfolders 
    temp_list = list';
    l_vector = cellfun(@(x) length(x), temp_list');
    allsubs = temp_list(max(l_vector) == l_vector); 
else 
    %Include all directory tree
    allsubs = list';    
end