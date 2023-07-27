function BSmooth_Acq_All = load_AllAcqData(FileStruct)
%Load SingleAcqData and put it into a cell named "BSmooth_Acq_Cell" 
    Main_Data_Folder = FileStruct.Main_Folder;
    Video_Date = FileStruct.VideoDate;
    Sample_Label = FileStruct.SampleLabel; 
    Ext_Label = FileStruct.Extensions;
    ROI = FileStruct.ROI;
    Tracking_Label = FileStruct.TrackingLabel;
    alpha = FileStruct.alpha;
    
        
        for i = 1:length(Sample_Label)
        Folder{i} = [Main_Data_Folder  filesep Video_Date{i} filesep ,...
        Sample_Label{i} Ext_Label{i} filesep,...
        ROI{i} filesep Tracking_Label{i}];
        %Case of trend filtered trajectories 
        list_cell{i} = dir([Folder{i} filesep '*' num2str(alpha) '.mat']);
        FileName{i} = list_cell{i}.name;
        load([Folder{i} filesep FileName{i}])
        BSmooth_Acq_All(i) = B_Smooth;
        end
end
