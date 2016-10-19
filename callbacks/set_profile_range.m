function set_profile_range(hObject, handles)
	if strcmpi(hObject.Tag, 'edit_min2t')
		lim = 'min';
	elseif strcmpi(hObject.Tag, 'edit_max2t')
		lim = 'max';
	else
		error('Profile range error')
	end
	

	
	% Check if there is currently a fit
	try call.overwriteExistingFit(handles);
	catch
		return
	end
	
	inputStr = hObject.String;
	inputNum = str2double(inputStr);
	min = str2double(get(handles.edit_min2t, 'String'));
	max = str2double(get(handles.edit_max2t, 'String'));
	
	% Check if valid number
	if isnan(inputNum)
		handles.xrd.Status = ['Error: ', inputStr, ' is not a valid number.'];
		if strcmpi(lim, 'min')
			set(hObject, 'String', sprintf('%2.4f', handles.xrd.Min2T));
		else
			set(hObject, 'String', sprintf('%2.4f', handles.xrd.Max2T));
		end
		return
	end
	
	% If user-inputted min2T is out of range, reset to the default and exit function
	if inputNum < handles.xrd.two_theta(1) || inputNum > handles.xrd.two_theta(end)
		msg=['Warning: ',lim, '2t value is not within bounds.'];
		handles.xrd.Status=[handles.xrd.Status, msg];
		
		if strcmpi(lim, 'min')
			inputNum = handles.xrd.two_theta(1);
			min = inputNum;
		else
			inputNum = handles.xrd.two_theta(end);
			max = inputNum;
		end
		
	end
	
	% If user-inputted min2T is greater than current max2T
	if min >= max
		max = min + handles.xrd.fitrange;
		if max > handles.xrd.two_theta(end)
			max = handles.xrd.two_theta(end);
		end
		handles.xrd.Max2T = max;
		set(handles.edit_max2t,'String',sprintf('%2.4f',max));
	end
	
	if max <= min
		min = max-handles.xrd.fitrange;
		if min < handles.xrd.two_theta(1)
			min = handles.xrd.two_theta(1);
		end
		handles.xrd.Min2T = min;
		set(handles.edit_min2t, 'String',sprintf('%2.4f',min));
	end
	
	% Reset background points if not within profile range
	if ~isempty(handles.xrd.bkgd2th) && ...
			(isempty(find(min<handles.xrd.bkgd2th,1)) ||...
			isempty(find(max>handles.xrd.bkgd2th,1)))
		handles.xrd.bkgd2th=[];
	end
	
	% Reset peak positions if not within profile range
	if ~isempty(handles.xrd.PeakPositions) &&...
			(isempty(find(min<handles.xrd.PeakPositions,1)) || ...
			isempty(find(max>handles.xrd.PeakPositions,1)))
		handles.xrd.PeakPositions=[];
		set(handles.popup_numpeaks,'Value',1);
		handles.xrd.bkgd2th=[];
		call.revertPanel(handles);
	end
	
	% Save into xrd object
	handles.xrd.Min2T = min;
	handles.xrd.Max2T = max;
	

	set(hObject,'String',sprintf('%2.4f', inputNum));
	set(findobj(handles.panel_bkgd), 'visible','on');
	
	handles.xrd.Fmodel=[];
	
	plotX(handles);
	