% If it is not empty, display the TooltipString for an object in statusbarObj even when it's
% disabled. 
function WindowButtonMotionFcn(hObject, evt, handles)
% 	handles.statusbarObj.setText(['Current point: ', num2str(hObject.CurrentPoint)]);
	
	try
		obj = hittest(hObject);
		if  ~isempty(obj.TooltipString)
			handles.statusbarObj.setText(obj.TooltipString);
		end
	catch
		try
			if strcmpi(class(obj), 'matlab.graphics.chart.primitive.Line')
				handles.statusbarObj.setText(['<html>Current 2&theta; value: ', num2str(obj.CurrentPoint(1, 1))]);
			else
				handles.statusbarObj.setText(handles.xrd.Status);
			end
		catch
			handles.statusbarObj.setText('');
		end
	end