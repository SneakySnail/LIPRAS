function handles = fitdata(~, ~, handles)
% hObject is push_fitdata

% Get saved parameter values 
fnames = handles.xrd.PSfxn;

data = handles.table_coeffvals.Data;	% initial parameter values to use
SP = []; 
UB = []; 
LB = [];

% Save table_coeffvals into SP, LB, and UB variables
for i = 1 : length(handles.table_coeffvals.RowName)
	SP(i) = data{i,1};
	LB(i) = data{i,2};
	UB(i) = data{i,3};
end

axes(handles.axes1)
peakpos = handles.xrd.PeakPositions;			% Initial peak positions guess
handles.xrd.fitData(peakpos, fnames, SP, UB, LB);	% Function - fit data

filenum = get(handles.popup_filename, 'Value');		% The current file visible
handles.xrd.plotFit(filenum);					  % Plot current file
vals = handles.xrd.fit_parms{filenum};			% The fitted parameter results

handles.table_coeffvals.Data = data;
