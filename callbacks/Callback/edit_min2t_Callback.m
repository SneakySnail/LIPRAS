function edit_min2t_Callback(hObject, eventdata, handles)
	handles.xrd.Status = ['<html>Editing Min2&theta;... '];
	set_profile_range(hObject, handles);
	
	handles.xrd.Status=['<html>Min2&theta; was set to ', get(hObject,'String'),'.'];