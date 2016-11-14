	function update_fitoptions(handles)
		coeff = handles.xrd.getCoeff(handles.xrd.PSfxn, handles.xrd.Constrains);
		fcnNames = handles.table_paramselection.Data(:, 1)'; 
		handles.guidata.coeff = coeff;
		handles.guidata.PSfxn = fcnNames;
		
		set(handles.table_fitinitial,'RowName', coeff);
		handles.table_fitinitial.Data = cell(length(coeff), 3);
		handles.xrd.Fmodel=[];

		try
			assert(length(fcnNames) <= length(handles.xrd.PeakPositions));
		catch
			return
		end
		
		[SP,LB,UB] = handles.xrd.getDefaultStartingBounds(fcnNames, handles.xrd.PeakPositions);
		
		% Fill in table with default values if cell is empty
		for i=1:length(coeff)
			if isempty(handles.table_fitinitial.Data{i,1})
				handles.table_fitinitial.Data{i,1} = SP(i);
			end
			if isempty(handles.table_fitinitial.Data{i,2})
				handles.table_fitinitial.Data{i,2}  =LB(i);
			end
			if isempty(handles.table_fitinitial.Data{i,3})
				handles.table_fitinitial.Data{i,3} = UB(i);
			end
		end
		
		
		handles.xrd.Status = [handles.xrd.Status, 'Done.'];
		plotX(handles);
		
		guidata(handles.figure1, handles)