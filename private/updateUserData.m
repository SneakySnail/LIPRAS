
% Executes whenever the value of a uicontrol object cvhanges
function updateUserData(o,e,handles)
hObject = e.AffectedObject;
try 
	switch hObject.Style
		case 'edit'
			val=str2double(hObject.String);
			if val~=hObject.UserData
				set(hObject, 'userdata', val);
			end
			
		otherwise
			val=hObject.Value - 1;
			if val ~= hObject.UserData
				set(hObject,'userdata', val);
			end
	end
catch
	return
end
