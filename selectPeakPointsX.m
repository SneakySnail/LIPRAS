function points = selectPeakPointsXXX(app)
% returns a NaN if the user presses Esc while selecting points
numpeaks =app.NumberofPeaksSpinner.Value;
points = zeros(1, numpeaks);
lines = app.UIAxes.Children;

dataLine = findobj(app.UIAxes, 'tag', 'Obs');
xdata = dataLine.XData; ydata = dataLine.YData;

[p] = app.PointSelected(2)-200;
key=app.KeyPressed;
points=p;
idx = utils.findIndex(xdata, p);
plot(app.UIAxes, p, ydata(idx), 'xr', 'MarkerSize', 15,'LineWidth',2,'Tag','PeakS');