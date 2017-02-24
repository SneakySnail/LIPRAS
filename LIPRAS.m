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
    
    % Restore previous search path
    path(getappdata(handles.figure1, 'oldpath'));
catch
end
clear('handles', 'var');

function LIPRAS_WindowButtonMotionFcn(hObject, evt, handles)
% Executes when the mouse moves inside the figure.
%
%   If it is not empty, display the TooltipString for an object in statusbarObj even when it's
%   disabled.
msg = '';
try
    obj = hittest(hObject);
    if  ~isempty(obj.TooltipString)
        msg = obj.TooltipString;
    end
catch
    try
        xx = num2str(handles.axes1.CurrentPoint(1,1));
        yy = sprintf('%.3G', handles.axes1.CurrentPoint(1,2));
        if strcmpi(class(obj), 'matlab.graphics.chart.primitive.Line')
            displayName = obj.DisplayName;
            msg = [displayName ': (' xx ', ' yy ')'];
        end
    catch
    end
end
handles.gui.Status = msg;

function LIPRAS_StatusChangedFcn(o, e, handles)
%STATUSCHANGE executes when the ProfileListManager property 'Status' is changed. 
handles.statusbarObj.setText(handles.profiles.Status);

%  Executes on button press in button_browse.
function button_browse_Callback(hObject, evt, handles)
handles.gui.PriorityStatus = 'Browsing for dataset... ';
if isfield(evt, 'test')
    isNew = handles.profiles.newXRD(evt.path, evt.filename);
else
    isNew = handles.profiles.newXRD();
end
if isNew % if not the same dataset as before
    ui.update(handles, 'dataset');
    utils.plotutils.plotX(handles, 'data');
else
    handles.gui.PriorityStatus = '';
end

function checkbox_reverse_Callback(o,e,handles)
if o.Value
    handles.gui.PriorityStatus = 'Dataset will fit in descending order.';
else
    handles.gui.PriorityStatus = 'Dataset will fit in ascending order.';
end
handles.profiles.xrd.reverseDataSetOrder;
handles.gui.reverseDataSetOrder;
utils.plotutils.plotX(handles);


%  Executes on button press in push_newbkgd.
function push_newbkgd_Callback(hObject, eventdata, handles)
%   EVENTDATA can be used to pass test values to this function to avoid any blocking calls like
%   ginput. If the number of background points is less than the background order,
%    issue a warning.
import utils.plotutils.*
plotX(handles,'data');
handles.checkbox_superimpose.Value = 0;
mode = get(handles.group_bkgd_edit_mode.SelectedObject, 'String');
points = selectBackgroundPoints(handles, mode);
if length(points) == 1 && isnan(points)
    utils.plotutils.plotX(handles, 'background');
    return
end
validPoints = handles.validator.backgroundPoints(points);
handles.profiles.xrd.setBackgroundPoints(validPoints);
ui.update(handles, 'backgroundpoints');

function menu_xplotscale_Callback(o,e,handles)
plotter = handles.gui.Plotter;
switch o.Tag
    case 'menu_xaxis_linear'
        plotter.XScale = 'linear';
    case 'menu_xaxis_dspace'
        answer = inputdlg('Enter wavelength (in Angstroms):', 'Input Wavelength', ...
            1, {'1.5406'}, struct('Interpreter', 'tex'));
        if isempty(answer)
            return
        elseif ~isnan(str2double(answer{1}))
            handles.profiles.KAlpha1 = str2double(answer{1});
        else
            errordlg('You did not input a valid number.', 'Invalid Wavelength')
            return
        end
        plotter.XScale = 'dspace';
end
set(findobj(o.Parent), 'Checked', 'off'); % turn off checks in all x plot menu items
o.Checked = 'on';

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
newValue = handles.validator.min2T(handles.gui.Min2T);
handles.profiles.xrd.Min2T = newValue;
handles.gui.Min2T = newValue;
utils.plotutils.plotX(handles);

function edit_max2t_Callback(~, ~, handles)
newValue = handles.validator.max2T(handles.gui.Max2T);
handles.profiles.xrd.Max2T = newValue;
handles.gui.Max2T = newValue;
utils.plotutils.plotX(handles);

function edit_polyorder_Callback(src, ~, handles)
%BACKGROUNDORDERCHANGED Summary of this function goes here
%   Detailed explanation goes here
value = round(src.getValue);
if value == 1 && strcmpi(handles.gui.BackgroundModel, 'Spline')
   value = 2;
   handles.gui.PriorityStatus = '<html><font color="red">Spline Order must be > 1.';
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
handles.profiles.xrd.KAlpha1 = ka1;
handles.profiles.xrd.KAlpha2 = ka2;
handles.gui.KAlpha1 = ka1;
handles.gui.KAlpha2 = ka2;
utils.plotutils.plotX(handles);
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
        handles.profiles.xrd.FitInitial = handles.validator.fitBounds;
    end
end
ui.update(handles, 'fitinitial');

% Executes on button press of 'Select Peak(s)'.
function push_selectpeak_Callback(hObject, ~, handles)
import utils.contains
import utils.plotutils.*

peakcoeffs = find(contains(handles.profiles.xrd.getCoeffs, 'x'));
points = utils.plotutils.selectPeakPoints(handles, length(peakcoeffs));
if length(points) == length(peakcoeffs)
    handles.profiles.xrd.PeakPositions = points;
    % Generate new default bounds because of new peak positions
    handles.profiles.xrd.generateDefaultFitBounds;
    ui.update(handles, 'peakposition');
    ui.update(handles, 'fitinitial');
else
    % Restore old plot
    plotX(handles, 'sample');
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

function table_paramselection_CellEditCallback(hObject, evt, handles)
%   EVT can be used to test the GUI by passing a struct variable with the field name 'test'
%   containing the value to set. It also has the field 'Indices'.
row = evt.Indices(1);
col = evt.Indices(2);
if isfield(evt, 'test')
    handles.gui.FcnNames{row} = evt.test;
end
if col == 1
    % Function change
    handles.profiles.xrd.setFunctions(handles.gui.FcnNames{row}, row);
    ui.update(handles, 'functions');
    handles.profiles.xrd.constrain(handles.gui.Constraints);
    ui.update(handles, 'constraints');
else
    % On constraint value change
    handles.profiles.xrd.unconstrain('Nxfwm');
    handles.profiles.xrd.constrain(handles.gui.ConstraintsInTable);
    ui.update(handles, 'Constraints');
    
end

% Executes when entered data in editable cell(s) in table_coeffvals.
function table_fitinitial_CellEditCallback(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% 
% Assumes handles.gui.Coefficients == handles.profiles.xrd.getCoeffs
row = eventdata.Indices(1);
column = eventdata.Indices(2);
newValue = eventdata.NewData;
fitinitial = handles.profiles.xrd.FitInitial;
coeffs = handles.profiles.xrd.getCoeffs;
switch column
    case 1
        fitinitial.start(row) = handles.validator.startPoint(coeffs{row}, newValue);
    case 2
        fitinitial.lower(row) = handles.validator.lowerBound(coeffs{row}, newValue);
    case 3
        fitinitial.upper(row) = handles.validator.upperBound(coeffs{row}, newValue);
end
handles.profiles.xrd.FitInitial = fitinitial;
handles.gui.FitInitial = fitinitial;
ui.update(handles, 'fitinitial');

assignin('base', 'handles', handles);
guidata(hObject,handles)

% Executes on button press in push_fitdata.
function push_fitdata_Callback(~, ~, handles)
try
    prfn = handles.profiles.getCurrentProfileNumber;    
    fitresults = handles.profiles.fitDataSet(prfn);
    if ~isempty(fitresults)
        ui.update(handles, 'results');
    end
catch ME
    ME.getReport
    assignin('base','lastException',ME)
    errordlg(ME.message)
end

function push_fitstats_Callback(~, ~, handles)
handles.gui.onPlotFitChange('stats');


function table_results_CellEditCallback(hObject,evt,handles)
hObject.Data(:,1) = {false};
hObject.Data{evt.Indices(1), 1} = true;
utils.plotutils.plotX(handles, 'coeff');


% Executes on button press in push_viewall.
function push_viewall_Callback(hObject, eventdata, handles)
utils.plotutils.plotX(handles, 'allfits');

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
    handles.gui.Legend = 'reset';
end
handles.xrd.Status='Superimposing raw data...';


%% Popup callback functions

% Executes on selection change in popup_filename.
function popup_filename_Callback(hObject, eventdata, handles)
handles.gui.CurrentFile = hObject.Value;
superimposed = get(handles.checkbox_superimpose, 'Value');
if superimposed
    utils.plotutils.plotX(handles, 'superimpose');
else
    utils.plotutils.plotX(handles);
end

function listbox_files_Callback(hObject,evt, handles)
handles.gui.CurrentFile = hObject.Value;
utils.plotutils.plotX(handles);

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
handles.gui.Legend = 'reset';

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

function menu_FileResetProfile_Callback(o,e,handles)
handles.profiles.reset;
cla(handles.axes1);
ui.update(handles, 'dataset');
utils.plotutils.plotX(handles, 'data');
handles.gui.Legend = 'reset';

function menu_restart_Callback(o,e,handles)
delete(handles.figure1);
fig = LIPRAS;
handles = guidata(fig);
guidata(handles.figure1, handles);

% Executes when the menu item 'Export->As Image' is clicked.
function menu_saveasimage_Callback(o,e,handles)
LiprasDialog.exportPlotAsImage(handles);


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


%% Close request functions
function figure1_CloseRequestFcn(~, ~, handles)
requestClose(handles);


