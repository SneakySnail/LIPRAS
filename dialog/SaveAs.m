function varargout = SaveAs(varargin)
% SAVEAS MATLAB code for SaveAs.fig
%      SAVEAS by itself, creates a new SAVEAS or raises the
%      existing singleton*.
%
%      H = SAVEAS returns the handle to a new SAVEAS or the handle to
%      the existing singleton*.
%
%      SAVEAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVEAS.M with the given input arguments.
%
%      SAVEAS('Property','Value',...) creates a new SAVEAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SaveAs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SaveAs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SaveAs

% Last Modified by GUIDE v2.5 30-Jan-2017 06:55:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SaveAs_OpeningFcn, ...
                   'gui_OutputFcn',  @SaveAs_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before SaveAs is made visible.
function SaveAs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SaveAs (see VARARGIN)

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
handles.output = [];
clear plottools
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

IconData=questIconData;
questIconMap(256,:) = get(handles.figSaveAs, 'Color');
IconCMap=questIconMap;
set(handles.figSaveAs, 'Colormap', IconCMap);

% Make the GUI always stay on top
set(handles.figSaveAs,'WindowStyle','normal', 'visible', 'on', ...
    'Units', 'pixels', 'Position', [140 300 186 215])
if strcmpi(handles.figSaveAs.Visible, 'on')
    jf = utils.javaGetFigureFrame(handles.figSaveAs);
    container = jf.getFigurePanelContainer;
    drawnow
    root = container.getRootPane;
    root.getParent.setAlwaysOnTop(1);
end

% Get figure handles of LIPRAS
liprasFig = findall(0, 'tag', 'figure1');
if isempty(liprasFig)
    error('No figure to save')
end
lipras = guidata(liprasFig);
handles.lipras = lipras;

% Create figure and axes to save/print
delete(findall(0,'tag', 'figCustomSave'));
newfigcopy = figure('Name', 'Save Options', 'NumberTitle', 'off', ...'DockControls', 'off', ...
    'Tag', 'figCustomSave'); %, 'WindowStyle', 'docked');
ax = copyobj(lipras.axes1, newfigcopy);
set(ax, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
legend(ax,'show');
handles.ax = ax;

ax.XTickMode = 'manual';
ax.YTickMode = 'manual';
ax.ZTickMode = 'manual';
ax.XLimMode = 'manual';
newfigcopy.PaperPositionMode = 'auto';
newfigcopy.PaperUnits = 'inches';
newfigcopy.PaperPosition = [0 0 6 3];

% Enable docking for deployed figures
jframe = utils.javaGetFigureFrame(newfigcopy);
jframe.fHG2Client.setClientDockable(true);
jframe.fHG2Client.setClientWindowStyle(true, false); % initially dock the figure
setappdata(newfigcopy, 'JavaFrame', jframe);

% Enable editing
pe = propertyeditor(newfigcopy, 'on');
pe.validate();
handles.fig2save = newfigcopy;

% First get the desktop handle to figure out if the property editor is
% minimized or undocked
persistent dt
if isempty(dt)
    dt = jframe.getDesktop;
end
if dt.isClientMinimized(pe)
    dt.setClientMinimized(pe, false);
elseif ~dt.isClientDocked(pe)
    dt.setClientDocked(pe, true);
end

% Update jframe and pe variables in case property editor was undocked
jframe = utils.javaGetFigureFrame(newfigcopy);
setappdata(newfigcopy, 'JavaFrame', jframe);
pe = propertyeditor(newfigcopy, 'on');

% Disable some options we don't need
if pe.isShowZAxisControls
    javaMethodEDT('setShowZAxisControls', pe, false);
end
if pe.isShowInspectorButton
    javaMethodEDT('setShowInspectorButton', pe, false);
end
if pe.isShowDataSources
    javaMethodEDT('setShowDataSources', pe, false);
end
if pe.isShowRefreshDataButton
    javaMethodEDT('setShowRefreshDataButton', pe, false);
end

rootpane = pe.getRootPane;
if isempty(rootpane)
    pause(0.05), drawnow
    rootpane = pe.getRootPane;
end

try
    dtgframe = rootpane.getContentPane.getComponent(1);
catch
    pause(0.05), drawnow
    dtgframe = rootpane.getContentPane.getComponent(1);
end

toolbar = dtgframe.getComponent(0).getComponent(0);
if toolbar.isVisible
    toolbar.setVisible(false);
end

hProp = findprop(handle(newfigcopy),'WindowStyle');  % a schema.prop object
% if figure becomes docked or undocked, invoke the callback
hlistener = addlistener(handle(newfigcopy), hProp, 'PostSet',@(o,e)SaveAs('DockingCallbackFcn',o,e));
% attach listener to the GUI since it needs to be known (as long as the figure exists)
setappdata(newfigcopy, 'Handle_Listener', hlistener);

% Make document bar invisible so as not to trigger mouse clicked callbacks,
dtsplitpane = pe.getParent.getParent.getParent;
for i=1:dtsplitpane.countComponents
    if strcmp(dtsplitpane.getComponent(i-1).getName, 'DesktopDocumentContainer')
        ddcontainer = dtsplitpane.getComponent(i-1);
        break
    end
end
if ~isempty(ddcontainer)
    DTDocumentBar = javaObjectEDT(ddcontainer.getComponent(0).getComponent(0));
    DTDocumentBar.setVisible(false);
end


handles.fig2save = newfigcopy;
handles.rootpane2save = rootpane;
% Update handles structure
guidata(hObject, handles)

function DockingCallbackFcn(o,e)
% Runs every time a new figure is docked in the group.
% disable unneeded matlab figure menu items
hmenu = guihandles(e.AffectedObject);
hmenu.figMenuHelp.Visible = 'off';
hmenu.figMenuView.Visible = 'off';
hmenu.figMenuDesktop.Visible = 'off';
% File Menu Items
set(allchild(hmenu.figMenuFile), 'Visible', 'off');
hmenu.figMenuFilePrintPreview.Visible = 'on';
hmenu.printMenu.Visible = 'on';
% Edit Menu Items
hmenu.figMenuEditCopyFigure.Visible = 'off';
hmenu.figMenuEditCopyOptions.Visible = 'off';
hmenu.figMenuEditGCF.Visible = 'off';
hmenu.figMenuEditGCA.Visible = 'off';
hmenu.figMenuEditGCO.Visible = 'off';
hmenu.figMenuEditFindFiles.Visible = 'off';
hmenu.figMenuEditClearCmdHistory.Visible = 'off';
hmenu.figMenuEditClearCmdWindow.Visible = 'off';
hmenu.figMenuEditClearFigure.Visible = 'off';
hmenu.figMenuEditClearWorkspace.Visible = 'off';
% Insert Menu Items
hmenu.figMenuInsertAxes.Visible = 'off';
hmenu.figMenuInsertLight.Visible = 'off';
% Tools Menu Items
hmenu.figMenuToolsPlotedit.Visible = 'off';
hmenu.figMenuRotate3D.Visible = 'off';
hmenu.figMenuResetView.Visible = 'off';
hmenu.figBrush.Visible = 'off';
hmenu.figLinked.Visible = 'off';
hmenu.figMenuToolsBF.Visible = 'off';
hmenu.figMenuToolsDS.Visible = 'off';
hmenu.figDataManagerBrush.Visible = 'off';
hmenu.figDataManagerBrushTools.Visible = 'off';  
% ---

rootpane = getappdata(e.AffectedObject, 'JavaFrame');
% disable unneeded java figure menu items
try %  catch if plottools is off
jmenu = rootpane.getAxisComponent.getTopLevelAncestor.getJMenuBar;
for i=1:jmenu.getComponentCount
    if strcmp(jmenu.getComponent(i-1).getName, 'DesktopDebugMenu')
        jmenu.getComponent(i-1).setVisible(false);
    elseif strcmp(jmenu.getComponent(i-1).getName, 'DesktopMenu')
        jmenu.getComponent(i-1).setVisible(false);
    elseif strcmp(jmenu.getComponent(i-1).getName, 'DesktopWindowMenu')
        jmenu.getComponent(i-1).setVisible(false);
    end
end
catch
end
% ---
    
% --- Outputs from this function are returned to the command line.
function varargout = SaveAs_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function push_save_Callback(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plottools(handles.fig2save, 'off');
plotedit(handles.fig2save, 'off');
selected = handles.saveoptions.SelectedObject;
ext = ['.' lower(selected.String)];

path = uigetdir(handles.lipras.profiles.OutputPath, 'Save In...');
if ~isequal(path, 0)
    if path(end) ~= filesep
        path = [path filesep];
    end
    % Get all line properties
    oldfilenum = handles.lipras.gui.CurrentFile;
    allnames = handles.lipras.gui.getFileNames;
    
    oldobjs = allchild(handles.ax);
    
    for i=1:length(allnames)
        handles.lipras.gui.CurrentFile = i;
        name = handles.lipras.axes1.Title.String;
        handles.ax.Title.String = name;
        name = regexprep(name, '(\w+)+(?:[( ).])+','$1_');
        name = name(1:end-1); % get rid of last letter underscore
        
        newobjs = allchild(handles.lipras.axes1);
        set(oldobjs, {'XData', 'YData'}, get(newobjs, {'XData', 'YData'}));
        
        saveas(handles.fig2save, [path name ext]);
    end
    handles.lipras.gui.CurrentFile = oldfilenum;
    
    handles.output.path = path;
    handles.output.ext = ext;
    handles.output.numfiles = length(allnames);
    
    msgbox([num2str(handles.output.numfiles) ' files were saved in the directory ' handles.output.path ' as ' handles.output.ext ...
        ' files.'], 'Saved')
    
    figSaveAs_CloseRequestFcn(handles.figSaveAs, [], guidata(handles.figSaveAs));
end



% --- Executes on button press in pushbutton2.
function push_cancel_Callback(hObject, ~, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = [];
figSaveAs_CloseRequestFcn(handles.figSaveAs, [], guidata(handles.figSaveAs));


% --- Executes when user attempts to close figSaveAs.
function figSaveAs_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plottools(hObject, 'off');
delete(findall(0,'tag', 'figCustomSave'))
delete(hObject);



% --- Executes on key press over figSaveAs with no controls selected.
function figSaveAs_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    figSaveAs_CloseRequestFcn(handles.figSaveAs, [], guidata(handles.figSaveAs));
    
    % Update handles structure
    guidata(hObject, handles);
end
    
