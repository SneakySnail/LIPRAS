% Check if all visible popup menus for functions are not empty and if
% they have the same constraints before enabling pushbutton15 ('Update' button) or uipanel4.
function isEnabled = setEnableUpdateButton(handles)

%% Verify all visible popup menus are not blank
% --- set initial values --- %
isEnabled = false;
set(handles.pushbutton15, 'enable', 'off');
set(handles.uipanel4.Children, 'enable', 'off');
% ----------------- %

if handles.popup_numpeaks.Value == 1
	set(handles.uipanel4, 'visible', 'off');
	return
end

%% Check if functions and constraints are the same values as previously
% prevfn = handles.uipanel6.UserData;
prev = getSavedParam(handles);
current = getModifiedParam(handles);

if isempty(current.fcnNames) % If there are some blank popups
	return
end

try
	if length(current.fcnNames) ~= length(prev.fcnNames)
		set(handles.pushbutton15, 'enable', 'on');
		return
	end
	
	cmpFcns = strcmpi(current.fcnNames, prev.fcnNames);
	
	if ~isempty(find(~cmpFcns, 1)) % if there is a mismatch of functions
		set(handles.pushbutton15, 'enable', 'on');
		isEnabled = true;
		return
	end
		
	if ~isempty(find(prev.constraints ~= current.constraints, 1))
		set(handles.pushbutton15, 'enable', 'on');
		isenabled = true;
	else
		% ONLY if functions AND constraints are the same 
		set(handles.uipanel4.Children, 'enable', 'on');
	end
	
catch % length of function names are not the same
	set(handles.pushbutton15, 'enable', 'on');
	isEnabled = true;
end
	



