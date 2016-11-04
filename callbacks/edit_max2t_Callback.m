
function edit_max2t_Callback(hObject, eventdata, handles)
	handles.xrd.Status = '<html>Editing Max2&theta;...';
	set_profile_range(hObject, handles);
	handles.xrd.Status = ['<html>Max2&theta; was set to ', get(hObject,'String'),'.'];