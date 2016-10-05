function handles = addProfile(handles)
	
	profileNum = handles.profiles(7).UserData + 1;
	handles.profiles(7).UserData = profileNum;
	handles.profiles(profileNum) = deepCopyPanel3();
	
	createXRD();
	
	handles = call.changeProfile(profileNum, handles);
	
	% Set appearance
	tab2 = findobj(handles.profiles(profileNum),'tag','tab_peak');
	set(tab2,'ForegroundColor',[0.8 0.8 0.8]);
	set(panel4.Children,'Visible','off');
	set(handles.push_update,'Enable','on');
	set(handles.togglebutton_showbkgd,'enable','off');
	set(handles.push_removeprofile,'enable','on');
	set(handles.panel_range,'visible','on');
	
	function obj = deepCopyPanel3()
		% Takes handles.profiles(1) and returns a deep copy. If there is an existing
		% profile panel, then just reset the panel.
		obj = copyobj(handles.profiles(7), handles.figure1);
		
		popup = findobj(obj.Children, 'style', 'popupmenu');
		edit = findobj(obj.Children, 'style', 'edit');
		check = findobj(obj.Children, 'style', 'checkbox');
		
		% Reset userdata to 0
		set([popup; edit; check], 'userdata', 0);
		
		% Assign listener when user data updates for all new popups,
		% checkboxes, and edit boxes
		addlistener([popup; check], 'Value', 'PreSet', @(o,e)listener.updateUserData(o,e,handles));
		addlistener(edit, 'String', 'PreSet', @(o,e)listener.updateUserData(o,e,handles));
		
		baseCtrls = findobj(handles.profiles(7).Children);
		newCtrls = findobj(obj.Children);
		assert(length(baseCtrls) == length(newCtrls)); % Make sure they have the same number of children
		
		% Assign callbacks for all new uicontrols
		for i=1:length(baseCtrls)
			if isprop(baseCtrls(i), 'Callback')
				newCtrls(i).Callback = baseCtrls(i).Callback;
			end
			if isprop(baseCtrls(i), 'CellEditCallback')
				newCtrls(i).CellEditCallback = baseCtrls(i).CellEditCallback;
			end
			if isprop(baseCtrls(i), 'CellSelectionCallback')
				newCtrls(i).CellSelectionCallback = baseCtrls(i).CellSelectionCallback;
			end
			if isprop(baseCtrls(i), 'SelectionChangedFcn')
				newCtrls(i).SelectionChangedFcn = baseCtrls(i).SelectionChangedFcn;
			end
			if isprop(baseCtrls(i), 'ButtonDownFcn')
				newCtrls(i).ButtonDownFcn = baseCtrls(i).ButtonDownFcn;
			end
		end
	end
	
	
	function createXRD
		handles.xrdContainer(profileNum) = copy(handles.xrdContainer(7));
		handles.profiles(profileNum).UserData = profileNum;
		
		% Add listener for each xrd object
		addlistener(handles.xrdContainer(profileNum), 'Status', ...
			'PostSet', @(o,e)listener.statusChange(o,e,handles,profileNum));
		addlistener(handles.xrdContainer(profileNum), 'DisplayName', ...
			'PostSet', @(o,e)listener.displayNameChange(o, e, handles));
		
		% Reset UserData
		popup=findobj(handles.profiles(profileNum).Children,'style','popupmenu','visible','on');
		edit=findobj(handles.profiles(profileNum).Children,'style','edit');
		check=findobj(handles.profiles(profileNum).Children,'style','checkbox');
		set([popup;edit;check],'userdata',0);
		
		minbox = findobj(handles.profiles(profileNum),'Tag','edit_min2t');
		maxbox = findobj(handles.profiles(profileNum),'Tag','edit_max2t');
		
		range = [handles.xrd.Min2T handles.xrd.Max2T];
		set(minbox,'String',num2str(range(1)));
		set(maxbox,'String',num2str(range(2)));
		
		panel4=findobj(handles.profiles(profileNum),'Tag','panel_coeffs');
		uitable=findobj(panel4,'Tag','table_coeffvals');
		uitable.Data=cell(1,4);
		

		
	end
	
end