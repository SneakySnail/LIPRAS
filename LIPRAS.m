%% Initialization
function varargout = LIPRAS(varargin)
% FDGUI MATLAB code for FDGUI.fig

% Last Modified by GUIDE v2.5 14-Nov-2016 10:45:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LIPRAS_OpeningFcn, ...
    'gui_OutputFcn',  @LIPRAS_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...get
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
import javax.swing.*
import java.awt.*

addpath(genpath('callbacks'));
addpath(genpath('dialog'));
addpath(genpath('listener'));
% addpath(genpath('Resources'));
% addpath('test-path/');

handles = init_GUI(handles, varargin);
handles.plotdata='yes';
% Choose default command line output for FDGUI
handles.output = hObject;

handles.figure1.WindowButtonMotionFcn = @(o, e)WindowButtonMotionFcn(o, e,guidata(o));

assignin('base','handles',handles);
% Update handles structure
guidata(hObject, handles)

% Outputs from this function are returned to the command line.
function varargout = LIPRAS_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

% Executes on button press in push_addprofile.
function push_addprofile_Callback(hObject, eventdata, handles)
handles = add_profile(handles);
assignin('base','handles',handles)
guidata(hObject, handles)

function menu_clearfit_Callback(hObject, eventdata, handles)

% Executes on button press in push_removeprofile.
function push_removeprofile_Callback(hObject, eventdata, handles)
handles = remove_profile(find(handles.uipanel3==handles.profiles), handles);
assert(handles.profiles(7).UserData==handles.guidata.numProfiles);
if handles.profiles(7).UserData<=1
    set(hObject, 'enable', 'off');
end

guidata(hObject, handles)


% Executes on button press in push_newbkgd.
function push_newbkgd_Callback(hObject, eventdata, handles)
polyorder = str2num(handles.edit_polyorder.String);
cp = handles.guidata.currentProfile;

wprof=handles.guidata.currentProfile; % which profile we talking about here...

% lets check xrdContainer to know if bkg2th is filled
if isempty(handles.xrdContainer(1,wprof).bkgd2th);
        [points, pos]=EditSelectBkgPoints(handles);
handles.points{wprof}=points;
handles.pos{wprof}=pos;

else % else we are not editing bkg points

if isempty(handles.points{wprof}) % incase of all points deleted using delete or reset
    [points, pos]=EditSelectBkgPoints(handles);
handles.points{wprof}=points;
handles.pos{wprof}=pos;    
elseif handles.radiobutton14_add.Value==1 % activated the add feature
    [points, pos]=EditSelectBkgPoints(handles,handles.points{wprof},handles.pos{wprof},'Append');
handles.points{wprof}=points;
handles.pos{wprof}=pos;
elseif handles.radiobutton15_delete.Value==1 % activated the delete
    [points, pos]=EditSelectBkgPoints(handles,handles.points{wprof},handles.pos{wprof},'Delete');
handles.points{wprof}=points;
handles.pos{wprof}=pos;
end

if and(handles.radiobutton15_delete.Value==0,handles.radiobutton14_add==0)
else
    handles.xrd.bkgd2th=points; % this is here to activate the FitBackground button
end
% handles.xrd.resetBackground(numpoints,polyorder);
end
% Lets assign 2th points to bkgd2th in each xrdContainer
handles.xrdContainer(1,wprof).bkgd2th=handles.points{wprof};

if handles.guidata.numPeaks(cp) == 0
    set(handles.panel_parameters.Children, 'visible', 'off');
    t12 = findobj(handles.uipanel3, 'tag', 'text12');
    set([t12, handles.edit_numpeaks], 'visible', 'on', 'enable', 'on');
end

if ~isempty(handles.xrdContainer(1,wprof).bkgd2th)
    handles.tabpanel.TabEnables{2}='on';
    set(handles.push_fitbkgd, 'enable', 'on');
    set(handles.tab1_next, 'visible', 'on');
else
    handles.tabpanel.TabEnables{2} = 'off';
    set(handles.push_fitbkgd, 'enable', 'off');
    set(handles.tab1_next, 'visible', 'off');
end




plotX(handles);
guidata(hObject, handles)


function uitoggletool4_ClickedCallback(hObject, eventdata, handles)

function tabgroup_SelectionChangedFcn(hObject, eventdata, handles)

function menu_edit_Callback(hObject, eventdata, handles)



function edit_lambda_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of edit_lambda as text
%        str2double(get(hObject,'String')) returns contents of edit_lambda as a double
lambda=str2double(get(hObject,'String'));
handles.xrd.lambda=lambda;



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




function table_results_CellEditCallback(hObject,evt,handles)
r = evt.Indices(1);
[hObject.Data{:, 1}]=deal(false);
hObject.Data{r, 1} = true;
s='NoStats';
plot_coeffs(r, s, handles);
guidata(hObject, handles)



% Executes on button press in push_viewall.
function push_viewall_Callback(hObject, eventdata, handles)
plotFit(handles, 'all');

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
plotData(handles, get(handles.popup_filename,'Value'));

% 	if strcmpi(handles.uitoggletool5.State,'on')
% 		legend(handles.xrd.DisplayName,'box','off')
% 	end

set(handles.axes2,'Visible','off');
set(handles.axes2.Children,'Visible','off');
handles.xrd.Status=[status,'Done.'];

guidata(hObject,handles)



%% Toggle Button callback functions



%% Checkbox callback functions

function checkbox_recycle_Callback(o, e, handles)
if get(o, 'value')
    handles.xrd.recycle_results = 1;
else
    handles.xrd.recycle_results = 0;
end

% Executes on button press in checkbox_lambda.
function checkbox_lambda_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.edit_lambda,'Enable','on');
    handles.xrd.CuKa=true;
else
    set(handles.edit_lambda,'Enable','off');
    handles.xrd.CuKa=false;
end


% Superimpose raw data.
function checkbox_superimpose_Callback(hObject, eventdata, handles)
handles.xrd.Status='Superimposing raw data...';
axes(handles.axes1)
filenum=get(handles.popup_filename,'Value');
cla
% If box is checked, turn on hold in axes1
if get(hObject,'Value')
    handles.xrd.DisplayName = {};
    plotData(handles, filenum,'superimpose');
    set(handles.axes2,'Visible','off');
    set(handles.popup_filename, 'enable', 'on');
    set(handles.listbox_files, 'enable', 'on');
    set(handles.axes2.Children,'Visible','off');
    % 		handles.uitoggletool5.UserData=handles.uitoggletool5.State;
    uitoggletool5_OnCallback(handles.uitoggletool5, eventdata, handles)
else
    hold off
    plotX(handles);
    
end
handles.xrd.Status='Superimposing raw data... Done.';




%% Popup callback functions

% Executes on selection change in popup_filename.
function popup_filename_Callback(hObject, eventdata, handles)
% hObject.UserData: table_fitinitial values for each separate file
filenum = get(hObject, 'Value');
set(handles.text_filenum,'String',[num2str(filenum),' of ',num2str(length(hObject.String))]);
set(hObject,'UserData',handles.table_fitinitial.Data);
set(handles.listbox_files,'Value',filenum);

axes(handles.axes1)
% If superimpose box is checked, plot any subsequent data sets together
if get(handles.checkbox_superimpose,'Value')==1
    % If there is only one dataset plotted
    if length(handles.xrd.DisplayName)==1
        % If the same dataset is chosen
        if strcmp(handles.xrd.Filename(filenum),handles.xrd.DisplayName)
            % Do nothing and exit out of the function
            return
        end
    end
    plotData(handles, filenum,'superimpose');
else
    cla
    hold off
    handles.xrd.Status=['File changed to ',handles.xrd.Filename{filenum},'.'];
    plotX(handles);
end

guidata(hObject, handles)

function listbox_files_Callback(hObject,evt, handles)
set(handles.popup_filename,'value',hObject.Value(1));

LIPRAS('popup_filename_Callback',handles.popup_filename,[],guidata(hObject));



%% Edit box callback functions

% Profile Range edit box callback function.
function edit_fitrange_Callback(hObject, eventdata, handles)
num = str2double(get(hObject, 'string'));
if isempty(num) || isnan(num) || num <= 0
    handles.xrd.Status = ['<html><font color="red"><b>Warning: ' hObject.String ' is not a valid fit range. Please enter a floating point number greater than 0.'];
    set(hObject, 'string', sprintf('%2.4f', handles.xrd.fitrange));
    return
end

handles.xrd.fitrange = num;
handles.guidata.fitrange = num;
set(hObject,'string', sprintf('%2.4f', handles.xrd.fitrange), 'UserData',handles.xrd.fitrange);
handles.xrd.Status = 'Fit range was updated.';

%
function edit_polyorder_Callback(hObject, eventdata, handles)
num = str2double(hObject.String);
if isempty(num) || isnan(num) || ~isinteger(int8(num)) || num < 1
    handles.xrd.Status = ['<html><font color="red"><b>Warning: ' hObject.String ' is not a valid positive integer.'];
    set(hObject, 'string', num2str(3));
    return
end
num = int8(num);
set(hObject, 'string', num2str(num), 'UserData', num);
handles.xrd.PolyOrder=str2double(hObject.String);
handles.xrd.Status=['Coefficient backgrounds changed to ',get(hObject,'String'),'.'];


%% uitable callback functions




%% Toobar callback functions

% Import new file(s) to fit.
function uipushtoolnew_ClickedCallback(hObject, eventdata, handles)
menu_new_Callback(hObject, eventdata, handles);
guidata(hObject,handles);

% Toggles the legend.
function uitoggletool5_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(hObject.State,'on')
    handles.xrd.Status='Legend was turned on.';
    uitoggletool5_OnCallback(hObject, eventdata, handles)
else
    handles.xrd.Status='Legend was turned off.';
    uitoggletool5_OffCallback(hObject, eventdata, handles)
end

% Turns off the legend.
function uitoggletool5_OffCallback(hObject, eventdata, handles)
set(hObject,'State','off');
lgd = findobj(handles.figure1, 'tag', 'legend');
set(lgd, 'visible', 'off');

% Turns on the legend.
function uitoggletool5_OnCallback(hObject, eventdata, handles)
set(hObject,'State','on');
legend(handles.axes1, handles.xrd.DisplayName,'Box','off')

%% Menu callback functions

function menu_new_Callback(hObject, eventdata, handles)
handles.xrd.Status='Loading data... ';

import_data(handles);

function menu_save_Callback(hObject, eventdata, handles)
handles.xrd.Status='Saving results...';
outputError(handles.xrd,handles.guidata.currentProfile);
handles.xrd.Status='Saving results... Done.';

% ---
function menu_parameter_Callback(hObject, eventdata, handles)
handles.xrd.Status='Loading options file... ';

% Check if there is already a fit
% 	try call.overwriteExistingFit(handles);
% 	catch
% 		return
% 	end
%
try
    handles=ui.manager.load_parameter(handles);
catch ME
    ME.stack(1)
    
    ME.message
    
    keyboard
end

handles.xrd.Status='Options file successfully loaded.';
guidata(hObject, handles)


function menu_help_Callback(hObject, eventdata, handles)


function Untitled_10_Callback(hObject, eventdata, handles)


function menuHelp_fxns_Callback(hObject, eventdata, handles)



function edit8_Callback(hObject, eventdata, handles)


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

% Menu option callback to Import Workspace.
function Untitled_9_Callback(hObject, eventdata, handles)


% Plots the background points selected.
function push_fitbkgd_Callback(~, ~, handles)

ui.manager.plotBackgroundFit(handles);




%% Close request functions
function figure1_CloseRequestFcn(o, e, handles)
close_fig(handles);


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

% --- Executes during object creation, after setting all properties.
function edit_bkgdpoints_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
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

% Executes during object creation, after setting all properties.
function popup_numpeaks_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function menu_file_Callback(hObject, eventdata, handles)

% Executes during object creation, after setting all properties.
function edit_fitrange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
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


function radiobutton14_add_Callback(hObject, eventdata, handles)
set(handles.radiobutton14_add,'Value',1)

if and(get(handles.radiobutton14_add,'Value')==0,get(handles.radiobutton15_delete,'Value')==0)
set(handles.radiobutton14_add,'Value',1)
elseif get(handles.radiobutton15_delete,'Value')==1
    set(handles.radiobutton15_delete,'Value',0)
end

function radiobutton15_delete_Callback(hObject, eventdata, handles)
set(handles.radiobutton15_delete,'Value',1)

if and(get(handles.radiobutton14_add,'Value')==0,get(handles.radiobutton15_delete,'Value')==0)
set(handles.radiobutton15_delete,'Value',1)
elseif get(handles.radiobutton14_add,'Value')==1
    set(handles.radiobutton14_add,'Value',0)
end