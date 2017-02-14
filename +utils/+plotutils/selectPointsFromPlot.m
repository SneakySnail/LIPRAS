function points = selectPointsFromPlot(handles, mode, numpoints)
%SELECTPOINTSFROMPLOT selects points on the plot until the ENTER key is pressed.
%   If the ESCAPE key is pressed, POINTS will be empty.
import utils.plotutils.*
ESCAPE_KEY = 27;
KEY_ENTER = 13;
points = [];
if nargin < 2
    mode = 'Add';
end

utils.plotutils.plotX(handles, 'data');
if ~strcmpi(mode, 'New') && handles.profiles.xrd.hasBackground
    utils.plotutils.plotX(handles, 'backgroundpoints');
end

while (true)
    if nargin > 2 && numpoints == 0
        break;
    end
    [p key] = selectPoint(handles.axes1);
    if isempty(key) || key == KEY_ENTER
        break
    elseif key == ESCAPE_KEY
        return
    end
        
    dataline = findobj(handles.axes1.Children, 'tag', 'raw');
%     xdata = handles.profiles.xrd.getTwoTheta;
%     ydata = handles.profiles.xrd.getData(handles.gui.CurrentFile);
%     if isequal(handles.gui.Plotter.XScale,'dspace')
%         ydata = handles.profiles
%     end

    xdata = dataline.XData;
    ydata = dataline.YData;
    if strcmpi(mode, 'Delete')
        bkgdplot = findobj(handles.axes1.Children, 'DisplayName', 'Background Points');
        bkgdx = bkgdplot.XData;
        bkgdy = bkgdplot.YData;
        xidx = utils.findIndex(bkgdx, p);
        bkgdx(xidx) = [];
        bkgdy(xidx) = [];
        set(bkgdplot, 'XData', bkgdx, 'YData', bkgdy);
        points = bkgdx;
    else
        xidx = utils.findIndex(xdata, p);
        plot(handles.axes1, p, ydata(xidx), '*r');
        points = [points p]; %#ok<AGROW>
    end
    
    if nargin > 2 && numpoints > 0
         numpoints = numpoints - 1;
    end
end

if strcmpi(handles.gui.Plotter.XScale, 'dspace')
    points = sort(handles.profiles.twotheta(points));
end

