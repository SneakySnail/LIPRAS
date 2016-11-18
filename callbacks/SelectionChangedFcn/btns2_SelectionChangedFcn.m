function btns2_SelectionChangedFcn(hObject, ~, handles)
set(handles.panel_parameters.Children, 'visible','off');
set(hObject, 'visible', 'on');
set(handles.tab2_prev, 'visible', 'on');

switch hObject.SelectedObject
        case handles.b2_toggle1
                set(handles.text12, 'visible', 'on');
                set(handles.edit_numpeaks, 'visible', 'on');
                guidata.numpeaks([], [], handles);
                
        case handles.b2_toggle2
                set(handles.panel_kalpha2, 'visible','on');
                
        case handles.b2_toggle3
                set(handles.t, 'visible', 'on');
                set(handles.edit_fitrange, 'visible', 'on');
                set(handles.panel_coeffs, 'visible', 'on');
                
end