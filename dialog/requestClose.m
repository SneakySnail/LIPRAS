% A dialog box that asks the user if they really want to quit the program.
function choice = requestClose(handles, choice)
if nargin < 2
    try
        if handles.profiles.hasData
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
        delete(findall(0,'tag','figure1'));
        delete(findall(0,'tag','TMWWaitbar'));
        
    case 'Cancel'
end

