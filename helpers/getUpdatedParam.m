function param = getUpdatedParam(handles)
% param.fcnNames
% param.constraints
% param.coeff
% param.peakPositions

param.fcnNames = handles.xrd.PSfxn;
param.constraints = handles.xrd.Constrains;
param.coeff = handles.xrd.getCoeff(param.fcnNames, param.constraints);
param.peakPositions = handles.xrd.PeakPositions;

