%% import_data(handles, filename, path)
% Imports new data.
function handles = import_data(handles, filename, path)

try
    PrefFile=fopen('Preference File.txt','r');
    data_path=fscanf(PrefFile,'%c');
    data_path(end)=[]; % method above adds a white space at the last character that messes with import
    fclose(PrefFile);
catch
    data_path=cd;
end

[filename, path] = uigetfile({'*.csv; *.txt; *.xy; *.fxye; *.dat; *.xrdml; *.chi; *.spr'},'Select Diffraction Pattern to Fit','MultiSelect', 'on',data_path);

if handles.checkbox_reverse.Value == 1
    filename = fliplr(filename);
end
axes(handles.axes1)

temp = PackageFitDiffractionData;
[temp, data_in] = temp.Read_Data(filename, path);

try
    confirm_new_dataset();
catch
    return
end

% Function continues from here only if there is data loaded into xrd
resetGUIData();

resizeAxes1ForErrorPlot(handles);

guidata(handles.figure1, handles)

%% Helper functions
% Check if there is data loaded
    function confirm_new_dataset()
        % 		try a = call.overwriteExistingFit(handles);
        % 		catch
        % 			a = '';
        % 		end
        a = 'yes';
        
        if strcmpi(a,'Cancel') || ~data_in % If user cancels action
            handles.xrd.Status = [handles.xrd.Status, 'Canceled: no data was loaded.'];
            error('No data was loaded.') % interrupts function
            % 				reset_panel_view(handles);
        end 
    end

    function resetGUIData()
        handles.xrdContainer(7) = copy(temp);
        handles.xrd = handles.xrdContainer(7);
        
        if isfield(handles, 'profiles')
            handles.uipanel3 = handles.profiles(7);
        else
            handles.profiles(7) = handles.uipanel3;
        end
        
        handles = resetGuiData(handles);
        
        for i=1:6
            handles = remove_profile(i, handles);
        end
        
        handles = add_profile(handles);
        
        for i=1:length(handles.xrd.Filename)
            files{i} = handles.xrd.Filename{i};  %#ok<AGROW>
        end
        
        set(handles.edit8, ...
            'String', handles.xrd.DataPath,...
            'FontAngle','normal', ...
            'ForegroundColor',[0 0 0]);
        set(handles.popup_filename, 'String', files);
        set(handles.listbox_files, 'String', files);
        set(handles.table_results,'ColumnName',files);
        set(handles.panel_profilecontrol, 'visible', 'on');
        set(handles.push_removeprofile, 'enable', 'off');
        %
        
        % Make axes options available based on # of files
        numfiles = length(handles.xrd.Filename);
        
        if numfiles > 1 % if there was more than file loaded
            set(handles.checkbox_superimpose,'Visible','on', 'enable', 'on'); % Superimpose Raw Data
            set(handles.radio_stopleastsquares, 'visible', 'on'); % Stop Least Squares
            set(handles.push_viewall,'Visible','on', 'enable', 'on'); % View All
            handles.xrd.Status=['Imported ', num2str(numfiles),' files to this dataset.'];
        else
            set(handles.checkbox_superimpose,'Visible','off'); % Superimpose Raw Data
            set(handles.radio_stopleastsquares, 'visible', 'off'); % Stop Least Squares
            set(handles.push_viewall,'Visible','off'); % View All
            handles.xrd.Status='Successfully imported. There is 1 file in this dataset.';
        end
        set(handles.text_filenum,'String',['1 of ',num2str(numfiles)]);
        set(handles.popup_filename, 'Value', 1);
        set(handles.panel_rightside,'visible','on');
        
    end

end