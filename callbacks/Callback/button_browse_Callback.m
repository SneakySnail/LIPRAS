%  Executes on button press in button_browse.
function button_browse_Callback(hObject, eventdata, handles)
	handles.xrd.Status='Browsing for dataset... ';
	handles = import_data(handles);
	
    if handles.xrdContainer(7).hasData
        handles.guidata.Filename = handles.xrd.Filename;
        handles.xrd.Status = 'Imported new dataset.';
    else
        handles.xrd.Status = '';
    end
	
	assignin('base','handles',handles)
	guidata(hObject, handles)
end