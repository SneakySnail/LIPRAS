
% Executes whenever the value of a uicontrol object cvhanges
function updateUserData(o,e,handles)
hObject = e.AffectedObject;
try 
	switch hObject.Style
		case 'edit'
			val=str2double(hObject.String);
			set(hObject, 'userdata', val);
			
		otherwise
			val=hObject.Value - 1;
			set(hObject,'userdata', val);
			
	end
catch
	return
end
