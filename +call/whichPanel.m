function num = whichPanel(hObject, handles)
% Finds and returns the array position of any child in the 1x6 
% array of handles.profiles (uipanel3 objects)
% 
% hObject is a descendent of a panel that belongs in the 
%	handles.profiles array 
num = [];
parent = hObject;

for i = 1:15
	if strcmpi(parent.Tag, 'uipanel3')
		num = find(parent == handles.profiles);
	else
		parent = parent.Parent;
	end
end