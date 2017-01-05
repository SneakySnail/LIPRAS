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
    
    properties (Hidden)        
        SP
        LB
        UB
    end
    
    % The values we want from the GUI
    properties (Dependent)
        CurrentFile % Currently viewing file in the plot
        NumPeaks
        NumPeakPositions
        Range2t
        BackgroundModel
        PolyOrder
        FcnNames
        Constraints %TODO
        FitInitial
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
        FitInitial_
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
        minStr = sprintf('%2.4f', range(1));
        maxStr = sprintf('%2.4f', range(2));
        
        obj.hg.edit_min2t.String = minStr;
        obj.hg.edit_max2t.String = maxStr;
        
        obj.hg.xrd.Min2T = range(1);
        obj.hg.xrd.Max2T = range(2);
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
        ht.Data(:, 1) = value';
        end
        
        function obj = set.Constraints(obj, value)
        obj.Constraints_ = value;
        % TODO update constraints controls
        end
        
        function obj = set.SP(obj, value)
        if ~isnumeric(value)
            MException('ProfileData:SP:InvalidType')
        end
        obj.SP = value;
        end
        function obj = set.LB(obj, value)
        if ~isnumeric(value)
            MException('ProfileData:SP:InvalidType')
        end
        obj.LB = value;
        end
        function obj = set.UB(obj, value)
        if ~isnumeric(value)
            MException('ProfileData:SP:InvalidType')
        end
        obj.UB = value;
        end
        
        function obj = set.FitInitial(obj, value)
        % Must be a struct with fields SP, LB, or UB. Otherwise, must be numeric
        if ~isstruct(value) || ~isnumeric(value)
                MException('ProfileData:FitInitial:InvalidType')
        end
            
        if isstruct(value)
            obj.SP = value.start;
            obj.LB = value.lower;
            obj.UB = value.upper;
            obj.FitInitial_ = [obj.SP; obj.LB; obj.UB];
            
        else
            obj.FitInitial_ = value;
        end
        
        hObject = obj.hg.table_fitinitial;
        constraints = model.fitcomponents.Constraints(obj.FitInitial_);
                
%         if find(handles.guidata.constraints{1}(:,2), 1)
%             nPeaks = length(find(~handles.guidata.constraints{1}(:,2))) + 1;
%         else
%             nPeaks = obj.NumPeaks;
%         end
%         
        % If not enough peak peakPositions for each function
        if length(obj.PeakPositions) < obj.NumPeaks
            return
        end
        try         
            [sp,lb,ub] = obj.hg.xrd.getDefaultStartingBounds(obj.FcnNames, ...
                obj.PeakPositions, obj.Constraints);
        catch
            return
        end
        
        
        
        try            
            % Fill in table with default values if cell is empty
            for i=1:length(profiledata.Coefficients)
                if isempty(hObject.Data{i,1})
                    hObject.Data{i,1} = sp(i);
                end
                if isempty(hObject.Data{i,2})
                    hObject.Data{i,2}  =lb(i);
                end
                if isempty(hObject.Data{i,3})
                    hObject.Data{i,3} = ub(i);
                end
            end
        catch
            
        end
                
        
        
        end
        
        function obj = set.FitRange(obj, value)
        obj.FitRange_ = value;
        
        end
        
        function obj = set.Coefficients(obj, value)
        %VALUE - 1xN string cell array
        obj.hg.table_fitinitial.RowName = value';
        
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
        
        function value = get.SP(obj)
        data = obj.hg.table_fitinitial.Data';
        value = cell2mat(data(1,:));
        end
        function value = get.LB(obj)
        data = obj.hg.table_fitinitial.Data';
        value = cell2mat(data(2,:));
        end
        function value = get.UB(obj)
        data = obj.hg.table_fitinitial.Data';
        value = cell2mat(data(3,:));
        end
        
        function value = get.FitInitial(obj)
        % Structure containing the the fit initial bounds.
        %
        %   start    - numeric array of starting points
        %   lower    - numeric array of lower bounds
        %   upper    - numeric array of upper bounds
        value.start = obj.SP;
        value.lower = obj.LB;
        value.upper = obj.UB;
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
        
        function result = getData(obj, file)
        % Returns an array where the first row contains the relevant 2theta values
        %   and the second row contains the relevant intensity of the experimental 
        %   data to be fitted. If the file is not specified, data for all files
        %   are returned in order starting in the second row.
        %  
        %FILE - the file number of wanted data. If not specified, data for all
        %   files are returned.
        Stro = obj.hg.xrd;
     
        dataIndices = PackageFitDiffractionData.Find2theta(Stro.two_theta, obj.Range2t);
        
        xRanged = Stro.two_theta(dataIndices(1):dataIndices(2)); %Extract relevant 2theta region
        
        if nargin < 2
            yRanged = Stro.data_fit(:,dataIndices(1):dataIndices(2)); %Extract relevant 2theta region
        else
            yRanged = Stro.data_fit(file, dataIndices(1):dataIndices(2));
        end
        
        result = [xRanged; yRanged];
                
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
        function value = xrd(obj)
        value = obj.hg.xrd;
        end
        
        function value = verifyCoeffName(obj, coeff)
        
        end
        
        function value = verifyBoundsType(obj, boundsType)
        
        end
        
    end
end

