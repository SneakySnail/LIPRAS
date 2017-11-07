function points = selectPeakPoints(handles)
% returns a NaN if the user presses Esc while selecting points
ESC_KEY = 27;
numpeaks = handles.profiles.NumPeaks;
points = zeros(1, numpeaks);
lines = handles.axes1.Children;
    handles.gui.PriorityStatus = 'Select peak positions from left to right, right-click delete last point selected';

if ~isempty(lines)
    notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
    delete(handles.axes1.Children(notDataLineIdx));
    set(lines(notDataLineIdx==0),'LineStyle','-');
end
utils.plotutils.plotX(handles, 'backgroundfit');
dataLine = findobj(handles.axes1, 'tag', 'raw');
xdata = dataLine.XData; ydata = dataLine.YData;
n=1;
while n~=numpeaks+1 % plus 1 because of n=n+1, otherwise, while loop will terminate
    [p, key] = utils.plotutils.selectPoint(handles.axes1);
    if ~isempty(key) && key == ESC_KEY
        points = [];
        break
    elseif key==3
        if sum(points)==0
            break
        end
        points(n-1)=[];
        n=n-1;
        delete(handles.axes1.Children(1))
   
    else
    if ~isempty(p)
        points(n) = p;
        idx = utils.findIndex(xdata, p);
        plot(handles.axes1, p, ydata(idx), '*r', 'MarkerSize', 5);
    else
        points = [];
        break
    end
        n=n+1;
    end
end
lines = handles.axes1.Children;
%     If there are lines, remove all other lines except data line
notDataLineIdx = strcmpi(get(lines, 'tag'), '');
if ~isempty(lines)
    delete(lines(notDataLineIdx));
end

if strcmp(handles.gui.XPlotScale, 'dspace')
    points = sort(handles.profiles.twotheta(points));
end