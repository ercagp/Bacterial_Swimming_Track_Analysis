%% Speed Distributions of individual acq.
%Compare ROIs
%by Ercag 
%July 2020 
clearvars;
close all; 
%% Define Path and call up trajectory files 
MainPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/3D_Tracking_Data'; 
%% Define Export Parameters 
ExpPath = '/Users/ercagpince/Dropbox/Research/NikauBackup/Data/SpeedAnalysis/SpeedDist_CmpSingleAcqs/'; %Export Path
ExpDate = '[20210610]'; %Export date
ExpTag = 'InstSpeed_CmpSingleAcq_'; %Export tag
%% Define call and experimental parameters 
VideoDate = '20210318';
StrainLabel = 'KMT53';

%Lambda parameter of ADMM 
Lambda = 0.5; 
%Minimum Trajectory length & speed
minT = 0; %sec 
minV = 0; %um/sec

%Histogram parameters
Bins.Size = 5;%um/sec
Bins.Max =  200;  %um/sec
YNorm = 'PDF'; 
Style = 'Stairs';
Lab.YAx = YNorm;
Lab.XAx = '';


%Define regular expression key to search for the strain label,ROI & IPTG
RegExp_IPTG = ['(?<=' StrainLabel '[_])\d*(?=\w*)']; 
RegExp_ROI = 'ROI[_]\d'; 

%Call files defined above 
Files = callTracks_Mac(MainPath,StrainLabel,VideoDate,Lambda);
IPTG = cellfun(@(x) str2num(regexp(x,RegExp_IPTG,'match','once')),Files); 

%List the file list 
disp('List of the Files\n')
for li = 1:length(Files)
    disp([num2str(li) '--' Files{li}]);
end



UN = unique(IPTG,'stable'); 
for i = 1:length(UN) 
    Files_Subset = Files(IPTG == UN(i));
    IPTG_Str = num2str(UN(i));
    %Create fig object
    hf{i} = figure(i);
    %Prepare figure for subplot configuration 
    HAx = prepareFig(hf{i},length(Files_Subset)); 
    %Define export folder 
    FullExp = fullfile(ExpPath,VideoDate,[StrainLabel '_' IPTG_Str 'uM']);
    mkdir(FullExp);

        for j = 1:length(Files_Subset)
            %Load file
            load(Files_Subset{j}); 
            %Find ROI number 
            ROI = regexp(Files_Subset{j},RegExp_ROI,'match','once');
            %Extract FPS 
            fps = B_Smooth.Parameters.fps;
            %Retrieve speed statistics
            S = cutoff(B_Smooth,minT,minV);
            
            AllSpeeds{j} = cell2mat(S.allV);
            %Subplot distributions
            axes(HAx(j));
            HHand = PlotHist(AllSpeeds{j},YNorm,Style,Bins); 

            if j == 1 
               title({[StrainLabel '@'  IPTG_Str 'uM [IPTG]'],ROI},'Interpreter','none')
            else
               title(ROI,'Interpreter','none')
            end
            
            if j == length(Files_Subset) 
               Lab.XAx = 'Instantaneous Speed (\mum/sec)';
            end
            PlotStyle(hf{i},Lab)   
            Lab.XAx = '';
        end
     FileName = [ExpDate ExpTag StrainLabel '_' IPTG_Str 'uM' '_minV_' num2str(minV) 'um_sec_minT_' num2str(minT) '_sec'];    
     printfig(hf{i},fullfile(FullExp,FileName),'-dpdf');   
     printfig(hf{i},fullfile(FullExp,FileName),'-dpng');   
end




function PlotStyle(hFig,Lab)
         figure(hFig);
         ax = gca; 
         %ax.Title.String = Lab.Title;
         ax.XLabel.String = Lab.XAx; 
         ax.YLabel.String = Lab.YAx;
         %ax.XLim = Lim.X;
         %ax.YLim = Lim.Y; 
         ErcagGraphics
         %settightplot(ax); 
end

function ha = prepareFig(hFig,No)
    %Set position of each figure panel 
    
    hFig.Position = [100 100 900 750];
    marg_h = [0.07 0.07];
    [ha,~] = tight_subplot(No,1,0.07,marg_h,0.1);
    
end

%Plot histogram with defined parameters
function HHand = PlotHist(XData,YNorm,Style,Bins)
         Bins.Array = 0:Bins.Size:Bins.Max; 
         HHand = histogram(XData,Bins.Array,'DisplayStyle',Style,...
                              'Normalization',YNorm,'LineWidth',1.5);
end
         

         
function SSNew = cutoff(B,minT,minV) 
         SpeedStats = SpeedStatistics(B);
         
         SSNew.allV = SpeedStats.allV(SpeedStats.medV > minV &  SpeedStats.TrajDur > minT);
         SSNew.allv = SpeedStats.allv(SpeedStats.medV > minV &  SpeedStats.TrajDur > minT);
         SSNew.medV = SpeedStats.medV(SpeedStats.medV > minV &  SpeedStats.TrajDur > minT);
         SSNew.meanV = SpeedStats.meanV(SpeedStats.medV > minV &  SpeedStats.TrajDur > minT);
         SSNew.TrajDur = SpeedStats.TrajDur(SpeedStats.medV > minV &  SpeedStats.TrajDur > minT);
end
    
    


