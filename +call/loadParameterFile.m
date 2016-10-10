function loadParameterFile(handles)
	
	if ~handles.xrd.Read_Inputs
		handles.xrd.Status = '<html><font color="red">Error: Input file not found.';
		error('Input file not found.')
	end
	
	handles.xrd.Fmodel=[]; % Delete any previous fits
	handles.panel_coeffs.UserData = handles.xrd.PeakPositions;
	
	% tab_setup
	set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
	set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
	set(handles.edit_fitrange,'String',num2str(handles.xrd.fitrange));
	
	% tab_parameters
	set(handles.tabgroup, 'SelectedTab', handles.tab_peak);
	set(handles.tab_peak, 'ForegroundColor', [0 0 0]);
	
	set(handles.text12,'visible','on');
	set(handles.edit_numpeaks,'visible','on','String',num2str(length(handles.xrd.PSfxn)));
	FDGUI('edit_numpeaks_Callback', handles.edit_numpeaks, [], guidata(handles.figure1));
	
	% load peak functions into table
	assert(length(handles.xrd.PSfxn)==length(handles.table_paramselection.Data(:,1)));
	handles.table_paramselection.Data(:, 1) = handles.xrd.PSfxn';
	
	% load constraints into constraints panel
	handles.panel_constraints.UserData = handles.xrd.Constrains;
	
	SP=handles.xrd.fit_initial{1};
	UB=handles.xrd.fit_initial{2};
	LB=handles.xrd.fit_initial{3};
	
	coeff=handles.xrd.Fcoeff;
	handles.table_coeffvals.RowName = coeff;
	handles.table_coeffvals.Data=cell(length(coeff), 3);
	
	for i=1:length(coeff)
		handles.table_coeffvals.Data{i,1}=SP(i);
		handles.table_coeffvals.Data{i,2}=LB(i);
		handles.table_coeffvals.Data{i,3}=UB(i);
	end
	
	set(handles.panel_coeffs,'Visible','on');
	set(handles.panel_coeffs.Children,'Enable','on', 'visible','on');
	set(handles.push_selectpeak,'string','Reselect Peak(s)');
	
	
	plotX(handles);