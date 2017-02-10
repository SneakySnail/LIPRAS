% Automatic GUI testing for LIPRAS

%% Initialize
delete(findall(0,'tag', 'figure1'));
LIPRAS % Start the GUI
robot = java.awt.Robot;

%% Read new dataset
% Read in files to create PackageFitDiffractionData object 
[data, filenames, path] = utils.fileutils.newDataSet({'350.chi', '355.chi'}, [pwd filesep]);
handles.profiles.newXRD(PackageFitDiffractionData(data, filenames, path));

% Simulate button_browse press. Copy of button_browse_Callback function so as not to trigger
% uigetfile dialog.
ui.update(handles, 'dataset');

%% Tab 1
set(handles.edit_min2t, 'string', '3.4');
LIPRAS('edit_min2t_Callback',handles.edit_min2t, [], handles);