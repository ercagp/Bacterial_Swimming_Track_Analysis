%MAC version of the function callTracks. 
function MATFiles = callTracks_Mac_v2(FilePath,StrainLabel,Lambda)
         Files = getallfilenames(FilePath);
         Files = Files(contains(Files,'.mat'));
         %Regexp key 
         rxKey = ['/' StrainLabel '[_]\w*/\w*/\d*[_]Tracking/\w*[_]\w*[_]\w*[_]\w*[_]' num2str(Lambda)];
                  
         FilesSubset = Files(~cellfun(@isempty,regexp(Files,rxKey,'once')));

         MATFiles = FilesSubset(contains(FilesSubset,StrainLabel)); 
end