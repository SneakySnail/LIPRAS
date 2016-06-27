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
if length(handles.xrd.PeakPositions) > length(param.fcnNames)
	param.peakPositions = handles.xrd.PeakPositions(1:length(param.fcnNames));
else
	param.peakPositions = handles.xrd.PeakPositions; 
end


param.Data = cell(length(param.coeff), 4);
