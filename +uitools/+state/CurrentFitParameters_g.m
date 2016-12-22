classdef CurrentFitParameters_g
    %CURRENTFITPARAMETERS This class serves as a link to the GUI components of fit parameters.
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
    
    properties (SetAccess = private)
        id; % The associated profile number
    end
    
    properties (Hidden)
        hg % handles structure
    end
    
    % The values we want from the GUI
    properties (Dependent)
        NumPeaks
        Range2t
        BackgroundModel
        PolyOrder
        FcnNames
        Constraints
        FitInitial
        FitRange
        Coefficients
    end
    
    % These properties don't depend on a uicomponent in the GUI, so they're not
    % visible but are still accessible
    properties (Dependent, Hidden)
        BackgroundPoints
        BackgroundPointsIdx
        PeakPositions
    end
    
    % The properties
    properties (SetAccess = protected, GetAccess = protected)
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
        Coefficients_
    end
    
    
    % Constructor
    methods
        % Takes the handles of the current figure and saves it as a Constant property.
        function obj = CurrentFitParameters_g(handles, id)
            %   handles - the handles structure to the GUI components
            %   id      - current profile
            if nargin < 2
                id = 1;
            end
            
            obj.hg = handles;
            obj.id = id;
            
        end
    end
    
    % get methods
    methods
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
        
        % Selected 2theta points to use for the initial peak positions.
        function value = get.PeakPositions(obj)
            value = obj.PeakPositions_; %TODO replace guidata
        end
        
        % Cell array of the fit function names.
        function value = get.FcnNames(obj)
            h = obj.hg.table_paramselection;
            if iscell(h.Data(:,1))
                value = h.Data(:,1)';
            else
                value = {h.Data(:,1)};
            end
            
        end
        
        % rx5 numeric array of the constraints.
        %   columns - N, x, f, w, m
        %   rows    - Peak number
        function value = get.Constraints(obj)
            value = obj.Constraints_;
            
        end
        
        % Structure containing the the fit initial bounds.
        %   start    - numeric array of starting points
        %   lower    - numeric array of lower bounds
        %   upper    - numeric array of upper bounds
        function value = get.FitInitial(obj)
            data = obj.hg.table_fitinitial.Data';
            value.start = cell2mat(data(1, :));
            value.lower = cell2mat(data(2, :));
            value.upper = cell2mat(data(3, :));
        end
        
        % Returns the fit range as an integer.
        function value = get.FitRange(obj)
            h = obj.hg.edit_fitrange;
            value = str2double(h.String);
        end
        
        % Returns the coefficients list as a cell array of strings.
        function value = get.Coefficients(obj)
            value = obj.Coefficients_;
            
        end
        
    end
    
    % set methods
    methods
        function obj = set.NumPeaks(obj, value)
            jh = obj.hg.edit_numpeaks.JavaPeer;
            jh.setValue(value);
        end
        
        function obj = set.Range2t(obj, range)
            % TODO add verification
            obj.Range2t_ = range;
            minStr = sprintf('%2.4f', range(1));
            maxStr = sprintf('%2.4f', range(2));
            
            obj.hg.edit_min2t.String = minStr;
            obj.hg.edit_max2t.String = maxStr;
        end
        
        function obj = set.BackgroundModel(obj, value)
            obj.BackgroundModel_ = value;
            h = obj.hg.popup_bkgdmodel;
            
            indx = find(strcmpi(value, h.String), 1); % Find index of current bkgd model
            h.Value = indx;
        end
        
        function obj = set.PolyOrder(obj, value)
            obj.PolyOrder_ = value;
            obj.hg.edit_polyorder.String = num2str(value);
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
        
        function obj = set.FitInitial(obj, value)
            obj.FitInitial_ = value;
            
            
        end
        
        function obj = set.FitRange(obj, value)
            obj.FitRange_ = value;
            
        end
        
        function obj = set.Coefficients(obj, value)
            obj.Coefficients_ = value;
            
        end
        
    end
    
end

