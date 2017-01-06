classdef ProfileData
    %PROFILEDATA This class serves as a link to the GUI components of fit parameters.
    % It defines a list of set/get methods for saving and extracting fit parameter values
    % to and from their corresponding uicontrols in the GUI.
    %
    % The get methods extract the values from the uicontrol object representing their
    %   corresponding fit parameters. The set methods save the values into a separate
    %   protected group of properties (visible only to this class), and then updates
    %   the uicontrol objects in the GUI to reflect these changes.
    %
    % For now, it assumes that all set values are verified.
    
    %   i.e. class version of handles.guidata
    
    properties (SetAccess = immutable)
        id % The profile number
    end
    
    % The values we want from the GUI
    properties (Dependent)
        CurrentFile % Currently viewing file number in the plot
        Data
        NumPeaks
        NumPeakPositions
        Range2t
        BackgroundModel
        PolyOrder
        FcnNames
        Constraints 
        FitInitialStart
        FitInitialLower
        FitInitialUpper
        FitRange
        Coefficients
    end
    
    % These properties don't depend on a uicomponent in the GUI, so they're not
    % visible but are still accessible
    properties (Dependent, Hidden)
        hg % handles structure ensures it's always updated by calling guidata
        BackgroundPoints
        BackgroundPointsIdx
        PeakPositions
        MinRange
        MaxRange
    end
    
    % The properties
    properties (SetAccess = protected, GetAccess = protected)
        hg_
        CurrentFile_
        NumPeaks_
        Range2t_
        BackgroundModel_
        PolyOrder_
        BackgroundPoints_
        BackgroundPointsIdx_
        PeakPositions_
        FcnNames_
        Constraints_
        FitInitialStart_
        FitInitialLower_
        FitInitialUpper_
        FitRange_
%         Coefficients_
    end
    
    
    % Constructor
    methods
        % Takes the handles of the current figure and saves it as a Constant property.
        function obj = ProfileData(handles, id)
        %   handles - the handles structure to the GUI components
        %   id      - current profile
        if nargin < 2
            id = 1;
        end
        
        obj.hg = handles;
        obj.id = id;
        
        end
    end
    
    % Set methods
    methods
        function obj = set.hg(obj, handles)
        obj.hg_ = handles;
        end
        
        
        function obj = set.CurrentFile(obj, value)
        obj.CurrentFile_ = value;
        obj.hg.popup_filename.Value = value;
        end 
        
        function obj = set.NumPeaks(obj, value)
        if isempty(obj.NumPeaks_) || obj.NumPeaks_ ~= value
            obj.NumPeaks_ = value;
            jh = obj.hg.edit_numpeaks.JavaPeer;
            jh.setValue(value);
        end
        end
        
        function obj = set.Range2t(obj, range)
        % TODO add verification
        obj.Range2t_ = range;
        
        end
        
        function obj = set.MinRange(obj, value)
        % Check if within range
        xrd = obj.hg.xrdContainer(obj.id);
        
        if value < xrd.two_theta(1)
            value = xrd.two_theta(1);
            
        elseif value > xrd.two_theta(end)
            value = xrd.two_theta(end);
        end        
        
        % Save value
        obj.hg.xrdContainer(obj.id).Min2T = value;
        obj.hg.edit_min2t.String = sprintf('%2.4f', value);
        obj.Range2t_(1) = value;
        
        plotX(obj.hg, 'limits');
        end
        
        function obj = set.MaxRange(obj, value)
         xrd = obj.hg.xrdContainer(obj.id);
        
        if value < xrd.two_theta(1)
            value = xrd.two_theta(1);
            
        elseif value > xrd.two_theta(end)
            value = xrd.two_theta(end);
        end
        
        % Save value
        obj.hg.xrdContainer(obj.id).Max2T = value;
        obj.hg.edit_max2t.String = sprintf('%2.4f', value);
        obj.Range2t_(2) = value;
        
        plotX(obj.hg, 'limits');
        
        % Check to make sure value < absolute maximum 2theta
        end
        
        
        function obj = set.BackgroundModel(obj, value)
        obj.BackgroundModel_ = value;
        h = obj.hg.popup_bkgdmodel;
        
        indx = find(strcmpi(value, h.String), 1); % Find index of current bkgd model
        h.Value = indx;
        end
        
        function obj = set.PolyOrder(obj, value)
        jh = obj.hg.edit_polyorder.JavaPeer;
        jh.setValue(value);
        end
        
        function obj = set.BackgroundPoints(obj, value)
        obj.BackgroundPoints_ = value;
        %             obj.hg.xrd.bkgd2th = value;
        % Note - No uicontrol to update
        end
        
        function obj = set.BackgroundPointsIdx(obj, value)
        obj.BackgroundPointsIdx_ = value;
        % Note - No uicontrol to update
        end
        
        function obj = set.PeakPositions(obj, value)
        obj.PeakPositions_ = value;
        % Note - No uicontrol to update
        end
        
        function obj = set.FcnNames(obj, value)
        obj.FcnNames_ = value;
        ht = obj.hg.table_paramselection;
        if size(ht.Data, 1) ~= length(value)
            set(ht, 'Data', cell(length(value), 1));
        end
        ht.Data(:, 1) = value';
        end
        
        function obj = set.Constraints(obj, value)
        obj.Constraints_ = value;
        % TODO update constraints controls
        
        constrained = model.fitcomponents.Constraints(value);
        ui.control.table.toggleConstraints(obj.hg, constrained);
        end
        
        
        function obj = set.FitInitialStart(obj, value)
        % Updates table_fitinitial with values specified in the argument value
        if isnumeric(value)
            value = num2cell(value);
        
        elseif ~iscell(value)
            msg = 'Value must be a numeric array.';
            MException('LIPRAS:ProfileData:FitInitial:InvalidType', msg)
        end
        
        hObject = obj.hg.table_fitinitial;
        
        if length(value) ~= length(hObject.Data(:,1))
            msg = 'Value must be the same length as table';
            MException('LIPRAS:ProfileData:FitInitial:InvalidLength', msg)
        end
            
        obj.FitInitialStart_ = value;
        
        hObject.Data(:, 1) = value;
        
        end
        
        function obj = set.FitInitialLower(obj, value)
        % Updates table_fitinitial with values specified in the argument value
        if isnumeric(value)
            value = num2cell(value);
        
        elseif ~iscell(value)
            MException('LIPRAS:ProfileData:FitInitial:InvalidType')
        end
        
        hObject = obj.hg.table_fitinitial;
        
        if length(value) ~= length(hObject.Data(:,1))
            MException('LIPRAS:ProfileData:FitInitial:InvalidLength')
        end
            
        obj.FitInitialStart_ = value;
        hObject.Data(:, 2) = value;
        
        end
        
        function obj = set.FitInitialUpper(obj, value)
        % Updates table_fitinitial with values specified in the argument value
        if isnumeric(value)
            value = num2cell(value);
        
        elseif ~iscell(value)
            MException('LIPRAS:ProfileData:FitInitial:InvalidType')
        end
        
        hObject = obj.hg.table_fitinitial;
        
        if length(value) ~= length(hObject.Data(:,1))
            MException('LIPRAS:ProfileData:FitInitial:InvalidLength')
        end
            
        obj.FitInitialStart_ = value;
        hObject.Data(:, 3) = value;
        
        end
        
        function obj = set.FitRange(obj, value)
        obj.FitRange_ = value;
        
        end
        
        function obj = set.Coefficients(obj, value)
        %VALUE - 1xN string cell array
        hObject = obj.hg.table_fitinitial;
        if ~isequal(hObject.RowName, value')
            hObject.RowName = value';
            hObject.Data = cell(length(value), 3);
        end
        end
        
    end
    
    % Get methods
    methods
        
        function value = get.hg(obj)
        value = guidata(obj.hg_.figure1);
        end
        
        function value = get.CurrentFile(obj)
        value = obj.hg.popup_filename.Value;
        end
        
        function value = get.Data(obj)
        % Returns the data in the current profile range for the current file
        % 
        % FIRST ROW: 2theta region
        % SECOND ROW & ABOVE: Integrated intensity of experimental data
        Stro = obj.hg.xrd;
     
        dataIndices = PackageFitDiffractionData.Find2theta(Stro.two_theta, obj.Range2t);
        
        xRanged = Stro.two_theta(dataIndices(1):dataIndices(2)); %Extract relevant 2theta region
        yRanged = Stro.data_fit(file, dataIndices(1):dataIndices(2));
        
        value = [xRanged; yRanged];
        end

        % Returns the 2theta range for the current fit as a 1x2 numeric array.
        function value = get.Range2t(obj)
        min2t = str2double(obj.hg.edit_min2t.String);
        max2t = str2double(obj.hg.edit_max2t.String);
        value = [min2t, max2t];
        end
        
        function value = get.NumPeaks(obj)
        jh = obj.hg.edit_numpeaks.JavaPeer;
        value = jh.getValue();
        end
        
        function value = get.NumPeakPositions(obj)
        % The number of unique peak positions selected on the plot by the user 
        
        logicalconstr = obj.Constraints;
        constraints = model.fitcomponents.Constraints(logicalconstr);
        
        if constraints.isXConstrained
            xConstrainedIndex = find(~constraints.Logical.x);
            value = length(xConstrainedIndex) + 1;
        else
             value = obj.NumPeaks;
        end
        
        
        end
        
        % Returns the name of the current background fit model as a string.
        function value = get.BackgroundModel(obj)
        h = obj.hg.popup_bkgdmodel;
        value = h.String{h.Value};
        end
        
        % Returns the polynomial order of the background fit as an integer.
        function value = get.PolyOrder(obj)
        jh = obj.hg.edit_polyorder.JavaPeer;
        value = jh.getValue();
        end
        
        % Selected 2theta points to use for the background fit.
        function value = get.BackgroundPoints(obj)
        value = obj.BackgroundPoints_;
        end
        
        function value = get.BackgroundPointsIdx(obj)
        value = obj.BackgroundPointsIdx_;
        end
        
        function value = get.PeakPositions(obj)
        % Selected 2theta points to use for the initial peak positions.
        value = obj.PeakPositions_; %TODO replace guidata
        end
        
        function value = get.FcnNames(obj)
        % Cell array of the fit function names.
        h = obj.hg.table_paramselection;
        if iscell(h.Data(:,1))
            value = h.Data(:,1)';
        else
            value = {h.Data(:,1)};
        end
        
        end
        
        function value = get.Constraints(obj)
        % rx5 numeric array of the constraints.
        %   columns - N, x, f, w, m
        %   rows    - Peak number
%         value = obj.Constraints_;
        value = getConsMatrix(obj.hg);
        if isempty(value)
            value = zeros(obj.NumPeaks, 5);
        end
        
        end
        
        function value = get.FitInitialStart(obj)
        % Gets the first column (the initial values) in table_fitinitial
        hObject = obj.hg.table_fitinitial;
        value = [hObject.Data{:, 1}];
        end
        
        function value = get.FitInitialLower(obj)
        % Gets the first column (the initial values) in table_fitinitial
        hObject = obj.hg.table_fitinitial;
        value = [hObject.Data{:, 2}];
        end
        
        function value = get.FitInitialUpper(obj)
        % Gets the first column (the initial values) in table_fitinitial
        hObject = obj.hg.table_fitinitial;
        value = [hObject.Data{:, 3}];
        end
        
        % Returns the fit range as an integer.
        function value = get.FitRange(obj)
        h = obj.hg.edit_fitrange;
        value = str2double(h.String);
        end
        
        % Returns the coefficients row name as a 1xN cell array of strings.
        function value = get.Coefficients(obj)
        value = obj.xrd.getCoeff(obj.FcnNames, obj.Constraints);
        end 
    end
    
    
    methods
        function value = isFitted(obj)
        if isempty(obj.hg.xrd.Fmodel)
            value = false;
        else
            value = true;
        end
        end
        
        function result = findCoeffIndex(obj, coeff)
        result = find(strcmpi(obj.Coefficients, coeff));
        end
        
        
        function obj = fillBounds(obj)
        
        
        end
        
        function result = getValueOf(obj, coeff, boundsType)
        %GETVALUEOF This function returns the value of the initial, lower, or
        %   upper bounds (specified by the argument boundsType) of the coefficient
        %   specified by coeff.
        %
        %COEFF - A string of the coefficient name and peak number.
        %
        %BOUNDS - Usage: 'lower', 'initial', or 'upper' only
        
        validCoeff = obj.verifyCoeffName(coeff);
        
        if nargin > 2
            validBoundsType = obj.verifyBoundsType(boundsType);
        end
        
        
        if ~validCoeff
            MException('ProfileData:InvalidCoeff', 'The coefficient name is not valid.')
            
            
        elseif ~validBoundsType
            
            
        end
        
        end
    end
    
    methods (Static)
        
        function value = hasEmptyCell(table)
        %VALUE - True if there is an empty cell in the table, false if not.
        temp = cellfun(@isempty, table.Data);
        if isempty(find(temp, 1))
            value = false;
        else
            value = true;
        end
        
        end
        
        
    end
    
    methods (Hidden)
        
        function value = verifyCoeffName(obj, coeff)
        
        end
        
        function value = verifyBoundsType(obj, boundsType)
        
        end
        
    end
end

