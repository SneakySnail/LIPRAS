function handles = remove_profile(ipeak, handles)
	%UNTITLED2 Summary of this function goes here
	%   Detailed explanation goes here
	
	num = handles.guidata.numProfiles;
	
	for j=num+1:6
		if ~isempty(handles.xrdContainer(j).Filename)
			handles.xrdContainer(j) = PackageFitDiffractionData;
		end
		if ~isequal(handles.profiles(j), gobjects)
			handles.profiles(j) = gobjects;
		end
	end
	
	if num == 0 || ipeak < num
		return
	end
	
	for j=ipeak:num
		handles.xrdContainer(j) = copy(handles.xrdContainer(j+1));
		handles.profiles(j) = gobjects;
		handles.profiles(j) = handles.profiles(j+1); 
	end
	
	handles.profiles(7).UserData = num - 1; % delete
	handles.guidata.numProfiles = num - 1;
	assert(handles.profiles(7).UserData == handles.guidata.numProfiles);
	
	assert(find(handles.xrd==handles.xrdContainer)==find(handles.profiles==handles.uipanel3));
	
	if ~(find(handles.xrd==handles.xrdContainer) < 7)
		n = handles.guidata.numProfiles;
		n = handles.profiles(7).UserData; % delete
		assert(n == handles.guidata.numProfiles);
		if n == 1
			set(handles.push_removeprofile, 'enable', 'off');
			handles = change_profile(1, handles);
		elseif ipeak <= n
			handles = change_profile(ipeak, handles);
		end
	end
	
	

