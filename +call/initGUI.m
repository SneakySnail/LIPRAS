% Initialize GUI controls
function handles = initGUI(hObject, eventdata, handles, varargin)


axes(handles.axes1)
hold(handles.axes1,'all');
xlabel('2\theta','FontSize',15);
ylabel('Intensity','FontSize',15);

createTabGroup;

% ------------------------------------------
% Initialize 7 instances of handles.uipanel3 for profile switching. Profiles 1-6
% are for user interface, profile 7 is an initial template for resetting
% profiles.
handles.profiles(7) = handles.uipanel3;
handles.profiles(7).UserData = 1; % UserData of profile 7 is current maximum enabled profiles

% Copy all callback functions to each instance of profiles
for i=1:6
	handles.profiles(i) = deepCopyPanel3;
	handles.profiles(i).UserData = i;
	if i == 1
		btn = findobj(handles.profiles(i), 'tag', 'push_prevprofile');
		set(btn, 'enable', 'off');
	elseif i == 6
		btn = findobj(handles.profiles(i), 'tag', 'push_nextprofile');
		set(btn, 'enable', 'off');
	end
end

handles.uipanel3 = handles.profiles(1);

% ------------------------------------------
% Initialize only one xrd object until user loads in data to fit
xrd = PackageFitDiffractionData;
handles.xrd = xrd;
handles.xrdContainer = xrd; % The handle which will contain the xrd array

assignin('base','handles',handles)

createStatusBar;

% Choose default command line output for FDGUI
handles.output = hObject;
guidata(hObject, handles)


	% Takes handles.profiles(1) and returns a deep copy. If there is an existing
	% profile panel, then just reset the panel.
	% TODO
	function obj = deepCopyPanel3()
	obj = copyobj(handles.profiles(7), handles.figure1);
	
	% Reset listeners and callbacks for all popups, edits, and checkboxes in uipanel3
	popup = findobj(obj.Children, 'style', 'popupmenu');
	edit = findobj(obj.Children, 'style', 'edit');
	check = findobj(obj.Children, 'style', 'checkbox');
	set([popup; edit; check], 'userdata', 0);
	addlistener([popup;check], 'Value', 'PreSet', @(o,e)listener.updateUserData(o,e,handles));
	addlistener(edit,'String','PreSet',@(o,e)listener.updateUserData(o,e,handles));
	
	uictrls = findobj(handles.profiles(7).Children,'Type','uicontrol');
	temp1 = findobj(obj.Children,'Type','uicontrol');
	[temp1.Callback] = deal(uictrls.Callback);
	
	table = findobj(handles.profiles(7).Children,'tag','uitable1');
	temp2=findobj(obj.Children,'tag','uitable1');
	temp2.CellEditCallback=table.CellEditCallback;
	temp2.CellSelectionCallback=table.CellSelectionCallback;
	
	temp3=findobj(obj.Children,'tag','tabgroup');
	temp3.SelectionChangedFcn = handles.tabgroup.SelectionChangedFcn;
	end

%{
Creates the tab groups for uipanel3.
%}
	function createTabGroup
	
	handles.tabgroup = uitabgroup(...
        'Parent', handles.uipanel16, ...
        'tag', 'tabgroup', ...
		'SelectionChangedFcn', @(hObject,eventdata)FDGUI('tabgroup_SelectionChangedFcn', hObject, eventdata, guidata(hObject)));
	
    handles.tab_setup = uitab(handles.tabgroup, 'Title', 'Setup', 'tag', 'tab_setup');
	
	set(flipud(handles.uipanel17.Children), 'Parent', handles.tab_setup);
	
	handles.tab_peak = uitab(handles.tabgroup, ...
		'Title', 'Peak Selection', ...
		'tag', 'tab_peak',...
		'ForegroundColor', [0.8 0.8 0.8]);
	
	set(flipud(handles.uipanel18.Children), ...
		'Parent',handles.tab_peak);
	end

	function createStatusBar
	% Create the java object status bar
	
	% Turn off JavaFrame obsolete warning
	warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame;

	jFrame=get(handles.figure1,'JavaFrame');
	try
		jRootPane = jFrame.fFigureClient.getWindow;  % This works up to R2011a
	catch
		try
			jRootPane = jFrame.fHG1Client.getWindow;  % This works from R2008b-R2014a
		catch
			jRootPane = jFrame.fHG2Client.getWindow;  % This works from R2014b and up
		end
	end
	
	handles.text_status = com.mathworks.mwswing.MJStatusBar;
	jRootPane.setStatusBar(handles.text_status);
	
	handles.text_status.setText('<html>Please import file(s) containing data to fit.</html>');
	end
end