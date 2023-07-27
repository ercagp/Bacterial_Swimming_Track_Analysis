function  TrackSpeedAnalysis(S, whichbug )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


k=whichbug;

ScaleXY=S.Parameters.Refstack.ScaleXY;
ScaleZ=S.Parameters.Refstack.ScaleZ;
RoughFocus=S.Parameters.Refstack.RoughFocus;
fps=S.Parameters.fps;


S=S.Speeds{k};
t=S(:,1)/fps*mean(diff(S(:,1)));
v=S(:,9);
x=S(:,2)*ScaleXY;
y=S(:,3)*ScaleXY;
z=(S(:,4)-RoughFocus)*ScaleZ;
dalpha=S(:,10);


% compute angles between sums of 2 subsequent velocity vectors

vec=S(:,6:8);
vec1= vec(1:end-1,:);
vec2=vec(2:end,:);
vecs=vec1+vec2;
vecs_1=vecs(1:end-2,:);
vecs_2=vecs(3:end,:);
dalpha2=real( acosd(sum(vecs_1.*vecs_2,2)./(  sqrt(sum(vecs_1.^2,2)).*sqrt(sum(vecs_2.^2,2)) ) ) );
dalpha2=[NaN; NaN; dalpha2; NaN];

dX = S(:,6:8);
ind_end = size(dX,1);

dAlpha3=NaN(ind_end,1);

for ind = 4:ind_end-3
    %add velocities
    %add velocities
    dX1=sum(dX(ind-3:ind-1,:));
    dX2=sum(dX(ind:ind+2,:));
    %compute speeds
    V1=sqrt(sum(dX1.^2));
    V2=sqrt(sum(dX2.^2));
    %compute angle between them
    dAlpha3(ind)=acosd ( sum(dX1.*dX2)/(V1*V2) );
end

% vec=S(:,6:8);
% vec1=vec(1:end-2,:);
% vec2=vec(2:end-1,:);
% vec3=vec(3:end,:);
% vecs=vec1+vec2+vec3;
% vecs_1=vecs(1:end-3,:);
% vecs_2=vecs(4:end,:);
% dalpha3=real( acosd(sum(vecs_1.*vecs_2,2)./(  sqrt(sum(vecs_1.^2,2)).*sqrt(sum(vecs_2.^2,2)) ) ) );
%dAlpha3=[NaN; NaN; NaN; dAlpha3; NaN; NaN];

%% speed histogram

figure
vbinsize=min(5,round(max(v)/20));
vbins=0:vbinsize:max(v);
histogram(v, vbins, 'DisplayStyle', 'stairs');
xlabel('v (\mu{}m/s)')
ylabel('counts')
KatjasGraphics



%% over time
PlotVariables=[v, dAlpha3, x, y, z ];
VariableNames={'v (\mu{}m/s)', 'd\alpha3','x (\mu{}m)','y (\mu{}m)','z (\mu{}m)'};

figure('Position', [ 100 100 2000 1000])
[ha, ~] = tight_subplot(5, 1, 0, 0.1, 0.1);
YLimMode={ 'manual', 'manual', 'auto', 'auto', 'auto'};
AxesYLims={[ 0 1.1*max(v)], [ 0 180], [ 0 400], [ 0 350],  110*[ -1 1]}; 
for i=1:length(ha)
    axes(ha(i));
    plot(t,PlotVariables(:,i), 'o-');
    set(ha(i), 'XLim', [t(1) t(end)],...
        'XGrid', 'on',...
        'XMinorGrid', 'on', ...
         'YGrid', 'on',...
        'YMinorGrid', 'on', ...
        'XTickLabel', [] ...
    );
    KatjasGraphics
    ylabel(VariableNames{i})
    if strcmp(YLimMode{i},'manual')
        set(gca, 'YLim', AxesYLims{i});
    end
end
xlabel('time (s)');
set(ha(end), 'XTickLabelMode', 'auto')

% same time zoom for all plots
linkaxes(ha, 'x');


% % add dalpha2 and 'noise line' to dalpha
% axes(ha(2));
% hold on;
% plot(t, dalpha2, '-c')
% %alphaNoiseEstimate=rad2deg(atan(0.5*fps./v));
% %plot(t, alphaNoiseEstimate, '-r');
% hold off


return

n=5;
statecolors={'y', 'y', 'c', 'r',  'g','m'};
vstates=cell(n,1);
legendlabels=cell(n,1);
legendlabels{1}='data';
for j=2:n
    [idx, c]=kmeans(v,j);
    axes(ha(1));
    hold on;
    vstates_temp=v;
    vstates_temp(~isnan(v))=c(idx(~isnan(v)));
    vstates{j}=vstates_temp;
    Partition=NaN(2,1);
    StateConstant=[diff(idx)==0 ; true(1)];
    StateChanges=~StateConstant;
    StateChanges_yesterday=[ false(1) ; StateChanges(1:end-1)];
   
    for i=1:j
        Partition(i)=sum(idx==i)/length(idx);
        
        l_changefrom=idx==i & StateChanges;
        l_changeto= idx==i & StateChanges_yesterday;
         %[idx StateChanges l_changeto l_changefrom]
        t_changefrom=t(l_changefrom);
        t_changeto=t(l_changeto);
        
        if t_changeto(1)<t_changefrom(1)
            if length(t_changeto)>length(t_changefrom)
                t_changefrom=[t_changefrom; NaN];
            end
            Durations{j}{i}=t_changefrom-t_changeto;
        else
            if length(t_changeto)<length(t_changefrom)
                t_changeto=[NaN; t_changeto];
            end
            
        end
        %t_changefrom-t_changeto
        disp([num2str(j) ' ' num2str(i)])
        
        Durations{j}{i}=t_changefrom-t_changeto;
             
        
        
    end
    cnorm=sort(c)/max(c);
    str1=[ num2str(j) ' speed states: ' ];
    str2=[ 'with ratios: '];
    str3=['and partitioning: '];
    
    for i=1:j
        str1=[str1 ' ' num2str(c(i)) ', '];
        str3=[str3 ' ' num2str(Partition(i))];
        
    end
    str1=[ str1 ' um/s'];
    for i=1:(j-1)
        str2=[ str2 ' ' num2str(cnorm(i))  ];
    end
    
    
    for i=1:j
        disp([ 'mean durations state ' num2str(i) ': ' num2str(mean(Durations{j}{i}, 'omitnan'))]);
        
    end
    
    
    TransFreq=sum(~diff(idx(~isnan(idx)),1)==0)/sum(~isnan(idx));
    str4=['transition frequency: ' num2str(TransFreq)];
    
    legendlabels{j}=[num2str(j) ' states'];
    
    disp(str1);
    disp(str2);
    disp(str3);
    disp(str4);
    
    plot(t, vstates{j}, '-', 'Color', statecolors{j})
    
   
   
    
end
hold off
legend(legendlabels)
% Gaussian mixture model 
    vbinsize=min(5,round(max(v)/20));

GaussianSpeedMixture1D(v,n, vbinsize)

% %% speed vs angular change
% 
% figure
% plot(v, dalpha,'k.');
% xlabel('v (\mu{}m/s)')
% ylabel('d\alpha')
% KatjasGraphics

% %% speed PSD
% figure
% [ PSD,f ] = ComputePSD(v(~isnan(v)),fps);
% plot(f,PSD, 'k-');
% set(gca, 'YScale', 'log')
% xlabel('frequency (Hz)')
% ylabel('PSD(v)')
% KatjasGraphics


end

