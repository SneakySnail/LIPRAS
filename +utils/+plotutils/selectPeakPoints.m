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
    if ~isempty(key) && key == ESC_KEY
        points = [];
        break
    elseif key==3
        if sum(points)==0
            break
        end
        points(n-1)=[];
        n=n-1;
        delete(app.UIAxes.Children(1))
    else
    if ~isempty(p)
        points(n) = p;
        idx = utils.findIndex(xdata, p);
        plot(app.UIAxes, p, ydata(idx), '*r', 'MarkerSize', 15,'MarkerEdgeColor','auto','LineWidth',1.0,'Color',[0.85,0.0,0.0]);
    else
        points = [];
        break
    end
        n=n+1;
    end
end
lines = app.UIAxes.Children;
%     If there are lines, remove all other lines except data line
notDataLineIdx = strcmpi(get(lines, 'tag'), '');
if ~isempty(lines)
    delete(lines(notDataLineIdx));
end

if strcmp(app.gui.XPlotScale, 'dspace')
    points = sort(app.profiles.twotheta(points));
end