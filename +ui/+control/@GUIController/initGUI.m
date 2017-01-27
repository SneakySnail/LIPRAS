% Initialize GUI controls
function handles = initGUI(handles)
set(handles.figure1, 'visible', 'on');

addToExecPath();

initComponents();

createJavaStatusBar();

guidata(handles.figure1, handles);

addControlListeners();

% handles.figure1.Position(1) = 0;
set(handles.figure1, 'visible', 'off'); % To prevent error

% ==============================================================================


%% helper functions
    function addToExecPath()
    directory = strsplit(which('LIPRAS'),filesep);
    addpath(strjoin(directory(1:end-1),filesep)); % add root directory of LIPRAS to path
    addpath(genpath([pwd '/callbacks']));
    addpath(genpath([pwd '/dialog']));
    addpath(genpath([pwd '/listener']));
    end
% ==========================================================================

    function initComponents()    
    % Default color order for plotting data series
    set(get(handles.axes1, 'Parent'), 'DefaultAxesColorOrder', ...
        [0      0     0;        % black
         1      0     0;        % red
         1      0.4   0;        % orange
         0.2    0.5   0;        % olive green
         0      0     0.502;    % navy blue
         0.502  0     0.502;    % violet
         0      0     1;        % royal blue
         0.502  0.502 0]);      % dark yellow
     handles.gui.Legend = 'on';
     set(handles.panel_setup, 'parent', handles.uipanel3);
     set(handles.panel_parameters,'parent', handles.uipanel3);
     set(handles.panel_results, 'parent', handles.uipanel3);
     handles.tabpanel = uix.TabPanel('parent', handles.uipanel3, 'tag','tabpanel');
     set(findobj(handles.uipanel3,'tag', 'panel_setup'), 'parent', handles.tabpanel, 'visible', 'on', 'title', '');
     set(findobj(handles.uipanel3,'tag','panel_parameters'),'parent',handles.tabpanel, 'visible', 'on', 'title','');
     set(findobj(handles.uipanel3,'tag','panel_results'), 'parent', handles.tabpanel, 'visible', 'on', 'title','');
     set(handles.tabpanel, 'tabtitles', {'1. Setup', '2. Options', '3. Results'}, ...
         'tabenables', {'on','off','off'}, 'fontsize', 11, 'tabwidth', 75);
     handles.edit_polyorder = utils.uispinner(handles.edit_polyorder, 3, 1, 25, 1);
     handles.edit_numpeaks = utils.uispinner(handles.edit_numpeaks, 0, 0, 20, 1);
    end
% ==========================================================================

    
% ==========================================================================

    function addControlListeners()
    addlistener(handles.gui, 'Status', ...
        'PostSet', @(o,e)statusChange(o,e,handles));
    addlistener(handles.axes1, 'ColorOrderIndex', ...
        'PostSet', @(o,e)colorOrderIndexChanged(o,e,guidata(e.AffectedObject)));
    set(handles.edit_numpeaks.JavaPeer, ...
        'StateChangedCallback', @(o,e)LIPRAS('edit_numpeaks_Callback',o,e,guidata(handles.figure1)));
    set(handles.edit_polyorder.JavaPeer, ...
        'StateChangedCallback', @(o,e)LIPRAS('edit_polyorder_Callback',o,e,guidata(handles.figure1)));
    % Requires a Java status bar to exist
    if ~isfield(handles, 'statusbarObj')
        msgId = 'LIPRAS:initGUI:InvalidJavaStatusBar';
        msg = 'Could not add a callback function for updating the status bar.';
        throw(MException(msgId, msg))
    end
    
    handles.figure1.WindowButtonMotionFcn = @(o, e)WindowButtonMotionFcn(o, e,guidata(o));
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
    try
        % left status bar
        handles.statusbarObj = javacomponent('com.mathworks.mwswing.MJStatusBar', 'South', handles.figure1);
        handles.statusbarObj = handles.statusbarObj.getComponent(0);
        handles.statusbarObj.setBackground(Color.white);
        handles.statusbarObj.setText('To start, import file(s) from your computer to fit.');
        handles.statusbarObj = handles.statusbarObj.getParent;
    catch
        msgId = 'LIPRAS:initGUI:JavaObjectCreation';
        msg = 'Could not create the Java status bar';
        throw(MException(msgId, msg));
    end
end
% ==========================================================================



end