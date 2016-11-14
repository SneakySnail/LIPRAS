function handles = clearTable(hObject, ~, handles)

% Reset Fmodel
handles.xrd.Fmodel = [];

len = size(handles.table_fitinitial.Data,1);
handles.table_fitinitial.Data = cell(len,3);

set(hObject.Parent.Children,'Enable','off');
set(handles.push_selectpeak,'Enable','on', 'string', 'Select Peak(s)');
set(handles.table_fitinitial,'Enable','on');
plotData(handles,get(handles.popup_filename,'Value'));
% 
% if strcmpi(handles.uitoggletool5.State,'on')
% 	legend(handles.xrd.DisplayName,'box','off')
% end

set(handles.axes2,'Visible','off');
set(handles.axes2.Children,'Visible','off');