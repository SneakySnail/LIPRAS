            function click_selection(app, event)
            temp = app.UIAxes.CurrentPoint; % Returns 2x3 array of points
            loc = [temp(1,1) temp(1,2)]; % Gets the (x,y) coordinates
            disp(loc)
            end  