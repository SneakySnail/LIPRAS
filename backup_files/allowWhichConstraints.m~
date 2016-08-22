function allowWhichConstraints(handles)

set(handles.checkboxN,'Enable','off','Value',0);
set(handles.checkboxf,'Enable','off','Value',0);
set(handles.checkboxw,'Enable','off','Value',0);
set(handles.checkboxm,'Enable','off','Value',0);
handles.uipanel5.UserData=[0 0 0 0];

% pop = array of visible popup objects for functions
pop=flipud(findobj(handles.uipanel6.Children,'visible','on','style','popupmenu'));
% fxns: doubles array representing current functions chosen
if ~isempty(pop)
	fxns = [pop.Value];
else
	return 
end

if length(find(fxns>1)) > 1
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