% A dialog box that asks the user if they really want to quit the program.
function choice = close_fig(handles)
	choice = questdlg('Do you really want to quit? Some data may be lost.', ...
		'Confirm Quit', ...
		'Yes','Cancel','Cancel');
	
	originalLnF = getappdata(handles.figure1, 'originalLnF');
	% Handle response
	switch choice
		case 'Yes'
			try
				delete(handles.figure1);
			catch
				delete(gcf);
			end
			
			evalin('base', 'clearvars h');
			 javax.swing.UIManager.setLookAndFeel(originalLnF);
			
		case 'Cancel'
			
	end