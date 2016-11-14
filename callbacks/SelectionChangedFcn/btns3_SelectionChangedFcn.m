function btns3_SelectionChangedFcn(hObject, evt, handles)
	handles.table_results.Data = {};
	result_vals = transpose(vertcat(handles.xrd.fit_parms{:}));
	
	switch hObject.SelectedObject
		case handles.radio_peakeqn
			set(handles.listbox_files, 'enable', 'on');
			set(handles.popup_filename, 'enable', 'on');
			set(handles.table_results, ...
					'Data', num2cell(result_vals), ...
					'ColumnName', handles.xrd.Filename, ...
					'ColumnFormat', {'numeric'}, ...
					'ColumnWidth', {'auto'}, ...
					'ColumnEditable', false);
			
			cla(handles.axes1)
			plotX(handles);
			
			
		case handles.radio_coeff
			set(handles.listbox_files, 'enable', 'off');
			set(handles.popup_filename, 'enable', 'off');
			rlen = length(handles.xrd.Fcoeff{1});
			set(handles.table_results, ...
					'Data', num2cell([zeros(rlen,1), result_vals]), ...
					'ColumnName', {'', handles.xrd.Filename{:}}, ...
					'ColumnFormat', {'logical', 'numeric'}, ...
					'ColumnWidth', {30, 'auto'}, ...
					'ColumnEditable', [true false]);
			
			handles.table_results.Data{1, 1} = true;
			
			r = find([handles.table_results.Data{:,1}], 1); % the selected coefficient to plot
<<<<<<< HEAD
			s='NoStats';
            plot_coeffs(r,s, handles);
=======
			plot_coeffs(r, 'NoStats', handles);
>>>>>>> gui-layout-tool
			
        case handles.radio_statistics
            set(handles.listbox_files, 'enable', 'off');
			set(handles.popup_filename, 'enable', 'off');
            			rlen = length(handles.xrd.Fcoeff{1});
			set(handles.table_results, ...
					'Data', num2cell([zeros(rlen,1), result_vals]), ...
					'ColumnName', {'', handles.xrd.Filename{:}}, ...
					'ColumnFormat', {'logical', 'numeric'}, ...
					'ColumnWidth', {30, 'auto'}, ...
					'ColumnEditable', [true false]);
			
			handles.table_results.Data{1, 1} = true;
			
            
            s='Rsquare';
            			r = 1; % the selected coefficient to plot

            			plot_coeffs(r,s, handles);
            
		otherwise
			
			
		
			
			
	end