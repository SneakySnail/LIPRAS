function newPSfxn( hObject, ~, uipanel3)
	%NEWPSFXN Summary of this function goes here
	%   Detailed explanation goes here
	fcnNames = hObject.Data(:, 1)'; % function names to use
	hasEmpty = cellfun(@isempty,hObject.Data(:, 1));
	
	if find(hasEmpty)
		setappdata(uipanel3, 'fitready', false);
	end
	
	
	setappdata(uipanel3, 'PSfxn', fcnNames);
	
end

