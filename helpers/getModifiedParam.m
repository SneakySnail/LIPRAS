function param = getModifiedParam(handles)
% param.fcnNames
% param.nFcn
% param.constraints
% param.coeff
% param.peakPositions

try 
	popObjs =  flipud(findobj(handles.uipanel6.Children, ...
		'visible','on','style','popupmenu'));
	nFcn = [popObjs.Value];
	param.fcnNames = num2fnstr(nFcn);
catch
	param.fcnNames = '';
end

param.constraints = handles.uipanel5.UserData;
param.coeff = handles.xrd.getCoeff(param.fcnNames, param.constraints);
param.peakPositions = handles.uitable1.UserData;