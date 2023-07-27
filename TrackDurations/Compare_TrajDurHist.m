%Compare track duration distr. of different acquisitions 
%by Ercag Pince
%October 2019 
clearvars;
close all; 
%% Loading parameters 
MainPath = 'Z:\Data\3D_Tracking_Data_Analysis'; 
VideoDates = {'\20191011\','\20191011\'};
StrainLabels = {'KMT9_Glu_5mM_1','KMT9_Glu_5mM_2'};
FileLabel = 'TrajDurandDensity';

Target_Flag = 'off';

%Retrieve all file list 
Files = getallfilenames(MainPath,Target_Flag);
%Select the indicated video dates from the list 
Files = Files(contains(Files,VideoDates{1}) | contains(Files,VideoDates{2})); 

Files = Files(contains(Files,StrainLabels{1}) | contains(Files,StrainLabels{2})); 
Files = Files(contains(Files,FileLabel));

%Define the bin edges
Edges_New = 0:0.5:20;

%Define regular expression key to search the strain label 
RegExp_StrainLabel = '\w*+(?=\\ROI)';
%Define regular expression key to search ROI number
RegExp_ROI = '\\+ROI+[_]+\d\\'; 

for i = 1:length(Files)
    [inLabel, outLabel] = regexp(Files{i}, RegExp_StrainLabel);
    StrainLabel = Files{i}(inLabel:outLabel); 
    [inROI, outROI] = regexp(Files{i},RegExp_ROI);
    ROI = Files{i}(inROI+1:outROI-1);
    
    load(Files{i})
    
    %Overlay trajectory dur. distributions
    hf_1 = figure(1);
    subplot(length(Files),1,i);
    histogram(TrajDur,Edges_New,'Normalization','PDF');
    title([StrainLabel ' - ' ROI],'Interpreter','none');
   
    ax_h1 = gca;
    %Set Axes Titles
    ax_h1.YLabel.String = 'PDF';
    if i == length(Files)
        ax_h1.XLabel.String = 'Total Duration (sec.)';
    else
        ax_h1.XLabel.String = '';
    end
    ax_h1.FontSize = 12; 
    ax_h1.Title.FontSize = 12;
    ax_h1.FontName = 'Helvetica'; 
    ax_h1.Box = 'on';
           
    %Set Style
    %ErcagGraphics
    %settightplot(ax_h1)
    
    %hold on 
    
    % Density versus median trajectory duration 
    hf_2 = figure(2); 
    p{i} = plot(Density,nanmedian(TrajDur),'.','MarkerSize',18); 
    hold on 
    %legend labels
    leg{i} = [StrainLabel '-' ROI];
    
    %Density versus mean trajectory duration 
    hf_3 = figure(3); 
    p_hf3{i} = plot(Density,nanmean(TrajDur),'.','MarkerSize',18); 
    hold on 
    %legend labels
    leg_hf3{i} = [StrainLabel '-' ROI];
end

hold off
hf_1.Units = 'centimeters';
hf_1.PaperUnits = 'centimeters';
hf_1.Position = [0 0 15 21];
hf_1.PaperPosition = hf_1.Position;
hf_1.PaperSize = [15 21]; 

ax_h1.GridColor = [0 0 0]; 
ax_h1.MinorGridColor = [0 0 0]; 
ax_h1.XColor = [0 0 0];
ax_h1.YColor = [0 0 0]; 
ax_h1.ZColor = [0 0 0];

print(hf_1,fullfile(MainPath,VideoDates{end},'TrajDurCompare.png'),'-dpng')
print(hf_1,fullfile(MainPath,VideoDates{end},'TrajDurCompare.pdf'),'-dpdf')


figure(2) 
legend(leg,'Interpreter','none');
ax_h2 = gca;
ax_h2.XLabel.String = 'Density (a.u.)';
ax_h2.YLabel.String = 'Median Traj. Dur. (sec)';
ax_h2.XLim = [2000 6000];
ax_h2.YLim = [1.0 2.5];
%Adjust style 
ErcagGraphics
settightplot(ax_h2)

printfig(hf_2,fullfile(MainPath,VideoDates{end},'Density_vs_MedTrajDur.png'),'-dpng')
printfig(hf_2,fullfile(MainPath,VideoDates{end},'Density_vs_MedTrajDur.pdf'),'-dpdf')


figure(3) 
hold off
legend(leg_hf3,'Interpreter','none');
ax_h3 = gca;
ax_h3.XLabel.String = 'Density (a.u.)';
ax_h3.YLabel.String = 'Mean Traj. Dur. (sec)';
ax_h3.XLim = [2000 6000];
ax_h3.YLim = [1.0 2.5];

%Adjust style 
ErcagGraphics
settightplot(ax_h3)

printfig(hf_3,fullfile(MainPath,VideoDates{end},'Density_vs_MeanTrajDur.png'),'-dpng')
printfig(hf_3,fullfile(MainPath,VideoDates{end},'Density_vs_MeanTrajDur.pdf'),'-dpdf')

