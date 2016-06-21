% --- Executes when a new file is read
function handles=createProfileObjects(handles)
% Returns the updated handle structure

range = [handles.xrd.Min2T handles.xrd.Max2T];
for i=1:6
	% Add listener for each xrd object
	addlistener(handles.xrdContainer(i),'Status','PostSet',@(o,e)statusChange(o,e,handles,i));
	
	% Reset UserData
	popup=findobj(handles.profiles(i).Children,'style','popupmenu','visible','on');
	edit=findobj(handles.profiles(i).Children,'style','edit');
	check=findobj(handles.profiles(i).Children,'style','checkbox');
	set([popup;edit;check],'userdata',0);
	
	minbox = findobj(handles.profiles(i).Children,'Tag','edit_min2t');
	maxbox = findobj(handles.profiles(i).Children,'Tag','edit_max2t');
	set(minbox,'String',num2str(range(1)));
	set(maxbox,'String',num2str(range(2)));
	
	panel4=findobj(handles.profiles(i).Children,'Tag','uipanel4');
	uitable=findobj(panel4,'Tag','uitable1');
	uitable.Data=cell(1,4);
	
	% Set appearance
	tab2 = findobj(handles.profiles(i).Children,'tag','tab_peak');
	set(tab2,'ForegroundColor',[0.8 0.8 0.8]);
	set(panel4.Children,'Visible','off');
	set(handles.pushbutton15,'Enable','on');
	set(handles.togglebutton_showbkgd,'enable','off');
end
