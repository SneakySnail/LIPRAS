% A dialog box that asks the user if they really want to quit the program.
function choice = close_fig(handles)
	choice = questdlg('Do you really want to quit? Some data may be lost.', ...
		'Confirm Quit', ...
		'Yes','Cancel','Cancel');
	% Handle response
	switch choice
		case 'Yes'
			closereq
			evalin('base', 'clearvars handles');
			
		case 'Cancel'
			
	
	end