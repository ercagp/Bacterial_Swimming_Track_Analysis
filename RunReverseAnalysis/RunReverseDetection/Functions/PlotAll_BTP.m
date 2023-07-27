    function [hf_dAlpha,hf_dAlpha3,hf_TurnAngle] = PlotAll_BTP(BugIndex,TrajValues,Angles,Runs,fps,SaveFigSwitch)
             
           
             TrajLength = TrajValues.Length;
             runend = Runs.runend; 
             %Plot bug trajectory 
             hf_Traj = PlotTraj_BTP(TrajValues,Runs,fps);
            
             title({[ 'Bug ' num2str(BugIndex) ', t = ' num2str(TrajLength) 's'],['# of TurnEvents = ' num2str(length(runend))]})
             drawnow;

             
             %Mark false positives
             %MarkFP(BugIndex,hf_Traj,SaveFigSwitch,LHead) 
      
            %Plot turning angle distributions (dAlpha & dAlpha3)
            hf_dAlpha = figure(2);
            hf_dAlpha3 = figure(3);
            hf_TurnAngle = figure(4); 
               
            angleEdges = 0:5:180;
              
            figure(hf_dAlpha);
            histogram(Angles.dAlphaTurns,angleEdges,'DisplayStyle','stairs','LineWidth',1);
            xlabel('dAlphaTurns')
            ylabel('Counts')
            ErcagGraphics
               
            figure(hf_dAlpha3)
            histogram(Angles.dAlpha3Turns,angleEdges,'DisplayStyle','stairs','LineWidth',1); 
            xlabel('dAlpha3Turns')
            ylabel('Counts')
            ErcagGraphics
               
            figure(hf_TurnAngle)
            histogram(Angles.ThetaTurnAll,angleEdges,'DisplayStyle','stairs','LineWidth',1);
            xlabel('Turn Angle')
            ylabel('Counts')
            ErcagGraphics
               
            %Save figures?
            if SaveFigSwitch.Flag
               %Set date stamp for export figures
               Date = datetime; 
               LHead = ['[' num2str(year(Date)) num2str(month(Date)) sprintf('%02d',day(Date)) ']'];
               %Define and make folders
               TrajExpFolder = fullfile(SaveFigSwitch.ExpPath,'Trajectories'); 
               dAlpha_Folder = fullfile(SaveFigSwitch.ExpPath,'dAlphaDist');
               dAlpha3_Folder = fullfile(SaveFigSwitch.ExpPath,'dAlpha3Dist');
               TurnAngle_Folder = fullfile(SaveFigSwitch.ExpPath,'TurnAngleDist');
               if ~(exist(dAlpha_Folder,'dir') && exist(dAlpha3_Folder,'dir') && exist(TurnAngle_Folder,'dir') && exist(TrajExpFolder,'dir'))
                  mkdir(TrajExpFolder); 
                  mkdir(dAlpha_Folder);
                  mkdir(dAlpha3_Folder);
                  mkdir(TurnAngle_Folder);
               end
               
               Traj_File = [LHead '[Traj]Bug#' num2str(BugIndex)];
               dAlpha_File = [LHead '[dAlphaDist]Bug#' num2str(BugIndex)];
               dAlpha3_File = [LHead '[dAlpha3Dist]Bug#' num2str(BugIndex)]; 
               TurnAngle_File = [LHead '[TurnAngleDist]Bug#' num2str(BugIndex)];
               
              
               FileFormat = SaveFigSwitch.Format; 
              
               savefig(hf_Traj,fullfile(TrajExpFolder,Traj_File));
               printfig(hf_dAlpha,fullfile(dAlpha_Folder,dAlpha_File),FileFormat); 
               printfig(hf_dAlpha3,fullfile(dAlpha3_Folder,dAlpha3_File),FileFormat);
               printfig(hf_TurnAngle,fullfile(TurnAngle_Folder,TurnAngle_File),FileFormat);
               
            end
                        
            
        function MarkFP(hf)
            %Marking false positives
            QMark = input('Mark False Positives?[Y/N]','s');
            if strcmp(QMark,'Y')
                Qi = 1;
               QPoints = 'Y';
               while strcmp(QPoints,'Y')
               figure(hf)
               % Enable data cursor mode
               datacursormode on
               dcm_obj = datacursormode(figure(hf));
               % Wait while the user to click
               disp('Click to select the point, then press "Return"')
               pause 
               % Export cursor to workspace
               ClickStruct = getCursorInfo(dcm_obj);
               SelectedP(Qi,:) = ClickStruct.Position;
               %Draw the sphere to the selected point
               hold on 
               [XMark, YMark, ZMark] = sphere(20);
               r = 0.5;
               Xs = XMark*r;
               Ys = YMark*r;
               Zs = ZMark*r;
               hSurf = surf(Xs+SelectedP(Qi,1),Ys+SelectedP(Qi,2),Zs+SelectedP(Qi,3)); 
               hSurf.EdgeColor = rgb('gray');
               hSurf.FaceColor = rgb('LightSkyBlue');
               hSurf.FaceLighting = 'gouraud'; 
               hSurf.EdgeAlpha = 0.2;
               hSurf.FaceAlpha = 0.2;
               
               Qi = Qi+1; 
               QPoints = input('Another Point to Mark?[Y/N]','s'); 
               end
               hold off 
            end
        end
    end