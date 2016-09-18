% Sets the visibility of the popup controls in uipanel6 for choosing fit functions according
% to the number of peaks chosen by the 
function setFuncPopupVisibility(handles)
	num = get(handles.popup_numpeaks, 'Value') - 1;
	
	% if the same number as previous, do nothing
	if num == handles.popup_numpeaks.UserData
		return
	end
	
	if num > 0
		handles.xrd.Status=['Number of peaks set to ',num2str(num),'.'];
		set(handles.uipanel6, 'Visible','on');
		set(handles.uipanel6.Children,'Visible','off');
		set(handles.panel_constraints,'Visible','on');
		set(handles.push_update, 'Visible','on');
		set(handles.text7,'Visible','on');
		set(handles.popup_function1,'Visible','on');
		set(handles.uipanel10,'Visible','on');
		
		if num > 1
			set(handles.text13,'Visible','on');
			set(handles.popup_function2,'Visible','on');
			if num > 2
				set(handles.text14,'Visible','on');
				set(handles.popup_function3,'Visible','on');
				if num > 3
					set(handles.text15,'Visible','on');
					set(handles.popup_function4,'Visible','on');
					if num > 4
						set(handles.text17,'Visible','on');
						set(handles.popup_function5,'Visible','on');
						if num > 5
							set(handles.text18,'Visible','on');
							set(handles.popup_function6,'Visible','on');
						end
					end
				end
			end
		end
		
		hiddenPops = flipud(findobj(handles.uipanel6.Children,'style','popupmenu', 'visible', 'off'));
		set(hiddenPops, 'value', 1);
		call.allowWhichConstraints(handles);
		
	else
		set(handles.uipanel10,'Visible','off');
		set(findobj(handles.uipanel6.Children,'style','popupmenu'),'value',1);
		set(findobj(handles.panel_constraints.Children),'Enable','off','Value',0);
		set(handles.uipanel6,'Visible','off');
		set(handles.panel_constraints,'Visible','off');
		set(handles.push_update,'Visible','off');
% 		set(handles.panel_coeffs,'Visible','off');
	end
	
	call.setEnableUpdateButton(handles);