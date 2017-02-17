function [jhSpinner, jwrapperSpinner] = uispinner(hedit, initialval, minval, maxval, incrval)
%UISPINNER takes an existing edit box uicomponent and replaces it with a Java Spinner
%   object.
% 
% jhSpinner is the thread-safe handle to the java object.
%
% jwrapSpinner is the wrapper
%
%   hedit      - handle to an editable text box component
%   initialval - initial value for the spinner component
%   minval     - minimum value of spinner component
%   maxval     - maximum value of spinner component
%   incrval    - increment value
jhSpinner = [];
jwrapperSpinner = [];
try
    jModel = javax.swing.SpinnerNumberModel( ...
        initialval, ...
        minval, ...
        maxval, ...
        incrval);
    jModel = javaObjectEDT(jModel);
    jhSpinner = javax.swing.JSpinner(jModel);
    jhSpinner = javaObjectEDT(jhSpinner);
    [jhSpinner, jwrapperSpinner] = javacomponent(jhSpinner);
    jhSpinner = handle(jhSpinner, 'CallbackProperties');
    
    % Prepare to take the edit box's place
    set(jwrapperSpinner, ...
        'Parent', hedit.Parent, ...
        'Units', hedit.Units, ...
        'Position', hedit.Position, ...
        'Tag', hedit.Tag);
    delete(hedit);
catch ME
    errordlg({ME.message ME.getReport})
end