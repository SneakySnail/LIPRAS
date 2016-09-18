% Imports new data.
function handles = importData(hObject, eventdata, handles)
	try confirm_new_dataset();
	catch return 
	end
	
	handles.xrdContainer(7) = handles.xrd;
	
	% Function continues from here only if there is data loaded into xrd
	resetPanels();
	
	setObjectAvailability();
	
	
	% Check if there is data loaded
	function confirm_new_dataset()
		try a = call.overwriteExistingFit(handles);
		catch
			handles.xrd = PackageFitDiffractionData;
			a = 'Yes';
		end
		
		if strcmpi(a,'Cancel') || ~handles.xrd.Read_Data % If user cancels action
			handles.xrd.Status = [handles.xrd.Status, 'Canceled: no data was loaded.'];
			error('No data was loaded.') % interrupts function
		end
	end
	
	function resetPanels()
		
		handles = call.addProfile(handles);
		
		for i=1:length(handles.xrd.Filename)
			files{i} = handles.xrd.Filename{i};  %#ok<AGROW>
		end
		
		set(handles.edit8, ...
				'String', handles.xrd.DataPath,...
				'FontAngle','normal', ...
				'ForegroundColor',[0 0 0]);
		set(handles.popup_filename, 'String', files);
		set(handles.listbox_files, 'String', files);
		
		% Make axes options available based on # of files
		numfiles = length(handles.xrd.Filename);
		
		if numfiles > 1 % if there was more than file loaded
			set(handles.checkbox_superimpose,'Visible','on'); % Superimpose Raw Data
			set(handles.radio_stopleastsquares, 'visible', 'on'); % Stop Least Squares
			set(handles.push_viewall,'Visible','on'); % View All
			handles.xrd.Status=['Imported ', num2str(numfiles),' files.'];
		else
			set(handles.checkbox_superimpose,'Visible','off'); % Superimpose Raw Data
			set(handles.radio_stopleastsquares, 'visible', 'off'); % Stop Least Squares
			set(handles.push_viewall,'Visible','off'); % View All
			handles.xrd.Status='Imported 1 file.';
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