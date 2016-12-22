classdef StateInterface
    %STATEINTERFACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        ID
    end
    
    enumeration
        InitialState
        HasDataState
        HasBackgroundFitState
        EmptyNumberOfPeaksState
        IncompleteFunctionsState
        NoFitBoundsState
        FitReadyState
        FitOutputState
    end
    methods (Static)
        
        function obj = constructor(id)
            
        end
        
        function obj = update(id)
            
        end
    end
    
end

