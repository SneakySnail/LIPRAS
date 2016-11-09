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

if iProfile == 1; handles.push_prevprofile.Enable = 'off';	
else handles.push_prevprofile.Enable = 'on'; end

if iProfile == max; handles.push_nextprofile.Enable = 'off';
else handles.push_nextprofile.Enable = 'on'; end

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
	% xrd
	handles.xrd = handles.xrdContainer(iProfile);

	% Tab 1. Setup 
	handles.panel_range = findobj(hObject, 'Tag', 'panel_range'); % range
	handles.edit_fitrange = findobj(hObject,'Tag','edit_fitrange'); 
	handles.edit_max2t = findobj(hObject,'Tag','edit_max2t');
	handles.edit_min2t = findobj(hObject,'Tag','edit_min2t');
	handles.panel_kalpha2 = findobj(hObject, 'tag', 'panel_kalpha2');
	handles.edit_lambda=findobj(hObject,'tag','edit_lambda');
	handles.checkbox_lambda=findobj(hObject,'tag','checkbox_lambda');
	handles.panel_bkgd = findobj(hObject,'Tag','panel_bkgd'); 
	handles.push_newbkgd = findobj(hObject,'Tag','push_newbkgd');
	handles.edit_bkgdpoints = findobj(hObject,'Tag','edit_bkgdpoints');
	handles.edit_polyorder = findobj(hObject,'Tag','edit_polyorder');
	
	% Tab 2. panel_parameters
	handles.table_paramselection = findobj(hObject, 'Tag', 'table_paramselection');
	handles.panel_constraints = findobj(hObject,'Tag','panel_constraints'); 
	handles.checkboxm = findobj(hObject,'Tag','checkboxm');
	handles.checkboxw = findobj(hObject,'Tag','checkboxw');
	handles.checkboxf = findobj(hObject,'Tag','checkboxf');
	handles.checkboxN = findobj(hObject,'Tag','checkboxN');
	handles.edit_numpeaks = findobj(hObject,'Tag','edit_numpeaks');
	handles.panel_coeffs = findobj(hObject,'Tag','panel_coeffs'); % table
	handles.table_fitinitial = findobj(hObject,'Tag','table_fitinitial');
	handles.push_selectpeak = findobj(hObject,'Tag','push_selectpeak');
	handles.push_fitdata = findobj(hObject,'Tag','push_fitdata');
	handles.push_default = findobj(hObject,'Tag','push_default');
	handles.push_update = findobj(hObject,'Tag','push_update'); % Update button
	handles.push_cancelupdate = findobj(hObject, 'tag', 'push_cancelupdate');
	
	
	% Tab 3. panel_results
	handles.btngroup_plotresults = findobj(hObject, 'Tag', 'btngroup_plotresults');
	handles.radio_coeff = findobj(hObject, 'Tag', 'radio_coeff');
	handles.radio_peakeqn = findobj(hObject, 'Tag', 'radio_peakeqn');
	handles.listbox_files = findobj(hObject, 'Tag', 'listbox_files');
	handles.table_results = findobj(hObject, 'Tag', 'table_results');
	
	
	% tabs
	handles.tabgroup=findobj(hObject,'tag','tabgroup');
	handles.tab_setup=findobj(hObject,'tag','tab_setup');
	handles.tab_peak=findobj(hObject,'tag','tab_peak');
	handles.tab_results=findobj(hObject,'tag','tab_results');
	
	end
end