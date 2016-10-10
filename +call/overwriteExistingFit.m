% If there is a current fit, check with user to overwrite. If user cancels
% action, this function throws an error to be caught by calling functions.
% User can suppress the dialog from UIGETPREF permanently by selecting
% "Do not show this dialog again".
function a = overwriteExistingFit(handles)
	
	prompt = 'Some data may be lost. Do you want to continue?';
	
	if ~isempty(handles.xrd.Fmodel)
	[selectedButton, dlgShown] = uigetpref(...
		'askToContinue',...               % Group
		'overwriteFit',...				 % Preference
		'Overwrite Existing Fit',...                    % Window title
		prompt, ...
		{'always','never';'Yes','No'},...        % Values and button strings
		'ExtraOptions','Cancel',...             % Additional button
		'DefaultButton','Cancel', ...            % Default choice      
		'CheckboxString','Always continue without asking');
	else
		return
	end
	
	if ~dlgShown
		selectedButton = 'always';
	end
	
	switch selectedButton
		case 'always'  
			a = 'Yes';
		case 'never'               % Throw error
			handles.xrd.Status = [handles.xrd.Status, ' Stopped.'];
			a = 'No';
			error('Operation canceled.')
		case 'cancel'               
			a = 'Cancel';
	end