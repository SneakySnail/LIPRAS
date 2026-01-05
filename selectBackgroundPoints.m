function bkgdpoints = selectBackgroundPoints(app, mode)
%   Selects background points interactively from the plot. 1-4-2026
%
% Behavior:
%   - User clicks to add/delete points
%   - ESCAPE key returns NaN (cancel)
%   - Right-click deletes nearest background point
%
% Inputs:
%   mode : 'new', 'add', or 'delete'
%
% Outputs:
%   bkgdpoints : sorted vector of background x-positions
%                NaN if user cancels with ESC

% ESCAPE_KEY = 27;
KEY_ENTER = 'escape';

% Default Mode
if nargin < 2
    mode = 'Add';
end

% If new, then oldpoints delete otherwise its new point selection
if strcmpi(mode, 'new')
    oldPoints = [];
else
    oldPoints = app.profiles.xrd.getBackgroundPoints;
end


if isempty(app.PointSelected)
       % Would triger if not empty
else 
[p] = app.PointSelected(2)-200;
key=app.KeyPressed;
end

% -------------------------------------------------------------------------
% Handle ESC key or empty selection
% -------------------------------------------------------------------------
if isempty(p) || isequal(key, KEY_ENTER)
    % Do nothing
elseif isequal(key, KEY_ENTER)
    bkgdpoints = nan;

    % Delete temporary points in plot
    delete(findobj(app.axes1.Children, 'tag', ''));

    return
end

% -------------------------------------------------------------------------
% Right-click behavior (delete)
% -------------------------------------------------------------------------
if key == 3   % Right mouse button

    % Initialize newPoints if not yet defined
    if exist('NewPoints', 'var') == 0
        newPoints = oldPoints;
    end

    % Update profile
    app.profiles.BackgroundPoints = newPoints;

    % Refresh background points plot
    oldPoints = app.profiles.xrd.getBackgroundPoints;
    utils.plotutils.plotX(app, 'backgroundpoints');

    % Delete selected point
    newPoints = deletePoint(app, p);
    newPoints = sort(newPoints);

    RClick = 1;

else
    RClick = 0;
end

    if RClick==1
        % Do nothing
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

    % Update stored points    
oldPoints = newPoints;
    
bkgdpoints = sort(newPoints);

function newpoints = deletePoint(app, point)
% Finds the index of POINT in the background line plot and deletes it from the plot, then returns
%   the remaining background points in the plot. 
bkgdplot = findobj(app.UIAxes.Children, 'tag', 'Bkgpts');
bkgdx = [bkgdplot.XData]; bkgdy = [bkgdplot.YData];
xidx = utils.findIndex(bkgdx, point);
bkgdx(xidx) = []; bkgdy(xidx) = [];
delete(app.UIAxes.Children(xidx));
newpoints = bkgdx;

function newpoints = plotPoint(app, oldPoints, point,col)
dataLine = findobj(app.UIAxes.Children, 'tag', 'Obs');
xdata = dataLine.XData; ydata = dataLine.YData;
pointIdx = utils.findIndex(xdata, point);
plot(app.UIAxes, point, ydata(pointIdx), col,'MarkerSize',8,'LineWidth',1.3,'Tag','Bkgpts');
newpoints = [oldPoints point];