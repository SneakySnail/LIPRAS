% Switches profiles. If hObject = 'push_prevprofile', switches to previous
% profile. If hObject = 'push_nextprofile', switches to next profile. 
function handles = change_profile(iProfile, handles)
	
max = handles.guidata.numProfiles;
max = handles.profiles(7).UserData; % DELETE
assert(max == handles.guidata.numProfiles);

handles.uipanel3.Visible = 'off';
handles.uipanel3 = handles.profiles(iProfile);
handles = reassign(handles);

set(handles.text_numprofile, 'string',...
	['Profile ',num2str(iProfile), ' of ', num2str(max)]);

if iProfile == 1
	handles.push_prevprofile.Enable = 'off';	
else
	handles.push_prevprofile.Enable = 'on'; 
end

if iProfile == max
	handles.push_nextprofile.Enable = 'off';
else
	handles.push_nextprofile.Enable = 'on'; 
end

plotX(handles);

% reset_panel_view(handles);

handles.uipanel3.Visible = 'on';

guidata(handles.figure1, handles)

	% Reassigns all saved handles in "handles" for each object in uipanel3 according to
	% the correct panel parent profile.
	function handles = reassign(handles)
	% Reassigns all of the children in the panel to the appropriate handles
	% reference
	
	% uipanels
	hObject = handles.uipanel3;
	objs = findobj(handles.uipanel3);
	handles.xrd = handles.xrdContainer(iProfile);
	
<<<<<<< HEAD
	% Tab 3. panel_results
	handles.btngroup_plotresults = findobj(hObject, 'Tag', 'btngroup_plotresults');
	handles.radio_coeff = findobj(hObject, 'Tag', 'radio_coeff');
    handles.radio_statistics = findobj(hObject, 'Tag', 'radio_statistics');
	handles.radio_peakeqn = findobj(hObject, 'Tag', 'radio_peakeqn');
	handles.listbox_files = findobj(hObject, 'Tag', 'listbox_files');
	handles.table_results = findobj(hObject, 'Tag', 'table_results');
	
	
	% tabs
	handles.tabgroup=findobj(hObject,'tag','tabgroup');
	handles.tab_setup=findobj(hObject,'tag','tab_setup');
	handles.tab_peak=findobj(hObject,'tag','tab_peak');
	handles.tab_results=findobj(hObject,'tag','tab_results');
=======
	for i=1:length(objs)
		handles.(objs(i).Tag) = objs(i);
	end
>>>>>>> gui-layout-tool
	
	end
end