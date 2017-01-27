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

if ~isempty(GUIController.getInstance())
    delete(GUIController.getInstance());
end

handles.profiles = ProfileListManager.getInstance();
guidata(hObject, handles);

handles.gui = GUIController.getInstance(hObject);
handles = GUIController.initGUI(handles);

assignin('base','handles',handles);
% Update handles structure
guidata(hObject, handles);
%===============================================================================

% Outputs from this function are returned to the command line.
function varargout = LIPRAS_OutputFcn(~, ~, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;
%===============================================================================

%  Executes on button press in button_browse.
function button_browse_Callback(hObject, ~, handles)
handles.gui.Status = 'Browsing for dataset... ';
handles.profiles.newXRD();
model.ProfileListManager.getInstance(handles.profiles);
if handles.profiles.hasData
    ui.update(handles, 'dataset');
else
    handles.gui.Status = '';
end

% Executes on button press in push_addprofile.
function push_addprofile_Callback(hObject, eventdata, handles)
handles = add_profile(handles);
assignin('base','handles',handles)
guidata(hObject, handles)
%===============================================================================

% Executes on button press in push_removeprofile.
function push_removeprofile_Callback(hObject, eventdata, handles)
handles = remove_profile(find(handles.uipanel3==handles.profiles), handles);
assert(handles.profiles(7).UserData==handles.guidata.numProfiles);
if handles.profiles(7).UserData<=1
    set(hObject, 'enable', 'off');
end

guidata(hObject, handles)
%===============================================================================

% Executes on button press in push_newbkgd.
function push_newbkgd_Callback(hObject, eventdata, handles)
import utils.plotutils.*
hold off
plotX(handles, 'data');
hold on

if handles.profiles.xrd.hasBackground
    plotX(handles, 'background');
end

selected = handles.group_bkgd_edit_mode.SelectedObject.String;

if strcmpi(selected, 'Delete')
    numpoints = length(handles.profiles.xrd.getBackgroundPoints);
    points = selectPointsFromPlot(handles, numpoints);
else
    points = selectPointsFromPlot(handles);
end

model.update(handles, 'backgroundpoints', points);
ui.update(handles, 'backgroundpoints');

% Plots the background points selected.
function push_fitbkgd_Callback(hObject, ~, handles)
import utils.plotutils.*
if handles.gui.isFitDirty
    plotX(handles, 'background');
else
    plotX(handles, 'sample');
end


function edit_min2t_Callback(~, ~, handles)
xrd = handles.profiles.xrd;
newValue = handles.gui.Min2T;
if ~isnan(newValue)
    model.update(handles, 'Min2T', newValue);
else
    handles.gui.Min2T = xrd.Min2T;
end
utils.plotutils.plotX(handles, 'sample');

function edit_max2t_Callback(~, ~, handles)
xrd = handles.profiles.xrd;
newValue = handles.gui.Max2T;
if ~isnan(newValue)
    model.update(handles, 'Max2T', newValue);
else
    handles.gui.Max2T = xrd.Max2T;
end
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
        handles.profiles.xrd.generateDefaultFitBounds;
    end
end
ui.update(handles, 'fitinitial');
utils.plotutils.plotX(handles, 'sample');

% Executes on button press of 'Select Peak(s)'.
function push_selectpeak_Callback(hObject, ~, handles)
import utils.plotutils.*
plotX(handles, 'data');
plotX(handles, 'backgroundfit');
peakcoeffs = find(contains(handles.profiles.xrd.getCoeffs, 'x'));
points = selectPointsFromPlot(handles, length(peakcoeffs));
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
function edit_numpeaks_Callback(src, ~, handles)
%NUMBEROFPEAKSCHANGED Callback function that executes when the value of the
%   JSpinner object changes. 
value = round(src.getValue);
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

% 	try call.overwriteExistingFit(handles);
% 	catch
% 		return
% 	end

handles.xrd.Fmodel=[];
len = size(handles.table_fitinitial.Data,1);
handles.table_fitinitial.Data = cell(len,3);
set(hObject.Parent.Children,'Enable','off');
set(handles.push_selectpeak,'Enable','on', 'string', 'Select Peak(s)');
set(handles.table_fitinitial,'Enable','on');
plotX(handles, 'Data');

% 	if strcmpi(handles.uitoggletool5.State,'on')
% 		legend(handles.xrd.DisplayName,'box','off')
% 	end

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

axes(handles.axes1)
cla
% If box is checked, turn on hold in axes1
if get(hObject,'Value')
    handles.xrd.DisplayName = {};
    plotX(handles, 'superimpose');
    set(handles.axes2,'Visible','off');
    set(handles.popup_filename, 'enable', 'on');
    set(handles.listbox_files, 'enable', 'on');
    set(handles.axes2.Children,'Visible','off');
    % 		handles.uitoggletool5.UserData=handles.uitoggletool5.State;
    toolbar_legend_OnCallback(handles.toolbar_legend, eventdata, guidata(hObject));
else
    hold off
    plotX(handles);
    
end
handles.xrd.Status='Superimposing raw data... Done.';




%% Popup callback functions

% Executes on selection change in popup_filename.
function popup_filename_Callback(hObject, eventdata, handles)

import utils.plotutils.plotX

ui.update(handles, 'filenumber');

superimposed = get(handles.checkbox_superimpose, 'Value');

% If superimpose box is checked, plot any subsequent data sets together
if superimposed
    numLines = length(handles.axes1.Children);
    
    isSameFile = strcmpi(handles.gui.getFileNames(filenum), handles.gui.DisplayName);
    
    % If there is only one dataset plotted and % if the same dataset is chosen
    if numLines > 1 && ~isSameFile
        plotX(handles, 'superimpose');    
    end
    
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

function menu_save_Callback(hObject, eventdata, handles)
if handles.profiles.xrd.hasFit
    handles.profiles.exportProfileParametersFile();
end

% ---
function menu_parameter_Callback(hObject, eventdata, handles)
filename = 0;
if handles.profiles.hasData
    [filename, pathName, ~]  = uigetfile({'*.txt;','*.txt'},'Select Input File','MultiSelect', 'off');
end
if filename ~= 0
    handles.profiles.importProfileParametersFile([pathName filename]);
    ui.update(handles, 'parameters');
end

function table_fitinitial_listener(src, e, handles)
dbstack(4)


function menu_preferences_Callback(~,~,~)
folder_name=uigetdir;
PreferenceFile=fopen('Preference File.txt','w');
fprintf(PreferenceFile,'%s\n',folder_name);

function menu_help_Callback(~,~)
h=uiwait(msgbox('Documentation is on its way...','Help'));
set(h, 'Position',[500 440 200 50]) % posx, posy, height, width
ah=get(h,'CurrentAxes');
c=get(ah,'Children');
set(c,'FontSize',11);

function menu_about_Callback(~,~)
% Displays a message box
h = uiwait(msgbox({'LIPRAS, version: 1.0' ['Authors: Klarissa Ramos, Giovanni Esteves, ' ...
    'Chris Fancher, and Jacob Jones'] 'North Carolina State University (2016)' '' ...
    'Contact Information' 'Giovanni Esteves' 'Email: gesteves21@gmail.com' ...
    'Jacob Jones' 'Email: jacobjones@ncsu.edu'}, 'About'));

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


function menu_close_Callback(hObject, eventdata, handles)
close_fig(handles);


% Menu: File -> Save As callback function
function Untitled_7_Callback(hObject, eventdata, handles)




%% Close request functions
function figure1_CloseRequestFcn(o, e, handles)
requestClose(handles);


%% CreateFcns and Unused Callbacks

% Executes during object creation, after setting all properties.
function edit_min2t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min2t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_max2t_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Executes during object creation, after setting all properties.
function edit_polyorder_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function noplotfit_Callback(hObject,eventdata,handles)

handles.noplotfit=get(hObject,'Value');


% Executes during object creation, after setting all properties.
function popup_filename_CreateFcn(hObject, eventdata, handles)
handles.n=1;
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)

% Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)

% Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Executes during object creation, after setting all properties.
function edit_lambda_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% function radiobutton14_add_Callback(hObject, eventdata, handles)
% set(handles.radiobutton14_add,'Value',1)
% 
% if and(get(handles.radiobutton14_add,'Value')==0,get(handles.radiobutton15_delete,'Value')==0)
%     set(handles.radiobutton14_add,'Value',1)
% elseif get(handles.radiobutton15_delete,'Value')==1
%     set(handles.radiobutton15_delete,'Value',0)
% end
% 
% function radiobutton15_delete_Callback(hObject, eventdata, handles)
% set(handles.radiobutton15_delete,'Value',1)
% 
% if and(get(handles.radiobutton14_add,'Value')==0,get(handles.radiobutton15_delete,'Value')==0)
%     set(handles.radiobutton15_delete,'Value',1)
% elseif get(handles.radiobutton14_add,'Value')==1
%     set(handles.radiobutton14_add,'Value',0)
% end

