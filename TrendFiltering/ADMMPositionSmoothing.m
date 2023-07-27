function B_filtered=ADMMPositionSmoothing(B, lambda,plotmode)

B_filtered=B;
ScaleXY=B.Parameters.Refstack.ScaleXY;
ScaleZ=B.Parameters.Refstack.ScaleZ;
fps=B.Parameters.fps;
%lambda=0.25;
B_filtered.lambda=lambda;

B_filtered.Speeds=B.Bugs;
%plotmode='plotoff';

for i=1:length(B.Bugs)
    
    b=B.Bugs{i};
    X=b(:,2:4);
    X(:,1:2)=X(:,1:2)*ScaleXY;
    X(:,3)=X(:,3)*ScaleZ;
    X_filtered=X;
    
    tstart=tic;
    for j=1:3
        X_filtered(:,j)=ADMM(X(:,j),lambda,1);
    end
    %X_filtered=BruteForceNoSpeedChangePositionFiltering(X,lambda);
    tcpu=toc(tstart);
    
    b_filt=b;
    b_filt(:,2:3)=X_filtered(:,1:2)/ScaleXY;
    b_filt(:,4)=X_filtered(:,3)/ScaleZ;
    
    B_filtered.Bugs{i}=b_filt;
    
    t=b(:,1)/fps;
    
    
    [v_raw, V_raw, dalpha_raw]=ComputeVDalpha(t,X);
    [v_filt, V_filt, dalpha_filt]=ComputeVDalpha(t,X_filtered);
    
    

    B_filtered.Speeds{i}=[b_filt v_filt V_filt dalpha_filt];
    B.Speeds{i}=[b v_raw V_raw dalpha_raw];

    
    
    %vraw=sqrt( sum(diff(X,1,1).^2,2) )*fps;
    %vfilt=sqrt( sum(diff(X_filtered,1,1).^2,2) )*fps;
    
    
    
    
    disp(['Bug ' num2str(i) ', \lambda= ' num2str(lambda) ' , ' num2str(tcpu,3) ' seconds for ' num2str(t(end)-t(1),3) ' s.']);
    
    switch plotmode
        case 'ploton'
            figure(1)
            subplot(2,1,1)
            plot(t,V_raw,'ok-');
            hold on;
            plot(t,V_filt, '*-r');
            hold off
            xlabel('time (s)')
            ylabel('speed (microns/s)')
            KatjasGraphics
            legend('raw', 'filtered')
            title(['Bug ' num2str(i) ', \lambda= ' num2str(lambda) ' , ' num2str(tcpu/60,2) ' minutes']);
            subplot(2,1,2)
            plot(t,dalpha_raw,'ok-');
            hold on;
            plot(t,dalpha_filt, '*-r');
            hold off
            xlabel('time (s)')
            ylabel('d\alpha (degrees/frame)')
            KatjasGraphics
            legend('raw', 'filtered')
            set(gcf, 'Position', [ 800 800 1500 400]);
            drawnow;
            
            figure(2)
            subplot(1,2,1);
            PlotColouredSpeedTrajectory(B.Speeds{i}, fps, 120);
            title(['Bug ' num2str(i)]);
            subplot(1,2,2);
            PlotColouredSpeedTrajectory(B_filtered.Speeds{i}, fps, 120);
            title(['Bug ' num2str(i) ', filtered']);
            set(gcf, 'Position', [ 800 100 1500 600]);
            
            drawnow
    end
    
    
end

end


function [v,V, dalpha]=ComputeVDalpha(t,X)

deltat=mean(diff(t), 'omitnan');
v=[diff(X,1,1)/deltat; NaN(1,3)];
V=sqrt( sum(v.^2,2) );

v1=v(1:end-1,:);
v2=v(2:end,:);
V1=V(1:end-1);
V2=V(2:end);
dalpha=real([NaN; acosd(sum(v1.*v2,2)./(V1.*V2)) ]);



end