% Check if all visible popup menus for functions are not empty
function isEntered = hasEnteredAllFunctions(handles)
% popups = array of visible popup objects for functions
popups = flipud(findobj(handles.uipanel6.Children,'visible','on','style','popupmenu'));

if isempty(popups)
		isEntered = false;
		return
end

popValue = [popups.Value];

if isempty(find(popValue==1, 1))
	isEntered = true;
	set(handles.uipanel4.Children, 'Enable', 'on');
	
	if isempty(handles.uitable1.Data{1})
		set(handles.push_fitdata, 'enable', 'off');
		set(handles.push_default, 'enable', 'off');
	end
else
		isEntered = false;
		set(handles.uipanel4.Children, 'enable', 'off');
end



