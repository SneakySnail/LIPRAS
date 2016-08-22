function peakChange(o, e, handles)

coeff = handles.xrd.getCoeff(handles.xrd.PSfxn, ...
	handles.xrd.Constrains);

peakTableRow = find(strncmp(coeff, 'x', 1));			% The row number(s) in the table for each peak position

for i=1:length(peakTableRow)
	handles.uitable1.Data{i, 1} = handles.xrd.PeakPositions(i);
	handles.uitable1.Data{i, 2} = handles.xrd.PeakPositions(i) - 0.02;
	handles.uitable1.Data{i, 3} = handles.xrd.PeakPositions(i) + 0.02;
end
