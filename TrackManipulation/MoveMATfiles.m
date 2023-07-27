%Move the 3D tracking data into new folders
clearvars;
close all;

Main_Path = 'Z:\Data\3D_Tracking_Data\';
list = getallsubdirectories(Main_Path); 

%starting index 
l_start = 14; % equivalent to 20190208
list = list(l_start:end); 
ROI_index = cellfun(@(x) contains(x,'ROI'),list);
sub_list = list(ROI_index);

for i = 1:length(sub_list)
    MATList = dir([sub_list{i} filesep '*.mat']);
    for j = 1:length(MATList)
        new_folder = [MATList(j).folder filesep MATList(j).name(6:13) '_Tracking'];
        mkdir(new_folder);
        status = movefile([MATList(j).folder filesep MATList(j).name],...
               new_folder)
    end
end

