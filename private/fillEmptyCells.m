
% --- 
function isFilled = fillEmptyCells(hObject, eventdata, handles)
% --- Fills empty cells in uitable1 with their default values only if the
% initial peak positions are in the table. 
profile=find(handles.uipanel3==handles.profiles);
fxnNum = handles.uipanel6.UserData;
rowname = hObject.RowName;
ind=[]; coeff={}; SP=[]; UB=[]; LB=[]; fxns='';
data = hObject.Data;
pos = handles.uipanel4.UserData.PeakPositions;
isFilled = false;

if length(pos) < length(fxnNum)
	for i=1:length(rowname)
		peaknum = str2double(rowname{i}(2));
		% If the peak 
		if peaknum > length(pos)
			break
		end
		
		if rowname{i}(1) == 'x'
			handles.uitable1.Data{i} = pos(peaknum);
		end
	end
	
	return
elseif length(pos) > length(fxnNum)
	pos = pos(1:length(fxnNum));
end

fxns = num2fnstr(fxnNum);
handles.uipanel4.UserData.PeakNames=fxns;
handles.xrd.Constrains = handles.uipanel5.UserData;

[coeff,SP,LB,UB] = handles.xrd.startingValues(...
	pos, fxns, str2double(handles.edit7.String));

% Fill in table with default values if cell is empty
for i=1:size(coeff,1)
	if isempty(hObject.Data{i,1})
		hObject.Data{i,1} = SP(i);
	end
	if isempty(hObject.Data{i,2})
		hObject.Data{i,2}  =LB(i);
	end
	if isempty(hObject.Data{i,3})
		hObject.Data{i,3} = UB(i);
	end
end

isFilled = true;

if strcmpi(handles.uitoggletool5.State,'on')
	legend(handles.xrd.DisplayName,'box','off')
end
plotSampleFit(handles);

guidata(hObject,handles)
