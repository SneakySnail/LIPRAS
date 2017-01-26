function points = selectPointsFromPlot(handles, numpoints)
%SELECTPOINTSFROMPLOT selects points on the plot until the ENTER key is pressed.
%   If the ESCAPE key is pressed, POINTS will be empty.
import utils.plotutils.*
ESCAPE_KEY = 27;
KEY_ENTER = 13;
points = [];
hold(handles.axes1, 'on')

while (true)
    if nargin > 1 && numpoints == 0
        break;
    end
    
    [p key] = selectPoint(handles.axes1);
    if isempty(key) || key == KEY_ENTER
        break
    elseif key == ESCAPE_KEY
        return
    end
        
    xdata = handles.profiles.xrd.getTwoTheta;
    ydata = handles.profiles.xrd.getData(handles.gui.CurrentFile);
    xidx = utils.findIndex(xdata, p);
    plot(handles.axes1, p, ydata(xidx), '*r');
    points = [points p]; %#ok<AGROW>
    if nargin > 1 && numpoints > 0
         numpoints = numpoints - 1;
    end
end

