<<<<<<< HEAD
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
=======
function points = selectPeakPoints(app)
% returns a NaN if the user presses Esc while selecting points
ESC_KEY= 27;
numpeaks = app.profiles.NumPeaks;
points = zeros(1, numpeaks);
lines = app.UIAxes.Children;
    app.HTML.HTMLSource= '<div align="right"><font size="2" face="Helvetica"><i>Select peak positions from left to right, right-click delete last point selected</i></div>';

if ~isempty(lines)
    notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'Obs');
    delete(app.UIAxes.Children(notDataLineIdx));
    set(lines(notDataLineIdx==0),'LineStyle','-');
end
utils.plotutils.plotX(app, 'backgroundfit');
dataLine = findobj(app.UIAxes, 'tag', 'Obs');
xdata = dataLine.XData; ydata = dataLine.YData;
n=1;

while n~=numpeaks+1 % plus 1 because of n=n+1, otherwise, while loop will terminate
    [p, key] = utils.plotutils.selectPoint(app.UIAxes);
>>>>>>> c38a598 (Initial App Designer migration)
    if ~isempty(key) && key == ESC_KEY
        points = [];
        break
    elseif key==3
        if sum(points)==0
            break
        end
        points(n-1)=[];
        n=n-1;
<<<<<<< HEAD
        delete(handles.axes1.Children(1))
   
=======
        delete(app.UIAxes.Children(1))
>>>>>>> c38a598 (Initial App Designer migration)
    else
    if ~isempty(p)
        points(n) = p;
        idx = utils.findIndex(xdata, p);
<<<<<<< HEAD
        plot(handles.axes1, p, ydata(idx), '*r', 'MarkerSize', 5);
=======
        plot(app.UIAxes, p, ydata(idx), '*r', 'MarkerSize', 15,'MarkerEdgeColor','auto','LineWidth',1.0,'Color',[0.85,0.0,0.0]);
>>>>>>> c38a598 (Initial App Designer migration)
    else
        points = [];
        break
    end
        n=n+1;
    end
end
<<<<<<< HEAD
lines = handles.axes1.Children;
=======
lines = app.UIAxes.Children;
>>>>>>> c38a598 (Initial App Designer migration)
%     If there are lines, remove all other lines except data line
notDataLineIdx = strcmpi(get(lines, 'tag'), '');
if ~isempty(lines)
    delete(lines(notDataLineIdx));
end

<<<<<<< HEAD
if strcmp(handles.gui.XPlotScale, 'dspace')
    points = sort(handles.profiles.twotheta(points));
=======
if strcmp(app.gui.XPlotScale, 'dspace')
    points = sort(app.profiles.twotheta(points));
>>>>>>> c38a598 (Initial App Designer migration)
end