% Initialize GUI controls
function handles = init_GUI(handles, varargin)
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

handles.profiles(7) = handles.uipanel3;
handles.profiles(7).UserData = 0; % delete
handles.xrd = PackageFitDiffractionData;
handles.xrdContainer(7) = handles.xrd;

handles.guidata.numProfiles = 0;
handles.guidata.PeakPositions = [];
handles.guidata.PSfxn = {};
handles.guidata.numPeaks = 0;
handles.guidata.constraints = handles.xrd.Constrains;
handles.guidata.fit_initial = [];
handles.guidata.coeff = '';
handles.guidata.fit_results = [];

% Change the time to wait until tooltip is displayed
% 	setToolTipDelay();

% Create the java object status bar
createJavaStatusBar();

addControlListeners();


set(handles.panel_setup, 'parent', handles.profiles(7));
set(handles.panel_parameters,'parent', handles.profiles(7));
set(handles.panel_results, 'parent', handles.profiles(7));


		function addControlListeners()
				addlistener(handles.edit_numpeaks, 'UserData', 'PostSet', @(o,e)guidata.numpeaks(o,e,guidata(e.AffectedObject)));
				
		end



		function  setToolTipDelay()
				% Set tool tip time delay
				tm = javax.swing.ToolTipManager.sharedInstance;
				javaMethodEDT('setInitialDelay', tm, 200);
		end

		function createJavaStatusBar()
				
				try
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
						
						
						% left status bar
						handles.statusbarObj = javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
						jRootPane.setStatusBar(handles.statusbarObj);
						handles.statusbarObj.setText('<html>Please import file(s) containing data to fit.</html>');
						
						% right status bar
						handles.statusbarRight = javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
						handles.statusbarObj.add(handles.statusbarRight, 'East');
						handles.statusbarRight.setText('');
						jRootPane.setStatusBarVisible(1);
						
				catch
						errordlg('Java components could not be created.')
				end
		end



		
end