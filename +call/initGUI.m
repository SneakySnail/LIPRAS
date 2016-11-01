% Initialize GUI controls
function handles = initGUI(hObject, eventdata, handles, varargin)

	initAxes();
	
	handles.profiles(7) = handles.uipanel3;
	handles.profiles(7).UserData = 0;
	handles.xrd = PackageFitDiffractionData;
	handles.xrdContainer(7) = handles.xrd;
	
	% Change the time to wait until tooltip is displayed
	setToolTipDelay();
	
	% Create the java object status bar
	createJavaStatusBar();
	
	createTabs();
	
	
	function initAxes()
		axes(handles.axes1)
		hold(handles.axes1,'all');
		
		set(get(handles.axes1, 'Parent'), 'DefaultAxesColorOrder', ...
				[0 0 0; % black
				1 0 0; % red
				1 0.4 0; % orange
				0.2 0.2 0; % olive green
				0 0 0.502; % navy blue
				0.502 0 0.502; % violet
				0 0 1; % royal blue
				0.502 0.502 0]); % dark yellow
	end
	
	function  setToolTipDelay()
		% Set tool tip time delay
		tm = javax.swing.ToolTipManager.sharedInstance;
		javaMethodEDT('setInitialDelay', tm, 200);
	end
	
	function createJavaStatusBar()
		
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
		
		handles.statusbarObj = com.mathworks.mwswing.MJStatusBar;
		jRootPane.setStatusBar(handles.statusbarObj);
		handles.statusbarObj.setText('<html>Please import file(s) containing data to fit.</html>');
		
	end
	
	function createTabs()
		tabnames = {'1. Setup', '2. Options', '3. Results'};
		
		% Creates the tabs and tab group for uipanel3.
		handles.tabgroup = uitabgroup('Parent', handles.uipanel3, ...
				'tag', 'tabgroup', ...
				'SelectionChangedFcn', @(hObject,eventdata)FDGUI('tabgroup_SelectionChangedFcn', hObject, eventdata, guidata(hObject)));
		handles.tab_setup = uitab(handles.tabgroup, ...
				'Title', tabnames{1}, ...
				'tag', 'tab_setup', ...
				'TooltipString', 'Edit the profile range and background points.');
		handles.tab_peak = uitab(handles.tabgroup, ...
				'Title', tabnames{2}, ...
				'tag', 'tab_peak', ...
				'ForegroundColor', [0.8 0.8 0.8], ...
				'TooltipString', 'Input the peak functions and initial bounds for the fit equation.');
		handles.tab_results = uitab(handles.tabgroup, ...
				'Title', tabnames{3}, ...
				'tag', 'tab_results', ...
				'ForegroundColor', [0.8 0.8 0.8], ...
				'TooltipString', 'View the results of the fit.');
		
 		set(flipud(handles.panel_setup.Children), 'Parent', handles.tab_setup);
 		set(flipud(handles.panel_parameters.Children), 'Parent', handles.tab_peak, 'Visible', 'off');
 		set(flipud(handles.panel_results.Children), 'Parent', handles.tab_results, 'visible', 'off');
		
		% UserData of profile 7 is current maximum enabled profiles
		handles.profiles(7).UserData = 0;
	end
end