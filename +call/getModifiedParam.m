function param = getModifiedParam(handles)
% param.fcnNames
% param.nFcn
% param.constraints
% param.coeff
% param.peakPositions

try
	param.fcnNames = handles.table_paramselection.Data(:, 1);
catch
	param.fcnNames = handles.table_paramselection.Data;
end

param.constraints = handles.panel_constraints.UserData;
param.coeff = handles.xrd.getCoeff(param.fcnNames, param.constraints);
if length(handles.xrd.PeakPositions) > length(param.fcnNames)
	param.peakPositions = handles.xrd.PeakPositions(1:length(param.fcnNames));
else
	param.peakPositions = handles.xrd.PeakPositions; 
end


param.Data = cell(length(param.coeff), 3);
