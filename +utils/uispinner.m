% Takes an existing edit box uicomponent and replaces it with a Java Spinner
% object.
function varargout = uispinner(hedit, initialval, minval, maxval, incrval)
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
    
    jSpinner = javax.swing.JSpinner(jModel);
    jSpinner = javaObjectEDT(jSpinner);
    [jhSpinner, hSpinner] = javacomponent(jSpinner);
    
    set(hSpinner, ...
        'Parent', hedit.Parent, ...
        'Units', hedit.Units, ...
        'Position', hedit.Position, ...
        'Tag', hedit.Tag);
    
    delete(hedit);
    %     set(hedit, 'visible','off');
    
    if nargout <= 1
        varargout{1} = hSpinner;
    end
    if nargout > 1
        varargout{2} = jhSpinner;
    end