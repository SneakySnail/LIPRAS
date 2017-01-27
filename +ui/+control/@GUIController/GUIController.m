classdef GUIController < handle
    %GUICONTROLLER This class serves as a link to the GUI components of fit parameters.
    % It defines a list of set/get methods for saving and extracting fit parameter values
    % to and from their corresponding uicontrols in the GUI.
    %
    % The get methods of the dependent properties extract the relevant values 
    %   directly from the uicontrol object representing their corresponding fit 
    %   parameters. 
    %
    % The set methods of the dependent properties directly updates the relevant 
    %   components of the GUI. 
        
    properties
        % True if the range was changed after choosing background points
%         DirtyPlot = false; 
    end
    
    % The values we want from the GUI
    properties (Dependent)
        DataPath
        
        SelectedCoeffResult
        
        SelectedPlotViewResult
        
        Legend
        
        CurrentProfile
        
        % Integer of the file number visible in the plot
        CurrentFile
        
        NumPeaks
        
        Min2T
        
        Max2T
        
        BackgroundModel
        
        PolyOrder
        
        FcnNames
        
        % The constraints as a cell array of strings, where each cell are the 
        %   constraints per function 
        Constraints
        
        ConstraintsInPanel
        
        ConstraintsInTable
        
        FitInitial
        
        FitResults
        
        FitRange
        
        Coefficients
        
        NumProfiles

        FileNames
            
        PeakPositions
    end
    
    properties (Hidden, Dependent)
       ConstrainedCoeffs 
    end
   
    properties (Hidden)
        Data
        NumPeakPositions
        Range2t
        DefaultOutputPath = 'FitOutputs/';
        DefaultDataPath
        Suffix
        Profiles
    end
   
    properties (Constant)
        FUNCTION_COLUMN_WIDTH = 250;
        CONSTRAINTS_COLUMN_WIDTH = 30;
        
    end
    
    % These properties don't depend on a uicomponent in the GUI, so they're not
    % visible but are still accessible
    properties (Dependent, Hidden)
        hg % handles structure ensures it's always updated by calling guidata
        BackgroundPoints
        
        
    end
    
    properties (SetObservable)
       Status 
       
       DisplayName
    end
    
    % The properties
    properties (SetAccess = protected, GetAccess = protected)
        hg_
        CurrentProfileID_ = 1;
    end
    
    
    % Constructor is private so as to control the number of instances generated.
    %   To create a new instance, call the static method 
    %   GUIController.getInstance(handles).
    methods (Access = private)
        % Takes the handles of the current figure and saves i
        function this = GUIController(figure1)
        %   handles - the handles structure to the GUI components 
        if nargin < 1
            this.hg = guidata(findall(get(0,'CurrentFigure'),'tag', 'figure1'));
        else
            this.hg = guidata(figure1);
        end
        
        this.Profiles = this.hg.profiles;
        end
    end
        
    % Set methods
    methods        
        function result = isFitDirty(this)
        %ISFITDIRTY returns TRUE if the selected options above the 'UPDATE' button (i.e. the fit
        %   parameters) don't match the table_fitinitial coefficients.
        xrd = this.hg.profiles.xrd;
        if isequal(this.FcnNames, xrd.getFunctionNames) && ...
                isequal(this.Coefficients, xrd.getCoeffs) && ...
                isequal(this.FitInitial, xrd.FitInitial)
            result = false;
        else
            result = true;
        end
        end
        
        function set.DataPath(this, pathname)
        component = this.hg.edit8;
        if isempty(pathname)
            set(component,...
                'String', 'Upload new file(s)...',...
                'FontAngle', 'italic',...
                'ForegroundColor', [0.5 0.5 0.5]);
            
        else
            set(component, ...
                'String', pathname,...
                'FontAngle','normal', ...
                'ForegroundColor',[0 0 0]);
        end
        end
        
        function set.Legend(this, mode)
        switch mode
            case 'on'
                this.hg.toolbar_legend.State = 'on';
                legend(this.hg.axes1, 'show');
                
            case 'off'
                this.hg.toolbar_legend.State = 'off';
                legend(this.hg.axes1, 'hide');
        end
        end
        
        function value = get.DataPath(this)
        component = this.hg.edit8;
        if this.hg.profiles.hasData
            value = component.String;
        else
            value = [];
        end
        end
        
        function result = get.Legend(this)
        if strcmpi(this.hg.toolbar_legend.State, 'on')
            result = 'on';
        else
            result = 'off';
        end
        end
        
        function set.SelectedCoeffResult(this, coeff)
        % In table_results, selects the checkbox in the same row as COEFF 
        table = this.hg.table_results;
        row = find(strcmpi(table.RowName, coeff), 1);
        table.Data(:,1) = {false};
        table.Data{row, 1} = true;
        end
        
        function set.SelectedPlotViewResult(this, view)
        if strcmpi(view, 'peakfit')
            this.hg.btns3.SelectedObject = this.hg.radio_peakeqn;
        elseif strcmpi(view, 'coeff')
            this.hg.btns3.SelectedObject = this.hg.radio_coeff;
        end
        end
        
        function value = get.SelectedPlotViewResult(this)
        switch this.hg.btns3.SelectedObject.String
            case 'Peak Fit'
                value = 'peakfit';
            case 'Coefficient Trends'
                value = 'coeff';
        end
        end
        
        function idx = get.SelectedCoeffResult(this)
        % Returns the index of the selected coefficient in table_results.
        table = this.hg.table_results;
        idx = find([table.Data{:,1}], 1);
        
        end
        
        function set.FileNames(this, strcell)
        % Updates both the listbox in Tab 3 and the popup above the axes1.
        this.hg.popup_filename.String = strcell;
        this.hg.listbox_files.String = strcell;
        end
        
        function set.hg(this, handles)
        this.hg_ = handles;
        end
        
        function set.CurrentFile(this, value)
        numfiles = this.hg.profiles.getNumFiles;
        this.hg.popup_filename.Value = value;
        this.hg.text_filenum.String = [num2str(value) ' of ' num2str(numfiles)];
        
        end 
        
        %TODO
        function set.CurrentProfile(this, value)
        numprofiles = this.hg.profiles.getNumProfiles;
        profiletitle = ['Profile ' num2str(value) ' of ' num2str(numprofiles)];
        set(this.hg.text_numprofile, 'String', profiletitle);
        
        end
        
        function set.NumPeaks(this, value)
        % Update the View
        jh = this.hg.edit_numpeaks.JavaPeer;
        jh.setValue(value);
        end
        
        function set.Min2T(this, value)
        profiles = model.ProfileListManager.getInstance;
        % Check if within range
        absRange = profiles.xrd.AbsoluteRange;
        if value < absRange(1)
            value = absRange(1);
        elseif value > absRange(2)
            value = absRange(1);
        end        
        this.hg.edit_min2t.String = sprintf('%.3f', value);
        end
        
        function set.Max2T(this, value)
        profiles = model.ProfileListManager.getInstance;
        absRange = profiles.xrd.AbsoluteRange;
        if value < absRange(1)
            value = absRange(2);
        elseif value > absRange(2)
            value = absRange(2);
        end        
        this.hg.edit_max2t.String = sprintf('%.3f', value);        
        % Check to make sure value < absolute maximum 2theta
        end
        
        function set.BackgroundModel(this, value)
        % Accepts either an integer or a string that specifies the
        % BackgroundModel. 
        %
        %VALUE: 
        %   'Polynomial' OR 1
        %   'Spline' OR 2
        h = this.hg.popup_bkgdmodel;
        if ischar(value)
            name = value;
            indx = find(strcmpi(name, h.String), 1); % Find index of current bkgd model
        elseif isnumeric(value)
            indx = value;
            name = h.String{indx};
        end
        profiles = this.hg.profiles;
        profiles.xrd.setBackgroundModel(name);
        h.Value = indx;
        end
        
        function set.PolyOrder(this, value)
        profiles = this.hg.profiles;
        profiles.xrd.setBackgroundOrder(value);
        jh = this.hg.edit_polyorder.JavaPeer;
        jh.setValue(value);
        end
        
        function set.FcnNames(this, value)
        %SET.FCNNAMES(THIS, VALUE) updates the Model to have the correct
        %   function object and then updates the View.
        ht = this.hg.table_paramselection;
        if isempty(value)
            set(ht, 'Data', cell(1,1), 'ColumnWidth', this.FUNCTION_COLUMN_WIDTH);
            return
        end
        olddata = ht.Data;
        if isempty(olddata) || isempty(olddata{1})
            ht.Data = cell(length(value), 1);
        elseif length(value) < size(olddata, 1)
            ht.Data = olddata(1:length(value), :);
        elseif length(value) > size(olddata, 1)
            extras = length(value) - size(olddata, 1);
            ht.Data = [value; cell(1:extras, size(olddata,2))];
        end
        ht.Data(:, 1) = value';
        end
        
        function value = areFuncsReady(this)
        if isempty(find(cellfun(@isempty, this.FcnNames), 1))
            % No blank cells in table
            value = true;
        else
            value = false;
        end
        end
        
        function set.Constraints(this, value)
        %CONSTRAIN(THIS, VALUE) updates the GUI so that it displays the
        %   constraints specified in VALUE.
        %   
        %   If VALUE is a string, then it updates the constraint checkboxes
        %   under handles.panel_constraints.
        %
        %   If VALUE is a cell array, then it updates table_paramselection to
        %   display checks in the appropriate location.
        set(this.hg.panel_constraints.Children, 'Value', 0);
        if ischar(value)
            for i=1:length(value)
                switch value(i)
                    case 'N'
                        this.hg.checkboxN.Value = 1;
                    case 'x'
                        this.hg.checkboxx.Value = 1;
                    case 'f'
                        this.hg.checkboxf.Value = 1;
                    case 'w'
                        this.hg.checkboxw.Value = 1;
                    case 'm'
                        this.hg.checkboxm.Value = 1;
                end
            end
            
        elseif iscell(value)
            this.setCons_(value);
        end
        
        end
        
        function this = setCons_(this, value)
        %SETCONS_(THIS, VALUE) is a helper function for SET.CONSTRAINTS(THIS, 
        %   VALUE). VALUE is a cell array of length NumPeaks, where each cell 
        %   is either empty or contains a combination of the letters 'Nxfwm'. 
        %   It sets the checkboxes in table_paramselection to TRUE if the cell
        %   at the same index as the function contains one of the letters.
        
        % cons = constraint coefficients as a string
        constr = unique([value{:}], 'stable');
        % Make sure Constraints in the panel are also checked
        this.Constraints = constr;
        table = this.hg.table_paramselection;
        colnames = table.ColumnName(2:end);
        import utils.*
        for i=1:length(colnames)
            newvals = contains(value, colnames{i})';
            table.Data(:, i+1) = num2cell(newvals);
        end
        end
        
        
        function set.FitInitial(this, input)
        % Updates table_fitinitial with values specified in the argument INPUT.
        %
        %   INPUT can be of types:
        %       Numeric  - Must be the same length as the number of coefficients.
        %
        %       Struct   - Field names 'start', 'lower', 'upper' contain numeric arrays. If an
        %                  element in the array = 0, the corresponding cell in the table is set to
        %                  empty.
        %       
        %       Cell     - Formatted as {'BOUNDS', VALUES}  or 
        %                  {'BOUNDS', {COEFFS}, VALUES} 
        hObject = this.hg.table_fitinitial;
        % Clear the table if input is empty
        if isempty(input)
            hObject.Data = cell(size(hObject.Data));
            return
            
        elseif isnumeric(input)
            if length(input) ~= length(hObject.Data(:,1))
                msg = 'Value must be the same length as table';
                throw(MException('LIPRAS:ProfileGUIManager:FitInitial:InvalidLength', msg))
            end
            input = num2cell(input);
            hObject.Data = input;
            
        elseif isstruct(input)
            if ~isempty(input.start)
                hObject.Data(:, 1) = num2cell(input.start)';
            else
                hObject.Data(:, 1) = cell(size(hObject.Data,1),1);
            end
            if ~isempty(input.lower)
                hObject.Data(:, 2) = num2cell(input.lower)';
            else
                hObject.Data(:, 2) = cell(size(hObject.Data,1),1);
            end
            if ~isempty(input.upper)
                hObject.Data(:, 3) = num2cell(input.upper)';
            else
                hObject.Data(:, 3) = cell(size(hObject.Data,1),1);
            end
        
        elseif ~iscell(input)
            msg = 'Value must be a numeric array.';
            throw(MException('LIPRAS:ProfileGUIManager:FitInitial:InvalidType', msg))
        end
        end
        
        function set.FitResults(this, value)
        component = this.hg.table_fitresults;
        
        if isequal(size(component.Data), size(value))
            error('Value does not match component data size.')
        end
        
        component.Data = value;
        end
        
        function set.Coefficients(this, value)
        % Sets both handles.table_fitinitial and handles.table_fitresults
        %   RowName property to the specified argument. 
        %
        %   VALUE - 1xN string cell array
        comp1 = this.hg.table_fitinitial;
        comp2 = this.hg.table_results;
        if ~isequal(comp1.RowName, value')
            comp1.RowName = value';
            comp1.Data = cell(length(value), 3);
        end
        comp2.RowName = value';
        comp2.Data = cell(length(value), 3);
        end
        
    end
    
    % Get methods
    methods
        
        function value = get.hg(this)
        value = guidata(this.hg_.figure1);
        end
        
        
        function value = get.CurrentFile(this)
        value = this.hg.popup_filename.Value;
        end
        

        % Returns the 2theta range for the current fit as a 1x2 numeric array.
        function value = get.Range2t(this)
        min2t = str2double(this.hg.edit_min2t.String);
        max2t = str2double(this.hg.edit_max2t.String);
        value = [min2t, max2t];
        end
        
        function value = get.Min2T(this)
        value = str2double(this.hg.edit_min2t.String);
        end
        
        function value = get.Max2T(this)
        value = str2double(this.hg.edit_max2t.String);
        end
        
        function value = get.NumPeaks(this)
        jh = this.hg.edit_numpeaks.JavaPeer;
        value = jh.getValue();
        end
        
        
        % Returns the name of the current background fit model as a string.
        function value = get.BackgroundModel(this)
        h = this.hg.popup_bkgdmodel;
        value = h.String{h.Value};
        end
        
        % Returns the polynomial order of the background fit as an integer.
        function value = get.PolyOrder(this)
        jh = this.hg.edit_polyorder.JavaPeer;
        value = jh.getValue();
        end
        
        
        function value = get.FcnNames(this)
        % Cell array of the fit function names.
        h = this.hg.table_paramselection;
        if iscell(h.Data(:,1))
            value = h.Data(:,1)';
        else
            value = {h.Data(:,1)};
        end
        end
        
        function value = get.PeakPositions(this)
        h = this.hg.table_fitinitial;
        coeffs = this.Coefficients;
        idx = contains(coeffs, 'x');
        value = cell2mat(h.Data(idx, 1)');
        end
        
        function output = get.Constraints(this)
        % This getter method returns a cell array of constraints for each 
        %   function per cell. Any cell in CONS can be either empty or it can 
        %   contain any combination of the characters 'Nxfwm'. 
        import utils.*
        table = this.hg.table_paramselection;
        if this.NumPeaks > 2
        % colnames = cell array of the name of the constrained coefficients
            output = this.ConstraintsInTable;
        else
            output = cell(1, this.NumPeaks);
            % constraints = cell array of coefficients that are constrained
            constraints = this.ConstraintsInPanel;
            % Return a cell array of constraints per peak depending on which
            % box is checked under panel_constraints
            for i=1:length(constraints)
                output = cellfun(@(c)[c constraints(i)], output, 'uni', false);
            end
        end
        
        end
        
        function output = get.ConstraintsInPanel(this)
        % Returns the checked constraints in handles.panel_constraints as a string of any
        % combinations of the letters 'Nxfwm'.
        coeffs = 'Nxfwm';
        value = '';
        for i=1:length(coeffs)
           obj = findobj(this.hg.panel_constraints.Children, 'String', coeffs(i));
           if obj.Value
               value = [value coeffs(i)]; 
           end
        end
        output = value;
        end
        
        function set.ConstraintsInPanel(this, coeffs)
        % Sets the checkbox values in handles.panel_constraints based on VALUE and removes any
        %   previously checked boxes.
        %
        %   VALUE is a string or cell array with any combination of the letters 'Nxfwm'.
        set(this.hg.panel_constraints.Children, 'Value', 0);
        if iscell(coeffs)
            coeffs = unique([coeffs{:}]);
        end
        for i=1:length(coeffs)
            obj = findobj(this.hg.panel_constraints.Children, 'String', coeffs(i));
            obj.Value = 1;
        end
        end
        
        function output = get.ConstraintsInTable(this)
        % Returns the checked constraints in handles.table_paramselection and returns a cell array
        % of any combination of the letters 'Nxfwm', with one cell per function.
        table = this.hg.table_paramselection;
        output = cell(1, this.NumPeaks);
        if length(table.ColumnName) > 1
            % colnames = cell array of the name of the constrained coefficients
            colnames = table.ColumnName(2:end);
            for i=1:this.NumPeaks
                idx = cell2mat(table.Data(i, 2:end));
                output{i} = [colnames{idx}];
            end
        end
        end
        
        function set.ConstraintsInTable(this, value)
        % VALUE is a cell array of any combination of the letters 'Nxfwm', with one cell per function.
        %   If the coefficient is not already a column, it creates a new one. It MUST be the same
        %   size as NumPeaks. 
        import utils.*
        table = this.hg.table_paramselection;
        if isempty(value)
            set(table, 'Data', this.FcnNames', 'ColumnName', table.ColumnName(1), ...
                'ColumnWidth', {this.FUNCTION_COLUMN_WIDTH});
            return
        elseif ~iscell(value) || length(value) ~= this.NumPeaks
            dbstack, keyboard
        end
        coeffstr = this.ConstraintsInPanel;
        this.resetTableColumnsOfConstraints_(coeffstr);
        cols = table.ColumnName(2:end);
        data = table.Data(:, 2:end);
        for i=1:length(value)
            if ~isempty(this.FcnNames{i}) 
                idxChecked = [];
                if ~isempty(value{i})
                    constraints = cellstr(value{i}')';
                    idxChecked = contains(cols, constraints);
                else
                    idxChecked = false(1,length(cols));
                end

                data(i, :) = {false};
                data(i, idxChecked) = {true};
            end
        end
        set(table, 'Data', [this.FcnNames', data]);
        end
        
        function resetTableColumnsOfConstraints_(this, value)
        % Helper function for setting new constraints in the table. This function ONLY gets called
        %   by setting new values with set.ConstraintsInTable.
        %
        %   VALUE is a string with any combination of the letters 'Nxfwm'
        
        % 
        table = this.hg.table_paramselection;
        data = [table.Data(:,1), cell(this.NumPeaks, length(value))];
        widths = {this.FUNCTION_COLUMN_WIDTH - length(value)*this.CONSTRAINTS_COLUMN_WIDTH};
        colnames = table.ColumnName(1);
        coledits = true(1, length(value)+1);
        for i=1:length(value)
            widths{end+1} = this.CONSTRAINTS_COLUMN_WIDTH;
            if value(i) == 'N'
                colnames = [colnames {value(i)}];
            elseif value(i) == 'x'
                colnames = [colnames {value(i)}];
            elseif value(i) == 'f'
                colnames = [colnames {value(i)}];
            elseif value(i) == 'w'
                colnames = [colnames {value(i)}];
            elseif value(i) == 'm'
                colnames = [colnames {value(i)}];
            end
            if ~isempty(data{i,1})
                
            end
        end
        set(table, 'ColumnWidth', widths, ...
                'ColumnName', colnames, ...
                'ColumnEditable', coledits, ...
                'Data', data);
        end
        
        function value = get.ConstrainedCoeffs(this)
        % Returns a cell array of strings of the coefficients that are checked
        % in the panel_constraints.
        coeffs = {'N' 'x' 'f' 'w' 'm'};
        value = [];
        for i=1:length(coeffs)
           obj = findobj(this.hg.panel_constraints.Children, 'String', coeffs{i});
           if obj.Value
               value = [value, coeffs(i)]; %#ok<AGROW>
           end
        end
        end
        
        function set.ConstrainedCoeffs(this, coeffs)

        for i=1:length(coeffs)
            if ischar(coeffs)
                c = coeffs(i);
            elseif iscell(coeffs)
                c = coeffs{i};
            end
            if ~isempty(c)
                obj = findobj(this.hg.panel_constraints.Children, 'String', c);
                obj.Value = true;
            end
        end
        end
            
        function output = get.FitInitial(this)
        % Gets the values in table_fitinitial
        hObject = this.hg.table_fitinitial;
        start = hObject.Data(:, 1)';
        lower = hObject.Data(:, 2)';
        upper = hObject.Data(:, 3)';
        for i=1:length(start)
            if isempty(start{i})
                start{i} = 0;
            end
            if isempty(lower{i})
                lower{i} = 0;
            end
            if isempty(upper{i})
                upper{i} = 0;
            end
        end
        output.start = cell2mat(start);
        output.lower = cell2mat(lower);
        output.upper = cell2mat(upper);
        end
        
        
        % Returns the coefficients row name as a 1xN cell array of strings.
        function value = get.Coefficients(this)
        hObject = this.hg.table_fitinitial;
        value = hObject.RowName';
        end 
    end
    
    
    methods
        
        function this = setCoeffInitialValue(this, coeff, value)
        %SETCOEFFINITIAL Sets the fit initial value of the coefficient specified
        %   in the argument. Also updates table_fitinitial to display the
        %   updated value.
        end
        
        function this = setCoeffLowerBoundValue(this, coeff, value)
        
        
        end
        
        function this = setCoeffUpperBoundValue(this, coeff, value)
        
        end
        

    
        function output = getFileNames(this, file)
        str = this.hg.popup_filename.String;
        if nargin > 1 
            output = str{file};
        else
            output = str;
        end
        end
                
        
        function result = findCoeffIndex(this, coeff)
        result = find(strcmpi(this.Coefficients, coeff));
        end
 
    end
    
    methods (Static)
        handles = initGUI(handles)
        
        function singleObj = getInstance(handles)
        % 
        persistent localObj;
        
        if isempty(localObj) || ~isvalid(localObj)
            if nargin < 1
                localObj = [];
            else
                localObj = ui.control.GUIController(handles);
            end
        end
        
        singleObj = localObj;
        end
        
        function value = hasEmptyCell(data)
        %HASEMPTYCELL 
        %
        %   VALUE = HASEMPTYCELL(DATA) True if there is an empty cell in the 
        %   cell array DATA, false if not.
        temp = cellfun(@isempty, data);
        if isempty(find(temp, 1))
            value = false;
        else
            value = true;
        end
        
        end
        
        
    end
    
end

