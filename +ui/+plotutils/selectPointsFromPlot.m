% Picks points on a plot. It returns an array of the 2theta and index 
% location.
% 
% Any time the user hits the Esc key while picking points on the plot, the mouse 
% pointer switches to the zoom capability. To resume picking points, press the 
% Esc key again.
function [points, idx] = selectPointsFromPlot(ax)
% Constants used in this function
ESCAPE = 27;
MOUSE_CLICK = 0;

points = []; 
idx = [];
i = 1;

while (true) 
    [x, ~, key] = ginput(1); % get x value of the selected point
    
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
        continue
            
    elseif isempty(x)
        break
        
    end % incase some clicks the add or delete half way
        
    points(i, 1) = x;
    i = i+1;
    
    idx(i, 1) = FindValue(twotheta, x);
    hold on
    plot(ax, x, intensity(idx(i),1), 'r*') % 'ko'
    
    if isempty(key) || key > 3 % if anything except a mouse click
        break
    end
end

points = sort(points);
idx = sort(pos);
