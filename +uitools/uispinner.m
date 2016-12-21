% Takes an existing edit box uicomponent and replaces it with a Java Spinner
% object.
function hedit = uispinner(hedit, initialval, minval, maxval, incrval)
    % hedit      - handle to an editable text box component
    % initialval - initial value for the spinner component
    % minval     - minimum value of spinner component
    % maxval     - maximum value of spinner component
    % incrval    - increment value
    
    jModel = javax.swing.SpinnerNumberModel( ...
        initialval, ...
        minval, ...
        maxval, ...
        incrval);
    
    jhSpinner = javax.swing.JSpinner(jModel);
    [~, jhSpinner] = javacomponent(jhSpinner);
    
    set(jhSpinner, ...
        'Parent', hedit.Parent, ...
        'Units', 'Normalized', ...
        'Position', hedit.Position);
    
    delete(hedit);
    
    hedit = jhSpinner;