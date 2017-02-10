function update(handles, varargin)
%UPDATE(HANDLES, 'PROPERTY', VALUE) checks the values saved in the Model
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
model.ProfileListManager.getInstance(handles.profiles);
if isfield(handles, 'gui') && handles.gui.isFitDirty
    set(handles.panel_coeffs.Children, 'enable', 'off');
else
    set(handles.panel_coeffs.Children, 'enable', 'on');
end
if isfield(handles, 'gui') && handles.gui.areFuncsReady
    set(handles.push_selectpeak, 'enable', 'on');
    set(handles.push_update, 'enable', 'on');
else
    set(handles.push_selectpeak, 'enable', 'off');
    set(handles.push_update, 'enable', 'off');
end
for i=1:length(varargin)
    property = varargin{i};
    switch lower(property)
        case 'reset'
            reset(handles)
        case 'dataset'
            newDataSet(handles);
        case 'tabchange'
            
        case 'filenumber'
            fileNumberChanged(handles);
        case 'parameters'
            newParameterFile(handles);
        case 'newrange'
            new2TRange(handles);
        case 'backgroundmodel'
            newBackgroundModel(handles);
        case 'backgroundpoints'
            newBackgroundPoints(handles);
        case 'numpeaks'
            newNumberOfPeaks(handles);
        case 'peakposition'
            newPeakPositions(handles);
        case 'functions'
            newFitFunctions(handles);
        case 'constraints'
            constraints(handles);
        case 'fitinitial'
            updateFitBoundsTable(handles);
        case 'results'
            newFitResults(handles);
    end
end
assignin('base', 'handles', handles);
guidata(handles.figure1, handles);
% ==============================================================================

function reset(handles)
clear(['+utils' filesep '+plotutils' filesep 'plotX'])
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

% Reset enabled controls
set([handles.push_prevprofile, handles.push_nextprofile, handles.push_removeprofile], ...
    'visible', 'off');
set(handles.tabpanel, 'TabEnables', {'on', 'off', 'off'}, 'Selection', 1);
set(findobj(handles.figure1, 'style', 'checkbox'), 'Value', false);

resetSetupTabView(handles);
resetOptionsTabView(handles);
resetResultsTabView(handles);


function resetSetupTabView(handles)
% Resets the setup tab view as if the user had just launched the GUI. Helper function for reset(). 
set(findobj(handles.panel_setup.Children, 'type', 'uicontrol'), 'enable', 'on');
handles.radiobutton15_delete.Enable = 'off';
handles.push_fitbkgd.Enable = 'off';
handles.group_bkgd_edit_mode.SelectedObject = handles.radio_newbkgd;
handles.tab1_next.Visible = 'off';

function resetOptionsTabView(handles)
% Reset the Options tab view as if the user had just launched the GUI. Helper function for reset().
handles.gui.NumPeaks = 0;
handles.table_fitinitial.Data = cell(size(handles.table_fitinitial));

function resetResultsTabView(handles)
% Reset Results tab view
handles.table_results.Data = cell([4 4]);
handles.btns3.SelectedObject = handles.radio_peakeqn;


function onTabChangeClick(handles)


function newDataSet(handles)
clear(['+utils' filesep '+plotutils' filesep 'plotX'])
xrd = handles.profiles.xrd;
handles.gui.FileNames = xrd.getFileNames;
handles.gui.DataPath = handles.profiles.DataPath;
handles.gui.Min2T = xrd.Min2T;
handles.gui.Max2T = xrd.Max2T;
handles.gui.CurrentFile = 1;
handles.gui.CurrentProfile = 1;
handles.gui.ConstraintsInPanel = '';
handles.gui.ConstraintsInTable = [];
handles.gui.NumPeaks = 0;
handles.gui.BackgroundModel = 1;
if xrd.NumFiles > 1
    set(handles.checkbox_superimpose,'Visible','on', 'enable', 'on'); % Superimpose Raw Data
    set(handles.push_viewall,'Visible','on', 'enable', 'on'); % View All
    handles.gui.Status=['Imported ', num2str(xrd.NumFiles),' files to this dataset.'];
else
    set(handles.checkbox_superimpose,'Visible','off'); % Superimpose Raw Data
    set(handles.push_viewall,'Visible','off'); % View All
    handles.gui.Status='There is 1 file in this dataset.';
end
set(handles.menu_parameter, 'enable', 'on');
set(handles.panel_profilecontrol, 'visible', 'on');
set(handles.tabpanel, 'TabEnables', {'on' 'off' 'off'}, 'Selection', 1);
set(handles.panel_rightside,'visible','on');
set(handles.uipanel3, 'visible', 'on');
set(handles.push_removeprofile, 'enable', 'off');
handles.menu_plot.Enable = 'on';
handles.menu_command.Enable = 'on';
% utils.plotutils.plotX(handles, 'data');
% ==============================================================================

function newParameterFile(handles)
%UPDATEPARAMETERS is called when a new parameter file is read in. This function updates
%   the GUI to display the new parameters.
profiles = model.ProfileListManager.getInstance(handles.profiles);
fcns = profiles.xrd.getFunctionNames;
bkgdpoints = profiles.xrd.getBackgroundPoints;
peakpos = profiles.xrd.PeakPositions;
constraints = profiles.xrd.getConstraints;
coeffs = profiles.xrd.getCoeffs;
fitinitial = handles.profiles.xrd.FitInitial;

handles.gui.Min2T = profiles.xrd.Min2T;
handles.gui.Max2T = profiles.xrd.Max2T;
handles.gui.BackgroundModel = profiles.xrd.getBackgroundModel;
handles.gui.PolyOrder = profiles.xrd.getBackgroundOrder;
ui.update(handles, 'backgroundpoints');
handles.gui.NumPeaks = length(fcns);
handles.gui.FcnNames = fcns;
ui.update(handles, 'functions');
handles.gui.ConstraintsInPanel = unique([constraints{:}]);
if handles.gui.NumPeaks > 2
    handles.gui.ConstraintsInTable = constraints;
else
    handles.gui.ConstraintsInTable = [];
end
ui.update(handles, 'constraints');
ui.update(handles, 'peakposition');

handles.gui.Coefficients = coeffs;
ui.update(handles, 'fitinitial');

set(handles.tabpanel, 'tabenables', {'on' 'on' 'off'}, 'selection', 2);
set(handles.tab2_next, 'visible', 'off');
set(handles.panel_coeffs.Children, 'enable', 'on');
set(handles.push_update, 'enable', 'on');
set(handles.push_selectpeak, 'enable', 'on');
utils.plotutils.plotX(handles, 'sample');
% ==============================================================================

function new2TRange(handles)
utils.plotutils.plotX(handles, 'data');
% ==============================================================================

function fileNumberChanged(handles)
plottitle = [num2str(handles.gui.CurrentFile) ' of ' num2str(handles.profiles.xrd.NumFiles)];
set(handles.text_filenum, 'String', plottitle);
set(handles.listbox_files, 'Value', handles.gui.CurrentFile);
% ==============================================================================

function newBackgroundModel(handles)
if isequal(handles.gui.BackgroundModel, 'Spline') && handles.gui.PolyOrder == 1
    handles.gui.PolyOrder = 2;
end
% ==============================================================================

function newBackgroundPoints(handles)
import utils.plotutils.*
handles.container_numpeaks.Visible = 'on';
if handles.profiles.xrd.hasBackground
    handles.tab1_next.Visible = 'on';
    handles.group_bkgd_edit_mode.SelectedObject = handles.radiobutton14_add;
    handles.radiobutton15_delete.Enable = 'on';
    handles.push_fitbkgd.Enable = 'on';
    handles.tabpanel.TabEnables{2} = 'on';
    if handles.gui.isFitDirty
        plotX(handles, 'background');
    else
        plotX(handles, 'sample');
    end
else
    handles.tab1_next.Visible = 'off';
    handles.group_bkgd_edit_mode.SelectedObject = handles.radio_newbkgd;
    handles.push_fitbkgd.Enable = 'off';
    handles.radiobutton15_delete.Enable = 'off';
    handles.tabpanel.TabEnables(2:3) = {'off'};
    plotX(handles, 'data');
end
% ==============================================================================

function newNumberOfPeaks(handles)
numpeaks = handles.profiles.xrd.NumFuncs;
if numpeaks == 0
    set(handles.panel_parameters.Children, 'visible', 'off');
    % Number of peaks label
    handles.container_numpeaks.Visible = 'on';
    % Number of peaks uicomponent
    set(handles.tab2_prev, 'visible', 'on');
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
    'Enable', 'on', ...
    'ColumnName', colname, ...
    'ColumnWidth', colwidth, ...
    'Data', cell(numpeaks, length(colname)));
% Add previous data to new table
if size(olddata, 1) < numpeaks
    extrarows = numpeaks - size(olddata, 1);
    newdata = [olddata; cell(extrarows, length(colname))];
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
% ==============================================================================

function constraints(handles)
%CONSTRAINTS should be called when a checkbox is checked in panel_constraints.
%   This function adds a new constraint column in table_paramselection, with default
%   values for rows where the peak function isn't empty will be set to TRUE.
%   It uses the values saved in handles.profiles.xrd to update the GUI, so it should
%   only be called AFTER handles.profiles.xrd is updated. 
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
% ==============================================================================

function newFitFunctions(handles)
% Updates the GUI components when the fit function changes
if handles.gui.isFitDirty
    set(handles.panel_coeffs.Children, 'enable', 'off');
else
    set(handles.panel_coeffs.Children, 'enable', 'on');
end
if handles.gui.areFuncsReady
    set(handles.push_selectpeak, 'enable', 'on');
else
    set(handles.push_selectpeak, 'enable', 'off');
end

% Make sure all peak positions are valid before updating the table
if isempty(find(handles.profiles.xrd.PeakPositions==0,1))
    set(handles.push_update, 'enable', 'on');
else
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
end

% Set property ENABLE of constraint checkboxm for Pearson VII 
if length(find(utils.contains(fcns, 'Pearson VII'))) > 1
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

% ==============================================================================

function newPeakPositions(handles)
set(handles.panel_coeffs, 'visible', 'on');
set(handles.panel_coeffs.Children, 'enable', 'on');
% ==============================================================================

function updateFitBoundsTable(handles)
%UPDATEFITBOUNDS should be called after the 'Update' button in the Options tab is pressed.
%   It updates the row names of table_fitinitial to display the correct coefficients.
coeffs = handles.profiles.xrd.getCoeffs;
if isempty(coeffs)
    return
elseif handles.gui.isFitDirty
    set(handles.table_fitinitial, 'RowName', coeffs, 'Data', cell(length(coeffs), 3));
end
handles.gui.FitInitial = handles.profiles.xrd.FitInitial;
set(handles.panel_coeffs, 'visible', 'on');
set(handles.panel_coeffs.Children, 'visible', 'on', 'enable', 'on');
% Enable/disable 'FIT DATA' button depending on if there is an empty cell in
%   table_fitinitial OR if only the 2theta positions were changed
emptyCell = find(cellfun(@isempty, handles.table_fitinitial.Data), 1);
if isempty(emptyCell) 
    set(handles.push_fitdata, 'enable', 'on');
else
    set(handles.push_fitdata, 'enable', 'off');
end
utils.plotutils.plotX(handles,'sample');
% ==============================================================================

function newFitResults(handles)
profiles = handles.profiles;
if profiles.hasFit
    set(handles.push_fitdata, 'enable', 'on');
    set(handles.tab2_next, 'visible', 'on');
    set(handles.menu_save,'Enable','on');
    set(handles.tabpanel, 'TabEnables', {'on', 'on', 'on'});
    set(handles.push_viewall, 'enable', 'on', 'visible', 'on');
    
    handles.gui.onPlotFitChange('peakfit');
else
    set(handles.push_fitdata, 'enable', 'on');
    set(handles.menu_save,'Enable','off');
    set(handles.tabpanel, 'TabEnables', {'on', 'on', 'off'});
    set(handles.tab2_next, 'visible', 'off');
end
