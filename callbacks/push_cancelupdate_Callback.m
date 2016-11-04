function push_cancelupdate_Callback(o,~,handles)
	set(o,'visible', 'off');
	set(handles.edit_numpeaks, 'string', num2str(length(handles.xrd.PeakPositions)));
	edit_numpeaks_Callback(handles.edit_numpeaks, [], handles);
	reset_panel_view(handles);