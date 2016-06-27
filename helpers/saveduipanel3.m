
% --- Resets handles.uipanel3 according to the last saved state.
function saveduipanel3(handles)
param = getSavedParam(handles);
% If there are no functions chosen
	if isempty(handles.xrd.bkgd2th)
		set(handles.uipanel6.Children,'Visible','off');
		set(handles.uipanel5.Children,'Value',0);
		set(handles.uipanel4.Children,'Visible','off');
		set(handles.pushbutton17,'Enable','on');
		set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
		set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
		set(handles.edit7,'String',sprintf('%2.3f',handles.xrd.fitrange));
		
		set(handles.uitable1,'Data',[]);
		set(handles.uipanel6,'UserData',[]);
		set(handles.uipanel5,'UserData',zeros(1,4));
		set(handles.popup_numpeaks,'Value',1);
		FDGUIv2_1('popup_numpeaks_Callback', handles.popup_numpeaks, [], handles); 
		set(handles.tabgroup,'SelectedTab',handles.tab_setup);
		set(handles.tab_peak,'ForegroundColor',[0.8 0.8 0.8]);
		
	else
		set(handles.tab_peak,'ForegroundColor',[0 0 0]);
		numpeaks=size(handles.xrd.PSfxn,2);
		set(handles.popup_numpeaks,'Value',numpeaks+1); 
		set(handles.uipanel5, 'visible','on');
		set(handles.uipanel6, 'visible','on');
		set(handles.uipanel4.Children,'visible','on','enable','on');
		
		
		% set availability of popup_functions and constraint checkboxes
		FDGUIv2_1('popup_numpeaks_Callback', handles.popup_numpeaks, [], handles); 
		
		% set appropriate value to popup_functions
		pop=flipud(findobj(handles.uipanel6.Children,...
			'style','popupmenu','visible','on')); 
		a=num2cell(fnstr2num(handles.xrd.PSfxn));
		try
			[pop.Value]=a{:};
		catch
% 			handles.xrd.PSfxn={};
% 			saveduipanel3(handles);
			return
		end
		
		allowWhichConstraints(handles);
		
		% Check/uncheck the constraints in uipanel5
		chk=flipud(handles.uipanel5.Children);
		cts=num2cell(handles.xrd.Constrains);
		set(handles.uipanel5,'UserData',handles.xrd.Constrains);
		[chk.Value]=cts{:};
	end
	
	% Check/uncheck to calculate CuKa2 peak
	set(handles.edit_lambda,'string',num2str(handles.xrd.lambda));
	if handles.xrd.CuKa
		set(handles.checkbox_lambda,'value',1);
		set(handles.edit_lambda,'enable','on');
	else
		set(handles.checkbox_lambda,'value',0);
		set(handles.edit_lambda,'enable','off');
	end
	