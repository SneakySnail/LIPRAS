% Initialize GUI controls
function handles = initGUI(handles)
addToExecPath();

initComponents();

createJavaStatusBar();

createUserData();

handles = resetGuiData(handles);

addControlListeners();

reparentTabPanels();

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
    
    o = handles.toolbar_legend;
    LIPRAS('toolbar_legend_ClickedCallback', o, [], guidata(o));
    
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
    
    addlistener(handles.axes1, 'ColorOrderIndex', ...
        'PostSet', @(o,e)colorOrderIndexChanged(o,e,guidata(e.AffectedObject)));
    end
% ==========================================================================

% Creates the Java status bar, used for updating the user on GUI actions. Throws
% an exception if the Java object could not be created.
    function createJavaStatusBar()
    % When calling for the underlying java window, it will return empty unless
    % the figure is visible
    import javax.swing.border.EtchedBorder
    import javax.swing.BorderFactory
    import java.awt.BorderLayout
    import java.awt.Color
    
    set(handles.figure1, 'visible', 'on');
    try
        % left status bar
        handles.statusbarObj = javaObjectEDT('com.mathworks.mwswing.MJStatusBar');
        handles.statusbarObj = javacomponent(handles.statusbarObj, 'South');
        handles.statusbarObj = handles.statusbarObj.getComponent(0);
        handles.statusbarObj.setBackground(Color.white);
        %         jRootPane.setStatusBar(handles.statusbarObj);
        handles.statusbarObj.setText('To start, import file(s) from your computer to fit.');
        
        % border
        %             newBorder = BorderFactory.createEtchedBorder(EtchedBorder.RAISED);
        %             newBorder = BorderFactory.createEtchedBorder(EtchedBorder.LOWERED);
        %             newBorder = BorderFactory.createLoweredBevelBorder();
        %         newBorder = BorderFactory.createRaisedBevelBorder();
        %         newBorder = BorderFactory.createEtchedBorder(EtchedBorder.LOWERED);
        %         handles.statusbarObj.setBorder(newBorder);
        
    catch
        msgId = 'LIPRAS:initGUI:JavaObjectCreation';
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