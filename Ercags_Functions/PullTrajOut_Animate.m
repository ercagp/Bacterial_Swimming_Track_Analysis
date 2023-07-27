%% Function to pull out the trajectory of the bug of interest and animate it!
%v1 by Ercag Pince
% October 2021, Philadelphia 
function [hFig, B_Smooth, Target_Track_File] = PullTrajOut_Animate(BugNo,FileName,Results) 
         
         MainPath = 'C:\Users\ercagp\Box\Research\VibrioFischeri_Project\Data\3D_Tracking_Data';
         
         if iscell(FileName) 
            FileName = cell2mat(FileName); 
         end
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
         
         if strcmp(IPTG, '1')
            SL_IPTG = ['KMT' SL '_' IPTG 'mM'];
         else
            SL_IPTG = ['KMT' SL '_' IPTG 'uM'];
         end
         
         ThreeD_Track_Dir = fullfile(MainPath,VD,SL_IPTG,ROI);
         Interim_List = getallfilenames(ThreeD_Track_Dir);
         
         Target_Track_File = cell2mat(Interim_List(contains(Interim_List,['Lambda_' Lambda])));
         
         load(Target_Track_File); 
         
         
         TCell = Results.T; 
         hFig = PlotColoredTraj(B_Smooth,BugNo,TCell);
         
         
    function hf = PlotColoredTraj(B,TrackNumber,TCell)
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
             %The frame number 
             Frame_No = Track(:,1); 
             
             %The run-reverse matrix 
             RunEnd = TCell{TrackNumber,3};
             RunSt = TCell{TrackNumber,2}; 
             
             %Scaled tracks are in the matrix X 
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
             speedcolor = jet(floor(maxV));
                                
             caxis([ 0 maxV])
             colormap jet
             chandle=colorbar;
             cpos = chandle.Position;
             chandle.Position(1) = cpos(1) + cpos(1) / 12; 
             chandle.Position(3) = cpos(3) / 1.5; 
             chandle.Title.String =  'Speed (\mu{}m/s)'; 
             chandle.Title.FontSize = 14; 
             
             %hold off
             
             ErcagGraphics
             set(gca, 'DataAspectRatio', [1 1 1]);
             axis tight
             axis([0 400 0 350 -110 110])
             xlabel('x (\mu{}m)')
             ylabel('y (\mu{}m)')
             zlabel('z (\mu{}m)')        
                         
             ax = gca;    
             ax.Title.FontSize = 13;
             ax.Clipping = 'off';
             rotate3d on
             
             k = 1; 
             for i=3:(N-3)
                 speedindex = max(1,min(maxV, round(V(i))));
                 plot3(X(i,1), X(i,2), X(i,3), 'o', 'MarkerEdgeColor', speedcolor(speedindex,:),'MarkerSize', MarkerSize, 'MarkerFaceColor', speedcolor(speedindex,:));                 
                                  
                 if  ~isempty(RunEnd) && ~isempty(RunSt) && any(i == RunEnd) 
                     ax.Title.Color = [1 0 0];
                     ax.Title.FontSize = 16; 
                     ax.Title.String = {['Turn(!) No. ' num2str(k)],num2str(Frame_No(i))};
                     
                     plot3(X(i,1), X(i,2), X(i,3), 'o', 'MarkerEdgeColor',[1 0 0], 'MarkerSize', 10, 'LineWidth', 1.5) 
                     
                     pause(0.5); 
                     drawnow();
                     
%                      if i == RunSt(k) && k < length(RunSt) 
                       k = k + 1;                          
%                      end
                 else
                     ax.Title.Color = [0 0 0]; 
                     ax.Title.String = num2str(Frame_No(i));
                     drawnow();
                 end
                 
                 %pause(0.1)
             end
             

        
    end                           
end
