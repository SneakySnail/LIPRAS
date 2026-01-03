function points = selectPeakPoints(app)
% returns a NaN if the user presses Esc while selecting points
numpeaks =app.NumberofPeaksSpinner.Value;
points = zeros(1, numpeaks);
lines = app.UIAxes.Children;

% if ~isempty(lines)
%     notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
%     delete(app.axes1.Children(notDataLineIdx));
%     set(lines(notDataLineIdx==0),'LineStyle','-');
% end
% utils.plotutils.plotX(app, 'backgroundfit');
dataLine = findobj(app.UIAxes, 'tag', 'Obs');
xdata = dataLine.XData; ydata = dataLine.YData;

[p] = app.PointSelected(2)-200;
key=app.KeyPressed;
points=p;
idx = utils.findIndex(xdata, p);
plot(app.UIAxes, p, ydata(idx), 'or', 'MarkerSize', 5,'Tag','PeakS');

% while n~=numpeaks+1 % plus 1 because of n=n+1, otherwise, while loop will terminate
%     [p, key] = utils.plotutils.selectPoint(app.axes1);
%     if ~isempty(key) && key == ESC_KEY
%         points = [];
%         break
%     elseif key==3
%         if sum(points)==0
%             break
%         end
%         points(n-1)=[];
%         n=n-1;
%         delete(app.axes1.Children(1))
%    
%     else
%     if ~isempty(p)
%         points(n) = p;
%         idx = utils.findIndex(xdata, p);
%         plot(app.axes1, p, ydata(idx), '*r', 'MarkerSize', 5);
%     else
%         points = [];
%         break
%     end
%         n=n+1;
%     end
% end
% lines = app.axes1.Children;
% %     If there are lines, remove all other lines except data line
% notDataLineIdx = strcmpi(get(lines, 'tag'), '');
% if ~isempty(lines)
%     delete(lines(notDataLineIdx));
% end
% 
% if strcmp(app.gui.XPlotScale, 'dspace')
%     points = sort(app.profiles.twotheta(points));
% end