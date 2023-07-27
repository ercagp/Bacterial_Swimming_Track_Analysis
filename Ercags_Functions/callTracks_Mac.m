%MAC version of the function callTracks. 
function MATFiles = callTracks_Mac(FilePath,StrainLabel,VideoDate,Lambda)
         Files = getallfilenames(FilePath);
         Files = Files(contains(Files,'.mat'));
         %Regexp key 
         %rxKey = ['/' VideoDate '/' StrainLabel '[_]\w*/\w*/\d*[_]Tracking/\w*[_]\w*[_]\w*[_]\w*[_]' num2str(Lambda)];
         rxKey = ['/' VideoDate '/' StrainLabel]; 
         rxKey_Lambda = ['[_]\w*/\w*/\d*[_]Tracking/\w*[_]\w*[_]\w*[_]\w*[_]' num2str(Lambda)];
         
         LMask = ~cellfun(@isempty,regexp(Files,rxKey,'once')) & ~cellfun(@isempty, regexp(Files,rxKey_Lambda,'once')); 
         
         FilesSubset = Files(LMask);

         MATFiles = FilesSubset(contains(FilesSubset,StrainLabel)); 
end