classdef LiprasDialog
    properties (Constant)
        ScreenSize = get(0, 'ScreenSize');
        
    end
    
    methods (Static)
        function d = fittingDataSet()
        % Creates a dialog box with a Cancel button while waiting for fitting to complete.
        dSize = [300 100];
        dPosition = 0.5*[LiprasDialog.ScreenSize(4)-dSize(1), LiprasDialog.ScreenSize(4)-dSize(2)];
        d = dialog('Name', 'Fitting Dataset...', 'Position', [dPosition dSize]);
        uicontrol(d, 'Style', 'text', 'String', 'Peak fitting in progress. Please wait...', ...
            'FontName', 'default', 'FontSize', 10, 'Units', 'normalized', 'tag', 'text', ...
            'Position', [0.1 0.5 0.8 0.3]);
        btnSize = [75 30];
        uicontrol(d, 'Style', 'pushbutton', 'Tag', 'btn', 'String', 'Cancel', ...
            'FontName', 'default', 'FontSize', 10, 'Units', 'pixels', ...
            'Position', [0.5*[dSize(1)-btnSize(1), 0.7*dSize(2)-btnSize(2)], btnSize], ...
            'Callback', 'delete(gcf)');
        end
    end
end