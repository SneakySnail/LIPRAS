function btns2_SelectionChangedFcn(hObject, eventdata, handles)
	switch hObject.SelectedObject
		case handles.b2_toggle1		
			set(findobj(handles.panel_parameters), 'visible','on');
			set(handles.panel_coeffs, 'visible', 'off');
			
		case handles.b2_toggle2
			set(findobj(handles.panel_parameters), 'visible','off');
			set(handles.panel_coeffs, 'visible', 'on');
			
	end