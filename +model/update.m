function update(handles, property, value)
%UPDATE(HANDLES, 'PROPERTY', VALUE) updates the Model in ProfileListManager
%   based on 'PROPERTY' and VALUE, then updates the related View components 
%   using the HANDLES structure. It does NOT change any of the properties in 
%   the GUI compontents.
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
var = 'dbstackcall_update_1';
i = 1;
while exist(var, 'var')
    var = ['dbstackcall_update_' num3str(i)];
    i=i+1;
end
assignin('base', var, dbstack(1))

switch lower(property)
    
    case 'min2t'
        updateMin2T(handles, value);
        
    case 'max2t'
        updateMax2T(handles, value);
        
    case 'backgroundmodel'
        updateBackgroundModel(handles, value);
        
    case 'backgroundorder'
        updateBackgroundOrder(handles, value);
        
    case 'backgroundpoints'
        updateBackgroundPoints(handles, value);
        
    case 'numpeaks'
        updateNumPeaks(handles, value);
        
    case 'fitfunctions'
        updateFunctions(handles, value);
        
    case 'constraints'
        onConstraintsInPanelUpdate(handles, value);
        
    case 'coefficients'
        updateCoefficients(handles, value);
        
    case 'peaks'
        updatePeakPosition(handles, value);
        
    case 'fitinitial'
        if nargin > 2
            updateFitInitial(handles, value);
        else
            updateFitInitial(handles);
        end
        
    case 'parameters'
        updateParameters(handles);

    case 'fitresults'
        updateFitResults(handles, value);
        
end
% ==============================================================================

function updateMin2T(handles, value)
%UPDATEMIN2T(HANDLES, VALUE) accepts a number within the appropriate bounds.
xrd = handles.profiles.xrd;
boundswarnmsg = '<html><font color="red">The inputted value is not within bounds.';

if value < xrd.AbsoluteRange(1)
    value = xrd.AbsoluteRange(1);
    handles.gui.Status = boundswarnmsg;
    
elseif value > xrd.AbsoluteRange(2)
    value = xrd.AbsoluteRange(2) - 0.5;
    handles.gui.Max2T = xrd.AbsoluteRange(2);
    handles.gui.Status = boundswarnmsg;
    
elseif value >= xrd.Max2T
    max = value + 0.5;
    if max > xrd.AbsoluteRange(2)
        max = xrd.AbsoluteRange(2);
    end
    handles.gui.Max2T = max;
    xrd.Max2T = max;
end
xrd.Min2T = value;

handles.gui.Min2T = xrd.Min2T;
% ==============================================================================


function updateMax2T(handles, value)
%UPDATEMAX2T(HANDLES, VALUE) accepts a number within the appropriate bounds.
xrd = handles.profiles.xrd;
boundswarnmsg = '<html><font color="red">The inputted value is not within bounds.';

if value < xrd.AbsoluteRange(1)
    value = xrd.AbsoluteRange(1) + 0.5;
    handles.gui.Min2T = xrd.AbsoluteRange(1);
    handles.gui.Status = boundswarnmsg;
    
elseif value > xrd.AbsoluteRange(2)
    value = xrd.AbsoluteRange(2);
    handles.gui.Status = boundswarnmsg;
    
elseif value <= xrd.Min2T
    min = value - 0.5;
    if min < xrd.AbsoluteRange(1)
        min = xrd.AbsoluteRange(1);
    end
    handles.gui.Min2T = min;
    xrd.Min2T = min;
end
xrd.Max2T = value;
handles.gui.Max2T = xrd.Max2T;

utils.plotutils.plotX(handles, 'data');
% ==============================================================================

function updateBackgroundModel(handles, value)

% ==============================================================================

function updateBackgroundOrder(handles, value)
handles.profiles.xrd.setBackgroundOrder(value);
handles.gui.PolyOrder = value;
% ==============================================================================

function updateBackgroundPoints(handles, points)
import utils.plotutils.*
hold off
selected = handles.group_bkgd_edit_mode.SelectedObject;
if strcmpi(selected.String, 'New')
    mode = 'New';
elseif strcmpi(selected.String, 'Add')
    hold on
    mode = 'Append';
else
    hold on
    mode = 'Delete';
end
handles.profiles.xrd.setBackgroundPoints(points, mode);
% ==============================================================================


function onConstraintsInPanelUpdate(handles, value)
%UPDATECONSTRAINTS(HANDLES, VALUE) accepts a cell array of strings containing 
%   the constrained coefficients for each function, where every cell are the 
%   constraints per function.

handles.profiles.xrd.unconstrain('Nxfwm');
handles.profiles.xrd.constrain(value);
% In case constraints aren't allowed for a function

% ==============================================================================

function updateCoefficients(handles, coeffs)
oldcoeffs = handles.gui.Coefficients;
if ~isequal(oldcoeffs, coeffs)
    % reset fit initial values
    handles.profiles.xrd.setFitInitial([]);
    set(handles.table_fitinitial, ...
        'data', cell(length(coeffs), 3), 'RowName', coeffs);
end

% Updates table_fitinitial to display the correct coefficients



% Enable/disable 'FIT DATA' button depending on if there is an empty cell in
%   table_fitinitial
emptyCell = find(cellfun(@isempty, handles.table_fitinitial.Data(:, 1:3)), 1);
if isempty(emptyCell)
    set(handles.push_fitdata, 'enable', 'on');
else
    set(handles.push_fitdata, 'enable', 'off');
end
% ==============================================================================

function updatePeakPosition(handles, pos)
xcoeffs = find(contains(handles.gui.Coefficients, 'x'));
if length(pos) == length(xcoeffs)
    handles.profiles.xrd.setPeakPosition(pos);
end
model.update(handles, 'fitinitial');

set(handles.panel_coeffs, 'visible', 'on');
set(handles.panel_coeffs.Children, 'enable', 'on');
% ==============================================================================

function updateFitInitial(handles, input)
%UPDATEFITINITIAL fills table_fitinitial with values specified in INPUT. 
%
%   UPDATEFITINITIAL(HANDLES) fills all empty cells in the table with default
%   values.
%
%   UPDATEFITINITIAL(HANDLES, INPUT) replaces the value in the table with the
%   values specified in INPUT.
%
%   If INPUT is a struct:
%       Fields 'start', 'lower', and 'upper' must contain numeric arrays of the 
%       same size.
%
%   If INPUT is a cell array:
%       {'BOUNDS', VALUES}        - 'BOUNDS' is either 'start', 'lower', or 'upper'.
%                                  VALUES is a numeric array that must be the same
%                                  length as the number of coefficients.
%       {'BOUNDS', 'COEFF', VALUE}- 'COEFF' is the coefficient name to update.
%                           
import utils.plotutils.*

table = handles.table_fitinitial;
xrd = handles.profiles.xrd;
newcoeffs = xrd.getCoeffs;

if nargin > 1
    if isstruct(input)
        start = input.start;
        lower = input.lower;
        upper = input.upper;
        if length(start) == length(newcoeffs)
            replaceFitInitialValue_(table, 'start', newcoeffs, start);
        end
        if length(lower) == length(newcoeffs)
            replaceFitInitialValue_(table, 'lower', newcoeffs, lower);
        end
        if length(upper) == length(newcoeffs)
            replaceFitInitialValue_(table, 'upper', newcoeffs, upper);
        end
        
    elseif iscell(input)
        if ischar(input{2})
            input{2} = {input{2}};
        end
        
        if length(input) == 2 
            replaceFitInitialValue_(table, input{1}, newcoeffs, input{2});
            
        elseif length(input) == 3 
            replaceFitInitialValue_(table, input{1}, input{2}, input{3});
        end
    end
    
else 
% if INPUT wasn't specified, then fill table with default values
    
    % Add default values to table_fitinitial if there are peak positions selected
    if ~isempty(xrd.PeakPositions) 
        SP = xrd.getDefaultStartingBounds;
        LB = xrd.getDefaultLowerBounds;
        UB = xrd.getDefaultUpperBounds;
        
        for i=1:length(newcoeffs)
            if isempty(table.Data{i,1})
                table.Data{i,1} = SP(i);
            end
            if isempty(table.Data{i,2})
                table.Data{i,2}  =LB(i);
            end
            if isempty(table.Data{i,3})
                table.Data{i,3} = UB(i);
            end
        end
    end
end

emptyCellsInStart = find(cellfun(@isempty, handles.gui.FitInitial.start), 1);
emptyCellsInLower = find(cellfun(@isempty, handles.gui.FitInitial.lower), 1);
emptyCellsInUpper = find(cellfun(@isempty, handles.gui.FitInitial.upper), 1);

% If all cells are filled, set these values as the new fit initial in the
% Model
if isempty(emptyCellsInStart)     
    start = cell2mat(handles.gui.FitInitial.start)';
    xrd.setFitInitial('start', handles.gui.Coefficients, start);
else
    xrd.setFitInitial('start', []);
end

if isempty(emptyCellsInLower)
    lower = cell2mat(handles.gui.FitInitial.lower)';
    xrd.setFitInitial('lower', handles.gui.Coefficients, lower);
else
    % If there is an empty cell, reset fit initial values in the Model 
    xrd.setFitInitial('lower', []);
end

if isempty(emptyCellsInUpper)
    upper = cell2mat(handles.gui.FitInitial.upper)';
    xrd.setFitInitial('upper', handles.gui.Coefficients, upper);
else
    xrd.setFitInitial('upper', []);
end

% If there are empty cells at all, disable Fit Data button
if isempty(find(cellfun(@isempty, table.Data),1))
    set(handles.push_fitdata, 'enable', 'on');
else
    set(handles.push_fitdata, 'enable', 'off');
end

plotX(handles, 'sample');
% ==============================================================================

function replaceFitInitialValue_(table, bounds, coeff, val)
%REPLACEFITINITIALVALUE_ is a helper function for UPDATEFITINITIAL.

rownames = table.RowName;
if isequal(bounds, 'start')
    col = 1;
elseif isequal(bounds, 'lower')
    col = 2;
elseif isequal(bounds, 'upper')
    col = 3;
end

if ~isempty(val)    
    for i=1:length(coeff)
        row = find(strcmpi(rownames, coeff{i}), 1);
        table.Data{row, col} = val(i);
    end
    
else
    row = find(strcmpi(rownames, coeff), 1);
    table.Data{row, col} = [];
end

% function updateFitResults(handles, ~)
%UPDATEFITRESULTS is called when push_fitdata is pressed. It fills table_fitinitial with
%   the fit result values.



