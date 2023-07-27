function [ax1,ax2, hp1, hp2] = BreakXAxis(InputStructure)
%UNTITLED Plot with broken x axis
%   varargin can be y_err for errorbar plot


x=InputStructure.x;
y=InputStructure.y;
breakpoint=InputStructure.breakpoint;
if isfield(InputStructure, 'Scaling')
    Scaling=InputStructure.Scaling;
else
    Scaling={'lin','log'};
end
if isfield(InputStructure, 'gapsize')
    gapsize=InputStructure.gapsize;
else
    gapsize=0.02;
end

if isfield(InputStructure, 'BottomLeftCorner')
    BottomLeftCorner=InputStructure.BottomLeftCorner;
end

if isfield(InputStructure, 'ylim')
    ylim=InputStructure.ylim;
else
    for j = 1:length(y)
        rangey(j)=max(y{j})-min(y{j});
        ylim{j}=[min(y{j}) max(y{j})]+rangey(j)*[-1 1];
    end
end

if isfield(InputStructure, 'y_err')
    y_err=InputStructure.y_err;
    PlotMode='errorbar';
else
    PlotMode='plot';
end

if isfield(InputStructure, 'YLabels')
    YLabels=InputStructure.YLabels;
    
else
    YLabels={[], []};
end

if isfield(InputStructure, 'XLabels')
    XLabels=InputStructure.XLabels;
    
else
    XLabels={[], []};
end

if isfield(InputStructure, 'RelativeHSize')
    RelativeHSize=InputStructure.RelativeHSize;
    
else
    
end

if isfield(InputStructure, 'MarkerStyle')
    MarkerStyle=InputStructure.MarkerStyle;
    
else
    MarkerStyle={'ko-', 'r*-', 'bs-', 'gd-'};
end


if isfield(InputStructure, 'AxisHandles')
    [ax1, ax2]=InputStructure.AxisHandles;
    
else
    ax1=subplot(121);
    ax2=subplot(122);

end



% hp1=NaN(length(x), 1);
% hp2=hp1;
switch PlotMode
    case 'plot'
        for i=1:length(x)
            % select data
            l1=x{i}<=breakpoint;
            l2=~l1;
            
            axes(ax1);
            hold on;
            hp1{i}=plot(x{i}(l1), y{i}(l1), MarkerStyle{i},'MarkerSize',10,'LineWidth',1.25);
            
            
            axes(ax2);
            hold on;
            hp2{i}=plot(x{i}(l2), y{i}(l2), MarkerStyle{i},'MarkerSize',10,'LineWidth',1.25);
            
            
            % set and maintain equal ylim - Note that length(x) and
            % length(y) must match! (note by EP)
            set([ax1 ax2], 'YLim', ylim{i}) 
            linkprop([ax1 ax2], 'YLim');            
        end
    case 'errorbar'
        for i=1:length(x)
             % select data
            l1=x{i}<=breakpoint;
            l2=~l1;
            
            axes(ax1);
            hold on;
            hp1(i)=errorbar(x{i}(l1), y{i}(l1), y_err{i}(l1), MarkerStyle{i});
            
            
            axes(ax2);
            hold on;
            hp2(i)=errorbar(x{i}(l2), y{i}(l2), y_err{i}(l2), MarkerStyle{i});
        end
        
end

%set chosen scaling (lin/log)
set(ax1, 'XScale', Scaling{1})
set(ax2, 'XScale', Scaling{2})



%% add labels
axes(ax1)
xlabel(XLabels{1});
ylabel(YLabels{1});
ErcagGraphics
axes(ax2)
xlabel(XLabels{2});
ylabel(YLabels{2});
ErcagGraphics

%% axis label positions
set(ax2, 'YAxisLocation','right');

set(ax2, 'YTickLabel', []);
%% set relative size of axes
xlim1=get(ax1, 'XLim');
xlim2=get(ax2, 'XLim');
pos1=get(ax1, 'Position');
pos2=get(ax2, 'Position');

if exist('BottomLeftCorner', 'var')
    
    %adjust height
    pos1(4)=pos1(2)+pos1(4)-BottomLeftCorner(2);
    pos2(4)=pos1(4);
    pos1(2)=BottomLeftCorner(2);
    pos2(2)=BottomLeftCorner(2);
    
    % adjust horizontal width of ax2 
    pos2(3)=pos2(3)+pos1(1)-BottomLeftCorner(1);
    pos2(1)=pos2(1)-pos1(1)+BottomLeftCorner(1);
    pos1(1)=BottomLeftCorner(1);
    
    set(ax1, 'Position', pos1);
    set(ax2,'Position', pos2);
    
    
end


newpos1=pos1;
newpos2=pos2;


if Scaling{1}==Scaling{2}
    
    if exist('RelativeHSize','var')
        
        % fill in sensible code here!
        
    else
        
        if strcmp(Scaling{1}, 'log')
           
            %make the axes size ratio match the log x range ratios
            rangeratio=diff(log(xlim2))/diff(log(xlim1));
            
            % and maintain same left and right edge position
            newpos1(3)=(pos2(1)+pos2(3)-pos1(1)-gapsize)/(1+rangeratio);
            newpos2(3)=rangeratio*newpos1(3);
            newpos2(1)=pos1(1)+newpos(3)+gapsize;
            
            
        elseif strcmp(Scaling{1}, 'lin') % if both scales are linear, 
            
            %make the axes size ratio match the x range ratios
            rangeratio=diff(xlim2)/diff(xlim1);
            
            % and maintain same left and right edge position
            newpos1(3)=(pos2(1)+pos2(3)-pos1(1)-gapsize)/(1+rangeratio);
            newpos2(3)=rangeratio*newpos1(3);
            newpos2(1)=pos1(1)+newpos1(3)+gapsize;
            
            
        end
        
    end
    
else
    if exist('RelativeHSize', 'var')
        
        newpos1(3)=(pos2(1)+pos2(3)-pos1(1)-gapsize)/(1+RelativeHSize);
        newpos2(3)=RelativeHSize*newpos1(3);
        newpos2(1)=pos1(1)+newpos1(3)+gapsize;
                    
    end
        
    
end

% adjust axis positions
set(ax1, 'Position',newpos1);
set(ax2, 'Position',newpos2);

set(ax1, 'Box', 'on')
set(ax2, 'Box', 'on')



end

