function handles = clearTable(hObject, ~, handles)

% Reset Fmodel
handles.xrd.Fmodel = [];

len = size(handles.table_coeffvals.Data,1);
handles.table_coeffvals.Data = cell(len,3);

set(hObject.Parent.Children,'Enable','off');
set(handles.push_selectpeak,'Enable','on', 'string', 'Select Peak(s)');
set(handles.table_coeffvals,'Enable','on');
handles.xrd.plotData(get(handles.popup_filename,'Value'));
% 
% if strcmpi(handles.uitoggletool5.State,'on')
% 	legend(handles.xrd.DisplayName,'box','off')
% end

set(handles.axes2,'Visible','off');
set(handles.axes2.Children,'Visible','off');