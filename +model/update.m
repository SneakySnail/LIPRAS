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

% function updateFitResults(handles, ~)
%UPDATEFITRESULTS is called when push_fitdata is pressed. It fills table_fitinitial with
%   the fit result values.



