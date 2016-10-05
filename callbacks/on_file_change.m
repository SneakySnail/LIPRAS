function on_file_change(hObject, filenum, handles)
	% 	filenum=file number, can be an array
	
	set(handles.text_filenum, 'string', [num2str(filenum(1)), ' of ', num2str(length(filenum))]);
	
	if strcmpi(hObject.Tag, 'popup_filename')
		popup_change(hObject, handles);
		
		
	else
		
		
		
	end
	
	
	
function popup_change(hObject, handles)
	% If superimpose box is checked, plot any subsequent data sets together
	if get(handles.checkbox_superimpose,'Value')==1
		% If there is only one dataset plotted
		if length(handles.xrd.DisplayName)==1
			% If the same dataset is chosen
			if strcmp(handles.xrd.Filename(filenum),handles.xrd.DisplayName)
				% Do nothing and exit out of the function
				return
			end
		end
		handles.xrd.plotData(filenum,'superimpose');
	else
		cla
		hold off
		handles.xrd.Status=['File changed to ',handles.xrd.Filename{filenum},'.'];
		plotX(handles.popup_filename.Value, handles);
	end