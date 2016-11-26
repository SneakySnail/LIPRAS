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

% Create the java object status bar
createJavaStatusBar();

createUserData();

addControlListeners();

set(handles.panel_setup, 'parent', handles.profiles(7));
set(handles.panel_parameters,'parent', handles.profiles(7));
set(handles.panel_results, 'parent', handles.profiles(7));

%% helper functions
    function createUserData()
        handles.profiles(7) = handles.uipanel3;
        handles.profiles(7).UserData = 0; % delete
        handles.xrd = PackageFitDiffractionData;
        handles.xrdContainer(7) = handles.xrd;
                
        % guidata contains relevant parameters for each profile
        handles = resetGuiData(handles);
        
        handles.panel_constraints.UserData = zeros(1,5);
    end

    function addControlListeners()
        addlistener(handles.edit_numpeaks, 'UserData', 'PostSet', @(o,e)guidata.numpeaks(o,e,guidata(e.AffectedObject)));
        addlistener(handles.xrdContainer(7), 'Status', ...
            'PostSet', @(o,e)statusChange(o,e,handles,7));
        % This listener will resize axes1 when axes2 becomes visible
        % 				addlistener(handles.axes2, 'Visible', 'PostSet', @(o,e)visible.resizeAxes1ToFitAxes2Axes1ToFitAxes2(o,e,guidata(e.AffectedObject)));
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