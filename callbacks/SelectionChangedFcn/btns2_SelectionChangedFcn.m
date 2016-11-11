function btns2_SelectionChangedFcn(hObject, eventdata, handles)
	switch hObject.SelectedObject
		case handles.b2_toggle1		
			set(findobj(handles.panel_parameters), 'visible','on');
			set(handles.panel_coeffs, 'visible', 'off');
			
		case handles.b2_toggle2
			set(handles.panel_parameters.Children, 'visible','off');
			set(findobj(handles.panel_coeffs), 'visible', 'on');
			set(findobj(handles.btns2), 'visible', 'on');
	end