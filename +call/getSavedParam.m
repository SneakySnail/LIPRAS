% Used in: [plotSampleFit.m, revertPanel.m, FDGUI.m, fillEmptyCells.m,
% setEnableUpdateButton.m].
function param = getSavedParam(handles)
% param.fcnNames
% param.constraints
% param.coeff
% param.peakPositions

param.fcnNames = handles.xrd.PSfxn;
param.constraints = handles.xrd.Constrains;
param.coeff = handles.xrd.getCoeff(param.fcnNames, param.constraints);
param.peakPositions = handles.xrd.PeakPositions;
param.Data = handles.table_coeffvals.Data;

