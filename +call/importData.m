% Imports new data.
function handles = importData(hObject, eventdata, handles)
	try 
		confirm_new_dataset();
	catch 
		dbstop in importData.m:18
	end
	
	% Function continues from here only if there is data loaded into xrd
	resetPanels();
	
	handles = call.addProfile(handles);
	
	setObjectAvailability();
	
	
	% Check if there is data loaded
	function confirm_new_dataset()
		try a = call.overwriteExistingFit(handles);
		catch
			a = 'Yes';
		end
		
		if strcmpi(a,'Cancel') || ~handles.xrd.Read_Data % If user cancels action
			handles.xrd.Status = [handles.xrd.Status, 'Canceled: no data was loaded.'];
			error('No data was loaded.') % interrupts function
		end
		
		plotX(handles.popup_filename.Value, guidata(hObject))
	end
	
	function resetPanels()
		for i=1:length(handles.xrd.Filename)
			files{i} = handles.xrd.Filename{i};  %#ok<AGROW>
		end
		
		set(handles.edit8, ...
				'String', handles.xrd.DataPath,...
				'FontAngle','normal', ...
				'ForegroundColor',[0 0 0]);
		set(handles.popup_filename, 'String', files);
		set(handles.listbox_files, 'String', files);
		set(handles.table_results,'ColumnName',files);
		
		% Make axes options available based on # of files
		numfiles = length(handles.xrd.Filename);
		
		if numfiles > 1 % if there was more than file loaded
			set(handles.checkbox_superimpose,'Visible','on', 'enable', 'on'); % Superimpose Raw Data
			set(handles.radio_stopleastsquares, 'visible', 'on'); % Stop Least Squares
			set(handles.push_viewall,'Visible','on'); % View All
			handles.xrd.Status=['Successfully imported. There are ', num2str(numfiles),' files in this dataset.'];
		else
			set(handles.checkbox_superimpose,'Visible','off'); % Superimpose Raw Data
			set(handles.radio_stopleastsquares, 'visible', 'off'); % Stop Least Squares
			set(handles.push_viewall,'Visible','off'); % View All
			handles.xrd.Status='Successfully imported. There is 1 file in this dataset.';
		end
		
		set(handles.text_filenum,'String',['1 of ',num2str(numfiles)]);
		
	end
	
	function setObjectAvailability()
		set(handles.panel_profilecontrol, 'visible', 'on');
		set(handles.panel_range, 'visible','on');
		set(handles.push_removeprofile, 'visible', 'on', 'enable', 'off');
		set(handles.push_addprofile, 'visible', 'on', 'enable', 'on');
		set(handles.panel_rightside,'Visible','on');
		set(handles.menu_save,'Enable','off');
		set(handles.axes2,'Visible','off');
		set(handles.axes2.Children,'Visible','off');
		set(handles.panel_coeffs.Children,'Enable','off');
		set(handles.push_update, 'Enable', 'on');
	end
	
end