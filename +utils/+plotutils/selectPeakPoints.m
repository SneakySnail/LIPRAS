function points = selectPeakPoints(handles)
% returns a NaN if the user presses Esc while selecting points
ESC_KEY = 27;
numpeaks = handles.profiles.NumPeaks;
points = zeros(1, numpeaks);
lines = handles.axes1.Children;
if ~isempty(lines)
    notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
    delete(handles.axes1.Children(notDataLineIdx));
end
utils.plotutils.plotX(handles, 'backgroundfit');
dataLine = findobj(handles.axes1, 'tag', 'raw');
xdata = dataLine.XData; ydata = dataLine.YData;
for i=1:numpeaks
    [p, key] = utils.plotutils.selectPoint(handles.axes1);
    if ~isempty(key) && key == ESC_KEY
        points = [];
        break
    end
    if ~isempty(p)
        points(i) = p;
        idx = utils.findIndex(xdata, p);
        plot(handles.axes1, p, ydata(idx), '*r', 'MarkerSize', 5);
    else
        points = [];
        break
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