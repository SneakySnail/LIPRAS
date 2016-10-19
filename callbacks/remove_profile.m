function handles = remove_profile(i, handles)
	%UNTITLED2 Summary of this function goes here
	%   Detailed explanation goes here
	
	num = handles.profiles(7).UserData;
	for j=num:6
		handles.xrdContainer(j) = PackageFitDiffractionData;
	end
	delete(findobj(handles.profiles(i)));
	for j=num:6
		handles.profiles(j) = handles.profiles(j+1);
	end
	
	handles.profiles(6) = gobjects;
	handles.profiles(7).UserData = num - 1;
	
end

