function MATFiles = callResultsv2(FilePath,StrainLabel,Lambda)

         Files = getallfilenames(FilePath);
         Files = Files(contains(Files,'.mat'));
         %Regexp key 
         rxKey = ['\[\d*\]\w*[_]\w*[_]\w*[_]\d*[_]\w*[_]' num2str(Lambda) '[_]\w*'];
         FilesSubset = Files(~cellfun(@isempty,regexp(Files,rxKey,'once')));
    
         MATFiles = FilesSubset(contains(FilesSubset,StrainLabel)); 
end