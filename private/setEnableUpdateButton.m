% Check if all visible popup menus for functions are not empty and if
% they have the same constraints before enabling pushbutton15 ('Update' button) or uipanel4.
function isEnabled = setEnableUpdateButton(handles)

%% Verify all visible popup menus are not blank
% --- set initial values --- %
isEnabled = false;
set(handles.pushbutton15, 'enable', 'off');
set(handles.uipanel4, 'visible', 'on');
set(handles.uipanel4.Children, 'enable', 'off');
% ----------------- %

% popups = array of visible popup objects for functions
popups = flipud(findobj(handles.uipanel6.Children, ...
	'visible','on','style','popupmenu'));

try 
	popValue = [popups.Value];
catch
	% if there are NO visible function popup menus
	set(handles.uipanel4, 'visible', 'off');
	return
end

%% Check if functions and constraints are the same values as previously
prevfn = handles.uipanel6.UserData;
if length(popValue) == length(prevfn) % ONLY if numpeaks the same 
	
	if isempty(find(popValue == 1, 1)) % ONLY if there are no blank popups 
		
		if isempty(find((prevfn==popValue) == 0, 1)) % ONLY if functions are the same
			
			if find(handles.xrd.Constrains ~= handles.uipanel5.UserData, 1) % ONLY if constraints not the same
				set(handles.pushbutton15, 'enable', 'on');
				isEnabled = true;
				
			else % ONLY if functions AND constraints are the same
				set(handles.uipanel4.Children, 'enable', 'on');
			end
			
		else % if functions are different
			% same numpeaks but different functions
			set(handles.pushbutton15, 'enable', 'on');
			isEnabled = true;
		end
		% Else leaves buttons disabled if there is at least 1 blank popup
	end
	
else % if previous values do not have the same length as currently
	% Check for blank popupmenus 
	if isempty(find(popValue == 1, 1)) 
		% ONLY if no blanks
		set(handles.pushbutton15, 'enable', 'on');
		isEnabled = true;
	end 
end


