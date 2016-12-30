% Switches between different tabs in the current profile.
function push_tabswitch_Callback(hObject, e, handles)
% Switches between Tabs 1 (Setup), 2 (Parameters), and 3 (Results).

switch hObject.Tag
		case 'tab1_next'
				set(handles.tabpanel, 'Selection', 2);
				
		case 'tab2_prev'
				set(handles.tabpanel, 'Selection', 1);
				
		case 'tab2_next'
				set(handles.tabpanel, 'Selection', 3);
				
		case 'tab3_prev'
				set(handles.tabpanel, 'Selection', 2);
				
end
