function bkgdpoints = selectBackgroundPoints(app, mode)
% NEW LIPRAS, 1-9-2020

%SELECTPOINTSFROMPLOT selects points on the plot until the ENTER key is pressed.
%   If the ESCAPE key is pressed, BKGDPOINTS is returned as a NaN. If MODE is 'delete' and all the points are
%   deleted, BKGDPOINTS is an empty array.
% import utils.plotutils.*
% ESCAPE_KEY = 27;
KEY_ENTER = 'escape';
if nargin < 2
    mode = 'Add';
end
% lines = app.axes1.Children;
% if ~isempty(lines)
%     notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
%     delete(app.axes1.Children(notDataLineIdx));
% end
if strcmpi(mode, 'new')
    oldPoints = [];
else
    oldPoints = app.profiles.xrd.getBackgroundPoints;
end
    if isempty(app.PointSelected)
           
    else 
    [p] = app.PointSelected(2)-200;
    key=app.KeyPressed;
    end
    if isempty(p) || isequal(key,KEY_ENTER)
        
    elseif isequal(key,KEY_ENTER)
        bkgdpoints = nan;
        % Delete temporary points in plot
        delete(findobj(app.axes1.Children, 'tag', ''));
        return
    elseif key==3

    if exist('NewPoints','var')==0
        newPoints=oldPoints;
    end

     app.profiles.BackgroundPoints = newPoints;
% lines = app.axes1.Children;
% if ~isempty(lines)
%     notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
%     delete(app.axes1.Children(notDataLineIdx));
% end
             oldPoints = app.profiles.xrd.getBackgroundPoints;
             utils.plotutils.plotX(app, 'backgroundpoints');
             newPoints = deletePoint(app, p);
             newPoints = sort(newPoints);  
             RClick=1;

    else
        RClick=0;
    end
    
    if RClick==1
    else
    switch lower(mode)
        case 'new'
            newPoints = plotPoint(app, oldPoints, p,'*r');
        case 'add'
            newPoints = plotPoint(app, oldPoints, p,'*b');
        case 'delete'
            newPoints = deletePoint(app, p);
    end
    end
    oldPoints = newPoints;
    

bkgdpoints = sort(newPoints);
% If in d-space, transform to two theta
% if strcmpi(app.gui.Plotter.XScale, 'dspace')
%     bkgdpoints = sort(app.profiles.twotheta(bkgdpoints));
% end

% Delete temporary points in plot
% delete(findobj(app.axes1.Children, 'tag', ''));

function newpoints = deletePoint(app, point)
% Finds the index of POINT in the background line plot and deletes it from the plot, then returns
%   the remaining background points in the plot. 
bkgdplot = findobj(app.UIAxes.Children, 'tag', 'Bkgpts');
bkgdx = [bkgdplot.XData]; bkgdy = [bkgdplot.YData];
xidx = utils.findIndex(bkgdx, point);
bkgdx(xidx) = []; bkgdy(xidx) = [];
delete(app.UIAxes.Children(xidx));
% set(bkgdplot, 'XData', bkgdx, 'YData', bkgdy);
newpoints = bkgdx;

function newpoints = plotPoint(app, oldPoints, point,col)
dataLine = findobj(app.UIAxes.Children, 'tag', 'Obs');
xdata = dataLine.XData; ydata = dataLine.YData;
pointIdx = utils.findIndex(xdata, point);
plot(app.UIAxes, point, ydata(pointIdx), col,'MarkerSize',8,'LineWidth',1.3,'Tag','Bkgpts');
newpoints = [oldPoints point];