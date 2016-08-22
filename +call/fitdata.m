function handles = fitdata(~, ~, handles)
% hObject is push_fitdata

% Get saved parameter values 
param = call.getSavedParam(handles);
fnames = param.fcnNames;

data = handles.uitable1.Data;								% initial parameter values to use
SP = []; 
UB = []; 
LB = [];

% Save uitable1 into SP, LB, and UB variables
for i = 1 : length(handles.uitable1.RowName)
	SP(i) = data{i,1};
	LB(i) = data{i,2};
	UB(i) = data{i,3};
end

axes(handles.axes1)
peakpos = handles.xrd.PeakPositions;					% Initial peak positions guess
handles.xrd.fitData(peakpos, fnames, SP, UB, LB);	% Function - fit data

filenum = get(handles.popup_filename, 'Value');		% The current file visible
handles.xrd.plotFit(filenum);								  % Plot current file
vals = handles.xrd.fit_parms{filenum};					 % The fitted parameter results

% Populate formatted results column in GUI table
for i=1:length(vals) 
	data{i,4} = ['<html><table border=0 width=75 ', ... 
		'bgcolor=#E5E4E2><tr><td align="right"><b>',...
		num2str(vals(i),'%6G'), '</b></td></tr></table></html>'];
end

handles.uitable1.Data = data;
