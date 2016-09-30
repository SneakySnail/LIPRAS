function setAvailableConstraints(handles)

set(handles.checkboxN,'Enable','off','Value',0);
set(handles.checkboxf,'Enable','off','Value',0);
set(handles.checkboxw,'Enable','off','Value',0);
set(handles.checkboxm,'Enable','off','Value',0);
handles.panel_constraints.UserData=[0 0 0 0];

% Function names
fcnNames = handles.table_paramselection.Data(:, 1)';

% TODO
if length(find(strcmpi(fcnNames,'Gaussian'))) > 1
	set(handles.checkboxN,'Enable','on');
	set(handles.checkboxf,'Enable','on');
	
	if length(find(fxns==4 | fxns==6)) > 1
		set(handles.checkboxm,'Enable','on');
	else
		set(handles.checkboxm,'Enable','off');
	end
	
	if length(find(fxns==5)) > 1
		set(handles.checkboxw,'Enable','on');
	else
		set(handles.checkboxw,'Enable','off');
	end
else
	set(handles.checkboxN,'Enable','off');
	set(handles.checkboxf,'Enable','off');
end