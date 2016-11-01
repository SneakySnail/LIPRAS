% Imports new data.
function handles = import_data(handles, filename, path)
	
	[filename, path] = uigetfile({'*.csv;*.txt;*.xy;*.fxye;*.dat;*.xrdml;*.chi;*.spr','*.csv, *.txt, *.xy, *.fxye, *.dat, *.xrdml, *.chi, or *.spr'},'Select Diffraction Pattern to Fit','MultiSelect', 'on');
	if handles.checkbox_reverse.Value == 1
		filename = fliplr(filename);
	end
	[handles.xrdContainer(7), data_in] = handles.xrdContainer(7).Read_Data(filename, path);

	try 
		confirm_new_dataset();
	catch 
		return
	end
	
	for i=1:6
		handles.xrdContainer(i) = PackageFitDiffractionData;
	end
	plotX(handles);
	
	% Function continues from here only if there is data loaded into xrd
	resetPanelData();	
	
	handles = add_profile(handles);
	
	setObjectAvailability(); 
	
	
	% Check if there is data loaded
	function confirm_new_dataset()
% 		try a = call.overwriteExistingFit(handles);
% 		catch
% 			a = '';
% 		end
		a = 'yes';
		
		if strcmpi(a,'Cancel') || ~data_in % If user cancels action
			handles.xrd.Status = [handles.xrd.Status, 'Canceled: no data was loaded.'];
			error('No data was loaded.') % interrupts function			
		end
		
		
	end
	
	function resetPanelData()
		handles.uipanel3 = handles.profiles(7);
		handles.xrd = handles.xrdContainer(7);
		handles = change_profile(7, handles);
		
		for i=1:handles.profiles(7).UserData
			handles = remove_profile(i, handles);
		end
		
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
		set(handles.tabgroup, 'SelectedTab', handles.tab_setup);
		set(findobj(handles.tab_peak.Children), 'Visible', 'off');
		set(findobj(handles.tab_results.Children), 'Visible', 'off');
		set(findobj(handles.tab_setup.Children), 'visible', 'on');
		
		set(handles.edit_min2t, 'String', sprintf('%2.4f', handles.xrd.Min2T));
		set(handles.edit_max2t, 'String', sprintf('%2.4f', handles.xrd.Max2T));
		
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
		set(handles.popup_filename, 'Value', 1);
		
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