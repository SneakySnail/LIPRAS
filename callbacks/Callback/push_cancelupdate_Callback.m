function push_cancelupdate_Callback(o,~,handles)
	set(o,'visible', 'off');
	set(handles.push_update, 'enable', 'off');
	set(handles.edit_numpeaks, 'string', num2str(length(handles.xrd.PSfxn));
	
	
	%***********************************************************
	% Set the constraints back to when fit options were saved/updated
	%***********************************************************
	cs = flip(handles.panel_constraints.Children);
% 	[cs.Value] = deal(
	edit_numpeaks_Callback(handles.edit_numpeaks, [], handles);
	reset_panel_view(handles);