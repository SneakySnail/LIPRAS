function displayNameChange(~,  ~, handles)
	
	if strcmpi(handles.uitoggletool5.State,'on')
		lgd = findobj(handles.figure1, 'tag', 'legend');
		if isempty(lgd)
			legend(handles.xrd.DisplayName,'box','off')
		else	
			set(lgd, 'string', handles.xrd.DisplayName, 'visible', 'on');
		end

	end
	
	guidata(handles.figure1, handles)