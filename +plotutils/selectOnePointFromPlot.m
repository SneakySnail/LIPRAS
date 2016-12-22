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
ESCAPE_KEY = 27;
ZOOM_KEY = 122;     % Key to press to enable zoom
MOUSE_CLICK = 0;

% get x value of the selected point
[x, ~, key] = ginput(1); 

% Allow user to zoom in and out if the Esc key is pressed
if key == ZOOM_KEY
    z = zoom(gcf);
    z.Direction = 'in';
    z.Enable = 'on';
    
    % Wait for user to press the escape key to exit zoom
    k = MOUSE_CLICK;
    while k == MOUSE_CLICK
        k = waitforbuttonpress;
    end
    
    % Turn off zoom
    z.Enable = 'off';
    
elseif isempty(key) || key == ESCAPE_KEY || isempty(x)
    point = []; idx = []; % Return empty if no x input    
    
else % output point
    point = x;
    rangedData = get(ax, 'UserData');
    idx = FindValue(rangedData(1,:), x);
    
end % incase some clicks the add or delete half way




