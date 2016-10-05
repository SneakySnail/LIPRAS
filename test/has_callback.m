% If a handle object has a callback property, check if it's empty

hObjs = findobj(handles.figure1);
j = 1;
for i=1:length(hObjs)
	if isprop(hObjs(i), 'Callback') && isempty(hObjs(i).Callback)
		disp([num2str(j),'. ',hObjs(i).Tag, ' does not have a Callback function.'])
		j = j+1;
	end
end
