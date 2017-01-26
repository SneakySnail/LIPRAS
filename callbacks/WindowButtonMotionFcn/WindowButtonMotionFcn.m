% If it is not empty, display the TooltipString for an object in statusbarObj even when it's
% disabled.
function WindowButtonMotionFcn(hObject, evt, handles)
% 	handles.statusbarObj.setText(['Current point: ', num2str(hObject.CurrentPoint)]);
msg = '';
try
    obj = hittest(hObject);
    if  ~isempty(obj.TooltipString)
        msg = obj.TooltipString;
    end
catch
    try
        xx = num2str(handles.axes1.CurrentPoint(1,1));
        yy = sprintf('%2.3G', handles.axes1.CurrentPoint(1,2));
        if strcmpi(class(obj), 'matlab.graphics.chart.primitive.Line')
            msg = ['Current point: [' xx ', ' yy ']'];
        end
    catch
    end
end

handles.statusbarObj.setText(msg);