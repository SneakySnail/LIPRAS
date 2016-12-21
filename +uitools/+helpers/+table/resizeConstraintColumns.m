function resizeConstraintColumns(handles, constrained)
table = handles.table_paramselection;
persistent originalWidth;
if isempty(originalWidth)
    originalWidth = table.ColumnWidth;
end

EXTRA_COL_WIDTH = 30;

resetTableColumns();

% If constraint box was checked and fitting more than 2 peaks

MIN_PEAKS = 3;

if constrained.nPeaks >= MIN_PEAKS
    
    for i=1:constrained.total
        
        coeff = constrained.coeffs{i};
        
        addConstraintColumn(coeff, constrained.(coeff));
        
    end
    
end

guidata(table, handles)


    function resetTableColumns()
    table.ColumnWidth = originalWidth;
    
    table.ColumnName = {'Function'};
    
    table.Data = table.Data(:, 1);
    end



    function addConstraintColumn(coeff, values)
    width = table.ColumnWidth;
    
    width{1} = width{1} - EXTRA_COL_WIDTH;
    
    width{end+1} = EXTRA_COL_WIDTH;
    
    table.ColumnName{end+1} = coeff;
    
    table.Data(:,end+1) = num2cell(values');
    
    table.ColumnWidth = width;
    
    end

end



