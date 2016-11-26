% Switches profiles. If hObject = 'push_prevprofile', switches to previous
% profile. If hObject = 'push_nextprofile', switches to next profile. 
function handles = change_profile(iProfile, handles)
	
max = handles.guidata.numProfiles;

handles.uipanel3.Visible = 'off';
handles.uipanel3 = handles.profiles(iProfile);
handles.guidata.currentProfile = iProfile;
handles = reassign(handles);

set(handles.text_numprofile, 'string',...
	['Profile ',num2str(iProfile), ' of ', num2str(max)]);



if iProfile == 1
	handles.push_prevprofile.Enable = 'off';	
else
	handles.push_prevprofile.Enable = 'on'; 
end

if iProfile == max
	handles.push_nextprofile.Enable = 'off';
else
	handles.push_nextprofile.Enable = 'on'; 
end

plotX(handles);

% reset_panel_view(handles);

handles.uipanel3.Visible = 'on';

guidata(handles.figure1, handles)

%% HELPER FUNCTIONS
	% Reassigns all saved handles in "handles" for each object in uipanel3 according to
	% the correct panel parent profile.
	function handles = reassign(handles)
	% Reassigns all of the children in the panel to the appropriate handles
	% reference
	
	% uipanels
	hObject = handles.uipanel3;
	objs = findobj(handles.uipanel3);
	handles.xrd = handles.xrdContainer(iProfile);
	
	for i=1:length(objs)
		handles.(objs(i).Tag) = objs(i);
	end
	
	end
end