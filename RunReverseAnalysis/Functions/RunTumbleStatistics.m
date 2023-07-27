function RTStats = RunTumbleStatistics(T,S,lTrajectory)


fps=30;
TSubset = T(lTrajectory,:); 
SSubset = S.Speeds(lTrajectory); 

% some filter
k1=cellfun(@(x) (~isempty(x)), TSubset(:,1));
medV=cell2mat(cellfun(@(x) (medianN(x(:,9))), SSubset, 'UniformOutput', 0));
k2=cellfun(@(x) (~isempty(x)), SSubset);

k=k1;
sum(k)
%trace lengths
TraceLength=cellfun(@(x) ( size(x,1)  ), SSubset);
k0=medV>17 & TraceLength > 3*fps;



RunLengths=[];
TumbleLengths=[];
TurningAngles=[];

TurningAngles2D=[];

for i=1:size(TSubset,1)
    
    %apply filter
    if k(i)
        
        runstart=TSubset{i,2};
        runend=TSubset{i,3};
        
        %tumble durations
        if ~isempty(runstart)
            tumblelengths=runstart-runend(1:length(runstart))-1;
            TumbleLengths=[ TumbleLengths tumblelengths];
        end
        %run lengths
        runlengths=runend(2:length(runstart))-runstart(1:(end-1))+1;
        RunLengths=[RunLengths runlengths];
        
        
        %turning angles
        
        for j=1:length(runstart)
            
            if runend(j)>4 && runstart(j)<TraceLength(i)-4
                ind1=(runend(j)-2):runend(j) ;
                ind2=runstart(j):(runstart(j)+2);
                %3D turning angle
                v1=SSubset{i}(ind1,6:8);
                v2=SSubset{i}(ind2,6:8);
                v1=sum(v1,1);
                v2=sum(v2,1);
                absv1=sqrt( v1*v1');
                absv2=sqrt( v2*v2');
                alpha= acosd( (v1*v2')/(absv1*absv2) );
                TurningAngles=[TurningAngles alpha];
                
                %2D turning angle projection
                v1=SSubset{i}(ind1,6:7);
                v2=SSubset{i}(ind2,6:7);
                v1=sum(v1,1);
                v2=sum(v2,1);
                absv1=sqrt( v1*v1');
                absv2=sqrt( v2*v2');
                alpha2D= acosd( (v1*v2')/(absv1*absv2) );
                TurningAngles2D=[TurningAngles2D alpha2D];
                
                
            end
        end
    end
    
end
RunLengths=RunLengths/fps;
TumbleLengths=TumbleLengths/fps;

RTStats.RunLengths = RunLengths; 
RTStats.TumbleLengths = TumbleLengths; 
RTStats.TurningAngles = TurningAngles; 
RTStats.TurningAngles2D = TurningAngles2D; 

return
%% Plot results
f1=figure('Position', [ 50 50 1000 900]);

ax0=subplot(2,2,1);
KatjasGraphics
maxV=120;
BinSizeV=4;
edgesV=0:BinSizeV:maxV;
nV=histc(medV, edgesV);
stairs(edgesV, nV,'b-');
xlabel('median speed (\mu{}m/s)')
ylabel('# bacteria')
axis([ 0 maxV 0 150]);
disp(['Swimming speeds: ' num2str(mean(medV(k1))) '\pm' num2str(std(medV(k1))) ' um/s'])


ax1=subplot(2,2,3);
KatjasGraphics
BinSizeR=0.25;
edgesR=0:BinSizeR:8;
nR=histc(RunLengths, edgesR);
NR=length(RunLengths);
cnR=NR-cumsum(nR);
cnR(end)=[];
cnR=[NR cnR];

stairs(edgesR, cnR,'b-');
xlabel('time (s)')
ylabel('# runs longer than given time')
set(gca, 'YScale', 'log');
axis([ 0 6 1 2000])
disp(['Run lengths: ' num2str(mean(RunLengths)) '\pm' num2str(std(RunLengths)) ' s'])

ax2=subplot(2,2,4);
KatjasGraphics
BinSizeT=0.05;
edgesT=0:BinSizeT:2;
nT=histc(TumbleLengths, edgesT);
NT=length(TumbleLengths);
cnT=NT-cumsum(nT);
cnT(end)=[];
cnT=[NT cnT];
stairs(edgesT, cnT,'b-');
xlabel('time (s)')
ylabel('# tumbles longer than given time')
set(gca, 'YScale', 'log');
axis([ 0 1 1 12000])
disp(['Tumble lengths: ' num2str(mean(TumbleLengths)) '\pm' num2str(std(TumbleLengths)) ' s'])



ax3=subplot(2,2,2);
KatjasGraphics
BinSizeAlpha=10;
edgesAlpha=0:BinSizeAlpha:180;
nA=histc(TurningAngles, edgesAlpha);
stairs(edgesAlpha, nA,'b-');
xlabel('turning angle (degrees)')
ylabel('# tumbles')
axis([ 0 180 0 1.1*max(nA)]);
disp(['Turning angles: ' num2str(mean(TurningAngles)) '\pm' num2str(std(TurningAngles)) ' degrees'])

%fit turning angle distribution with isotropic and Gaussian reversal
%distributions:
midBinAlpha=edgesAlpha(2:end)-BinSizeAlpha/2;
NA=sum(nA);
nAp=nA(1:(end-1)); 
p=lsqcurvefit(@(p,midBinAlpha) BinSizeAlpha*NA*(p(1)/2*sind(midBinAlpha)*pi/180 + (1-p(1))*2/sqrt(2*pi*p(2).^2)*exp( -(midBinAlpha-180).^2/(2*p(2).^2) ) ), [ 0.5 10], midBinAlpha, nAp)    
q=lsqcurvefit(@(q,midBinAlpha) BinSizeAlpha*NA*(q(1)/sqrt(2*pi*q(3).^2)*exp( -(midBinAlpha-90).^2/(2*q(3).^2) ) + (1-q(1))*2/sqrt(2*pi*q(2).^2)*exp( -(midBinAlpha-180).^2/(2*q(2).^2) ) ), [ 0.5 10 60], midBinAlpha, nAp)    


hold on
%plot(midBinAlpha, NA*2/sqrt(2*pi*p(2)^2)*exp(-(180-midBinAlpha).^2/(2*p(2)^2)), 'g-')

%p=[ 1 10];
plot(midBinAlpha,   BinSizeAlpha*NA*(p(1)/2*sind(midBinAlpha)*pi/180 + (1-p(1))*2/sqrt(2*pi*p(2).^2)*exp( -(midBinAlpha-180).^2/(2*p(2).^2) ) ), 'r-');

plot(midBinAlpha, BinSizeAlpha*NA*(q(1)/sqrt(2*pi*q(3).^2)*exp( -(midBinAlpha-90).^2/(2*q(3).^2) ) + (1-q(1))*2/sqrt(2*pi*q(2).^2)*exp( -(midBinAlpha-180).^2/(2*q(2).^2) ) ), 'g-')
hold off





f2=figure;
TumbleFreq=NaN(length(TSubset),1);
%RunLengthsV=[];

for i=1:length(TSubset)
    
        if k1(i)
            runstart=TSubset{i,2};
            runend=TSubset{i,3};
            %RunLengthsV=[RunLengthsV  ; runlengths repmat(medV(i),length(runlengths),1)];
            
            TumbleFreq(i)=length(runend)/TraceLength(i)*fps;
       
        end
    
end

k3=~isnan(medV.*TumbleFreq);
%plot(medV(k3), TumbleFreq(k3), 'ok');
colourlength=jet(100);

for i=1:length(medV)
    if k3(i)
        
        plot(medV(i), TumbleFreq(i),'o', 'color', colourlength(min(TraceLength(i),size(colourlength,1)),:));
        hold on;
    end
end
hold off
%plot(RunLengthsV(:,2),RunLengthsV(:,1), 'ok') ;
KatjasGraphics
xlabel('median speed')
ylabel('tumble frequency (s^{-1})')
zlabel('trajectory length (s)')
%ylabel('run length (s)')
[R, p]=corrcoef(medV(k3), TumbleFreq(k3));
%[R, p]=corrcoef(RunLengthsV(:,2),RunLengthsV(:,1));
disp(['Correlation between speed and tumble frequency: R= ' num2str(R(1,2)) ', R^2= ' num2str(R(1,2)^2) ', p= ' num2str(p(1,2)) '.'])
%disp(['Correlation between speed and run length: R= ' num2str(R(1,2)) ', R^2= ' num2str(R(1,2)^2) ', p= ' num2str(p(1,2)) '.'])


