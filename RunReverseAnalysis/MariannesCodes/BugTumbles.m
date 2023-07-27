% BUGTUMBLES 
%
% INPUT :
%   V : Structure of speeds extracted from initial Structure (use
%       BugsToSpeeds_ForStruct to obtain it)
%   f : function used to identify run start/end. Depends on bug type
function [T,indVec] =BugTumbles(V,SpeedThreshold,TimeThreshold,ThreshFactorA)

display='yes'; %change to yes if you wish to see graph of trajectories with detected events

% Taking info from input structure
Speeds=V.Speeds;
ScaleXY=V.Parameters.Refstack.ScaleXY;
ScaleZ=V.Parameters.Refstack.ScaleZ;
RoughFocus=V.Parameters.Refstack.RoughFocus;
fps=V.Parameters.fps;

medV=cell2mat(cellfun(@(x) (nanmedian(x(:,9))), Speeds, 'UniformOutput', 0));

% THRESHOLD
%SpeedThreshold=20;% minimal speed to be included
%TimeThreshold=10;%number of second minimal to be included
T=cell(size(Speeds,1), 3);

disp(strcat('ANALYSIS BUGTUMBLE. Minimal Time :',num2str(TimeThreshold),' s. Minimal Speed :',num2str(SpeedThreshold),' um/s'))


Stats=[];u=0;
% Counter for the if clause inside the loop 
ifk = 1;
for i=1:length(Speeds)

    if ( size(Speeds{i},1)>(TimeThreshold*fps) ) && ( medV(i)>SpeedThreshold )
        disp(['Analyzing Bug ' num2str(i)]);
        %store the index information to recall later 
        indVec(ifk) = i;
        
        X=Speeds{i}(:,2:4);% trajectory from Speeds is the filtered one, already scaled
        dX=Speeds{i}(:,6:8);
        dAlpha=Speeds{i}(:,end);
        
        if strcmp(display,'yes')
            [R,runstart,runend]=RunTumble_Marine(X,dX,dAlpha,fps,ThreshFactorA);
            pause(5)
        else
            [R,runstart,runend]=RunTumble_Marine(X,dX,dAlpha,fps,ThreshFactorA,'noplot');
        end
        
        %medA=nanmedian(dAlpha);
        %medV=nanmedian(Speeds{i}(:,9));
        %       
        T{i,1}=R;
        T{i,2}=runstart;
        T{i,3}=runend;        

        %Stats=[Stats;i,medA,medV];
     ifk = ifk + 1; 
     end
end

end

