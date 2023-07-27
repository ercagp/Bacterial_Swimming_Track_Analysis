function MATFiles = callResults(FilePath,StrainLabel,Lambda)

Files = getallfilenames(FilePath);
Files = Files(contains(Files,'.mat'));
%Regexp key 
%[20191204]KMT47_50uM_ROI_2_Lambda_0.5_Results.mat'
rxKey = ['\[\d*\]\w*[_]\w*[_]\w*[_]\d*[_]\w*[_]' num2str(Lambda) '[_]\w*'];
FilesSubset = Files(~cellfun(@isempty,regexp(Files,rxKey,'once')));

MATFiles = FilesSubset(contains(FilesSubset,StrainLabel)); 
end