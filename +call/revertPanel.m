% Resets all buttons in handles.uipanel3 to the last time the 'Update' button
% was clicked. Used in: [FDGUI.m, changeProfile.m].
function revertPanel(handles)
set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
set(handles.edit_fitrange,'String',sprintf('%2.3f',handles.xrd.fitrange));

% If there are no background points yet 
	if isempty(handles.xrd.bkgd2th)
		set(handles.panel_constraints.Children,'Value',0);
		set(handles.panel_constraints,'UserData',zeros(1,4));
		set(handles.tabgroup,'SelectedTab',handles.tab_setup);
		set(handles.tab_peak,'ForegroundColor',[0.8 0.8 0.8]);
		
	elseif isempty(handles.xrd.Fmodel)
		set(handles.tab_peak,'ForegroundColor',[0 0 0]);
		set(handles.tabgroup, 'SelectedTab', handles.tab_peak);
		set(handles.panel_constraints, 'visible','on');
		
	else
		set(handles.tabgroup.Children, 'foregroundcolor',  [0 0 0]);
		set(handles.tabgroup, 'selectedtab',handles.tab_peak);
		
	end
	
	% Check/uncheck to calculate CuKa2 peak
	set(handles.edit_lambda,'string', num2str(handles.xrd.lambda));
	if handles.xrd.CuKa
		set(handles.checkbox_lambda,'value',1);
		set(handles.edit_lambda,'enable','on');
	else
		set(handles.checkbox_lambda,'value',0);
		set(handles.edit_lambda,'enable','off');
	end
	