classdef (Abstract) FitParametersInterface
    %CURRENTFITPARAMETERS This class keeps track of the fit parameters selected in the GUI.
    % It defines a list of static methods for extracting the relevant values from
    % the uicomponents.
    %
    %   i.e. class version of handles.guidata
    
    properties (Abstract, SetAccess = protected)
       id; % The associated profile number
    end
    
    properties (Hidden, SetAccess = protected)
       hg
    end
    
    properties (Abstract)
        Range2t
        BackgroundModel
        PolyOrder
        BackgroundPoints
        PeakPositions
        FcnNames
        Constraints
        FitInitial
        FitRange
        Coefficients
    end
    
    methods
        
        
        
    end
    
end

