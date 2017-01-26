% A dialog box that asks the user if they really want to quit the program.
function choice = requestClose(handles, choice)

if nargin < 2
    try
        if ~handles.profiles.hasData
            choice = questdlg('Do you really want to quit? Some data may be lost.', ...
                'Confirm Quit', ...
                'Yes','Cancel','Cancel');
        else
            choice = 'Yes';
        end
    catch
        choice = 'Yes';
    end
end

% Handle response
switch choice
    case 'Yes'
        closing(handles);
        
    case 'Cancel'
end

function closing(handles)
try
    delete(handles.gui);
catch
end

try
    delete(handles.profiles);
catch
end

try
    delete(handles.figure1);
catch
    delete(findall(0,'tag','figure1'));
end
