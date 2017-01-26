%% Initial
assert(logical(exist('handles', 'var')));

%% Test out gui.Constraints
handles.gui.Constraints = 'N';
assert(isequal(handles.gui.ConstrainedCoeffs, {'N'}));

constraints = handles.gui.Constraints;


handles.gui.Constraints = 'f';
assert(isequal(handles.gui.ConstrainedCoeffs, {'f'}));

handles.gui.Constraints = 'fN';
assert(isequal(handles.gui.ConstrainedCoeffs, {'N' 'f'}));

disp('TEST PASSED')