% Picks one point on a plot and returns an array of length 2 for the 2theta and index
% location. 
%
% Any time the user hits the Esc key while picking points on the plot, the mouse
% pointer switches to the zoom capability. To resume picking points, press the
% Esc key again.
function [point, idx] = selectOnePointFromPlot(ax)
% point - 2theta value. Empty if keypress was anything except a mouse click or Esc
% idx - index into data array. Empty if keypress was anything except a mouse click or Esc

% Constants used in this function
ESCAPE = 27;
MOUSE_CLICK = 0;

% get x value of the selected point
[x, ~, key] = ginput(1); 

% Allow user to zoom in and out if the Esc key is pressed
if key == ESCAPE
    z = zoom(gcf);
    z.Direction = 'in';
    z.Enable = 'on';
    
    % Wait for user to press the escape key to exit zoom
    k = MOUSE_CLICK;
    while k == MOUSE_CLICK
        k = waitforbuttonpress;
    end
    
    % Turn off zoom and resume picking points
    z.Enable = 'off';
    
elseif isempty(x)
    point = []; idx = []; % Return empty if no x input
    return
    
end % incase some clicks the add or delete half way

point = x;
rangedData = get(ax, 'UserData');
idx = FindValue(rangedData(1,:), x);


