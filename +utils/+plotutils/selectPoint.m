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
import utils.plotutils.*
ESCAPE_KEY = 27;
ZOOM_KEY = 122;     
MOUSE_CLICK = 0;
KEY_PRESS = 1;
KEY_ENTER = 13;
if nargin < 1
    ax = gca;
end
point = []; 
<<<<<<< HEAD
=======


>>>>>>> c38a598 (Initial App Designer migration)
[x, ~, key] = ginput(1);    

if key == ZOOM_KEY
    % Allow user to zoom in and out if the z key is pressed
    z = zoom(gcf);
    set(z, 'Direction', 'in', 'Enable', 'on');
    z.setAllowAxesZoom(ax, true);
    % Wait for user to press the escape key to exit zoom
    key = MOUSE_CLICK;
    while key == MOUSE_CLICK 
        key = waitforbuttonpress;
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
        % Recurse
        point = selectPoint(ax);
    end
    
else % output point
    point = x;
end % incase some clicks the add or delete half way