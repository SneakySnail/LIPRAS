function handles = add_profile(handles)
	
	profileNum = handles.guidata.numProfiles+1;
	handles.guidata.numProfiles = profileNum;
	handles.profiles(7).UserData = profileNum;
	
	
	createXRD();
	
	handles = change_profile(profileNum, handles);
	
	if handles.guidata.numProfiles >= 6
		set(handles.push_addprofile, 'enable', 'off');
	end

% 	set(handles.togglebutton_showbkgd,'enable','off');
	set(handles.push_removeprofile,'enable','on');
	set(handles.panel_range,'visible','on');
	set(handles.panel_setup, 'visible', 'on');
	set(handles.panel_parameters,'visible', 'on');
	set(handles.panel_results, 'visible', 'on');
	
	%***********************************************************************%
	% Create the array containing data for each profile. When the user switches
	%	profiles, the current values of all the uicontrols are stored in here and
	%	are switched back when the current profile is activated.
	%***********************************************************************%
	function data = addProfileData()
		
	p.xrd = PackageFitDiffractionData;		% object containing xrd
	p.numprofiles = 0;				% total number of profiles 
	p.min2t
	
		
	end
	
	
	function createXRD
		handles.xrdContainer(profileNum) = copy(handles.xrdContainer(7));
		handles.profiles(profileNum).UserData = profileNum;
		
		% Add listener for each xrd object
		addlistener(handles.xrdContainer(profileNum), 'Status', ...
			'PostSet', @(o,e)listener.statusChange(o,e,handles,profileNum));
		
		% Reset UserData
		popup=findobj(handles.profiles(profileNum).Children,'style','popupmenu','visible','on');
		edit=findobj(handles.profiles(profileNum).Children,'style','edit');
		check=findobj(handles.profiles(profileNum).Children,'style','checkbox');
		set([popup;edit;check],'userdata',0);
		
		minbox = findobj(handles.profiles(profileNum),'Tag','edit_min2t');
		maxbox = findobj(handles.profiles(profileNum),'Tag','edit_max2t');
		
		range = [handles.xrdContainer(7).Min2T handles.xrdContainer(7).Max2T];
		set(minbox,'String',num2str(range(1)));
		set(maxbox,'String',num2str(range(2)));
		
		panel4=findobj(handles.profiles(profileNum),'Tag','panel_coeffs');
		uitable=findobj(panel4,'Tag','table_fitinitial');
		uitable.Data=cell(1,4);
		set(panel4.Children,'Visible','off');
	end
	
	function tabpanel=createTabs()
		tabnames = {'1. Setup', '2. Options', '3. Results'};
		
		% create tab panels
		tabpanel = uix.TabPanel('Parent', handles.uipanel3, 'Padding', 5, 'tag', 'tabpanel', 'fontsize', 11, 'tabwidth', 75, ...
				'SelectionChangedFcn', @(o, e)tabpanel_SelectionChangedFcn(o, e, guidata(o)));
		set(findobj(handles.profiles(7), 'tag', 'panel_setup'), 'parent', tabpanel, 'title', '', 'bordertype', 'none', 'visible', 'on');
		set(handles.panel_parameters, 'parent', tabpanel, 'title', '', 'bordertype', 'none', 'visible', 'on');
		set(handles.panel_results, 'parent', tabpanel, 'title', '', 'bordertype', 'none', 'visible', 'on');

		set(tabpanel, 'TabTitles', tabnames, 'TabEnables', {'on', 'off', 'off'});
		
	end
	
end