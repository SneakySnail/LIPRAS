<<<<<<< HEAD
function bkgdpoints = selectBackgroundPoints(handles, mode)
=======
function bkgdpoints = selectBackgroundPoints(app, mode)
>>>>>>> c38a598 (Initial App Designer migration)
%SELECTPOINTSFROMPLOT selects points on the plot until the ENTER key is pressed.
%   If the ESCAPE key is pressed, BKGDPOINTS is returned as a NaN. If MODE is 'delete' and all the points are
%   deleted, BKGDPOINTS is an empty array.
import utils.plotutils.*
ESCAPE_KEY = 27;
KEY_ENTER = 13;
if nargin < 2
    mode = 'Add';
end
<<<<<<< HEAD
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
=======
% lines = app.axes1.Children;
% if ~isempty(lines)
%     notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
%     delete(app.axes1.Children(notDataLineIdx));
% end
if strcmpi(mode, 'new')
    oldPoints = [];
else
    oldPoints = app.profiles.xrd.getBackgroundPoints;
%     utils.plotutils.plotX(app, 'backgroundpoints'); % Need to plot bkg points in this line
end
while true
    [p, key] = selectPoint(app.UIAxes);
>>>>>>> c38a598 (Initial App Designer migration)
    if isempty(p) || key == KEY_ENTER
        break
    elseif key == ESCAPE_KEY
        bkgdpoints = nan;
        % Delete temporary points in plot
<<<<<<< HEAD
        delete(findobj(handles.axes1.Children, 'tag', ''));
=======
        delete(findobj(app.axes1.Children, 'tag', ''));
>>>>>>> c38a598 (Initial App Designer migration)
        return
    elseif key==3

    if exist('NewPoints','var')==0
        newPoints=oldPoints;
    end
            if isempty(newPoints)
                break
            end
<<<<<<< HEAD
            handles.profiles.BackgroundPoints = newPoints;
lines = handles.axes1.Children;
if ~isempty(lines)
    notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
    delete(handles.axes1.Children(notDataLineIdx));
end
                oldPoints = handles.profiles.xrd.getBackgroundPoints;
                utils.plotutils.plotX(handles, 'backgroundpoints');
                newPoints = deletePoint(handles, p);
=======
            app.profiles.BackgroundPoints = newPoints;
% lines = app.axes1.Children;
% if ~isempty(lines)
%     notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
%     delete(app.axes1.Children(notDataLineIdx));
% end
                oldPoints = app.profiles.xrd.getBackgroundPoints;
                utils.plotutils.plotX(app, 'backgroundpoints');
                newPoints = deletePoint(app, p);
>>>>>>> c38a598 (Initial App Designer migration)
                newPoints = sort(newPoints);  
            RClick=1;

    else
        RClick=0;
    end
    if RClick==1
    else
    switch lower(mode)
        case 'new'
<<<<<<< HEAD
            newPoints = plotPoint(handles, oldPoints, p,'*r');
        case 'add'
            newPoints = plotPoint(handles, oldPoints, p,'*b');
        case 'delete'
            newPoints = deletePoint(handles, p);
=======
            newPoints = plotPoint(app, oldPoints, p,'*r');
        case 'add'
            newPoints = plotPoint(app, oldPoints, p,'*b');
        case 'delete'
            newPoints = deletePoint(app, p);
>>>>>>> c38a598 (Initial App Designer migration)
            if isempty(newPoints)
                break
            end
    end
    end
    oldPoints = newPoints;
    
end
bkgdpoints = sort(newPoints);
% If in d-space, transform to two theta
<<<<<<< HEAD
if strcmpi(handles.gui.Plotter.XScale, 'dspace')
    bkgdpoints = sort(handles.profiles.twotheta(bkgdpoints));
end
% Delete temporary points in plot
delete(findobj(handles.axes1.Children, 'tag', ''));

function newpoints = deletePoint(handles, point)
% Finds the index of POINT in the background line plot and deletes it from the plot, then returns
%   the remaining background points in the plot. 
bkgdplot = findobj(handles.axes1.Children, 'tag', 'background');
=======
if strcmpi(app.gui.Plotter.XScale, 'dspace')
    bkgdpoints = sort(app.profiles.twotheta(bkgdpoints));
end

% Delete temporary points in plot
% delete(findobj(app.axes1.Children, 'tag', ''));

function newpoints = deletePoint(app, point)
% Finds the index of POINT in the background line plot and deletes it from the plot, then returns
%   the remaining background points in the plot. 
bkgdplot = findobj(app.UIAxes.Children, 'tag', 'background');
>>>>>>> c38a598 (Initial App Designer migration)
bkgdx = bkgdplot.XData; bkgdy = bkgdplot.YData;
xidx = utils.findIndex(bkgdx, point);
bkgdx(xidx) = []; bkgdy(xidx) = [];
set(bkgdplot, 'XData', bkgdx, 'YData', bkgdy);
newpoints = bkgdx;

<<<<<<< HEAD
function newpoints = plotPoint(handles, oldPoints, point,col)
dataLine = findobj(handles.axes1.Children, 'tag', 'raw');
xdata = dataLine.XData; ydata = dataLine.YData;
pointIdx = utils.findIndex(xdata, point);
plot(handles.axes1, point, ydata(pointIdx), col,'MarkerSize',8,'LineWidth',1.3);
=======
function newpoints = plotPoint(app, oldPoints, point,col)
dataLine = findobj(app.UIAxes.Children, 'tag', 'Obs');
xdata = dataLine.XData; ydata = dataLine.YData;
pointIdx = utils.findIndex(xdata, point);
plot(app.axes1, point, ydata(pointIdx), col,'MarkerSize',8,'LineWidth',1.3);
>>>>>>> c38a598 (Initial App Designer migration)
newpoints = [oldPoints point];