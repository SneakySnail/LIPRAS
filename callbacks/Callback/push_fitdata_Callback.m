
% Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, ~, handles)
	handles.xrd.Status='Fitting dataset...';
	set(handles.radio_stopleastsquares, 'enable', 'on');
	
	% Get saved parameter values
	fnames = handles.xrd.PSfxn;
	
	data = handles.table_fitinitial.Data;	% initial parameter values to use
	SP = [];
	UB = [];
	LB = [];
	
	% Save table_coeffvals into SP, LB, and UB variables
	for i = 1 : length(handles.table_fitinitial.RowName)
		SP(i) = data{i,1};
		LB(i) = data{i,2};
		UB(i) = data{i,3};
	end
	
	axes(handles.axes1)
	peakpos = handles.xrd.PeakPositions;			% Initial peak positions guess
	handles.xrd.fitData(peakpos, fnames, SP, UB, LB);	% Function - fit data
	
	if handles.radio_stopleastsquares.Value == 1
		set(handles.radio_stopleastsquares, 'value', 0, 'enable', 'off');
		plotX(handles);
		return
	end
	
	filenum = get(handles.popup_filename, 'Value');		% The current file visible
	plotFit(handles, filenum);					  % Plot current file
	vals = handles.xrd.fit_parms{filenum};			% The fitted parameter results
	
	handles.table_fitinitial.Data = data;
	guidata(handles.figure1, handles)
	
	
	
	set(handles.menu_save,'Enable','on');

	
	fill_table_results(handles);

	set(handles.tabpanel, 'TabEnables', {'on', 'on', 'on'});
	set(handles.tab2_next, 'visible', 'on');
	
	handles.xrd.Status = 'Fitting dataset... Done.';
	
	set(handles.radio_stopleastsquares, 'enable', 'off', 'value', 0);
	assignin('base','h',handles)
	guidata(hObject, handles)

	
