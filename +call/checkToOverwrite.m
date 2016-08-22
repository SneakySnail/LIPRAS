
% --- If there is a current fit, check with user to overwrite.
function ans=checkToOverwrite(prompt,handles)
if ~isempty(handles.xrd.Fmodel)
	ans=questdlg(prompt,'Warning','Continue','Cancel','Continue');
else
	ans='Yes';
end
