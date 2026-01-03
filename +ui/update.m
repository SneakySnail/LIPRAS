<<<<<<< HEAD
function update(handles, varargin)
%UPDATE(HANDLES, 'PROPERTY', VALUE) checks the values saved in the Model
=======
function update(app, varargin)
%UPDATE(app, 'PROPERTY', VALUE) checks the values saved in the Model
>>>>>>> c38a598 (Initial App Designer migration)
%   PROFILELISTMANAGER and updates the GUI based on these values. It does NOT change any of
%   the model.
%
%   'PROPERTY' - VALUE:
%       'Min2T'
%       'Max2T'
%       'BackgroundModel'
%       'BackgroundOrder'
%       'BackgroundPoints'
%       'NumPeaks'
%       'FitFunctions'
%       'Constraints'   - VALUE is a matrix of 0's and 1's with size ?x5. Each
%                         function's constraints is located in order per row.
%                         Use getConsMatrix to generate the matrix based on the
%                         currently selected options in the GUI.
%       'FitInitial'    - VALUE is a cell array {'BOUNDS', 'COEFF', COEFFVAL}.
%
<<<<<<< HEAD
model.ProfileListManager.getInstance(handles.profiles);
% if isfield(handles, 'gui') && handles.gui.isFitDirty % this might not be needed
%     set(handles.panel_coeffs.Children, 'enable', 'off');
% else
%     set(handles.panel_coeffs.Children, 'enable', 'on');
=======
model.ProfileListManager.getInstance(app.profiles);
% if isfield(app, 'gui') && app.gui.isFitDirty % this might not be needed
%     set(app.panel_coeffs.Children, 'enable', 'off');
% else
%     set(app.panel_coeffs.Children, 'enable', 'on');
>>>>>>> c38a598 (Initial App Designer migration)
% end

switch lower(varargin{1})
    case 'reset'
<<<<<<< HEAD
        reset(handles)
    case 'dataset'
        newDataSet(handles);
        handles.profiles.Weights='Default'; % sets to default after reading in dataset
    case 'tabchange'
        
    case 'filenumber'
        fileNumberChanged(handles);
    case 'parameters'
        newParameterFile(handles);
    case 'backgroundmodel'
        newBackgroundModel(handles);
    case 'backgroundpoints'
        newBackgroundPoints(handles);
    case 'numpeaks'
        newNumberOfPeaks(handles);
    case 'peakposition'
        updateOptionsTabView(handles);
    case 'functions'
        updateOptionsTabView(handles);
    case 'constraints'
        updateOptionsTabView(handles);
    case 'fitinitial'
        updateFitBoundsTable(handles);
    case 'fitinitial_peakselect'
        updateFitBoundsTable(handles,'peakselect');
    case 'results'
        newFitResults(handles);
end
set(findobj(handles.figure1, 'enable','inactive'), 'enable', 'on');
assignin('base', 'handles', handles);
guidata(handles.figure1, handles);


function reset(handles)
clear(['+utils' filesep '+plotutils' filesep 'plotX'])
handles.axes1.ColorOrderIndex = 1;
handles.gui.Plotter.Mode = 'data';
set(handles.figure1.Children, 'visible', 'off');
set([handles.text22, handles.edit8, handles.button_browse, handles.checkbox_reverse], ...
         'Visible', 'on');
set(findobj(handles.figure1.Children, 'type', 'uimenu'), 'visible', 'on');
set(findobj(handles.figure1.Children, 'type', 'uitoolbar'), 'visible', 'on');
handles.gui.DataPath = '';
% Reset enabled menu controls
handles.menu_parameter.Enable = 'off';
handles.menu_plot.Enable = 'off';
handles.menu_command.Enable = 'off';
handles.menu_saveasimage.Enable = 'off';
% Reset enabled controls
set([handles.push_prevprofile, handles.push_nextprofile, handles.push_removeprofile], ...
    'visible', 'off');
set(handles.tabpanel, 'TabEnables', {'on', 'off', 'off'}, 'Selection', 1);
set(findobj(handles.figure1, 'style', 'checkbox'), 'Value', false);
set(handles.popup_filename, 'enable', 'on');

resetSetupTabView(handles);
resetOptionsTabView(handles);
resetResultsTabView(handles);


function resetSetupTabView(handles)
% Resets the setup tab view as if the user had just launched the GUI. Helper function for reset(). 
set(handles.group_bkgd_edit_mode.Children, 'enable', 'off');
set(handles.group_bkgd_edit_mode, 'SelectedObject', handles.radio_newbkgd);
set(handles.radio_newbkgd, 'enable', 'on');
handles.push_fitbkgd.Enable = 'off';
handles.gui.BackgroundModel = 'Polynomial';
handles.gui.PolyOrder = 3;
handles.tab1_next.Visible = 'off';

function resetOptionsTabView(handles)
% Reset the Options tab view as if the user had just launched the GUI. Helper function for reset().
handles.gui.NumPeaks = 0;
handles.table_fitinitial.Data = cell(1,3);
handles.gui.KAlpha2 = 'off';
handles.gui.ConstraintsInPanel = '';
handles.gui.ConstraintsInTable = [];

function resetResultsTabView(handles)
% Reset Results tab view
handles.table_results.Data = cell([4 4]);
handles.panel_choosePlotView.SelectedObject = handles.radio_peakeqn;

function newDataSet(handles)
clear(['+utils' filesep '+plotutils' filesep 'plotX'])
try
    reset(handles);
catch ME
    ME.getReport
end
xrd = handles.profiles.xrd;
handles.gui.XPlotScale = 'linear';
handles.gui.YPlotScale = 'linear';
handles.gui.FileNames = xrd.getFileNames;
handles.gui.DataPath = handles.profiles.DataPath;
handles.gui.Min2T = xrd.Min2T;
handles.gui.Max2T = xrd.Max2T;
handles.gui.CurrentFile = 1;
handles.gui.CurrentProfile = 1;
handles.menu_saveasimage.Enable = 'on';

if xrd.NumFiles > 1
%     set(handles.checkbox_superimpose,'Visible','on', 'enable', 'on'); % Superimpose Raw Data
    set(handles.push_viewall,'Visible','on', 'enable', 'on'); % View All
    handles.gui.PriorityStatus = ['Imported ', num2str(xrd.NumFiles),' files to this dataset.'];
else
%     set(handles.checkbox_superimpose,'Visible','off'); % Superimpose Raw Data
    set(handles.push_viewall,'Visible','off'); % View All
    handles.gui.PriorityStatus = 'Imported 1 file to this dataset.';
end
set(handles.menu_parameter, 'enable', 'on');
set(handles.tabpanel, 'TabEnables', {'on' 'off' 'off'}, 'Selection', 1);
set(handles.panel_rightside,'visible','on');
set(handles.uipanel3, 'visible', 'on');
handles.menu_plot.Enable = 'on';
handles.menu_command.Enable = 'on';
if handles.profiles.CuKa
handles.gui.KAlpha1 = handles.profiles.KAlpha1(1); %specify 1 for multile XRDML
handles.gui.KAlpha2 = handles.profiles.KAlpha2(1);
end
handles.gui.Legend = 'on';
handles.gui.Legend = 'reset';



function newParameterFile(handles)
%UPDATEPARAMETERS is called when a new parameter file is read in. This function updates
%   the GUI to display the new parameters.
profiles = handles.profiles;
fcns = profiles.xrd.getFunctionNames;
constraints = profiles.xrd.getConstraints;
coeffs = profiles.xrd.getCoeffs;
handles.gui.Min2T = profiles.xrd.Min2T;
handles.gui.Max2T = profiles.xrd.Max2T;
handles.gui.BackgroundModel = profiles.xrd.getBackgroundModel;
handles.gui.PolyOrder = profiles.xrd.getBackgroundOrder;

newBackgroundPoints(handles);
handles.gui.NumPeaks = length(fcns);
handles.gui.FcnNames = fcns;

handles.gui.ConstraintsInPanel = unique([constraints{:}]);
if handles.gui.NumPeaks > 2
    handles.gui.ConstraintsInTable = constraints;
else
    handles.gui.ConstraintsInTable = [];
end
updateOptionsTabView(handles);
newPeakPositions(handles);

handles.gui.Coefficients = coeffs;
updateFitBoundsTable(handles);

set(handles.tabpanel, 'tabenables', {'on' 'on' 'off'}, 'selection', 2);
set(handles.tab2_next, 'visible', 'off');
set(handles.panel_coeffs.Children, 'enable', 'on');
set(handles.push_update, 'enable', 'on');
set(handles.push_selectpeak, 'enable', 'on');
handles.gui.Plotter.updateXYLim 
utils.plotutils.plotX(handles, 'sample');
handles.gui.Plotter.updateXYLim 



function newBackgroundModel(handles)
if isequal(handles.gui.BackgroundModel, 'Spline') && handles.gui.PolyOrder == 1
    handles.gui.PolyOrder = 2;
end

function newBackgroundPoints(handles)
import utils.plotutils.*
handles.container_numpeaks.Visible = 'on';
xrd = handles.profiles.xrd;
if xrd.hasBackground && length(handles.profiles.BackgroundPoints) > xrd.getBackgroundOrder
    handles.tab1_next.Visible = 'on';
    handles.group_bkgd_edit_mode.SelectedObject = handles.radiobutton14_add;
    set(findobj(handles.panel_setup, 'enable', 'off'), 'enable', 'on')
    handles.tabpanel.TabEnables{2} = 'on';
    
elseif ~isempty(handles.profiles.BackgroundPoints)
    set(handles.group_bkgd_edit_mode, 'SelectedObject', handles.radiobutton14_add);
    set(handles.group_bkgd_edit_mode.Children, 'Enable', 'on');
    set(handles.push_fitbkgd, 'enable', 'off');
    handles.tabpanel.TabEnables{2} = 'off';
    set(handles.tab1_next,'visible', 'off');
    utils.plotutils.plotX(handles, 'backgroundpoints');
    
else
    handles.tab1_next.Visible = 'off';
    handles.group_bkgd_edit_mode.SelectedObject = handles.radio_newbkgd;
    set(handles.group_bkgd_edit_mode.Children, 'enable', 'off');
    set(handles.radio_newbkgd, 'enable', 'on');
    handles.push_fitbkgd.Enable = 'off';
    handles.tabpanel.TabEnables(2:3) = {'off'};
    lines = handles.axes1.Children;
    if ~isempty(lines)
        notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'raw');
        delete(handles.axes1.Children(notDataLineIdx));
    end
end

function newNumberOfPeaks(handles)
numpeaks = handles.profiles.xrd.NumFuncs;
if numpeaks == 0
    set(handles.panel_parameters.Children, 'visible', 'off');
    % Number of peaks label
    handles.container_numpeaks.Visible = 'on';
    % Number of peaks uicomponent
    set(handles.tab2_prev, 'visible', 'on');
    if handles.checkbox_lambda.Value
        handles.panel_cuka.Visible = 'on';
    end
else
    set([handles.container_fitfunctions, handles.panel_constraints handles.checkbox_lambda], ...
        'visible', 'on');
    set(handles.container_numpeaks, 'visible', 'on');
end

olddata = handles.table_paramselection.Data;
colwidth = handles.table_paramselection.ColumnWidth;
colname = handles.table_paramselection.ColumnName;
% set uicontrol visibility of table_paramselection
set(handles.table_paramselection, ...
=======
        reset(app)
    case 'dataset'
        newDataSet(app);
        app.profiles.Weights='Default'; % sets to default after reading in dataset
    case 'tabchange'
        
    case 'filenumber'
        fileNumberChanged(app);
    case 'parameters'
        newParameterFile(app);
    case 'backgroundmodel'
        newBackgroundModel(app);
    case 'backgroundpoints'
        newBackgroundPoints(app);
    case 'numpeaks'
        newNumberOfPeaks(app);
    case 'peakposition'
        updateOptionsTabView(app);
    case 'functions'
        updateOptionsTabView(app);
    case 'constraints'
        updateOptionsTabView(app);
    case 'fitinitial'
        updateFitBoundsTable(app);
    case 'fitinitial_peakselect'
        updateFitBoundsTable(app,'peakselect');
    case 'results'
        newFitResults(app);
end
set(findobj(app.figure1, 'enable','inactive'), 'enable', 'on');
assignin('base', 'app', app);
guidata(app.figure1, app);


function reset(app)
clear(['+utils' filesep '+plotutils' filesep 'plotX'])
app.UIAxes.ColorOrderIndex = 1;
app.gui.Plotter.Mode = 'data';
% set(app.figure1.Children, 'visible', 'off');
set([app.text22, app.edit8, app.button_browse, app.checkbox_reverse], ...
         'Visible', 'on');
set(findobj(app.figure1.Children, 'type', 'uimenu'), 'visible', 'on');
set(findobj(app.figure1.Children, 'type', 'uitoolbar'), 'visible', 'on');
app.gui.DataPath = '';
% Reset enabled menu controls, this needs work 12-20-2022
app.FitParamExport.Enable = 'off';
app.menu_plot.Enable = 'off';
app.menu_command.Enable = 'off';
app.menu_saveasimage.Enable = 'off';
Reset enabled controls
set([app.push_prevprofile, app.push_nextprofile, app.push_removeprofile], ...
    'visible', 'off');
set(app.tabpanel, 'TabEnables', {'on', 'off', 'off'}, 'Selection', 1);
set(findobj(app.figure1, 'style', 'checkbox'), 'Value', false);
set(app.DropDown, 'enable', 'on');

resetSetupTabView(app);
resetOptionsTabView(app);
resetResultsTabView(app);


function resetSetupTabView(app)
% Resets the setup tab view as if the user had just launched the GUI. Helper function for reset(). 
set(app.group_bkgd_edit_mode.Children, 'enable', 'off');
set(app.group_bkgd_edit_mode, 'SelectedObject', app.radio_newbkgd);
set(app.radio_newbkgd, 'enable', 'on');
app.push_fitbkgd.Enable = 'off';
app.gui.BackgroundModel = 'Polynomial';
app.gui.PolyOrder = 3;
app.tab1_next.Visible = 'off';

function resetOptionsTabView(app)
% Reset the Options tab view as if the user had just launched the GUI. Helper function for reset().
app.gui.NumPeaks = 0;
app.table_fitinitial.Data = cell(1,3);
app.gui.KAlpha2 = 'off';
app.gui.ConstraintsInPanel = '';
app.gui.ConstraintsInTable = [];

function resetResultsTabView(app)
% Reset Results tab view
app.table_results.Data = cell([4 4]);
app.panel_choosePlotView.SelectedObject = app.radio_peakeqn;

function newDataSet(app)
clear(['+utils' filesep '+plotutils' filesep 'plotX'])
try
%     reset(app); % not needed, or needs to be fixed 12-20-2022
catch ME
    ME.getReport
end
xrd = app.profiles.xrd;
app.gui.XPlotScale = 'linear';
app.gui.YPlotScale = 'linear';
app.gui.FileNames = xrd.getFileNames;
% app.gui.DataPath = app.profiles.DataPath; % Not needed, done in mlapp
app.gui.Min2T = xrd.Min2T;
app.gui.Max2T = xrd.Max2T;
app.gui.CurrentFile = 1;
app.gui.CurrentProfile = 1;
app.menu_saveasimage.Enable = 'on';

if xrd.NumFiles > 1
%     set(app.checkbox_superimpose,'Visible','on', 'enable', 'on'); % Superimpose Raw Data
%     set(app.push_viewall,'Visible','on', 'enable', 'on'); % View All
    app.gui.PriorityStatus = ['Imported ', num2str(xrd.NumFiles),' files to this dataset.'];
else
%     set(app.checkbox_superimpose,'Visible','off'); % Superimpose Raw Data
%     set(app.push_viewall,'Visible','off'); % View All
%     app.gui.PriorityStatus = 'Imported 1 file to this dataset.';
end
% set(app.menu_parameter, 'enable', 'on');
% set(app.tabpanel, 'TabEnables', {'on' 'off' 'off'}, 'Selection', 1);
% set(app.panel_rightside,'visible','on');
% set(app.uipanel3, 'visible', 'on');
% app.menu_plot.Enable = 'on';
% app.menu_command.Enable = 'on';
if app.profiles.CuKa
app.gui.KAlpha1 = app.profiles.KAlpha1(1); %specify 1 for multile XRDML
app.gui.KAlpha2 = app.profiles.KAlpha2(1);
end
app.gui.Legend = 'on'; % figure out how to handle legend
app.gui.Legend = 'reset';



function newParameterFile(app)
%UPDATEPARAMETERS is called when a new parameter file is read in. This function updates
%   the GUI to display the new parameters.
profiles = app.profiles;
fcns = profiles.xrd.getFunctionNames;
constraints = profiles.xrd.getConstraints;
coeffs = profiles.xrd.getCoeffs;
app.gui.Min2T = profiles.xrd.Min2T;
app.gui.Max2T = profiles.xrd.Max2T;
app.gui.BackgroundModel = profiles.xrd.getBackgroundModel;
app.gui.PolyOrder = profiles.xrd.getBackgroundOrder;

newBackgroundPoints(app);
app.gui.NumPeaks = length(fcns);
app.gui.FcnNames = fcns;

app.gui.ConstraintsInPanel = unique([constraints{:}]);
if app.gui.NumPeaks > 2
    app.gui.ConstraintsInTable = constraints;
else
    app.gui.ConstraintsInTable = [];
end
updateOptionsTabView(app);
newPeakPositions(app);

app.gui.Coefficients = coeffs;
updateFitBoundsTable(app);

set(app.tabpanel, 'tabenables', {'on' 'on' 'off'}, 'selection', 2);
set(app.tab2_next, 'visible', 'off');
set(app.panel_coeffs.Children, 'enable', 'on');
set(app.push_update, 'enable', 'on');
set(app.push_selectpeak, 'enable', 'on');
app.gui.Plotter.updateXYLim 
utils.plotutils.plotX(app, 'sample');
app.gui.Plotter.updateXYLim 



function newBackgroundModel(app)
if isequal(app.gui.BackgroundModel, 'Spline') && app.gui.PolyOrder == 1
    app.gui.PolyOrder = 2;
end

function newBackgroundPoints(app)
import utils.plotutils.*
% app.container_numpeaks.Visible = 'on';
xrd = app.profiles.xrd;
if xrd.hasBackground && length(app.profiles.BackgroundPoints) > xrd.getBackgroundOrder
    app.tab1_next.Visible = 'on';
    app.group_bkgd_edit_mode.SelectedObject = app.radiobutton14_add;
    set(findobj(app.panel_setup, 'enable', 'off'), 'enable', 'on')
    app.tabpanel.TabEnables{2} = 'on';
    
elseif ~isempty(app.profiles.BackgroundPoints)
    set(app.group_bkgd_edit_mode, 'SelectedObject', app.radiobutton14_add);
    set(app.group_bkgd_edit_mode.Children, 'Enable', 'on');
    set(app.push_fitbkgd, 'enable', 'off');
    app.tabpanel.TabEnables{2} = 'off';
    set(app.tab1_next,'visible', 'off');
    utils.plotutils.plotX(app, 'backgroundpoints');
    
else
    app.tab1_next.Visible = 'off';
    app.group_bkgd_edit_mode.SelectedObject = app.radio_newbkgd;
    set(app.group_bkgd_edit_mode.Children, 'enable', 'off');
    set(app.radio_newbkgd, 'enable', 'on');
    app.push_fitbkgd.Enable = 'off';
    app.tabpanel.TabEnables(2:3) = {'off'};
    lines = app.axes1.Children;
    if ~isempty(lines)
        notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'Obs');
        delete(app.axes1.Children(notDataLineIdx));
    end
end

function newNumberOfPeaks(app)
numpeaks = app.profiles.xrd.NumFuncs;
if numpeaks == 0
    set(app.panel_parameters.Children, 'visible', 'off');
    % Number of peaks label
    app.container_numpeaks.Visible = 'on';
    % Number of peaks uicomponent
    set(app.tab2_prev, 'visible', 'on');
    if app.checkbox_lambda.Value
        app.panel_cuka.Visible = 'on';
    end
else
    set([app.container_fitfunctions, app.panel_constraints app.checkbox_lambda], ...
        'visible', 'on');
    set(app.container_numpeaks, 'visible', 'on');
end

olddata = app.table_paramselection.Data;
colwidth = app.table_paramselection.ColumnWidth;
colname = app.table_paramselection.ColumnName;
% set uicontrol visibility of table_paramselection
set(app.table_paramselection, ...
>>>>>>> c38a598 (Initial App Designer migration)
    'Enable', 'on', ...
    'ColumnName', colname, ...
    'ColumnWidth', colwidth, ...
    'Data', cell(numpeaks, length(colname)));
% Add previous data to new table
if size(olddata, 1) < numpeaks
    extrarows = numpeaks - size(olddata, 1);
    newdata = [olddata; cell(extrarows, length(colname))];
<<<<<<< HEAD
    handles.table_paramselection.Data = newdata;
    % Reset the peak positions if increasing number of peaks
elseif size(olddata, 1) > numpeaks
    newdata = olddata(1:numpeaks, :);
    handles.table_paramselection.Data = newdata;
else
    handles.table_paramselection.Data = olddata;
end
if handles.gui.isFitDirty
    set(handles.panel_coeffs.Children, 'enable', 'off');
else
    set(handles.panel_coeffs.Children, 'enable', 'on');
end
if ~isempty(cellfun(@(a)isempty(a), handles.gui.FcnNames))
    set(handles.push_update, 'enable', 'off');
    set(handles.push_selectpeak, 'enable', 'off');
else
    set(handles.push_update, 'enable', 'on');
    set(handles.push_selectpeak, 'enable', 'on');
end

function updateOptionsTabView(handles)
% Updates the GUI components when the fit function changes
if handles.gui.isFitDirty
    set(handles.panel_coeffs.Children, 'enable', 'off');
else
    set(handles.panel_coeffs.Children, 'enable', 'on');
end

if handles.gui.areFuncsReady
    set(handles.push_selectpeak, 'enable', 'on');
    set(handles.push_update, 'enable', 'on');
else
    set(handles.push_selectpeak, 'enable', 'off');
    set(handles.push_update, 'enable', 'off');
end

fcns = handles.gui.FcnNames;
% Set property ENABLE for constraint checkboxN, checkboxx, and checkboxf if 
%   there is more than 1 function
if length(find(~cellfun(@isempty, fcns))) > 1
    set(handles.checkboxN,'Enable','on');
    set(handles.checkboxx,'Enable','on');
    set(handles.checkboxf,'Enable','on');
else
    set(handles.checkboxN,'Enable','off');
    set(handles.checkboxx,'Enable','off');
    set(handles.checkboxf,'Enable','off');
=======
    app.table_paramselection.Data = newdata;
    % Reset the peak positions if increasing number of peaks
elseif size(olddata, 1) > numpeaks
    newdata = olddata(1:numpeaks, :);
    app.table_paramselection.Data = newdata;
else
    app.table_paramselection.Data = olddata;
end
if app.gui.isFitDirty
    set(app.panel_coeffs.Children, 'enable', 'off');
else
    set(app.panel_coeffs.Children, 'enable', 'on');
end
if ~isempty(cellfun(@(a)isempty(a), app.gui.FcnNames))
    set(app.push_update, 'enable', 'off');
    set(app.push_selectpeak, 'enable', 'off');
else
    set(app.push_update, 'enable', 'on');
    set(app.push_selectpeak, 'enable', 'on');
end

function updateOptionsTabView(app)
% Updates the GUI components when the fit function changes
if app.gui.isFitDirty
    app.UITable2.Enable='off';
else
    app.UITable2.Enable='on';
end

if app.gui.areFuncsReady
    set(app.SelectPeaksButton, 'enable', 'on');
    set(app.UpdateButton, 'enable', 'on');
else
    set(app.SelectPeaksButton, 'enable', 'off');
    set(app.UpdateButton, 'enable', 'off');
end

fcns = app.gui.FcnNames;
% Set property ENABLE for constraint checkboxN, checkboxx, and checkboxf if 
%   there is more than 1 function
if length(find(~cellfun(@isempty, fcns))) > 1
    set(app.NCheckBox,'Enable','on')
    set(app.xCheckBox,'Enable','on');
    set(app.fCheckBox,'Enable','on');
else
    set(app.NCheckBox,'Enable','off');
    set(app.xCheckBox,'Enable','off');
    set(app.fCheckBox,'Enable','off');
>>>>>>> c38a598 (Initial App Designer migration)
end

% Set property ENABLE of constraint checkboxm for Pearson VII 
if length(find(utils.contains(fcns, 'Pearson VII'))) > 1
<<<<<<< HEAD
    set(handles.checkboxm,'Enable','on');
else
    set(handles.checkboxm,'Enable','off');
end
% Set property ENABLE of constraint checkboxw for Pseudo-Voigt 
if length(find(utils.contains(fcns, 'Pseudo-Voigt'))) > 1
    set(handles.checkboxw,'Enable','on');
else
    set(handles.checkboxw,'Enable','off');
end

% Constraints
constraints = handles.profiles.xrd.getConstraints;
handles.gui.ConstraintsInPanel = constraints;
if handles.gui.NumPeaks > 2
    handles.gui.ConstraintsInTable = constraints;
else
    handles.gui.ConstraintsInTable = [];
end
if handles.gui.isFitDirty
    set(handles.panel_coeffs.Children, 'enable', 'off');
else
    set(handles.panel_coeffs.Children, 'enable', 'on');
end

% Enable CuKa if necessary
if ~isempty(handles.profiles.CuKa)
    handles.gui.KAlpha1 = handles.profiles.KAlpha1;
end
if handles.profiles.CuKa
    handles.gui.KAlpha2 = handles.profiles.KAlpha2;
end

function newPeakPositions(handles)
set(handles.panel_coeffs, 'visible', 'on');
set(handles.panel_coeffs.Children, 'enable', 'on');

function updateFitBoundsTable(handles, origin)
=======
    set(app.mCheckBox,'Enable','on');
else
    set(app.mCheckBox,'Enable','off');
end
% Set property ENABLE of constraint checkboxw for Pseudo-Voigt 
if length(find(utils.contains(fcns, 'Pseudo-Voigt'))) > 1
    set(app.wCheckBox,'Enable','on');
else
    set(app.wCheckBox,'Enable','off');
end

% Constraints
constraints = app.profiles.xrd.getConstraints;
app.gui.ConstraintsInPanel = constraints;
if app.gui.NumPeaks > 2
    app.gui.ConstraintsInTable = constraints;
else
    app.gui.ConstraintsInTable = [];
end
if app.gui.isFitDirty
    set(app.FitDataButton, 'enable', 'off'); % changed to fit data button since layout changed in LIPRAS App
else
    set(app.FitDataButton, 'enable', 'on');
end

% Enable CuKa if necessary
if ~isempty(app.profiles.CuKa)
    app.gui.KAlpha1 = app.profiles.KAlpha1;
end
if app.profiles.CuKa
    app.gui.KAlpha2 = app.profiles.KAlpha2;
end

function newPeakPositions(app)
set(app.FitDataButton, 'visible', 'on');
% set(app.panel_coeffs.Children, 'enable', 'on'); % this and line above
% were for panel coeffs which in app is not relevant given that
% Line-Profiles panel is all encompassing of update and fit data buttons

function updateFitBoundsTable(app, origin)
>>>>>>> c38a598 (Initial App Designer migration)
%UPDATEFITBOUNDS should be called after the 'Update' button in the Options tab is pressed.
%   It updates the row names of table_fitinitial to display the correct coefficients.
if nargin <2
    origin='false';
end
<<<<<<< HEAD
isFitD=handles.gui.isFitDirty;
if and(~isFitD, handles.profiles.xrd.BkgLS) % part of reset profile when isFitDirty is true when BkgLS is on
    handles.checkbox_BkgLS.Value=1;
elseif and(isFitD, ~handles.profiles.xrd.BkgLS)
    handles.checkbox_BkgLS.Value=0;
    handles.checkbox_ignoreBounds.Value=0;
end
coeffs = handles.profiles.xrd.getCoeffs;
if isempty(coeffs)
    return
elseif isFitD
    set(handles.table_fitinitial, 'RowName', coeffs, 'Data', cell(length(coeffs), 3));
end

try % will only fail when there is no fit
dif=length(handles.profiles.FitResults{1,1}{1}.CoeffValues)-length(handles.profiles.xrd.FitInitial.coeffs)+1; % diff in coefficients between BkgLS and no BkgLS
catch
end

if isempty(handles.profiles.FitResults)
    handles.gui.FitInitial = handles.profiles.xrd.FitInitial;
    handles.profiles.xrd.OriginalFitInitial=handles.profiles.xrd.FitInitial; % First instance in preserving FitInitial originally created
elseif ~isempty(handles.profiles.FitResults) && ~isFitD&& ~handles.profiles.xrd.BkgLS % should only pin after fit and with same profile and coefficients and BkgLS
         if strcmp(origin,'peakselect') % for scenarios in which Refine background is selected and user wants to hard reset by using peak selection
        handles.gui.FitInitial=handles.profiles.xrd.FitInitial; % update the table with fit results
%         handles.gui.FitInitial = handles.gui.FitInitial;
         else
                if  isequal(handles.profiles.xrd.FitInitial.coeffs,handles.profiles.xrd.OriginalFitInitial.coeffs)
                        try
                    handles.profiles.xrd.BkgCoeff=handles.profiles.FitResults{1,1}{1}.CoeffValues(1:dif-1); % writting bkg coefficients
                    handles.gui.FitInitial.start=handles.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the table with fit results
                    handles.profiles.FitInitial.start=handles.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the actual FitInitial fed into LS and Parameter File
=======
isFitD=app.gui.isFitDirty;
if and(~isFitD, app.profiles.xrd.BkgLS) % part of reset profile when isFitDirty is true when BkgLS is on
    app.RefineBkgCheckBox.Value=1;
elseif and(isFitD, ~app.profiles.xrd.BkgLS)
    app.RefineBkgCheckBox.Value=0;
    app.NoBoundsCheckBox.Value=0;
end
coeffs = app.profiles.xrd.getCoeffs;
if isempty(coeffs)
    return
elseif isFitD
    set(app.UITable2, 'RowName', coeffs, 'Data', cell(length(coeffs), 3)); % changed to 3 from 4
end

try % will only fail when there is no fit
dif=length(app.profiles.FitResults{1,1}{1}.CoeffValues)-length(app.profiles.xrd.FitInitial.coeffs)+1; % diff in coefficients between BkgLS and no BkgLS
catch
end

if isempty(app.profiles.FitResults)
    app.gui.FitInitial = app.profiles.xrd.FitInitial;
    app.profiles.xrd.OriginalFitInitial=app.profiles.xrd.FitInitial; % First instance in preserving FitInitial originally created
elseif ~isempty(app.profiles.FitResults) && ~isFitD&& ~app.profiles.xrd.BkgLS % should only pin after fit and with same profile and coefficients and BkgLS
         if strcmp(origin,'peakselect') % for scenarios in which Refine background is selected and user wants to hard reset by using peak selection
        app.gui.FitInitial=app.profiles.xrd.FitInitial; % update the table with fit results
%         app.gui.FitInitial = app.gui.FitInitial;
         else
                if  isequal(app.profiles.xrd.FitInitial.coeffs,app.profiles.xrd.OriginalFitInitial.coeffs)
                        try
                    app.profiles.xrd.BkgCoeff=app.profiles.FitResults{1,1}{1}.CoeffValues(1:dif-1); % writting bkg coefficients
                    app.gui.FitInitial.start=app.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the table with fit results
                    app.profiles.FitInitial.start=app.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the actual FitInitial fed into LS and Parameter File
>>>>>>> c38a598 (Initial App Designer migration)
                        catch
                        end                       
                end
         end
<<<<<<< HEAD
elseif ~isempty(handles.profiles.FitResults) && ~isFitD&& handles.profiles.xrd.BkgLS 
    if strcmp(origin,'peakselect') % for scenarios in which Refine background is selected and user wants to hard reset by using peak selection
        handles.gui.FitInitial=handles.profiles.xrd.FitInitial; % update the table with fit results
        handles.gui.FitInitial = handles.gui.FitInitial;
    else
handles.profiles.xrd.BkgCoeff=handles.profiles.FitResults{1,1}{1}.CoeffValues(1:dif-1); % writting bkg coefficients
handles.gui.FitInitial.start=handles.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the table with fit results
handles.gui.FitInitial = handles.gui.FitInitial;
handles.profiles.FitInitial.start=handles.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the actual FitInitial fed into LS and Parameter File
=======
elseif ~isempty(app.profiles.FitResults) && ~isFitD&& app.profiles.xrd.BkgLS 
    if strcmp(origin,'peakselect') % for scenarios in which Refine background is selected and user wants to hard reset by using peak selection
        app.gui.FitInitial=app.profiles.xrd.FitInitial; % update the table with fit results
        app.gui.FitInitial = app.gui.FitInitial;
    else
app.profiles.xrd.BkgCoeff=app.profiles.FitResults{1,1}{1}.CoeffValues(1:dif-1); % writting bkg coefficients
app.gui.FitInitial.start=app.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the table with fit results
app.gui.FitInitial = app.gui.FitInitial;
app.profiles.FitInitial.start=app.profiles.FitResults{1,1}{1}.CoeffValues(dif:end); % update the actual FitInitial fed into LS and Parameter File
>>>>>>> c38a598 (Initial App Designer migration)

    end
else % Updating after changing number of functions and or constraints
    
<<<<<<< HEAD
    handles.gui.FitInitial = handles.profiles.xrd.FitInitial;
end

set(handles.panel_coeffs, 'visible', 'on');
set(handles.panel_coeffs.Children, 'visible', 'on', 'enable', 'on');
% Enable/disable 'FIT DATA' button depending on if there is an empty cell in
%   table_fitinitial OR if only the 2theta positions were changed
emptyCell = find(cellfun(@isempty, handles.table_fitinitial.Data), 1);
if isempty(emptyCell) 
    set(handles.push_fitdata, 'enable', 'on');
    pause(0.5) % this is needed otherwise the GUI is too fast and wont activate...
else
    set(handles.push_fitdata, 'enable', 'off');
end

function newFitResults(handles)
profiles = handles.profiles;
if profiles.hasFit
    fitted = profiles.getProfileResult{handles.gui.CurrentFile};
    coeffvals = getCoeffResultsForFillingTable(handles);
    
    set(handles.push_fitdata, 'enable', 'on');
    set(handles.tab2_next, 'visible', 'on');
    set(handles.menu_save,'Enable','on');
    set(handles.tabpanel, 'TabEnables', {'on', 'on', 'on'});
    set(handles.push_viewall, 'enable', 'on', 'visible', 'on');
    set(handles.table_results, ...
            'Data', num2cell(coeffvals), ...
            'RowName', fitted.CoeffNames, ...
            'ColumnName', num2cell(1:handles.profiles.NumFiles), ...
=======
    app.gui.FitInitial = app.profiles.xrd.FitInitial;
end

set(app.UITable2, 'enable', 'on');
set(app.ConstraintsPanel.Children, 'visible', 'on', 'enable', 'on');% not needed with new LIPRAS App
% Enable/disable 'FIT DATA' button depending on if there is an empty cell in
%   table_fitinitial OR if only the 2theta positions were changed
emptyCell = find(cellfun(@isempty, app.UITable2.Data), 1);
if isempty(emptyCell) 
    set(app.FitDataButton, 'enable', 'on');
    pause(0.5) % this is needed otherwise the GUI is too fast and wont activate...
else
    set(app.FitDataButton, 'enable', 'off');
end

function newFitResults(app)
profiles = app.profiles;
if profiles.hasFit
    fitted = profiles.getProfileResult{app.DropDown.Value};
    coeffvals = getCoeffResultsForFillingTable(app);
    
%     set(app.push_fitdata, 'enable', 'on');
%     set(app.tab2_next, 'visible', 'on');
%     set(app.menu_save,'Enable','on');
%     set(app.tabpanel, 'TabEnables', {'on', 'on', 'on'});
%     set(app.push_viewall, 'enable', 'on', 'visible', 'on');
    set(app.UITable3, ...
            'Data', num2cell(coeffvals), ...
            'RowName', fitted.CoeffNames, ...
            'ColumnName', num2cell(1:app.profiles.NumFiles), ...
>>>>>>> c38a598 (Initial App Designer migration)
            'ColumnFormat', {'numeric'}, ...
            'ColumnWidth', {75}, ...
            'ColumnEditable', false);
    
<<<<<<< HEAD
    handles.gui.onPlotFitChange('peakfit');
end

function coeffvals = getCoeffResultsForFillingTable(handles)
fitresults = handles.profiles.getProfileResult;
fitted = fitresults{handles.gui.CurrentFile};
=======
%     app.gui.onPlotFitChange('peakfit');
end

function coeffvals = getCoeffResultsForFillingTable(app)
fitresults = app.profiles.getProfileResult;
fitted = fitresults{app.DropDown.Value};
>>>>>>> c38a598 (Initial App Designer migration)
coeffvals = zeros(length(fitresults), length(fitted.CoeffNames));
for i=1:length(fitresults)
    coeffvals(i, :) = fitresults{i}.CoeffValues;
end
coeffvals = transpose(coeffvals);
