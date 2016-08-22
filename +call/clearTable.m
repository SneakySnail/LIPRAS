function handles = clearTable(hObject, ~, handles)

% Reset Fmodel
handles.xrd.Fmodel = [];

len = size(handles.uitable1.Data,1);
handles.uitable1.Data = cell(len,4);

set(hObject.Parent.Children,'Enable','off');
set(handles.pushbutton17,'Enable','on', 'string', 'Select Peak(s)');
set(handles.uitable1,'Enable','on');
handles.xrd.plotData(get(handles.popup_filename,'Value'));

if strcmpi(handles.uitoggletool5.State,'on')
	legend(handles.xrd.DisplayName,'box','off')
end

set(handles.axes2,'Visible','off');
set(handles.axes2.Children,'Visible','off');