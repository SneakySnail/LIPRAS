function varargout = LIPRAS(varargin)
% LIPRAS MATLAB code for LIPRAS.fig

% Last Modified by GUIDE v2.5 14-Nov-2016 10:45:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LIPRAS_OpeningFcn, ...
    'gui_OutputFcn',  @LIPRAS_OutputFcn, ...
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

% Executes just before LIPRAS is made visible.
function LIPRAS_OpeningFcn(hObject, eventdata, handles, varargin)
import ui.control.*
import model.*
import utils.fileutils.*

% Choose default command line output for FDGUI
handles.output = hObject;

handles.profiles = ProfileListManager.getInstance();
guidata(hObject, handles);

handles.gui = GUIController.getInstance(hObject);
handles = GUIController.initGUI(handles);

handles.validator = utils.Validator(handles);

assignin('base','handles',handles);
% Update handles structure
guidata(hObject, handles);
%===============================================================================

% Outputs from this function are returned to the command line.
function varargout = LIPRAS_OutputFcn(~, ~, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
%===============================================================================

function LIPRAS_DeleteFcn(hObject, eventdata, handles)
% Executes before closing the GUI, even if the function delete() is called instead of manually 
%   closing the figure. Cleans up the workspace.
try
    delete(handles.gui);
    delete(handles.profiles);
    delete(handles.validator);
catch
end
clear('handles', 'var');

%  Executes on button press in button_browse.
function button_browse_Callback(hObject, evt, handles)
handles.gui.Status = 'Browsing for dataset... ';
if isfield(evt, 'test')
    isNew = handles.profiles.newXRD(evt.path, evt.filename);
else
    isNew = handles.profiles.newXRD();
end
if isNew % if not the same dataset as before
    ui.update(handles,'reset');
    ui.update(handles, 'dataset');
else
    handles.gui.Status = '';
end

guidata(hObject, handles)

%  Executes on button press in push_newbkgd.
function push_newbkgd_Callback(hObject, eventdata, handles)
%   EVENTDATA can be used to pass test values to this function to avoid any blocking calls like
%   ginput.
import utils.plotutils.*

if isfield(eventdata, 'test')
    points = eventdata.test;
else
    selected = handles.group_bkgd_edit_mode.SelectedObject.String;
    if strcmpi(selected, 'Delete')
        oldpoints = handles.profiles.xrd.getBackgroundPoints;   
        numpoints = length(oldpoints);
        points = selectPointsFromPlot(handles, selected, numpoints);
    elseif strcmpi(selected, 'Add')
        oldpoints = handles.profiles.xrd.getBackgroundPoints;
        newpoints = selectPointsFromPlot(handles);
        points = sort([oldpoints newpoints]);
    else
        points = selectPointsFromPlot(handles, selected);
    end
end

try
    handles.profiles.xrd.setBackgroundPoints(points);
    ui.update(handles, 'backgroundpoints');
catch exception
    
    if strcmp(exception.identifier, 'MATLAB:polyfit:PolyNotUnique')
        warndlg('Polynomial is not unique; degree >= number of data points.', 'Warning')
    end
end

function menu_yplotscale_Callback(o,e,handles)
%MENU_YPLOTSCALE_CALLBACK executes when any option under 'Plot'->'Y-Axis Scale' menu is clicked. The
%   default selection is 'menu_ylinear'.
set(findobj(o.Parent), 'Checked', 'off'); % turn off checks in all x plot menu items
o.Checked = 'on';
plotter = handles.gui.Plotter;
switch o.Tag
    case 'menu_ylinear' % linear
        plotter.YScale = 'linear';
        
    case 'menu_ylog'% log
        plotter.YScale = 'log';
        
    case 'menu_yroot' % d-space
        plotter.YScale = 'sqrt';    
end

% Plots the background points selected.
function push_fitbkgd_Callback(hObject, ~, handles)
import utils.plotutils.*
if ~handles.gui.areFuncsReady || handles.gui.isFitDirty 
    plotX(handles, 'background');
else
    plotX(handles, 'sample');
end


function edit_min2t_Callback(~, ~, handles)
%EDIT_MIN2T_CALLBACK executes when the minimum 2theta value is changed in the GUI. 
xrd = handles.profiles.xrd;
newValue = handles.gui.Min2T;
if ~isnan(newValue)
    boundswarnmsg = '<html><font color="red">The inputted value is not within bounds.';
    if newValue < xrd.AbsoluteRange(1)
        newValue = xrd.AbsoluteRange(1);
        handles.gui.Status = boundswarnmsg;
        
    elseif newValue > xrd.AbsoluteRange(2)
        newValue = xrd.AbsoluteRange(2) - 0.5;
        handles.gui.Max2T = xrd.AbsoluteRange(2);
        handles.gui.Status = boundswarnmsg;
        
    elseif newValue >= xrd.Max2T
        max = newValue + 0.5;
        if max > xrd.AbsoluteRange(2)
            max = xrd.AbsoluteRange(2);
        end
        handles.gui.Max2T = max;
        xrd.Max2T = max;
    end
xrd.Min2T = newValue;
end
handles.gui.Min2T = xrd.Min2T;
utils.plotutils.plotX(handles, 'sample');

function edit_max2t_Callback(~, ~, handles)
xrd = handles.profiles.xrd;
newValue = handles.gui.Max2T;
if ~isnan(newValue)
    boundswarnmsg = '<html><font color="red">The inputted value is not within bounds.';
    
    if newValue < xrd.AbsoluteRange(1)
        newValue = xrd.AbsoluteRange(1) + 0.5;
        handles.gui.Min2T = xrd.AbsoluteRange(1);
        handles.gui.Status = boundswarnmsg;
        
    elseif newValue > xrd.AbsoluteRange(2)
        newValue = xrd.AbsoluteRange(2);
        handles.gui.Status = boundswarnmsg;
        
    elseif newValue <= xrd.Min2T
        min = newValue - 0.5;
        if min < xrd.AbsoluteRange(1)
            min = xrd.AbsoluteRange(1);
        end
        handles.gui.Min2T = min;
        xrd.Min2T = min;
    end
    xrd.Max2T = newValue;
end
handles.gui.Max2T = xrd.Max2T;
utils.plotutils.plotX(handles, 'sample');

function edit_polyorder_Callback(src, ~, handles)
%BACKGROUNDORDERCHANGED Summary of this function goes here
%   Detailed explanation goes here
value = round(src.getValue);

if value == 1 && strcmpi(handles.gui.BackgroundModel, 'Spline')
   value = 2;
   handles.gui.Status = '<html><font color="red"><b>Spline Order must be > 1.';
end

xrd = handles.profiles.xrd;
xrd.setBackgroundOrder(value);
handles.gui.PolyOrder = value;


function popup_bkgdmodel_Callback(o, ~, handles)
handles.profiles.xrd.setBackgroundModel(o.String{o.Value});
ui.update(handles,'backgroundmodel');

% Executes on button press of any checkbox in panel_constraints.
function checkbox_constraints_Callback(o, ~, handles)
% Save new constraint as an index from panel_constraints.UserData
if o.Value
    handles.profiles.xrd.constrain(o.String);
else
    handles.profiles.xrd.unconstrain(o.String);
end
ui.update(handles, 'Constraints');

% Executes on button press in checkbox_lambda.
function checkbox_CuKa_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.profiles.xrd.CuKa=true;
    set(handles.panel_cuka,'Visible', 'on');
else
    handles.profiles.xrd.CuKa=false;
    set(handles.panel_cuka,'Visible', 'off');
end


function edit_kalpha_Callback(hObject, eventdata, handles)
ka1 = str2double(get(handles.edit_kalpha1, 'String'));
ka2 = str2double(get(handles.edit_kalpha2, 'String'));
set(handles.edit_kalpha1, 'String', sprintf('%.4f', ka1));
set(handles.edit_kalpha2, 'String', sprintf('%.4f', ka2));
handles.profiles.xrd.KAlpha1 = ka1;
handles.profiles.xrd.KAlpha2 = ka2;
handles.gui.Status = ['<html>' hObject.TooltipString ' wavelength set to ' hObject.String '.'];


% Executes on  'Update' button press.
function push_update_Callback(hObject, ~, handles)
% This function sets the table_fitinitial in the GUI to have the coefficients for the new
% user-inputted function names.
% It also saves handles.guidata into handles.xrd
if handles.gui.isFitDirty
    % Make sure all peak positions are valid
    if isempty(find(handles.profiles.xrd.PeakPositions == 0,1))
        % Generate new values for the start, lower, and upper bounds
        handles.profiles.xrd.FitInitial = handles.validator.updatedFitBounds;
    end
end
ui.update(handles, 'fitinitial');

% Executes on button press of 'Select Peak(s)'.
function push_selectpeak_Callback(hObject, ~, handles)
import utils.contains
import utils.plotutils.*
plotX(handles, 'data');
plotX(handles, 'backgroundfit');

peakcoeffs = find(contains(handles.profiles.xrd.getCoeffs, 'x'));
points = selectPointsFromPlot(handles, [], length(peakcoeffs));
if length(points) == length(peakcoeffs)
    handles.profiles.xrd.PeakPositions = points;
    % Generate new default bounds because of new peak positions
    handles.profiles.xrd.generateDefaultFitBounds;
    ui.update(handles, 'peakposition');
    ui.update(handles, 'fitinitial');
else
    % Restore old plot
    plotX(handles, 'data');
end

% Executes when the handles.edit_numpeaks spinner value is changed.
function edit_numpeaks_Callback(src, eventdata, handles)
%NUMBEROFPEAKSCHANGED Callback function that executes when the value of the
%   JSpinner object changes. 
% 
%   EVENTDATA can be used to pass test values to this function by creating a structure with a
%   field 'test' containing the value(s) to use.
if isfield(eventdata, 'test')
    value = eventdata.test;
    src.setValue(value);
else
    value = round(src.getValue);
end
oldfcns = handles.profiles.xrd.getFunctions;
newfcns = cell(1, value);
for i=1:value
    if i <= length(oldfcns) && ~isempty(oldfcns{i})
        newfcns{i} = oldfcns{i}.Name;
    else
        break
    end
end
handles.profiles.xrd.setFunctions(newfcns);
ui.update(handles, 'NumPeaks');
ui.update(handles, 'functions');
ui.update(handles, 'constraints');

% Executes on button press in push_prevprofile.
function push_prevprofile_Callback(hObject, eventdata, handles)
i = find(handles.uipanel3==handles.profiles, 1) - 1;
if i<1; i=1; end
handles = change_profile(i, handles);
handles.xrd.Status = ['<html>Now editing <b>Profile ', num2str(i), '.</b></html>'];

assignin('base','handles',handles)
guidata(hObject,handles)

% Executes on button press in push_nextprofile.
function push_nextprofile_Callback(hObject, eventdata, handles)
i = find(handles.uipanel3==handles.profiles, 1) + 1;
handles = change_profile(i, handles);
handles.xrd.Status = ['<html>Now editing <b>Profile ', num2str(i), '.</b></html>'];

assignin('base','handles',handles)
guidata(hObject,handles)

function push_fitstats_Callback(~, ~, handles)
handles.gui.onPlotFitChange('stats');


function table_results_CellEditCallback(hObject,evt,handles)
hObject.Data(:,1) = {false};
hObject.Data{evt.Indices(1), 1} = true;
utils.plotutils.plotX(handles, 'coeff');


% Executes on button press in push_viewall.
function push_viewall_Callback(hObject, eventdata, handles)
utils.plotutils.plotX(handles, 'allfits');

% Executes on button press in push_default.
function push_default_Callback(hObject, eventdata, handles)
status='Clearing the table... ';
handles.xrd.Status=status;

handles.xrd.Fmodel=[];
len = size(handles.table_fitinitial.Data,1);
handles.table_fitinitial.Data = cell(len,3);
set(hObject.Parent.Children,'Enable','off');
set(handles.push_selectpeak,'Enable','on', 'string', 'Select Peak(s)');
set(handles.table_fitinitial,'Enable','on');
plotX(handles, 'Data');


set(handles.axes2,'Visible','off');
set(handles.axes2.Children,'Visible','off');
handles.xrd.Status=[status,'Done.'];

guidata(hObject,handles)


% Switches between different tabs in the current profile.
function push_tabswitch_Callback(hObject, e, handles)
% Switches between Tabs 1 (Setup), 2 (Parameters), and 3 (Results).
switch hObject.Tag
    case 'tab1_next'
        set(handles.tabpanel, 'Selection', 2);
    case 'tab2_prev'
        set(handles.tabpanel, 'Selection', 1);
    case 'tab2_next'
        set(handles.tabpanel, 'Selection', 3);
    case 'tab3_prev'
        set(handles.tabpanel, 'Selection', 2);		
end

%% Toggle Button callback functions



%% Checkbox callback functions

function checkbox_recycle_Callback(o, e, handles) %#ok<*DEFNU>
if get(o, 'value')
    handles.xrd.recycle_results = 1;
else
    handles.xrd.recycle_results = 0;
end

% Superimpose raw data.
function checkbox_superimpose_Callback(hObject, eventdata, handles)

cla(handles.axes1)
% If box is checked, turn on hold in axes1
if get(hObject,'Value')
    hold(handles.axes1, 'on')
    utils.plotutils.plotX(handles, 'superimpose');
else
    utils.plotutils.plotX(handles);
end
handles.xrd.Status='Superimposing raw data...';




%% Popup callback functions

% Executes on selection change in popup_filename.
function popup_filename_Callback(hObject, eventdata, handles)
import utils.plotutils.plotX
ui.update(handles, 'filenumber');
superimposed = get(handles.checkbox_superimpose, 'Value');

% If superimpose box is checked, plot any subsequent data sets together
if superimposed
    plotX(handles, 'superimpose');
else
    plotX(handles);
end

guidata(hObject, handles)

function listbox_files_Callback(hObject,evt, handles)
set(handles.popup_filename,'value',hObject.Value(1));

LIPRAS('popup_filename_Callback',handles.popup_filename,[],guidata(hObject));



%% Toobar callback functions

function toolbar_legend_ClickedCallback(hObject, eventdata, handles)
% Toggles the legend.
if strcmpi(hObject.State,'on')
    toolbar_legend_OnCallback(hObject, eventdata, handles);

else
    toolbar_legend_OffCallback(hObject, eventdata, handles);
end

% Turns off the legend.
function toolbar_legend_OffCallback(~, ~, handles)
handles.gui.Legend = 'off';

function toolbar_legend_OnCallback(~, ~, handles)
% Turns on the legend.
handles.gui.Legend = 'on';

%% Menu callback functions

function menu_save_Callback(~, ~, handles)
if handles.profiles.hasFit
    handles.profiles.exportProfileParametersFile();
end

% ---
function menu_parameter_Callback(~, evt, handles)
filename = 0;
if isfield(evt, 'test')
    filename = evt.test;
    pathName = evt.path;
else
    if handles.profiles.hasData
        filespec = fullfile(handles.profiles.OutputPath,'*.txt');
        [filename, pathName, ~]  = uigetfile(filespec,'Select Input File','MultiSelect', 'off');
    end
end
if filename ~= 0
    handles.profiles.importProfileParametersFile([pathName filename]);
    ui.update(handles, 'parameters');
end

function menu_restart_Callback(o,e,handles)
delete(handles.figure1);
LIPRAS;
handles = guidata(LIPRAS);
guidata(handles.figure1, handles);

% Executes when the menu item 'Export->As Image' is clicked.
function menu_saveasimage_Callback(o,e,handles)
SaveAs;

function menu_preferences_Callback(~,~,~)
folder_name=uigetdir;
PreferenceFile=fopen('Preference File.txt','w');
fprintf(PreferenceFile,'%s\n',folder_name);

function menu_help_Callback(~,~)
h=msgbox('Documentation is on its way...','Help');
set(h, 'Position',[500 440 200 50]) % posx, posy, height, width
ah=get(h,'CurrentAxes');
c=get(ah,'Children');
set(c,'FontSize',11);

function menu_about_Callback(~,~)
% Displays a message box
h = msgbox({'LIPRAS, version: 1.0' ['Authors: Klarissa Ramos, Giovanni Esteves, ' ...
    'Chris Fancher, and Jacob Jones'] 'North Carolina State University (2016)' '' ...
    'Contact Information' 'Giovanni Esteves' 'Email: gesteves21@gmail.com' ...
    'Jacob Jones' 'Email: jacobjones@ncsu.edu'}, 'About');

set(h, 'Position',[500 440 400 180]) % posx, posy, horiz, vert
ah=get(h,'CurrentAxes');
c=get(ah,'Children');
set(c,'FontSize',11);


function menu_clearall_Callback(hObject, eventdata, handles)
% If there is data loaded, confirm
ans=questdlg('This will reset the figure and your data will be lost.','Warning','Continue','Cancel','Cancel');
if strcmp(ans,'Continue')
    handles.xrd = PackageFitDiffractionData;
    handles.xrdContainer = handles.xrd;
    set(handles.panel_rightside,'Visible','off');
    set(handles.edit8,...
        'String', 'Upload new file(s)...',...
        'FontAngle', 'italic',...
        'ForegroundColor', [0.5 0.5 0.5]);
end


%% Close request functions
function figure1_CloseRequestFcn(~, ~, handles)
requestClose(handles);

function noplotfit_Callback(hObject,~,handles)
handles.noplotfit=get(hObject,'Value');


