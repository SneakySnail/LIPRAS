function [point, key] = selectPoint(ax)
%GETPOINT Picks one point on a plot and returns an array of length
% 2 for the 2theta and index location. 
%
% Any time the user hits the Esc key while picking points on the plot, the mouse
% pointer switches to the zoom capability. To resume picking points, press the
% Esc key again.
% 
% point - 2theta value. Empty if keypress was anything except a mouse click or Esc
% idx - index into data array. Empty if keypress was anything except a mouse click or Esc

% Constants used in this function
ESCAPE_KEY = 27;
ZOOM_KEY = 122;     % Key to press to enable zoom
MOUSE_CLICK = 0;
KEY_PRESS = 1;
KEY_ENTER = 13;

import utils.plotutils.*

if nargin < 1
    ax = gca;
end

% Get figure
fig = ax;
while ~isa(fig, 'matlab.ui.Figure')
    fig = fig.Parent;
end

set(0, 'currentfigure', fig);
set(fig, 'currentaxes', ax);

% get x value of the selected point
[x, ~, key] = ginput(1);

    
if key == KEY_ENTER
    point = [];
    
elseif key == ZOOM_KEY
    % Allow user to zoom in and out if the Esc key is pressed
    z = zoom(gcf);
    z.Direction = 'in';
    z.Enable = 'on';
    others = findall(gcf, 'tag', 'axes2');
    z.setAllowAxesZoom(ax, true);
    z.setAllowAxesZoom(others, false);
    % Wait for user to press the escape key to exit zoom
    key = MOUSE_CLICK;
    
    while key == MOUSE_CLICK 
        key = waitforbuttonpress;
        
        % toggle zoom in and out
        if key == KEY_PRESS
            char = get(gcf, 'CurrentCharacter');
            
            if char == 'z'
                if strcmpi(z.Direction, 'in')
                    z.Direction = 'out';
                else
                    z.Direction = 'in';
                end
                key = MOUSE_CLICK;
                
            elseif char == ESCAPE_KEY
                break
            end
        end
    end
    
    % Turn off zoom
    z.Enable = 'off';
    
    if char == KEY_ENTER || char == ESCAPE_KEY
        [point key] = selectPoint(ax);
    end
    
    
else % output point
    point = x;

end % incase some clicks the add or delete half way