%% Function to pull out the trajectory of the bug of interest
%v1 by Ercag Pince
% October 2021, Philadelphia 
function [hFig, B_Smooth, Target_Track_File] = PullTrajOut(BugNo,FileName) 
         
         MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\3D_Tracking_Data';
         
         FileName = cell2mat(FileName);
         RegKeyVD = ['(?<=RunReverse_Data' filesep filesep ')\d*']; 
         RegKeySL = '(?<=KMT)\d*'; %Strain Label
         SL = regexp(FileName, RegKeySL,'match','once');

         
         RegKeyIPTG = ['(?<=' SL '\_)\d*']; 
         RegKeyROI = 'ROI[_]\d';                  
         RegKeyADMM = '(?<=Lambda\_)\d\.\d';
         
         VD = regexp(FileName, RegKeyVD,'match','once');
         IPTG = regexp(FileName, RegKeyIPTG,'match','once');
         ROI =  regexp(FileName, RegKeyROI,'match','once');
         Lambda = regexp(FileName, RegKeyADMM ,'match','once');
         
 % Target Address = MainPath / VideoDate / StrainLabel_IPTG / ROI 
         
         SL_IPTG = ['KMT' SL '_' IPTG 'uM'];
         ThreeD_Track_Dir = fullfile(MainPath,VD,SL_IPTG,ROI);
         Interim_List = getallfilenames(ThreeD_Track_Dir);
         
         Target_Track_File = cell2mat(Interim_List(contains(Interim_List,['Lambda_' Lambda])));
         
         load(Target_Track_File); 
           

         hFig = PlotColoredTraj(B_Smooth,BugNo);
         
         
    function hf = PlotColoredTraj(B,TrackNumber)
             %Parameters
             ScaleXY = B.Parameters.Refstack.ScaleXY; 
             ScaleZ = B.Parameters.Refstack.ScaleZ;
             RoughFocus = B.Parameters.Refstack.RoughFocus;
             epsV = 10; %um/sec
             MarkerSize = 5; 
             
             %The track 
             Track = B.Bugs{TrackNumber,:};
             %The speed on the track
             V = B.Speeds{TrackNumber}(:,9); 
             maxV = max(V) + epsV; %the color scale that speed maxes out
                            
             X(:,1:2) = Track(:,2:3) * ScaleXY; 
             X(:,3) = (Track(:,4) - RoughFocus) * ScaleZ;
             N = size(X,1);
         
             %Mark the initial points  
             hf = figure; 
             %Set figure size
             hf.Position = [490,240,1307,1079]; 
             
             plot3(X(1,1), X(1,2), X(1,3), 'ok', 'MarkerSize', MarkerSize*2, 'MarkerFaceColor','k'); 
             hold on;
             plot3(X(:,1), X(:,2), X(:,3), '-', 'Color',[ 0.8 0.8 0.8]);                         
             speedcolours = jet(floor(maxV));
             
             for i=3:(N-3)
                 speedindex=max(1,min(maxV, round(V(i))));
                 plot3(X(i,1), X(i,2), X(i,3), 'o', 'MarkerEdgeColor', speedcolours(speedindex,:),'MarkerSize', MarkerSize, 'MarkerFaceColor', speedcolours(speedindex,:));
        
             end
             
             
             caxis([ 0 maxV])
             colormap jet
             chandle=colorbar;
             cpos = chandle.Position;
             chandle.Position(1) = cpos(1) + cpos(1) / 12; 
             chandle.Position(3) = cpos(3) / 1.5; 
             chandle.Title.String =  'Speed (\mu{}m/s)'; 
             chandle.Title.FontSize = 14; 
             
             hold off
             
             ErcagGraphics
             set(gca, 'DataAspectRatio', [1 1 1]);
             axis tight
             axis([0 400 0 350 -110 110])
             xlabel('x (\mu{}m)')
             ylabel('y (\mu{}m)')
             zlabel('z (\mu{}m)')                         
    end                           
end
