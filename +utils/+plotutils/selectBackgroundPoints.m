function bkgdpoints = selectBackgroundPoints(handles, mode)
%SELECTPOINTSFROMPLOT selects points on the plot until the ENTER key is pressed.
%   If the ESCAPE key is pressed, BKGDPOINTS is returned as a NaN. If MODE is 'delete' and all the points are
%   deleted, BKGDPOINTS is an empty array.
import utils.plotutils.*
ESCAPE_KEY = 27;
KEY_ENTER = 13;
if nargin < 2
    mode = 'Add';
end
lines = handles.axes1.Children;
if ~isempty(lines)
    notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
    delete(handles.axes1.Children(notDataLineIdx));
end
if strcmpi(mode, 'new')
    oldPoints = [];
else
    oldPoints = handles.profiles.xrd.getBackgroundPoints;
    utils.plotutils.plotX(handles, 'backgroundpoints');
end
while true
    [p, key] = selectPoint(handles.axes1);
    if isempty(p) || key == KEY_ENTER
        break
    elseif key == ESCAPE_KEY
        bkgdpoints = nan;
        % Delete temporary points in plot
        delete(findobj(handles.axes1.Children, 'tag', ''));
        return
    end
    switch lower(mode)
        case 'new'
            newPoints = plotPoint(handles, oldPoints, p);
        case 'add'
            newPoints = plotPoint(handles, oldPoints, p);
        case 'delete'
            newPoints = deletePoint(handles, p);
            if isempty(newPoints)
                break
            end
    end
    oldPoints = newPoints;
    
end
bkgdpoints = sort(newPoints);
% If in d-space, transform to two theta
if strcmpi(handles.gui.Plotter.XScale, 'dspace')
    bkgdpoints = sort(handles.profiles.twotheta(bkgdpoints));
end
% Delete temporary points in plot
delete(findobj(handles.axes1.Children, 'tag', ''));

function newpoints = deletePoint(handles, point)
% Finds the index of POINT in the background line plot and deletes it from the plot, then returns
%   the remaining background points in the plot. 
bkgdplot = findobj(handles.axes1.Children, 'tag', 'background');
bkgdx = bkgdplot.XData; bkgdy = bkgdplot.YData;
xidx = utils.findIndex(bkgdx, point);
bkgdx(xidx) = []; bkgdy(xidx) = [];
set(bkgdplot, 'XData', bkgdx, 'YData', bkgdy);
newpoints = bkgdx;

function newpoints = plotPoint(handles, oldPoints, point)
dataLine = findobj(handles.axes1.Children, 'tag', 'raw');
xdata = dataLine.XData; ydata = dataLine.YData;
pointIdx = utils.findIndex(xdata, point);
plot(handles.axes1, point, ydata(pointIdx), '*r');
newpoints = [oldPoints point];