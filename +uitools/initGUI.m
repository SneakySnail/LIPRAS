% Initialize GUI controls
function handles = initGUI(handles)    
    addToExecPath();
    
    initComponents();
    
    createJavaStatusBar();
    
    createUserData();
    
    handles = resetGuiData(handles);
    
    addControlListeners();

    reparentTabPanels();
    
%      handles.edit_polyorder = uitools.uispinner(handles.edit_polyorder, 3, 1, 25, 1);
    
    addLastCallbacks();

% ==============================================================================
    
    
    %% helper functions
    function addToExecPath()
        addpath(genpath('callbacks'));
        addpath(genpath('dialog'));
        addpath(genpath('listener'));
        % addpath(genpath('Resources'));
        % addpath('test-path/');
    end
    % ==========================================================================
    
    function initComponents()
        hold(handles.axes1, 'on');
        
        % Default color order for plotting data series
        set(get(handles.axes1, 'Parent'), 'DefaultAxesColorOrder', ...
            [0 0 0; % black
            1 0 0; % red
            1 0.4 0; % orange
            0.2 0.2 0; % olive green
            0 0 0.502; % navy blue
            0.502 0 0.502; % violet
            0 0 1; % royal blue
            0.502 0.502 0]); % dark yellow
        
        set(handles.table_paramselection, 'Data', cell(1, 1), ...
            'enable', 'on', 'ColumnName', {'Peak function'}, ...
            'ColumnWidth', {250}, 'Data', cell(1, 1));
        
    end
    % ==========================================================================
    
    function createUserData()
        handles.profiles(7) = handles.uipanel3;
        handles.profiles(7).UserData = 0; % delete
        handles.xrd = PackageFitDiffractionData;
        handles.xrdContainer(7) = handles.xrd;
        
    end
    % ==========================================================================
    
    function addControlListeners()
        addlistener(handles.xrdContainer(7), 'Status', ...
            'PostSet', @(o,e)statusChange(o,e,handles,7));
    end
    % ==========================================================================
    
    % Creates the Java status bar, used for updating the user on GUI actions. Throws
    % an exception if the Java object could not be created.
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
            
            % separator
%             sep = javaObjectEDT('javax.swing.JSeparator');
%             sep
            % right status bar
            handles.statusbarRight = javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
            handles.statusbarObj.add(handles.statusbarRight, 'East');
            handles.statusbarRight.setText('');
            jRootPane.setStatusBarVisible(1);
            
        catch
            msgId = 'initGUI:JavaObjectCreation';
            msg = 'Could not create the Java status bar';
            MException(msgId, msg);
        end
    end
    % ==========================================================================
    
    % Set the parents of the 3 major panels for tab switching functionality.
    function reparentTabPanels()
        set(handles.panel_setup, 'parent', handles.profiles(7));
        set(handles.panel_parameters,'parent', handles.profiles(7));
        set(handles.panel_results, 'parent', handles.profiles(7)); 
    end
    % ==========================================================================
    
    function replaceUiComponentWithSpinner()
        INCREMENT_VALUE = 1;
        
        hPoly = handles.edit_polyorder;
        INITIAL_POLYORDER = 3;
        MIN_POLYORDER = 1;
        MAX_POLYORDER = 25;
        
        jmodelPoly = javax.swing.SpinnerNumberModel( ...
            INITIAL_POLYORDER, ...
            MIN_POLYORDER, ...
            MAX_POLYORDER, ...
            INCREMENT_VALUE);
        
        jPoly = javax.swing.JSpinner(jmodelPoly);
        [~, jhPoly] = javacomponent(jPoly, hPoly.Position, hPoly.Parent);
        set(jhPoly, 'Units', 'Normalized', 'Position', hPoly.Position);
        
        handles.edit_polyorder = jhPoly;
        
    end
    % ==========================================================================
    
    
    % Adds callback functions to all other uicomponents. 
    % 
    % Assumes this is the last function called in the GUI initialization.
    % 
    % Throws an exception if the status bar is invalid.
    function addLastCallbacks()
        
        % Requires a Java status bar to exist
        if ~isa(handles.statusbarObj, 'com.mathworks.mwswing.MJStatusBar')
            msgId = 'initGUI:InvalidJavaStatusBar';
            msg = 'Could not add a callback function for updating the status bar.';
            MException(msgId, msg);
        end
        handles.figure1.WindowButtonMotionFcn = @(o, e)WindowButtonMotionFcn(o, e,guidata(o));
    end
    % ==========================================================================
end