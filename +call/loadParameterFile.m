function loadParameterFile(handles)
	
	if ~handles.xrd.Read_Inputs
		error('Input file not found.')
	end
	
	handles.xrd.Fmodel=[]; % Delete any previous fits
	handles.panel_coeffs.UserData = handles.xrd.PeakPositions;
	
	set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
	set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
	set(handles.edit_fitrange,'String',num2str(handles.xrd.fitrange));
	set(handles.popup_numpeaks,'Value',length(handles.xrd.PSfxn)+1);
	
	% Set uipanel6/popup functions
% 	popup_numpeaks_Callback(handles.popup_numpeaks, [], handles);
	
% 	call.revertPanel(handles);
	set(handles.tabgroup, 'SelectedTab', handles.tab_peak);
	set(handles.tab_peak, 'ForegroundColor', [0 0 0]);
	
	
% 	push_update_Callback(handles.push_update,[],handles);
	coeff=handles.xrd.Fcoeff;
	
	SP=handles.xrd.fit_initial{1};
	UB=handles.xrd.fit_initial{2};
	LB=handles.xrd.fit_initial{3};
	
	for i=1:length(coeff)
		handles.table_coeffvals.Data{i,1}=SP(i);
		handles.table_coeffvals.Data{i,2}=LB(i);
		handles.table_coeffvals.Data{i,3}=UB(i);
	end
	
	set(handles.panel_coeffs.Children,'Enable','on');

	objs = findobj(handles.uipanel3);
	for i=1:length(objs)
		if isprop(objs(i), 'visible')
			set(objs(i), 'visible', 'on');
		end
	end
	call.plotX(handles);