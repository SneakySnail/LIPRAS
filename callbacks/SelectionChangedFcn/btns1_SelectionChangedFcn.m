function btns1_SelectionChangedFcn(hObject, eventdata, handles)
	switch(hObject.SelectedObject)
		case handles.b1_toggle2
			set(handles.panel_kalpha2, 'visible', 'on');
			set(handles.panel_range, 'visible', 'off');
			set(handles.panel_bkgd, 'visible', 'off');
		case handles.b1_toggle1
			set(handles.panel_kalpha2, 'visible', 'off');
			set(handles.panel_range, 'visible', 'on');
			set(handles.panel_bkgd, 'visible', 'off');
		case handles.b1_toggle3
			set(handles.panel_kalpha2, 'visible', 'off');
			set(handles.panel_range, 'visible', 'off');
			set(handles.panel_bkgd, 'visible', 'on');
			
	end