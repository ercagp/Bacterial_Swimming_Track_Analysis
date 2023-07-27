%Windows version of the function callTracks. 
function MATFiles = callTracks_Win_v2(FilePath,StrainLabel,Lambda)
         Files = getallfilenames(FilePath);
         Files = Files(contains(Files,'.mat'));
         %Regexp key 
         rxKey = [filesep StrainLabel '[_]\w*' filesep '\w*' filesep '\d*[_]Tracking' filesep '\w*[_]\w*[_]\w*[_]\w*[_]' num2str(Lambda)];
         %rxKey = ['\[\d*\]\w*[_]\w*[_]\w*[_]\d*[_]\w*[_]' num2str(Lambda) '[_]\w*'];
        
         FilesSubset = Files(~cellfun(@isempty,regexp(Files,rxKey,'once')));

         MATFiles = FilesSubset(contains(FilesSubset,StrainLabel)); 
end