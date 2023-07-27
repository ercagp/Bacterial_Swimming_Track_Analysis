function Results= IterativeRunTumbleAnalysisFinal(B,AnalysisParam,varargin)
minV = AnalysisParam.minV;
minT = AnalysisParam.minT; 
AbsT = AnalysisParam.AbsT; %Note that absolute angle threshold is being used
N = AnalysisParam.N;

if nargin > 2
    plotswitch = varargin{1}; 
    SaveFigSwitch = varargin{2};
else
   plotswitch = false;
   SaveFigSwitch.Flag = false;
   SaveFigSwitch.ExpPath = [];
   SaveFigSwitch.Format = [];
end

n = length(AbsT);
m=1;
AlphaThresholdVec = ones(1,length(B.Speeds)).*AbsT; 


%full median speeds and deviations from the median
medV=cell2mat(cellfun(@(x) (medianN(x(:,9))), B.Speeds, 'UniformOutput', 0));
medDalpha=cell2mat(cellfun(@(x) (medianN(x(:,10))), B.Speeds, 'UniformOutput', 0));
admV=cell2mat(cellfun(@(x) (admN(x(:,9))), B.Speeds, 'UniformOutput', 0));
%admDalpha=cell2mat(cellfun(@(x) (admN(x(:,10))), S, 'UniformOutput', 0));
TrajLength=cell2mat(cellfun(@(x) (size(x,1)/B.Parameters.fps), B.Speeds, 'UniformOutput', 0));

 
%Which tracks to consider?
lTrajectory=medV>minV & TrajLength>minT;

Results=struct('RTStats',[]);
Results(1:n, 1:m,1:N)=deal(Results);
   

%% start iterating
% go through values
for i=1:n
    for j=1:m
        
                
        %initial median run speed estimates: full median
        medRDalpha=medDalpha;
        medRV=medV;
        admRV=admV;
        %admRDalpha=admDalpha;
        
        iteration=1;
        while iteration<=N
            disp(['Working on iteration ' num2str(iteration) '.'])
      
            if iteration==N
                %close all;
                %T=BugTumblesParam(S,lTrajectory,@AngleOnly,medRDalpha*(1+AT(i)),'ploton');
                %Use absolute angular threshold
                [T, AngleCell, ConditionCell] = BugTumblesParam(B,lTrajectory,AlphaThresholdVec,plotswitch,SaveFigSwitch);
            else
                %T=BugTumblesParam(S,lTrajectory,@AngleOnly,medRDalpha*(1+AT(i)),'plotoff');
                [T, AngleCell, ConditionCell] = BugTumblesParam(B,lTrajectory,AlphaThresholdVec,plotswitch,SaveFigSwitch);

            end
            
            %identify all the time points where running
            k=cellfun(@(x) (any(x,2)),T(:,1),'UniformOutput', 0);
            
            %All running speeds
            RunningSpeeds=cell(1,size(T,1));
            for l=1:size(T,1)
                RunningSpeeds{l}=B.Speeds{l}(k{l},9:10);
            end
            %median of running speeds
            medRV=cellfun(@(x) (medianN(x(:,1))), RunningSpeeds, 'UniformOutput',1);
            %medRV=cell2mat(cellfun(@(x) (medianN(x(:,1))), RunningSpeeds, 'UniformOutput',1)');
            meanRV=cellfun(@(x) (meanN(x(:,1))), RunningSpeeds, 'UniformOutput',1);
            msRV=cellfun(@(x) (meanN(x(:,1).^2)), RunningSpeeds, 'UniformOutput',1);
            medRDalpha=cell2mat(cellfun(@(x) (medianN(x(:,2))), RunningSpeeds, 'UniformOutput',0)');
            admRV=cellfun(@(x) (admN(x(:,1))), RunningSpeeds)';
            %admRDalpha=cellfun(@(x) (admN(x(:,2))), RunningSpeeds)';
   
            %[RunLengths, TumbleLengths, TurningAngles, pvalue, CorrelationCoefficient,TumbleFreq,VRDotProduct,TumbleNumber, TurningAngles2D]=RunTumbleStatisticsParamByInd4(T,S, lTrajectory);
           
           RTStats=RunTumbleStatistics(T,B, lTrajectory);
           %close(gcf);
%            title(['AT=' num2str(AT(i)) ', VT=' num2str(VT(j)) ])
%           Use absolute threshold 
          % title(['AbsT=' num2str(AbsT(i)) ])

             %title(['AT=' num2str(AT(i)) ])
 %           close all;
                       
            
             %Results(i,j,iteration).AlphaThresholds=AT;
             %Use Absolute Angular Threshold 
             Results(i,j,iteration).AlphaThresholds = AbsT; 
             Results(i,j,iteration).T=T;
             Results(i,j,iteration).RTStats=RTStats;
             
            %Results(i,j,iteration).VThresholds=VT(j);
%             Results(i,j,iteration).TurningAngles=TurningAngles;
%             Results(i,j,iteration).TurningAngles2D=TurningAngles2D;
%             
%             Results(i,j,iteration).RunLengths=RunLengths;
%             Results(i,j,iteration).TumbleLengths=TumbleLengths;
%              Results(i,j,iteration).TumbleNumber=TumbleNumber;
%             Results(i,j,iteration).VRDotProduct=VRDotProduct;
%             
%             Results(i,j,iteration).p=pvalue;
%             Results(i,j,iteration).R=CorrelationCoefficient;
%             Results(i,j,iteration).TumbleFreq=TumbleFreq;
%             Results(i,j,iteration).N=length(TumbleLengths);
            Results(i,j,iteration).medRV=medRV;
            Results(i,j,iteration).meanRV=meanRV;
            Results(i,j,iteration).msRV=msRV;
            Results(i,j,iteration).medRDalpha=medRDalpha;
            Results(i,j,iteration).admRV=admRV;
            %Results(i,j,iteration).admRDalpha=admRDalpha;
            Results(i,j,iteration).Ang = AngleCell;  
            Results(i,j,iteration).minT = minT;
            Results(i,j,iteration).minV = minV;
            Results(i,j,iteration).AnalysedTrajNum = sum(lTrajectory);
            %Which selection criterion triggered which trajectory points
            Results(i,j,iteration).ConditionCheck = ConditionCell; 

         
            iteration=iteration+1;
        end
    end
    
    
end



