function [jhSpinner, hSpinner] = uispinner(hedit, initialval, minval, maxval, incrval)
%UISPINNER takes an existing edit box uicomponent and replaces it with a Java Spinner
%   object.
%
%   hedit      - handle to an editable text box component
%   initialval - initial value for the spinner component
%   minval     - minimum value of spinner component
%   maxval     - maximum value of spinner component
%   incrval    - increment value
jhSpinner = hedit;
hSpinner = [];
try
    jModel = javax.swing.SpinnerNumberModel( ...
        initialval, ...
        minval, ...
        maxval, ...
        incrval);
    jModel = javaObjectEDT(jModel);
    jSpinner = javax.swing.JSpinner(jModel);
    jSpinner = javaObjectEDT(jSpinner);
    [jSpinner, hSpinner] = javacomponent(jSpinner);
    
    % Prepare to take the edit box's place
    set(hSpinner, ...
        'Parent', hedit.Parent, ...
        'Units', hedit.Units, ...
        'Position', hedit.Position, ...
        'Tag', hedit.Tag);
    delete(hedit);
    jhSpinner = handle(jSpinner, 'CallbackProperties');
catch ME
    errordlg({ME.message ME.getReport})
end