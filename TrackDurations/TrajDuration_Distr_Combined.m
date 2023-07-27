%% Plot Distribution Total Trajectory Durations

%June 2019
%Ercag 
clearvars;
close all; 

%% Define Loading Parameters 
Main_Path = 'Z:\Data\3D_Tracking_Data_Analysis\Combined'; 
Video_Date = '20190701';
Main_Path = fullfile(Main_Path,Video_Date); 
%Strain keyword 
%Strain_Keyword = '\\+KMT9+\w+\w+\\';
% ROI_Keyword = '\\+Acq+\w+\w+\\';
% TrackLabel_Keyword = '\\+\w+_Tracking+\\';
%Retrieve the file list 
%Include only final subfolders? 
TargetFlag = 'off';
Files = getallfilenames(Main_Path,TargetFlag);
Files = Files(cellfun(@(x) contains(x,'.mat'),Files)); 
%Define export path
Main_Export_Path = 'Z:\Data\3D_Tracking_Data_Analysis\Combined';

 for i = 1:length(Files)
      [in_Label, out_Label]= regexp(Files{i},'KMT9_Chemotaxis_+\w+\w+\w+\w+\\');
      Sample_Label = Files{i}(in_Label:out_Label-1); 
      Export_Folder = fullfile(Main_Export_Path, Video_Date,Sample_Label);
      mkdir(Export_Folder)
     %Load the file 
     load(Files{i}) 
     %% Carry the speed statistics 
     %Create the structure containing speed info 
     S.Speeds = CB.Speeds;
     S.Parameters = CB.Parameters;
     %Get the speed statistics
     SpeedStats = SpeedStatistics(S); 
     %Get the total trajectory duration for each bug and plot it
     hf_1 = figure;
     Edges = 0:50; %seconds
     histogram(SpeedStats.TrajDur,Edges,'Normalization','PDF');
     title({[Sample_Label ' - Combined']},'interpreter','none')
     ax_h1 = gca;
     %Set Axes Titles
     ax_h1.XLabel.String = 'Total Duration (sec.)';
     ax_h1.YLabel.String = 'PDF';
     %Adjust style 
     ErcagGraphics
     settightplot(ax_h1)
     %Save the figure to the target(i.e. export) folder 
     printfig(hf_1,fullfile(Export_Folder,[Sample_Label '_TotalDurationDist.pdf']),'-dpdf')
%       
end



