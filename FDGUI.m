%% GUI for FitDiffractionData

%% handles structure
% Descriptions of each variable saved in the handles structure.
% 
% <include>handles_structure.m</include>

%% Initialization

function varargout = FDGUI(varargin)
% FDGUI MATLAB code for FDGUI.fig
%      FDGUI, by itself, creates a new FDGUI or raises the existing
%      singleton*.
%
%      H = FDGUI returns the handle to a new FDGUI or the handle to
%      the existing singleton*.
%
%      FDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FDGUI.M with the given input arguments.
%
%      FDGUI('Property','Value',...) creates a new FDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FDGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FDGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 15-Aug-2016 21:10:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
	'gui_Singleton',  gui_Singleton, ...
	'gui_OpeningFcn', @FDGUI_OpeningFcn, ...
	'gui_OutputFcn',  @FDGUI_OutputFcn, ...
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

% --- Executes just before FDGUI is made visible.
function FDGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FDGUI (see VARARGIN)

handles = call.initGUI(hObject, eventdata, handles, varargin);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = FDGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Pushbutton callback functions

%  Executes on button press in button_browse.
function button_browse_Callback(hObject, eventdata, handles)
% hObject    handle to button_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xrd.Status='Browsing files... ';

call.importData(hObject, eventdata, handles);

%%% pushbutton15
% Executes on  'Update' button press.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'enable','off');
set(handles.uipanel4,'visible','on');
set(handles.uipanel4.Children,'visible','on');
status='Updating fit parameters... ';
handles.xrd.Status=status;
filenum = handles.popup_filename.Value;

% If data has already been fitted, issue warning
a = call.checkToOverwrite('This will cause the current fit to be discarded. Continue?', handles);

if strcmp(a,'Cancel')
	handles.xrd.Status=[status,'Canceled.'];
	call.revertPanel(handles);
	return
end

handles.xrd.Fmodel=[];

% Set parameters in xrd
param = call.getModifiedParam(handles);
handles.xrd.PSfxn = param.fcnNames;
handles.xrd.Constrains = param.constraints;
handles.xrd.PeakPositions = param.peakPositions;

set(handles.uitable1,'RowName', param.coeff);
handles.uitable1.Data = cell(length(param.coeff), 4);

cla(handles.axes1), cla(handles.axes2)
handles.axes2.Visible = 'off';
handles.xrd.plotData(filenum)

handles.xrd.Status = [status,'Done.'];

call.fillEmptyCells(handles);
handles = call.plotSampleFit(handles);
call.checkuitable1(handles);

guidata(hObject,handles)
	
% --- Executes on button press in push_newbkgd.
function push_newbkgd_Callback(hObject, eventdata, handles)
% hObject    handle to push_newbkgd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numpoints = str2num(handles.edit_bkgdpoints.String);
polyorder = str2num(handles.edit_polyorder.String);
handles.xrd.resetBackground(numpoints,polyorder);
if ~isempty(handles.xrd.bkgd2th)
	set(handles.tab_peak,'ForegroundColor',[0 0 0]);
	handles.tabgroup.SelectedTab=handles.tab_peak;
	set(handles.togglebutton_showbkgd,'enable','on');
end

call.plotX(handles);


% --- Executes on button press in push_fitdata.
function push_fitdata_Callback(hObject, eventdata, handles)
% hObject    handle to push_fitdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xrd.Status='Fitting dataset...';

handles = call.fitdata(hObject, eventdata, handles);

handles.xrd.Status = 'Fitting dataset... Done.';
set(handles.menu_save,'Enable','on');

guidata(hObject, handles)

% --- Executes on button press in push_prevprofile.
function push_prevprofile_Callback(hObject, eventdata, handles)
% hObject    handle to push_prevprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = call.changeProfile(hObject, eventdata,handles);
guidata(hObject,handles)

% --- Executes on button press in push_nextprofile.
function push_nextprofile_Callback(hObject, eventdata, handles)
% hObject    handle to push_nextprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = call.changeProfile(hObject, eventdata, handles);
guidata(hObject,handles)

% --- Executes on button press in push_viewall.
function push_viewall_Callback(hObject, eventdata, handles)
% hObject    handle to push_viewall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.xrd.plotFit('all')

% --- Executes on button press in push_default.
function push_default_Callback(hObject, eventdata, handles)
% hObject    handle to push_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status='Clearing the table... ';
handles.xrd.Status=status;
a=call.checkToOverwrite('This will cause the current fit to be discarded. Continue?',handles);

if strcmpi(a,'Cancel')
	handles.xrd.Status=[status,'Canceled.'];
	return
end

handles.xrd.Fmodel=[];
len = size(handles.uitable1.Data,1);
handles.uitable1.Data = cell(len,4);
set(hObject.Parent.Children,'Enable','off');
set(handles.pushbutton17,'Enable','on', 'string', 'Select Peak(s)');
set(handles.uitable1,'Enable','on');
handles.xrd.plotData(get(handles.popup_filename,'Value'));

if strcmpi(handles.uitoggletool5.State,'on')
	legend(handles.xrd.DisplayName,'box','off')
end

set(handles.axes2,'Visible','off');
set(handles.axes2.Children,'Visible','off');
handles.xrd.Status=[status,'Done.'];

guidata(hObject,handles)

% --- Executes on button press of 'Select Peak(s)'.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status='Selecting peak positions(s)... ';
handles.xrd.Status=status;

a=call.checkToOverwrite('This will cause the current fit to be discarded. Continue?',handles);

if strcmpi(a,'Cancel')
	handles.xrd.Status=['Current action was interrupted.'];
	return
end

call.selectPeaks(hObject, eventdata, handles);

handles.xrd.Status=[status, 'Done.'];


%% Toggle Button callback functions

% --- Executes on button press in togglebutton_showbkgd.
function togglebutton_showbkgd_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_showbkgd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_showbkgd
filenum=get(handles.popup_filename,'value');

axes(handles.axes1)
call.plotx(handles);

if hObject.Value
	[pos,indX]=handles.xrd.getBackground;
	hold on
	plot(pos,handles.xrd.data_fit(filenum,indX),'r*')
end


% ------------------------------------------
%% Checkbox callback functions
% ------------------------------------------

% --- Executes on button press in checkbox_lambda.
function checkbox_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lambda

if get(hObject,'Value')
	set(handles.edit_lambda,'Enable','on');
	handles.xrd.CuKa=true;
else
	set(handles.edit_lambda,'Enable','off');
	handles.xrd.CuKa=false;
end

% --- Executes on button press of any checkbox in uipanel5.
% Saves new constraint values to handles.uipanel5.UserData.
function checkboxN_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the values of the popups for choosing functions
pop = flipud(findobj(handles.uipanel6.Children, ...
		'style', 'popupmenu', ...
		'visible','on'));
fxns = [pop.Value];

% Save constraint value in uipanel5.UserData
if hObject.Value == 1
	handles.xrd.Status=['Selected constraint ',get(hObject,'String'),'.'];
	if strcmpi(hObject.String, 'N')
		hObject.Parent.UserData(1) = 1;
	elseif strcmpi(hObject.String, 'f')
		hObject.Parent.UserData(2) = 1;
	elseif strcmpi(hObject.String, 'w')
		hObject.Parent.UserData(3) = 1;
	elseif strcmpi(hObject.String,'m')
		hObject.Parent.UserData(4) = 1;
	end
else
	handles.xrd.Status=['Deselected constraint ',get(hObject,'String'),'.'];
	if strcmpi(hObject.String, 'N')
		hObject.Parent.UserData(1) = 0;
	elseif strcmpi(hObject.String, 'f')
		hObject.Parent.UserData(2) = 0;
	elseif strcmpi(hObject.String, 'w')
		hObject.Parent.UserData(3) = 0;
	elseif strcmpi(hObject.String,'m')
		hObject.Parent.UserData(4) = 0;
	end
end

call.setEnableUpdateButton(handles);

% --- Superimpose raw data.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xrd.Status='Superimposing raw data...';
axes(handles.axes1)
filenum=get(handles.popup_filename,'Value');
cla
% If box is checked, turn on hold in axes1
if get(hObject,'Value')
	handles.xrd.DisplayName = {};
	handles.xrd.plotData(filenum,'superimpose');
	set(handles.axes2,'Visible','off');
	set(handles.axes2.Children,'Visible','off');
	handles.uitoggletool5.UserData=handles.uitoggletool5.State;
	uitoggletool5_OnCallback(handles.uitoggletool5, eventdata, handles)
else
	hold off
	call.plotx(handles);
	if strcmpi(handles.uitoggletool5.UserData,'off')
		uitoggletool5_OffCallback(handles.uitoggletool5, eventdata, handles)
	end
end
handles.xrd.Status='Superimposing raw data... Done.';


%% Popup callback functions
	% --- Executes on selection change in popup_filename.
function popup_filename_Callback(hObject, eventdata, handles)
% hObject    handle to popup_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject.UserData: uitable1 values for each separate file
filenum = get(hObject, 'Value');
set(handles.text_filenum,'String',[num2str(filenum),' of ',num2str(length(hObject.String))]);
set(hObject,'UserData',handles.uitable1.Data);

axes(handles.axes1)
% If superimpose box is checked, plot any subsequent data sets together
if get(handles.checkbox10,'Value')==1
	% If there is only one dataset plotted
	if length(handles.xrd.DisplayName)==1
		% If the same dataset is chosen
		if strcmp(handles.xrd.Filename(filenum),handles.xrd.DisplayName)
			% Do nothing and exit out of the function
			return
		end
	end
	handles.xrd.plotData(filenum,'superimpose');
	
else
	cla
	hold off
	handles.xrd.Status=['File changed to ',handles.xrd.Filename{filenum},'.'];
	call.plotX(handles);
end

guidata(hObject, handles)


% --- Executes on selection change in popup_functionX where X is 1-6.
% Enables/disables checkboxes in handles.uipanel5 based on what function(s)
% are already chosen.
function popup_function1_Callback(hObject, eventdata, handles)
% hObject    handle to popup_function1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% Hints: contents = cellstr(get(hObject,'String')) returns popup_function1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_function1

contents = cellstr(get(hObject,'String'));
tag=get(hObject,'Tag');
selection=contents{get(hObject,'Value')};

if get(hObject,'Value') > 1
	handles.xrd.Status=['Function ',tag(end),' set to ', selection,'.'];
end

call.allowWhichConstraints(handles);

call.setEnableUpdateButton(handles); % enables/disables 'Update' button and uipanel4


% --- Executes on selection change in popup_numpeaks.
% Sets visibility of uipanel6 and uipanel5. 
% Sets visibility of popup_functionX in uipanel6.
% Calls popup_function1 which enables/disables uipanel5 (constraints).
function popup_numpeaks_Callback(hObject, eventdata, handles)
% hObject    handle to popup_numpeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hints: contents = cellstr(get(hObject,'String')) returns popup_numpeaks contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_numpeaks

num = get(hObject, 'Value') - 1;

% if the same value as previous, exit function
if num==hObject.UserData
	return
end

if num > 0
	handles.xrd.Status=['Number of peaks set to ',num2str(num),'.'];
	set(handles.uipanel6, 'Visible','on');
	set(handles.uipanel6.Children,'Visible','off');
	set(handles.uipanel5,'Visible','on');
	set(handles.pushbutton15, 'Visible','on');
	set(handles.text7,'Visible','on');
	set(handles.popup_function1,'Visible','on');
	set(handles.uipanel10,'Visible','on');
	
	if num > 1
		set(handles.text13,'Visible','on');
		set(handles.popup_function2,'Visible','on');
		if num > 2
			set(handles.text14,'Visible','on');
			set(handles.popup_function3,'Visible','on');
			if num > 3
				set(handles.text15,'Visible','on');
				set(handles.popup_function4,'Visible','on');
				if num > 4
					set(handles.text17,'Visible','on');
					set(handles.popup_function5,'Visible','on');
					if num > 5
						set(handles.text18,'Visible','on');
						set(handles.popup_function6,'Visible','on');
					end
				end
			end
		end
	end
	
	hiddenPops = flipud(findobj(handles.uipanel6.Children,'style','popupmenu', 'visible', 'off'));
	set(hiddenPops, 'value', 1);
	call.allowWhichConstraints(handles);
	
else
	set(handles.uipanel10,'Visible','off');
	set(findobj(handles.uipanel6.Children,'style','popupmenu'),'value',1);
	set(findobj(handles.uipanel5.Children),'Enable','off','Value',0);
	set(handles.uipanel6,'Visible','off');
	set(handles.uipanel5,'Visible','off');
	set(handles.pushbutton15,'Visible','off');
	set(handles.uipanel4,'Visible','off');
end

call.setEnableUpdateButton(handles);

% ------------------------------------------
%% Edit box callback functions
% ------------------------------------------

% --- Profile Range edit box callback function.
function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.xrd.fitrange=str2double(get(hObject,'String'));
set(hObject,'UserData',get(hObject,'value'));

% --- 
function edit_polyorder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_polyorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'UserData',get(hObject,'value'));
handles.xrd.PolyOrder=str2double(hObject.String);
handles.xrd.Status=['Polynomial order changed to ',get(hObject,'String'),'.'];


% --- 
function edit_min2t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_min2t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status='Editing min2T... ';
handles.xrd.Status=status;

a=call.checkToOverwrite('This will cause the current fit to be discarded. Continue?',handles);

if strcmp(a,'No') || strcmp(a,'Cancel')
	handles.xrd.Status=[status, 'Stopped.'];
	set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
	return
end

min = str2double(get(hObject,'String'));
max = str2double(get(handles.edit_max2t,'String'));

% If user-inputted min2T is out of range, reset to the default and exit function
if min < handles.xrd.two_theta(1) || min > handles.xrd.two_theta(end) || isnan(min)
	msg='Error: min2t value is not within bounds.';
	handles.xrd.Status=[status, msg];
	
	if min<handles.xrd.two_theta(1)
		min=handles.xrd.two_theta(1);
	else
		min=handles.xrd.Min2T;
	end
	
	handles.xrd.Min2T=min;
	set(handles.edit_min2t,'String',sprintf('%2.4f',min));
	return
end

% Save min2T into xrd
handles.xrd.Min2T = min;
set(handles.popup_numpeaks,'Enable','on');
set(handles.edit_min2t,'String',sprintf('%2.4f',min));

% If user-inputted min2T is greater than current max2T, 
if min >= max 
	max = min+handles.xrd.fitrange;
	if max > handles.xrd.two_theta(end)
		max = handles.xrd.two_theta(end);
	end
	handles.xrd.Max2T = max;
	set(handles.edit_max2t,'String',sprintf('%2.4f',max));
end

% Reset background points if not within profile range
if ~isempty(handles.xrd.bkgd2th) && ...
		(isempty(find(min<handles.xrd.bkgd2th,1)) ||...
		isempty(find(max>handles.xrd.bkgd2th,1)))
	handles.xrd.bkgd2th=[];
end

% Reset peak positions if not within profile range
if ~isempty(handles.xrd.PeakPositions) &&...
		(isempty(find(min<handles.xrd.PeakPositions,1)) ||...
		isempty(find(max>handles.xrd.PeakPositions,1)))
	handles.xrd.PeakPositions=[];
	set(handles.popup_numpeaks,'Value',1);
	handles.xrd.bkgd2th=[];
	call.revertPanel(handles);
end

handles.xrd.Fmodel=[];
handles.xrd.plotData(handles.popup_filename.Value)
handles.xrd.Status=['<html>Min2&theta; set to ',get(hObject,'String'),'.'];

% --- 
function edit_max2t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_max2t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status='Editing max2T... ';
handles.xrd.Status=status;

filenum = handles.popup_filename.Value;

a=call.checkToOverwrite('This will cause the current fit to be discarded. Continue?',handles);

if strcmp(a,'No') || strcmp(a,'Cancel')
	handles.xrd.Status=[status, 'Stopped.'];
	set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
	return
end

min = str2double(get(handles.edit_min2t,'String'));
max = str2double(get(hObject,'String'));

if isnan(max)
	handles.xrd.Status=['Error: ',hObject.String,' is not a valid number.'];
	set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
	return
end

set(handles.edit_max2t,'String',sprintf('%2.4f',max));

% If maximum is less than absolute max
if min < handles.xrd.two_theta(1) || max > handles.xrd.two_theta(end) || isnan(max)
	msg='Error: max2t value is not within bounds.';
	handles.xrd.Status=[status,msg];
	if max > handles.xrd.two_theta(end)
		max=handles.xrd.two_theta(end);
	else
		max=handles.xrd.Max2T;
	end
	
	handles.xrd.Max2T=max;
	set(handles.edit_max2t,'String',sprintf('%2.4f',max));
	
	return
end

handles.xrd.Max2T = max;
set(handles.edit_max2t,'String',sprintf('%2.4f',max));

if max <= min 
	min = max-handles.xrd.fitrange;
	if min < handles.xrd.two_theta(1)
		min = handles.xrd.two_theta(1);
	end
	handles.xrd.Min2T = min;
	set(handles.edit_min2t,'String',sprintf('%2.4f',min));
end

if ~isempty(handles.xrd.bkgd2th) &&...
		(isempty(find(min<handles.xrd.bkgd2th,1)) ||...
		isempty(find(max>handles.xrd.bkgd2th,1)))
	handles.xrd.bkgd2th=[];
end

if ~isempty(handles.xrd.PeakPositions) &&...
		(isempty(find(min<handles.xrd.PeakPositions,1)) ||...
		isempty(find(max>handles.xrd.PeakPositions,1)))
	handles.xrd.PeakPositions=[];
	set(handles.popup_numpeaks,'Value',1);
	handles.xrd.PSfxn={};
	call.revertPanel(handles);
end

handles.xrd.Fmodel=[];
handles.xrd.plotData(filenum)
handles.xrd.Status=['<html>Max2&theta; set to ',get(hObject,'String'),'.'];

guidata(hObject, handles)

function edit_bkgdpoints_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bkgdpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'UserData',get(hObject,'value'));
handles.xrd.Status=['Number of background points changed to ',get(hObject,'String'),'.'];
guidata(hObject,handles)

% ------------------------------------------
%% uitable callback functions
% ------------------------------------------

% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.xrd.Status=['Editing table...'];
numpeaks=get(handles.popup_numpeaks,'Value')-1;
r=eventdata.Indices(1);
c=eventdata.Indices(2);

if ~isa(eventdata.NewData, 'double')
	try
		num = str2double(eventdata.NewData);
		hObject.Data{r, c} = num;
	catch
		hObject.Data{r,c} = [];
		cla
		call.plotx(handles);
		return
	end
else
	num = eventdata.NewData;
end

% If NewData is empty or was not changed
if isnan(num)
	hObject.Data{r,c} = [];
	handles.xrd.Status=[handles.uitable1.ColumnName{c},...
		' value of coefficient ',hObject.RowName{r}, ' is now empty.'];
	call.checkuitable1(handles);
	cla
	call.plotx(handles);
	return
	
else
	
	if strcmpi(hObject.RowName{r}(1), 'x') && c == 1
		ipk = str2double(hObject.RowName{r}(2));
		hObject.UserData{ipk} = num;
	end
	
	% Check if SP, LB, and UB are within bounds
	switch c
		case 1 % If first column, SP
			if num < hObject.Data{r,2}
				hObject.Data{r,2} = num;
			end
			if num > hObject.Data{r,3}
				hObject.Data{r,3} = num;
			end
		case 2 % If second column, LB
			if num > hObject.Data{r,1}
				hObject.Data{r,1} = num;
			end
			if num > hObject.Data{r,3}
				hObject.Data{r,3} = num;
			end
		case 3 % If third column, UB
			if num < hObject.Data{r,1}
				hObject.Data{r,1} = num;
			end
			if num < hObject.Data{r,2}
				hObject.Data{r,2} = num;
			end
	end
end

% Enable/disable 'Clear' button
call.checkuitable1(handles);

if ~isempty(num)
	handles.xrd.Status=[handles.uitable1.ColumnName{c},...
		' value of coefficient ',hObject.RowName{r}, ' was changed to ',num2str(num),'.'];
end

handles = call.plotSampleFit(handles);
guidata(hObject,handles)

% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
%

% ------------------------------------------
%% Toobar callback functions
% ------------------------------------------

% --- Import new file(s) to fit.
function uipushtoolnew_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtoolnew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_new_Callback(hObject, eventdata, handles);
guidata(hObject,handles);

% --- Toggles the legend. 
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

% --- Turns off the legend.
function uitoggletool5_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'State','off');
legend('hide')

% ----Turns on the legend.
function uitoggletool5_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'State','on');
legend(handles.xrd.DisplayName,'Box','off')

% ------------------------------------------
%% Menu callback functions
% ------------------------------------------

% --- 
function menu_new_Callback(hObject, eventdata, handles)
% hObject    handle to menu_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xrd.Status='Loading data... ';

call.importData(hObject, eventdata, handles);

% --- 
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xrd.Status='Saving results...';
handles.xrd.outputError;
handles.xrd.Status='Saving results... Done.';

% --- 
function menu_input_Callback(hObject, eventdata, handles)
% hObject    handle to menu_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status='Loading input parameter file... ';
handles.xrd.Status=status;

% --- Check if there is already a fit
a=call.checkToOverwrite('This will cause the current fit to be discarded. Continue?',handles);

if strcmp(a,'Cancel')
	handles.xrd.Status=[status,'Canceled.'];
	return
end

if ~handles.xrd.Read_Inputs
	handles.xrd.Status=[status,'Input file not found.'];
	return
end

handles.xrd.Fmodel=[];

handles.uipanel4.UserData = handles.xrd.PeakPositions;

set(handles.edit_min2t,'String',sprintf('%2.4f',handles.xrd.Min2T));
set(handles.edit_max2t,'String',sprintf('%2.4f',handles.xrd.Max2T));
set(handles.edit7,'String',num2str(handles.xrd.fitrange));
set(handles.popup_numpeaks,'Value',length(handles.xrd.PSfxn)+1);

% Set uipanel6/popup functions
popup_numpeaks_Callback(handles.popup_numpeaks, [], handles); 


call.revertPanel(handles);
set(handles.tabgroup,'SelectedTab',handles.tab_peak);

pushbutton15_Callback(handles.pushbutton15,[],handles);
coeff=handles.xrd.Fcoeff;

SP=handles.xrd.fit_initial{1};
UB=handles.xrd.fit_initial{2};
LB=handles.xrd.fit_initial{3};

for i=1:length(coeff)
	handles.uitable1.Data{i,1}=SP(i);
	handles.uitable1.Data{i,2}=LB(i);
	handles.uitable1.Data{i,3}=UB(i);
end

handles.xrd.Status=[status,'Done.'];
set(handles.uipanel4.Children,'Enable','on');
call.plotX(handles);

guidata(hObject, handles)

% --------------------------------------------------------------------
function menu_savefig_Callback(hObject, eventdata, handles)
% hObject    handle to menu_savefig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)axes(handles.axes1)
profile = find(handles.uipanel3==handles.profiles,1);
fitOutputPath =strcat(handles.xrd.DataPath,'FitOutputs/Fit_Figure/');
if ~exist(fitOutputPath,'dir')
	mkdir(fitOutputPath);
end

tot=handles.text_numprofile.String(end);

for s=1:length(handles.xrd.Filename)
	f_new=figure;
	a1=copyobj(handles.axes1,f_new);
	a2=copyobj(handles.axes2,f_new);
	
	filename=['Profile ',num2str(profile),' of ',tot,' - ',handles.xrd.Filename{s}];
	set(gcf,'name',filename,'numbertitle','off');
	set(a1.Title,'String',filename);
	saveas(gcf,[fitOutputPath,filename,'-plotFit.png'])
	delete(gcf)
end

handles.xrd.plotFit('all')
saveas(figure(5),strcat(fitOutputPath,'Profile ',num2str(profile), 'of ',tot,' - ',strcat('Master','-','plotFit')));
delete(gcf);


% --------------------------------------------------------------------
function menu_clearall_Callback(hObject, eventdata, handles)
% hObject    handle to menu_clearall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --------------------------------------------------------------------
function menu_close_Callback(hObject, eventdata, handles)
% hObject    handle to menu_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ans=questdlg('Are you sure you want to quit?','Warning','Yes','No','Yes');
if strcmp(ans,'Yes')
	delete(gcf)
end

% --------------------------------------------------------------------
function menu_bkgdpoints_Callback(hObject, eventdata, handles)
% hObject    handle to menu_bkgdpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Menu: File -> Save As callback function
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Menu option callback to Import Workspace.
function Untitled_9_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ------------------------------------------
%% Custom helper functions
% ------------------------------------------

% Executes when the active tab changes to/from 'Setup' and 'Peak Selection'.
function tabgroup_SelectionChangedFcn(hObject, eventdata, handles)
%%
% 
%  PREFORMATTED
%  TEXT
% 


% If user switches to 'Peak Selection' tab from 'Setup' tab and there is no
% background, issue warning
if hObject.SelectedTab == handles.tab_peak && isempty(handles.xrd.bkgd2th)
	hObject.SelectedTab = handles.tab_setup;
	uiwait(warndlg('Please select background points first.','No Background Points'));
	return
end

% If user switches to 'Setup' tab from 'Peak Selection' tab
if hObject.SelectedTab == handles.tab_setup
	set(handles.uipanel4, 'visible', 'off');
elseif handles.popup_numpeaks.Value > 1
	call.setEnableUpdateButton(handles);
end
	

% ------------------------------------------
%% CreateFcns and Unused Callbacks
% ------------------------------------------

% --- Executes during object creation, after setting all properties.
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
% hObject    handle to edit_max2t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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
% hObject    handle to edit_bkgdpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_polyorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_polyorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popup_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.n=1;
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popup_numpeaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_numpeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- 
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Stop Least Squares radio button.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- 
function uitoggletool4_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function popup_function1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_function1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popup_function2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_function2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popup_function3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_function3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popup_function4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_function4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popup_function5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_function5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popup_function6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_function6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuHelp_fxns_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelp_fxns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lambda as text
%        str2double(get(hObject,'String')) returns contents of edit_lambda as a double
lambda=str2double(get(hObject,'String'));
handles.xrd.lambda=lambda;

% --- Executes during object creation, after setting all properties.
function edit_lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_clearfit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_clearfit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_removeprofile.
function push_removeprofile_Callback(hObject, eventdata, handles)
% hObject    handle to push_removeprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_addprofile.
% 
function push_addprofile_Callback(hObject, eventdata, handles)
% hObject    handle to push_addprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% When user adds a profile:
% * push_nextprofile is enabled unless the number of profiles is max (6)
% * Automatically switch profile to the added one
handles.profiles(7).UserData = handles.profiles(7).UserData + 1;

call.changeProfile(hObject, [], handles);
