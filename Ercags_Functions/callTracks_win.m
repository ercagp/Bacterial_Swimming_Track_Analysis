%The windows version of the function "callTracks"
function MATFiles = callTracks_win(FilePath,StrainLabel,VideoDate,Lambda)
         Files = getallfilenames(FilePath);
         Files = Files(contains(Files,'.mat'));
         rxKey = [VideoDate filesep filesep StrainLabel '[_]\w*' filesep filesep '\w*' filesep filesep '\d*[_]Tracking' filesep filesep '\w*[_]\w*[_]\w*[_]\w*[_]' num2str(Lambda)];
                  
         FilesSubset = Files(~cellfun(@isempty,regexp(Files,rxKey,'once')));

         MATFiles = FilesSubset(contains(FilesSubset,StrainLabel)); 
end