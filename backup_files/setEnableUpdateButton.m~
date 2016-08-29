% In the 'Peak Selection' tab, this function enables pushbutton15 if fit
% functions are filled and disables it if not. 
function isEnabled = setEnableUpdateButton(handles)

%% Verify all visible popup menus are not blank
% pushbutton15 is initially disabled before checking for functions.
isEnabled = false;
set(handles.pushbutton15, 'enable', 'off');
set(handles.uipanel4.Children, 'enable', 'off');
% ----------------- %

% If the number of peaks is empty, make uipanel4 invisible
if handles.popup_numpeaks.Value == 1
	set(handles.uipanel4, 'visible', 'off');
	return
end

%% Check if functions and constraints are the same values as previous
% prevfn = handles.uipanel6.UserData;
prev = call.getSavedParam(handles);
current = call.getModifiedParam(handles);

% Exit function if there are some blank functions
if isempty(current.fcnNames) 
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
	



